#' Coerce an Object to a Cluster Object
#'
#' @param x An object to be coerced.
#'
#' @param \ldots Additional arguments passed to the underlying coercion method.
#'            For `c(...)`, the clusters and cluster nodes to be combined.
#'
#' @return An object of class `cluster`.
#'
#' @example incl/as.cluster.R
#'
#' @export
as.cluster <- function(x, ...) {
  UseMethod("as.cluster")
}

#' @rdname as.cluster
#' @export
as.cluster.cluster <- function(x, ...) x

#' @rdname as.cluster
#' @export
as.cluster.list <- function(x, ...) {
  x <- lapply(x, FUN = as.cluster, ...)
  Reduce(c, x)
}

#' @rdname as.cluster
#' @export
as.cluster.SOCKnode <- function(x, ...) {
  cl <- structure(list(x), class = c("SOCKcluster", "cluster"))
}

#' @rdname as.cluster
#' @export
as.cluster.SOCK0node <- as.cluster.SOCKnode


#' @rdname as.cluster
#' @export
as.cluster.RichSOCKnode <- function(x, ...) {
  cl <- structure(list(x), class = c("RichSOCKcluster", "SOCKcluster", "cluster"))
}


#' @param recursive Not used.
#'
#' @return `c(...)` combine multiple clusters and / or cluster nodes into one
#' cluster returned as an of class `cluster`.  A warning will be produced if
#' there are duplicated nodes in the resulting cluster.
#'
#' @rdname as.cluster
#' @export
c.cluster <- function(..., recursive = FALSE) {
  x <- list(...)
  x <- lapply(x, FUN = as.cluster)

  ## AD HOC: Use common demonator class as new class
  class <- lapply(x, FUN = class)
  class <- Reduce(intersect, class)
  stop_if_not(is.element("cluster", class))

  ## Combine list of clusters
  x <- lapply(x, FUN = unclass)
  x <- Reduce(c, x)

  ## Assert no duplicates
  dups <- duplicated(x)
  if (any(dups)) {
    warnf("The combined cluster contains %d duplicated nodes", sum(dups))
  }
  
  class(x) <- class
  
  x  
}
