#' Find a TCP port that can be opened
#'
#' @param ports (integer vector, or character string)
#' Zero or more TCP ports in \[0, 65535\] to scan.
#' If `"random"`, then a random set of ports is considered.
#' If `"auto"`, then the port given by environment variable
#' \env{R_PARALLEL_PORT} is used, which may also specify `random`.
#'
#' @param default (integer) `NA_integer_` or a port to returned if
#' an available port could not be found.
#' If `"first"`, then `ports[1]`.  If `"random"`, then a random port
#' among `ports` is used. If `length(ports) == 0`, then `NA_integer_`.
#'
#' @param randomize (logical) If TRUE, `ports` is randomly shuffled
#' before searched.  This shuffle does _not_ forward the RNG seed.
#'
#' @return
#' Returns an integer representing the first port among `ports` that
#' can be opened.  If none can be opened, then `default` is returned.
#'
#' @export
freePort <- function(ports = 1024:65535, default = "random", randomize = TRUE) {
  if (is.character(default)) {
    default <- match.arg(default, choices = c("first", "random"))
  } else {
    default <- as.integer(default)
    stop_if_not(length(default) == 1L)
    if (!is.na(default)) default <- assertPort(default)
  }

  if (is.character(ports)) {
    how <- match.arg(ports, choices = c("auto", "random"))
    if (identical(how, "auto")) {
      ports <- Sys.getenv("R_PARALLEL_PORT", "random")
      if (identical(ports, "random")) {
        how <- "random"
      } else {
        ports <- suppressWarnings(as.integer(ports))
        if (is.na(ports)) {
          warnf("Will use a random port because environment variable 'R_PARALLEL_PORT' coerced to NA_integer_: %s", sQuote(Sys.getenv("R_PARALLEL_PORT")))
          how <- "random"
        }
      }
    }
    if (identical(how, "random")) {
      ports <- randomParallelPorts()
      randomize <- TRUE
    }
  }

  ## Update 'default'?
  ## Note, this will become NA_integer_ if length(ports) == 0
  if (is.character(default)) {
    default <- switch(default,
      first  = ports[1],
      random = stealth_sample(ports, size = 1L)
    )
  }

  stop_if_not(is.logical(randomize), !is.na(randomize))
  if (randomize) ports <- stealth_sample(ports)

  ## Nothing todo?
  if (length(ports) == 0L) return(default)

  ## Find first available port
  for (kk in seq_along(ports)) {
    port <- ports[kk]
    
    ## Available?
    if (isTcpPortAvailable(port)) {
      return(port)
    }
  }

  default
}



assertPort <- function(port) {
  stop_if_not(is.numeric(port), length(port) == 1L)
  port <- as.integer(port)
  if (is.na(port) || port < 0L || port > 65535L) {
    stopf("Invalid port: %s", port)
  }
  port
}


randomParallelPorts <- function(default = 11000:11999) {
  random <- getEnvVar2("R_PARALLELLY_RANDOM_PORTS", "")
  if (!nzchar(random)) return(default)

  specs <- strsplit(random, split = ",", fixed = TRUE)[[1]]

  pattern_port <- "^([[:digit:]]{1,5})$"
  pattern_range <- "^([[:digit:]]{1,5}):([[:digit:]]{1,5})$"

  ports <- integer(0L)
  for (kk in seq_along(specs)) {
    spec <- specs[kk]
    if (grepl(pattern_port, spec)) {
      ports_kk <- as.integer(spec)
      if (is.na(ports_kk)) {
        ## This should never be able to happen with the above
        ## regular expressions /HB 2024-11-06
        warnf("Skipping port specification in environment variable 'R_PARALLELLY_RANDOM_PORTS' that coerced to NA_integer_: %s", sQuote(spec))
        next
      }
    } else if (grepl(pattern_range, spec)) {
      from <- sub(pattern_range, "\\1", spec)
      to <- sub(pattern_range, "\\2", spec)
      from <- as.integer(from)
      to <- as.integer(to)
      if (is.na(from) || is.na(to)) {
        ## This should never be able to happen with the above
        ## regular expressions /HB 2024-11-06
        warnf("Skipping port specification in environment variable 'R_PARALLELLY_RANDOM_PORTS' that coerced to NA_integer_: %s", sQuote(spec))
        next
      } else if (from < 0L || from > 65535L || to < 0L || to > 65535L) {
        warnf("Skipping port specification in environment variable 'R_PARALLELLY_RANDOM_PORTS' that specify ports outside of [0,65535]: %s", sQuote(spec))
        next
      }
      ports_kk <- from:to
    } else {
       warnf("Skipping unknown port specification in environment variable 'R_PARALLELLY_RANDOM_PORTS': %s", sQuote(spec))
       next
    }
    ports <- c(ports, ports_kk)
  } ## for (kk ...)

  if (length(ports) == 0L) {
    warnf("Will use the default set of random ports, because environment variable 'R_PARALLELLY_RANDOM_PORTS' did not specify any valid ports: %s", sQuote(random))
    ports <- default
  }

  ports <- unique(sort(ports))

  ports
}


