#' Number of Available and Free Connections
#'
#' The number of [connections] that can be open at the same time in \R is
#' _typically_ 128, where the first three are occupied by the always open
#' [stdin()], [stdout()], and [stderr()] connections, which leaves 125 slots
#' available for other types of connections.  Connections are used in many
#' places, e.g. reading and writing to file, downloading URLs, communicating
#' with parallel \R processes over a socket connections (e.g.
#' [parallel::makeCluster()] and [makeClusterPSOCK()]), and capturing
#' standard output via text connections (e.g. [utils::capture.output()]).
#'
#' @return
#' A non-negative integer, or `+Inf` if the available number of connections
#' is greater than 16384, which is a limit be set via option
#' \code{\link[=parallelly.options]{parallelly.availableConnections.tries}}.
#'
#' @section How to increase the limit:
#' In R (>= 4.4.0), it is possible to _increase_ the limit of 128 connections
#' to a greater number via command-line option `--max-connections=N`, e.g.
#'
#' ```r
#' $ Rscript -e "parallelly::availableConnections()"
#' [1] 128
#'
#' $ Rscript --max-connections=512 -e "parallelly::availableConnections()"
#' [1] 512
#' ```
#'
#' For R (< 4.4.0), the limit can only be changed by rebuilding \R from
#' source, because the limited is hardcoded as a
#'
#' ```c
#' #define NCONNECTIONS 128
#' ```
#'
#' in \file{src/main/connections.c}.
#'
#' @section How the limit is identified:
#' Since the limit _might_ changed, for instance in custom \R builds or in
#' future releases of \R, we do not want to assume that the limit is 128 for
#' all \R installation.  Unfortunately, it is not possible to query \R for what
#' the limit is.
#' Instead, `availableConnections()` infers it from trial-and-error.
#' Specifically, it attempts to open as many concurrent connections as possible
#' until it fails.  For efficiency, the result is memoized throughout the 
#' current \R session.
#'
#' @examples
#' total <- availableConnections()
#' message("You can have ", total, " connections open in this R installation")
#' free <- freeConnections()
#' message("There are ", free, " connections remaining")
#'
#' @seealso
#' [base::showConnections()].
#'
#' @references
#' 1. 'WISH: Increase limit of maximum number of open connections (currently 125+3)', 2016-07-09, 
#' \url{https://github.com/HenrikBengtsson/Wishlist-for-R/issues/28}
#' @export
availableConnections <- local({
  max <- NULL
  
  function() {
    ## Overridden by R options?
    value <- getOption2("parallelly.availableConnections", NULL)
    if (!is.null(value)) {
      stop_if_not(length(value) == 1L, is.numeric(value), !is.na(value),
                  value >= 3L)
      return(value)
    }
    
    if (is.null(max)) {
      tries <- getOption2("parallelly.availableConnections.tries", 16384L)
      stop_if_not(length(tries) == 1L, is.numeric(tries), !is.na(tries),
                  tries >= 0L)

      cons <- list()
      on.exit({
        lapply(cons, FUN = function(con) try(close(con), silent = TRUE))
      })
      max <<- tryCatch({
        for (kk in seq_len(tries)) cons[[kk]] <- rawConnection(raw(0L))
        +Inf
      }, error = function(ex) {
        length(getAllConnections())
      })
    }
    
    max
  }               
})


#' @rdname availableConnections
#' @export
freeConnections <- function() {
  availableConnections() - length(getAllConnections())
}
