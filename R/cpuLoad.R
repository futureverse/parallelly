#' Get the Recent CPU Load
#'
#' @return A named numeric vector with three elements `1min`, `5min`, and
#' `15min` with non-negative values.
#' These values represent estimates of the CPU load during the last minute,
#' the last five minutes, and the last fifteen minutes \[1\].
#' An idle system have values close to zero, and a heavily loaded system
#' have values near `parallel::detectCores()`.
#' If they are unknown, missing values are returned.
#'
#' @details
#' This function works only Unix-like system with \file{/proc/loadavg}.
#'
#' @example incl/cpuLoad.R
#'
#' @references
#' 1. Linux Load Averages: Solving the Mystery,
#'    Brendan Gregg's Blog, 2017-08-08,
#'    \url{https://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html}
#'
#' @keywords internal
#' @export
cpuLoad <- function() {
  if (file.exists("/proc/loadavg")) {
    res <- readLines("/proc/loadavg", n = 1L)
    res <- strsplit(res, split=" ", fixed = TRUE)[[1]]
    res <- as.numeric(res[1:3])
  } else {
    res <- rep(NA_real_, times = 3L)
  }
  names(res) <- c("1min", "5min", "15min")
  res
}