#' Initialize R's internet module
#'
#' R needs to initialize its Internet module before we can create sockets.
#' This is automatically done when R starts on Linux and macOS, but not on
#' MS Windows.
#'
#' This function triggers the initialization, but calling one of R's
#' built-in functions that does so.  See 'src/main/internet.c' in the
#' R source code for where this happens under the hood.
#'
#' @noRd
initialize_internet <- local({
  done <- (.Platform[["OS.type"]] != "windows")
  baseenv <- baseenv()
  
  function() {
    ## Already done?
    if (done) return()
  
    if (exists("serverSocket", mode = "function", envir = baseenv, inherits = FALSE)) {
      ## R (>= 4.0.0)
      serverSocket <- get("serverSocket", mode = "function", envir = baseenv, inherits = FALSE)
      con <- serverSocket(port = 0L)
      close(con)
    } else {
      ## R (< 4.0.0)
      tryCatch({
        con <- socketConnection(port = 0L, server = FALSE, blocking = FALSE, timeout = 0.0)
        close(con)
      }, error = identity)
    }
    
    done <<- TRUE
  }
})


#' Check whether a TCP port is available
#'
#' @param port (integer) TCP port in $\[1,65535\]$ to test.
#'
#' @param test One or more tests to apply.
#' If `"bind"`, check if it is possible to _bind_ the TCP port.
#' If `"listen"`, check if it is possible to _listen_ to the TCP port.
#'
#' @return
#' Return TRUE if the TCP port is available, otherwise FALSE.
#'
#' @keywords internal
#' @noRd
isTcpPortAvailable <- function(port, test = c("bind", "listen")) {
  stopifnot(
    length(port) == 1L,
    is.numeric(port),
    !is.na(port),
    port >= 1,
    port <= 65535
  )
  port <- as.integer(port)
  stopifnot(
    port >= 1L,
    port <= 65535L
  )

  test <- match.arg(test, several.ok = TRUE)

  ## SPECIAL: Fake port availability?
  if (nzchar(Sys.getenv("_R_PARALLELLY_CHECK_AVAILABLE_PORTS_"))) {
    value <- Sys.getenv("_R_PARALLELLY_CHECK_AVAILABLE_PORTS_")
    if (value == "any") {
#      warning("parallelly:::isTcpPortAvailable() returns TRUE because _R_PARALLELLY_CHECK_AVAILABLE_PORTS_=any")
      return(TRUE)
    }
    stop("Unknown value on _R_PARALLELLY_CHECK_AVAILABLE_PORTS_: ", sQuote(value))
  }

  initialize_internet()
  res <- .Call(C_R_test_tcp_port, port)
  
  if (nzchar(Sys.getenv("R_PARALLELLY_DEBUG"))) {
    reason <- if (res == 0) {
      "available (can bind and listen)"
    } else if (res %/% 10 == 1) {
      "not available (cannot set up socket)"
    } else if (res %/% 10 == 2) {
      "not available (cannot reuse port in TIME_WAIT state)"
    } else if (res %/% 10 == 3) {
      "not available (cannot bind to port)"
    } else if (res %/% 10 == 4) {
      "not available (cannot listen)"
    }
    message(sprintf("parallelly:::isTcpPortAvailable(%d): %s", port, reason))
  }
  
  (res == 0L)
}
