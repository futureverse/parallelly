#' Checks if a Connection is Valid
#'
#' Get a unique identifier for an R \link[base:connections]{connection} 
#' and check whether or not the connection is still valid.
#'
#' @param con A \link[base:connections]{connection}.
#'
#' @return
#' `isConnectionValid()` returns TRUE if the connection is still valid,
#' otherwise FALSE.  If FALSE, then character attribute `reason` provides
#' an explanation why the connection is not valid.
#'
#' @return
#' `connectionId()` returns an non-negative integer, -1, or `NA_integer_`.
#' For connections stdin, stdout, and stderr, 0, 1, and 2, are returned,
#' respectively.  For all other connections, an integer greater or equal to
#' 3 based on the connection's internal pointer is returned.
#' A connection that has been serialized, which is no longer valid, has
#' identifier -1.
#' Attribute `raw_id` returns the pointer string from which the above is
#' inferred.
#'
#' @section Connection Index versus Connection Identifier:
#' R represents \link[base:connections]{connections} as indices using plain
#' integers, e.g. `idx <- as.integer(con)`.
#' The three connections standard input ("stdin"), standard output ("stdout"),
#' and standard error ("stderr") always exists and have indices 0, 1, and 2.
#' Any connection opened beyond these will get index three or greater,
#' depending on availability as given by [base::showConnections()].
#' To get the connection with a given index, use [base::getConnection()].
#' **Unfortunately, this index representation of connections is non-robust**,
#' e.g. there are cases where two or more 'connection' objects can end up with
#' the same index and if used, the written output may end up at the wrong
#' destination and files and database might get corrupted.  This can for
#' instance happen if [base::closeAllConnections()] is used (*).
#' **In contrast, `id <- connectionId(con)` gives an identifier that is unique
#' to that 'connection' object.**  This identifier is based on the internal
#' pointer address of the object.  The risk for two connections in the same
#' \R session to end up with the same pointer address is very small.
#' Thus, in case we ended up in a situation where two connections `con1` and
#' `con2` share the same index---`as.integer(con1) == as.integer(con2)`---
#' they will never share the same identifier---
#' `connectionId(con1) != connectionId(con2)`.
#' Here, `isConnectionValid()` can be used to check which one of these
#' connections, if any, are valid.
#'
#' (*) Note that there is no good reason for calling `closeAllConnections()`
#'     If called, there is a great risk that the files get corrupted etc.
#'     See (1) for examples and details on this problem.
#'     If you think there is a need to use it, it is much safer to restart \R
#'     because that is guaranteed to give you a working \R session with
#'     non-clashing connections.
#'     It might also be that `closeAllConnections()` is used because
#'     [base::sys.save.image()] is called, which might happen if \R is being
#'     forced to terminate.
#'
#' @section Connections Cannot be Serialized Or Saved:
#' A 'connection' cannot be serialized, e.g. it cannot be saved to file to
#' be read and used in another \R session.  If attempted, the connection will
#' not be valid.  This is a problem that may occur in parallel processing
#' when passing an \R object to parallel worker for further processing, e.g.
#' the exported object may hold an internal database connection which will
#' no longer be valid on the worker.
#' When a connection is serialized, its internal pointer address will be
#' invalidated (set to nil). In such cases, `connectionId(con)` returns -1
#' and `isConnectionValid(con)` returns FALSE.
#'
#' @examples
#' ## R represents connections as plain indices
#' as.integer(stdin())          ## int 0
#' as.integer(stdout())         ## int 1
#' as.integer(stderr())         ## int 2
#'
#' ## The first three connections always exist and are always valid
#' isConnectionValid(stdin())   ## TRUE
#' connectionId(stdin())        ## 0L
#' isConnectionValid(stdout())  ## TRUE
#' connectionId(stdout())       ## 1L
#' isConnectionValid(stderr())  ## TRUE
#' connectionId(stderr())       ## 2L
#'
#' ## Connections cannot be serialized
#' con <- file(tempfile(), open = "w")
#' x <- list(value = 42, stderr = stderr(), con = con)
#' y <- unserialize(serialize(x, connection = NULL))
#' isConnectionValid(y$stderr)  ## TRUE
#' connectionId(y$stderr)       ##  2L
#' isConnectionValid(y$con)     ## FALSE with attribute 'reason'
#' connectionId(y$con)          ## -1L
#' close(con)
#'
#' @references
#' 1. ['BUG: A `connection` object may become corrupt and re-referenced to another connection (PATCH)'](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/81), 2018-10-30.
#' 2. R-devel thread [PATCH: Asserting that 'connection' used has not changed + R_GetConnection2()](https://stat.ethz.ch/pipermail/r-devel/2018-October/077004.html), 2018-10-31.
#'
#' @seealso
#' See [base::showConnections()] for currently open connections and their
#' indices. To get a connection by its index, use [base::getConnection()].
#'
#' @importFrom utils capture.output
#' @export
isConnectionValid <- function(con) {
  stop_if_not(inherits(con, "connection"))
  index <- as.integer(con)
  
  ## stdin, stdout, or stderr?
  if (index <= 2) return(TRUE)

  ## No such connection index?
  if (!is.element(index, getAllConnections())) {
    res <- FALSE
    attr(res, "reason") <- sprintf("Connection (%s) is no longer valid. There is currently no registered R connection with that index %d among the known ones (%s)", connectionInfo(con), index, paste(getAllConnections(), collapse = ", "))
    return(res)
  }

  ## That connection is no longer registered?
  current_con <- getConnection(index)
  res <- identical(attr(con, "conn_id"), attr(current_con, "conn_id"))
  if (!isTRUE(res)) {
    attr(res, "reason") <- sprintf("Connection (%s) is no longer valid. It differ from the currently registered R connection with the same index %d (%s)", connectionInfo(con), index, connectionInfo(current_con))
    return(res)
  }

  ## A valid connection
  TRUE
}

#' @rdname isConnectionValid
#' @export
connectionId <- function(con) {
  stop_if_not(inherits(con, "connection"))
  
  ## stdin, stdout, or stderr?
  index <- as.integer(con)
  if (index <= 2) return(index)

  id <- attr(con, "conn_id")
  if (is.null(id)) return(NA_integer_)
  
  id <- raw_id <- capture.output(print(id))
  id <- gsub("(<pointer:| |>)", "", id)
  
  ## Has the connection been serialized?
  ## 0: observed on Solaris
  if (id == "(nil)" || id == "0x0" || id == "0") return(-1L)
  
  id <- strtoi(id, base = 16L)

  attr(id, "raw_id") <- raw_id
  
  id
}


connectionInfo <- function(con) {
  index <- as.integer(con)
  if (is.element(index, getAllConnections())) {
    details <- summary(con)
  } else {
    details <- as.list(rep(NA_character_, times = 7L))
    names(details) <- c("description", "class", "mode", "text", "opened", "can read", "can write")
  }
  id <- connectionId(con)
  details$id <- id
  details$raw_id <- attr(id, "raw_id")
  info <- unlist(lapply(details, FUN = function(x) {
    if (is.character(x)) paste0('"', x, '"') else x
  }), use.names = FALSE)
  info <- sprintf("%s=%s", names(details), info)
  info <- paste(info, collapse = ", ")
  info <- sprintf("connection: index=%d, %s", index, info)
  info
}


