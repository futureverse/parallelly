#' Clone one or more nodes
#'
#' @param x A cluster node or a cluster.
#'
#' @param ... Optional arguments overriding the recorded ones.
#'
#' @return An object of class `class(x)`.
#'
#' @examples
#' \donttest{
#' cl <- makeClusterPSOCK(2)
#' print(cl)
#'
#' ## Terminate the second cluster node
#' parallel::stopCluster(cl[2])
#'
#' ## Show that cluster node #2 is no longer alive (wait a bit first)
#' Sys.sleep(1.0)
#' print(isNodeAlive(cl))
#' print(cl)
#' 
#' ## "Restart" it
#' cl[2] <- cloneNode(cl[2])
#' print(cl)
#'
#' ## Check all nodes
#' print(isNodeAlive(cl))
#' }
#'
#' @export
cloneNode <- function(x, ...) UseMethod("cloneNode")

#' @export
cloneNode.default <- function(x, ...) {
  stopf("Do not know how to clone node of class %s", sQuote(class(x)[1]))
}

#' @export
cloneNode.RichSOCKnode <- function(x, ..., method = c("as-is", "vanilla")) {
  debug <- isTRUE(getOption("parallelly.debug"))
  if (debug) {
    mdebug_push("cloneNode() for RichSOCKnode ...")
    on.exit(mdebug_pop("cloneNode() for RichSOCKnode ... DONE"))
  }

  method <- match.arg(method)
  if (debug) mdebugf("method: %s", method)
  
  ## Get the arguments used for creating the node to be cloned
  options <- attr(x, "options")

  if (method == "as-is") {
    make_fcn <- launchNodePSOCK
    options$setup_strategy <- "sequential"
    make_args <- list(options)
  } else {
    make_fcn <- options$make_fcn
    make_args <- options$arguments
  }

  ## Optionally, override some of the arguments
  args <- list(...)
  if (length(args) > 0) {
    stop_if_not(!is.null(names(args)))
    for (name in names(args)) {
      make_args[[name]] <- args[[name]]
    }
  }

  if (debug) {
    mdebug("Calling node-creation function with arguments:")
    mstr(make_args)
  }
  
  node <- do.call(make_fcn, args = make_args)

  if (!is.null(x$session_info)) {
    if (debug) mdebug("Adding node session information")
    node <- add_cluster_session_info(node)
  }

  node
}


#' @export
cloneNode.cluster <- function(x, ...) {
  res <- lapply(x, FUN = cloneNode, ...)
  class(res) <- class(x)
  res
}
