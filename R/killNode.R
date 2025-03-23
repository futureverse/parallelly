#' Terminate one or more cluster nodes using process signaling
#'
#' @param x cluster or cluster node to terminate.
#'
#' @param signal An integer that specifies the signal level to be sent
#' to the parallel R process.
#' It's only `tools::SIGINT` (2) and `tools::SIGTERM` (15) that are
#' supported on all operating systems (i.e. Unix, macOS, and MS Windows).
#' All other signals are platform specific, cf. [tools::pskill()].
#'
#' @param \ldots Not used.
#'
#' @return
#' TRUE if the signal was successfully applied, FALSE if not, and NA if
#' signaling is not supported on the specific cluster or node.
#' _Warning_: With R (< 3.5.0), NA is always returned. This is due to a
#' bug in R (< 3.5.0), where the signaling result cannot be trusted.
#'
#' @details
#' Note that the preferred way to terminate a cluster is via
#' [parallel::stopCluster()], because it terminates the cluster nodes
#' by kindly asking each of them to nicely shut themselves down.
#' Using `killNode()` is a much more sever approach. It abruptly
#' terminates the underlying R process, possibly without giving the
#' parallel worker a chance to terminate gracefully.  For example,
#' it might get terminated in the middle of writing to file.
#' 
#' [tools::pskill()] is used to send the signal to the R process hosting
#' the parallel worker.
#'
#' @section Known limitations:
#' This function works only with cluster nodes of class `RichSOCKnode`,
#' which were created by [makeClusterPSOCK()].  It does not work when
#' using [parallel::makeCluster()] and friends.
#'
#' Currently, it's only possible to send signals to parallel workers, that
#' is, cluster nodes, that run on the local machine.
#' If attempted to use `killNode()` on a remote parallel workers, `NA`
#' is returned and an informative warning is produced.
#'
#' @examples
#' \dontshow{if (.Platform$OS.type != "windows" || interactive()) \{}
#' cl <- makeClusterPSOCK(2)
#' print(isNodeAlive(cl))  ## [1] TRUE TRUE
#' 
#' res <- killNode(cl)
#' print(res)
#' 
#' ## It might take a moment before the background
#' ## workers are shutdown after having been signaled
#' Sys.sleep(1.0)
#' 
#' print(isNodeAlive(cl))  ## [1] FALSE FALSE
#' \dontshow{\}}
#'
#' @seealso
#' Use [isNodeAlive()] to check whether one or more cluster nodes are alive.
#'
#' @export
killNode <- function(x, signal = tools::SIGTERM, ...) {
  stop_if_not(
    length(signal) == 1L,
    is.numeric(signal),
    is.finite(signal),
    signal >= 1L,
    signal <= 64L
  )
  UseMethod("killNode")
}

#' @export
killNode.default <- function(x, signal = tools::SIGTERM, ...) {
  warning(sprintf("killNode() is not supported for this %s. Signal %d was not sent", sQuote(class(x)[1]), signal))
  NA
}

#' @importFrom tools pskill
#' @export
killNode.RichSOCKnode <- function(x, signal = tools::SIGTERM, timeout = 0.0, ...) {
  debug <- isTRUE(getOption("parallelly.debug"))
  if (debug) {
    mdebug_push("killNode() for RichSOCKnode ...")
    on.exit(mdebug_pop("killNode() for RichSOCKnode ... DONE"))
  }

  stop_if_not(length(signal) > 0, is.numeric(signal), !anyNA(signal),
              all(signal > 0))
  signal <- as.integer(signal)
  stop_if_not(all(signal > 0))

  timeout <- as.numeric(timeout)
  stop_if_not(length(timeout) == 1L, !is.na(timeout), timeout >= 0)
  debug && mdebugf("Timeout: %g seconds", timeout)
  
  si <- x$session_info

  ## Is PID available?
  pid <- si$process$pid
  if (!is.integer(pid)) {
    debug && mdebug("Process ID for R worker is unknown")
    return(NextMethod())
  }

  ## Is hostname available?
  hostname <- si$system$nodename
  if (!is.character(hostname)) {
    debug && mdebug("Hostname for R worker is unknown")
    return(NextMethod())
  }

  ## Are we calling this from that same host?
  if (identical(hostname, Sys.info()[["nodename"]])) {
    debug && mdebug("The R worker is running on the current host")
    ## Try to signal the process
    res <- pskill(pid, signal = signal)
    if (getRversion() < "3.5.0") res <- NA
    return(res)
  }

  debug && mdebug("The R worker is running on another host")
  
  ## Can we connect to the host?
  options <- attr(x, "options")
  args_org <- options$arguments
  worker <- options$worker
  rshcmd <- options$rshcmd
  rscript <- options$rscript
  rscript_sh <- options$rscript_sh

  ## Command to call Rscript -e
  signal_str <- paste(sprintf("%s", signal), collapse = ", ")
  if (length(signal) > 1) signal_str <- sprintf("c(%s)", signal_str)
  code <- sprintf("cat(tools::pskill(%d, signal = %s))", pid, signal_str)
  rscript_args <- paste(c("-e", shQuote(code, type = rscript_sh[1])), collapse = " ")
  cmd <- paste(rscript, rscript_args)
  debug && mdebugf("Rscript command to be called on the other host: %s", cmd)
  stop_if_not(length(cmd) == 1L)

  rshopts <- args_org$rshopts
  if (length(args_org$user) == 1L) rshopts <- c("-l", args_org$user, rshopts)
  rshopts <- paste(rshopts, collapse = " ")
  rsh_call <- paste(paste(shQuote(rshcmd), collapse = " "), rshopts, worker)
  debug && mdebugf("Command to connect to the other host: %s", rsh_call)
  stop_if_not(length(rsh_call) == 1L)

  local_cmd <- paste(rsh_call, shQuote(cmd, type = rscript_sh[2]))
  debug && mdebugf("System call: %s", local_cmd)
  stop_if_not(length(local_cmd) == 1L)

  ## system() ignores fractions of seconds, so need to be at least 1 second
  if (timeout > 0 && timeout < 1) timeout <- 1.0
  debug && mdebugf("Timeout: %g seconds", timeout)

  ## system() does not support argument 'timeout' in R (<= 3.4.0)
  if (getRversion() < "3.5.0") {
    if (timeout > 0) warning("killNode() does not support argument 'timeout' in R (< 3.5.0) for cluster nodes running on a remote maching")
    system <- function(..., timeout) base::system(...)
  }
  
  reason <- NULL
  res <- withCallingHandlers({
    system(local_cmd, intern = TRUE, ignore.stderr = TRUE, timeout = timeout)
  }, condition = function(w) {
    reason <<- conditionMessage(w)
    debug && mdebugf("Caught condition: %s", reason)
  })
  debug && mdebugf("Results: %s", res)
  status <- attr(res, "status")
  res <- as.logical(res)
  if (length(res) != 1L || is.na(res)) {
    res <- NA
    attr(res, "status") <- status
    
    msg <- sprintf("Could not kill %s node", sQuote(class(x)[1]))
    if (!is.null(reason)) {
      debug && mdebugf("Reason: %s", reason)
      msg <- sprintf("%s. Reason reported: %s", msg, reason)
    }

    if (!is.null(status)) {
      debug && mdebugf("Status: %s", status)
      msg <- sprintf("%s [exit code: %d]", msg, status)
    }

    warning(msg)
  }

  res
}

#' @export
killNode.cluster <- function(x, signal = tools::SIGTERM, ...) {
  vapply(x, FUN = killNode, signal = signal, ..., FUN.VALUE = NA)
}
