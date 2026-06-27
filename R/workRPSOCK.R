#' Worker Event-Loop Function for PSOCK Workers
#'
#' This is a version of `parallel:::.workRSOCK()` with an option
#' to override the default `parallel:::workerCommand()`.
#'
#' @param workCommand A function taking a single argument `master`
#' (the socket node connection) that processes one incoming command
#' from the parent process. It should return `TRUE` to continue the
#' work loop, `FALSE` to shut down, or `NULL` if the connection was
#' not established.
#' If `NULL` (default), `parallel:::workCommand()` is used.
#' 
#' @return Nothing. The function enters an event loop and does not
#' return until the worker receives a `"DONE"` message.
#'
#' @keywords internal
workRPSOCK <- function(workCommand = NULL) {
  if (is.null(workCommand)) {
    workCommand <- importParallel("workCommand")
  } else {
    stopifnot(is.function(workCommand))
  }

  ## Import internal functions from the 'parallel' package
  sinkWorkerOutput <- importParallel("sinkWorkerOutput")

  ## Verbatim copy of makeSOCKmaster() in parallel:::.workRSOCK()
  makeSOCKmaster <- function(master, port, setup_timeout, timeout, useXDR,
                             setup_strategy)
  {
      port <- as.integer(port)
      timeout <- as.integer(timeout)
      stopifnot(setup_timeout >= 0)
      cls <- if(useXDR) "SOCKnode" else "SOCK0node"

      ## Retry scheme parameters (do these need to be customizable?)
      retryDelay <- 0.1     # 0.1 second initial delay before retrying
      retryScale <- 1.5     # 50% increase of delay at each retry

      ## Retry multiple times in case the master is not yet ready
      t0 <- Sys.time()

      scon_timeout <- 1
      repeat {
          ## Set up a short timeout for the connection with parallel
          ## setup, which is needed to deal with half-opened connections
          ## (opened on client, closed on server).  The final connection
          ## timeout defaults to a large number, updated after the setup.
          if (setup_strategy == "parallel")
              scon_timeout <- scon_timeout + 0.2
          else
              ## Using "timeout" makes socketConnection() essentially
              ## blocking, which has been the practice for many years.
              ## Perhaps we could now use values similar to those for
              ## parallel setup.
              scon_timeout <- timeout

          con <- tryCatch({
              socketConnection(master, port = port, blocking = TRUE,
                               open = "a+b",
                               timeout = as.integer(scon_timeout))
          }, error = identity)

          hres <- NULL
          if (inherits(con, "connection")) {
              scon <- structure(list(con = con), class = cls)
              if (setup_strategy == "sequential")
                  return(scon)

              ## Serve the first command as a handshake during connection
              ## setup.  This is to get rid of half-opened connections.
              hres <- tryCatch({ workCommand(scon) }, error = identity)
              if (identical(hres, TRUE)) {
                  if (setup_strategy == "parallel")
                      socketTimeout(socket = con, timeout = timeout)
                  return(scon)
              } else if (identical(hres, FALSE)) {
                  ## "Done" command from server.  Could happen with server
                  ## accidentally not performing parallel setup.
                  return(NULL)
              } else
                  ## Error, possibly half-opened connection.
                  close(con)
          }

          if (difftime(Sys.time(), t0, units="secs") > setup_timeout) {
              if (inherits(hres, "error"))
                  stop(hres)
              if (inherits(con, "error"))
                  stop(con)
              stop("Connection setup failed or timed out.")
          }
          Sys.sleep(retryDelay)
          retryDelay <- retryScale * retryDelay
      }
  }

  master <- "localhost"
  port <- NA_integer_
  outfile <- Sys.getenv("R_SNOW_OUTFILE")
  setup_timeout <- 120
  timeout <- 2592000L
  useXDR <- TRUE
  setup_strategy <- "sequential"
  for (a in commandArgs(TRUE)) {
    pos <- regexpr("=", a)
    name <- substr(a, 1L, pos - 1L)
    value <- substr(a, pos + 1L, nchar(a))
    switch(name, MASTER = {
      master <- value
    }, PORT = {
      port <- value
    }, OUT = {
      outfile <- value
    }, SETUPTIMEOUT = {
      setup_timeout <- as.numeric(value)
    }, TIMEOUT = {
      timeout <- value
    }, XDR = {
      useXDR <- as.logical(value)
    }, SETUPSTRATEGY = {
      setup_strategy <- match.arg(value, c("sequential", 
        "parallel"))
    })
  }

  if (is.na(port)) stop("PORT must be specified")

  sinkWorkerOutput(outfile)

  msg <- sprintf("starting worker pid=%d on %s at %s\n",
         Sys.getpid(), paste(master, port, sep = ":"),
         format(Sys.time(), "%H:%M:%OS3"))
  cat(msg)

  master <- makeSOCKmaster(master, port, setup_timeout, timeout, useXDR,
                           setup_strategy)
  if (!is.null(master)) {
    repeat {
      workCommand(master)
    }
  }
}
