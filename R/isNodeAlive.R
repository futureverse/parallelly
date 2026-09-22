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
      }, add = TRUE)
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

  code <- sprintf("cat(%s:::pid_exists(%d))", .packageName, pid)
  res <- run_remote_rscript(x, code = code, timeout = timeout, debug = debug,
    what = "isNodeAlive()",
    msg = sprintf("Could not infer whether %s node is alive", sQuote(class(x)[1]))
  )

  res
}


#' @export
isNodeAlive.cluster <- function(x, ...) {
  vapply(x, FUN = isNodeAlive, ..., FUN.VALUE = NA)
}
