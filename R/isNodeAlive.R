#' Check whether or not the cluster nodes are alive
#'
#' @param x A cluster or a cluster node ("worker").
#'
#' @param ... Not used.
#'
#' @return A logical vector of length `length(x)` with values
#' FALSE, TRUE, and NA.  If it can be established that the
#' process for a cluster node is running, then TRUE is returned.
#' If it does not run, then FALSE is returned.
#' If neither can be inferred, or it times out, then NA is returned.
#'
#' @details
#' This function works by checking whether the cluster node process is
#' running or not.  This is done by querying the system for its process
#' ID (PID), which is registered by [makeClusterPSOCK()] when the node
#' starts. If the PID is not known, the NA is returned.
#' On Unix and macOS, the PID is queried using [tools::pskill()] with
#' fallback to `system("ps")`. On MS Windows, `system2("tasklist")` is used,
#' which may take a long time if there are a lot of processes running.
#' For details, see the _internal_ [pid_exists()] function.
#'
#' @examples
#' \donttest{
#' cl <- makeClusterPSOCK(2)
#' 
#' ## Check if cluster node #2 is alive
#' print(isNodeAlive(cl[[2]]))
#' 
#' ## Check all nodes
#' print(isNodeAlive(cl))
#' }
#'
#' @seealso
#' Use [parallel::stopCluster()] to shut down cluster nodes.
#' If that's not sufficient, [killNode()] may be attempted.
#'
#' @export
isNodeAlive <- function(x, ...) UseMethod("isNodeAlive")

#' @export
isNodeAlive.default <- function(x, ...) NA

#' @export
isNodeAlive.RichSOCKnode <- function(x, timeout = 0.0, ...) {
  debug <- isTRUE(getOption("parallelly.debug"))
  if (debug) {
    mdebug_push("isNodeAlive() for RichSOCKnode ...")
    on.exit(mdebug_pop("isNodeAlive() for RichSOCKnode ... DONE"))
  }

  timeout <- as.numeric(timeout)
  stop_if_not(length(timeout) == 1L, !is.na(timeout), timeout >= 0)
  if (debug) mdebugf("Timeout: %g seconds", timeout)
  
  si <- x$session_info

  ## Is PID available?
  pid <- si$process$pid
  if (!is.integer(pid)) {
    if (debug) mdebug("Process ID for R worker is unknown")
    return(NextMethod())
  }

  ## Is hostname available?
  hostname <- si$system$nodename
  if (!is.character(hostname)) {
    if (debug) mdebug("Hostname for R worker is unknown")
    return(NextMethod())
  }

  ## Are we running on that host?
  if (identical(hostname, Sys.info()[["nodename"]])) {
    if (debug) mdebug("The R worker is running on the current host")
    if (timeout > 0) {
      setTimeLimit(cpu = timeout, elapsed = timeout, transient = TRUE)
      on.exit({
        setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
      })
    }
    res <- tryCatch({
      pid_exists(pid)
    }, error = function(ex) {
      warning(sprintf("Could not infer whether %s node is alive. Reason reported: %s", class(x)[1], conditionMessage(ex)))
      NA
    })
    return(res)
  }

  if (debug) mdebug("The R worker is running on another host")
  
  ## Can we connect to the host?
  options <- attr(x, "options")
  args_org <- options$arguments
  worker <- options$worker
  rshcmd <- options$rshcmd
  rscript <- options$rscript
  rscript_sh <- options$rscript_sh

  ## Command to call Rscript -e 
  code <- sprintf("cat(%s:::pid_exists(%d))", .packageName, pid)
  rscript_args <- paste(c("-e", shQuote(code, type = rscript_sh[1])), collapse = " ")
  cmd <- paste(rscript, rscript_args)
  if (debug) mdebugf("Rscript command to be called on the other host: %s", cmd)
  stop_if_not(length(cmd) == 1L)

  rshopts <- args_org$rshopts
  if (length(args_org$user) == 1L) rshopts <- c("-l", args_org$user, rshopts)
  rshopts <- paste(rshopts, collapse = " ")
  rsh_call <- paste(paste(shQuote(rshcmd), collapse = " "), rshopts, worker)
  if (debug) mdebugf("Command to connect to the other host: %s", rsh_call)
  stop_if_not(length(rsh_call) == 1L)

  local_cmd <- paste(rsh_call, shQuote(cmd, type = rscript_sh[2]))
  if (debug) mdebugf("System call: %s", local_cmd)
  stop_if_not(length(local_cmd) == 1L)

  ## system() ignores fractions of seconds, so need to be at least 1 second
  if (timeout > 0 && timeout < 1) timeout <- 1.0
  if (debug) mdebugf("Timeout: %g seconds", timeout)

  ## system() does not support argument 'timeout' in R (<= 3.4.0)
  if (getRversion() < "3.5.0") {
    if (timeout > 0) warning("isNodeAlive() does not support argument 'timeout' in R (< 3.5.0) for cluster nodes running on a remote maching")
    system <- function(..., timeout) base::system(...)
  }

  reason <- NULL
  res <- withCallingHandlers({
    system(local_cmd, intern = TRUE, ignore.stderr = TRUE, timeout = timeout)
  }, condition = function(w) {
    reason <<- conditionMessage(w)
    if (debug) mdebugf("Caught condition: %s", reason)
  })
  if (debug) mdebugf("Results: %s", res)
  status <- attr(res, "status")
  res <- as.logical(res)
  if (length(res) != 1L || is.na(res)) {
    res <- NA
    attr(res, "status") <- status
    
    msg <- sprintf("Could not infer whether %s node is alive", sQuote(class(x)[1]))
    if (!is.null(reason)) {
      if (debug) mdebugf("Reason: %s", reason)
      msg <- sprintf("%s. Reason reported: %s", msg, reason)
    }

    if (!is.null(status)) {
      if (debug) mdebugf("Status: %s", status)
      msg <- sprintf("%s [exit code: %d]", msg, status)
    }

    warning(msg)
  }
  
  res
}


#' @export
isNodeAlive.cluster <- function(x, ...) {
  vapply(x, FUN = isNodeAlive, ..., FUN.VALUE = NA)
}
