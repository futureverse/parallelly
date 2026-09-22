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
#' With the exception of MS Windows, as explained below, using `SIGINT`
#' will trigger an R \code{\link[base:conditions]{interrupt}} condition that
#' can be caught with [tryCatch()] and [withCallingHandlers()] using an
#' `interrupt` calling handler.
#' 
#' When using `SIGTERM`, there will be no `interrupt` condition signaled,
#' meaning your parallel R code does _not_ have a chance to exit gracefully.
#' Instead, the R process terminates rather abruptly, leaving behind its
#' temporary folder.
#'
#' Importantly, contrary to Linux and macOS, it is not possible to get a
#' cluster node running on MS Windows to exit gracefully. For example,
#' despite using `SIGINT`, there is no `interrupt` condition signaled.
#' As a matter of fact, on MS Windows, `SIGINT` works identically to
#' `SIGTERM`, where they both terminate the cluster node abruptly without
#' giving the R process a chance to exit gracefully. This means that R will
#' _not_ clean up after itself, e.g. its temporary directory will
#' remain even after R terminates. 
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
#' Using `killNode()` is a much more severe approach. It abruptly
#' terminates the underlying R process, possibly without giving the
#' parallel worker a chance to terminate gracefully.  For example,
#' it might get terminated in the middle of writing to file.
#' [tools::pskill()] is used to send the signal to the R process hosting
#' the parallel worker.
#'
#' If `signal = tools::SIGTERM` is used and success, this function
#' will also close any existing socket connection to the node, if they
#' exist. Moreover, if the node is running on the local host, this
#' function will also attempt to remove the node's temporary directory,
#' which is done because the node's R process might not have been exited
#' gracefully.
#'
#' @section Known limitations:
#' This function works only with cluster nodes of class `RichSOCKnode`,
#' which were created by [makeClusterPSOCK()].  It does not work when
#' using [parallel::makeCluster()] and friends.
#'
#' @examplesIf (interactive() || .Platform[["OS.type"]] != "windows")
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
#'
#' @seealso
#' Use [isNodeAlive()] to check whether one or more cluster nodes are alive.
#'
#' @importFrom tools SIGTERM
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

#' @importFrom tools SIGTERM
#' @export
killNode.default <- function(x, signal = tools::SIGTERM, ...) {
  warning(sprintf("killNode() is not supported for this %s. Signal %d was not sent", sQuote(class(x)[1]), signal))
  NA
}

#' @importFrom tools pskill SIGKILL SIGTERM
#' @importFrom utils file_test
#' @export
killNode.RichSOCKnode <- function(x, signal = tools::SIGTERM, timeout = 0.0, ...) {
  debug <- isTRUE(getOption("parallelly.debug"))
  if (debug) {
    mdebugf_push("killNode() for %s ...", class(x)[1])
  }

  ## If successfully killed, and node has a socket connection, close it
  signaled <- NA  # was signal sent?
  on.exit({
    ## Epilogue cleanups, if successfully signaled
    if (isTRUE(signaled)) local({
      if (debug) {
        mdebug_push("Post-kill cleanup ...")
        mdebugf("Signal: %d", signal)
        on.exit(mdebug_pop("Post-kill cleanup ... done"))
      }

      ## We can only assume worker has been terminated if
      ## SIGTERM or SIGKILL was used
      if (signal %in% c(tools::SIGTERM, tools::SIGKILL)) {
        ## (a) Close socket connection, if it exists
        if (inherits(x[["con"]], "connection")) {
          local({
            res <- FALSE
            if (debug) {
              mdebug_push("Closing node socket connection ...")
              on.exit({
                mdebugf("Socket connection closed successfully: %s", res)
                mdebug_pop("Closing node socket connection ... done")
              })
            }
            res <- tryCatch({
              close(x[["con"]])
              TRUE
            }, error = function(ex) FALSE)
          })
        }
        
        ## (b) Remove node's temporary folder, it exists
        tempdir <- x[["session_info"]][["tempdir"]]
        if (length(tempdir) == 1L) {
          ## Importantly, we can delete this even if the parallel
          ## worker is still running. This has been confirmed on
          ## Linux. Given that we wish to terminate the node,
          ## I guess that's alright. If the node tries to create
          ## or write more temporary files, it will produce an
          ## error on the node, which will cause the worker to
          ## terminate.

          local({
            mdebug_push("Remove node's temporary directory ...")
            on.exit({
              mdebug_pop("Remove node's temporary directory ... done")
            })
            
            host <- x[["host"]]
            localhost <- isTRUE(attr(host, "localhost"))
            mdebugf("Host: %s (%s)", sQuote(host),
                    if (localhost) "localhost" else "remote")
            mdebugf("Directory: %s", sQuote(tempdir))

            res <- FALSE

            ## Are we running on local host?
            if (localhost) {
              if (file_test("-d", tempdir)) {
                res <- tryCatch({
                  unlink(tempdir, recursive = TRUE, force = TRUE)
                  TRUE
                }, error = function(ex) FALSE)
                mdebugf("Directory removed successfully: %s", res)
              } else {
                mdebug("Skipping. Directory does not exist")
              }
            } else {
              mdebug("Skipping. Deletion of remote temporary folders is not yet implemented")
            } ## if (localhost)
          }) ## local()
        } ## if (length(tempdir) == 1)
      } else {
        if (debug) mdebugf("Skipping, because signal was %d", signal)
      } ## if (signal %in% ...)
    }) ## if (isTRUE(signaled)) local({ ... })
  }) ## on.exit()

  # Return value in {FALSE, TRUE} or NA for R (< 3.5.0)
  success <- NA

  if (debug) {
    on.exit({
      mdebugf("%s killed successfully: %s", class(x)[1], success)
      mdebugf_pop("killNode() for %s ... DONE", class(x)[1])
    }, add = TRUE)
  }

  stop_if_not(length(signal) > 0, is.numeric(signal), !anyNA(signal),
              all(signal > 0))
  signal <- as.integer(signal)
  stop_if_not(all(signal > 0))

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

  ## Are we calling this from that same host?
  if (identical(hostname, Sys.info()[["nodename"]])) {
    if (debug) {
      mdebug("The R worker is running on the current host")
      mdebugf("pskill(pid = %d, signal = %d)", pid, signal)
    }
    ## Try to signal the process
    signaled <- pskill(pid, signal = signal)
    success <- signaled
    if (getRversion() < "3.5.0") success <- NA
    return(success)
  }

  if (debug) mdebug("The R worker is running on another host")

  signal_str <- paste(sprintf("%s", signal), collapse = ", ")
  if (length(signal) > 1) signal_str <- sprintf("c(%s)", signal_str)
  code <- sprintf("cat(tools::pskill(%d, signal = %s))", pid, signal_str)
  res <- run_remote_rscript(x, code = code, timeout = timeout, debug = debug,
    what = "killNode()",
    msg = sprintf("Could not kill %s node", sQuote(class(x)[1]))
  )

  success <- isTRUE(res)
  signaled <- success

  success
}

#' @importFrom tools SIGTERM
#' @export
killNode.cluster <- function(x, signal = tools::SIGTERM, ...) {
  vapply(x, FUN = killNode, signal = signal, ..., FUN.VALUE = NA)
}
