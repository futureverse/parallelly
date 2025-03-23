#' Automatically Stop a Cluster when Garbage Collected
#'
#' Registers a finalizer to a cluster such that the cluster will
#' be stopped when garbage collected
#'
#' @param cl A cluster object created by for instance [makeClusterPSOCK()]
#' or [parallel::makeCluster()].
#'
#' @param debug If TRUE, then debug messages are produced when
#' the cluster is garbage collected.
#'
#' @return The cluster object with attribute `gcMe` set.
#'
#' @example incl/autoStopCluster.R
#'
#' @details
#' The cluster is stopped using
#' \code{\link[parallel:makeCluster]{stopCluster}(cl)}.
#' An alternative to explicitly call this function on an existing
#' `cluster` object, is to create the `cluster` object using
#' `makeClusterPSOCK()` with argument `autoStop = TRUE`.
#'
#' @importFrom parallel stopCluster
#' @importFrom utils capture.output
#' @export
autoStopCluster <- function(cl, debug = FALSE) {
  stop_if_not(inherits(cl, "cluster"))
  ## Already got a finalizer?
  if (inherits(attr(cl, "gcMe"), "environment")) return(cl)
  
  env <- new.env()
  env$cluster <- cl
  attr(cl, "gcMe") <- env

  if (debug) {
    reg.finalizer(env, function(e) {
      mdebug_push("Finalizing cluster ...")
      on.exit(mdebug_pop("Finalizing cluster ... done"))
      mprint(e$cluster)
      try(stopCluster(e$cluster), silent = FALSE)
    })
  } else {
    reg.finalizer(env, function(e) {
      try(stopCluster(e$cluster), silent = TRUE)
    })
  }
  cl
}
