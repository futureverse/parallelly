launchNodePSOCK <- function(options, verbose = FALSE) {
  stop_if_not(inherits(options, "makeNodePSOCKOptions"))

  local_cmd <- options[["local_cmd"]]
  worker <- options[["worker"]]
  rank <- options[["rank"]]
  rshlogfile <- options[["rshlogfile"]]
  port <- options[["port"]]
  connectTimeout <- options[["connectTimeout"]]
  timeout <- options[["timeout"]]
  pidfile <- options[["pidfile"]]
  ## For messages, warnings, and errors"]]
  useXDR <- options[["useXDR"]]
  outfile <- options[["outfile"]]
  rshcmd_label <- options[["rshcmd_label"]]
  rsh_call <- options[["rsh_call"]]
  cmd <- options[["cmd"]]
  localMachine <- options[["localMachine"]]
  manual <- options[["manual"]]
  dryrun <- options[["dryrun"]]
  quiet <- options[["quiet"]]
  rshcmd <- options[["rshcmd"]]
  revtunnel <- options[["revtunnel"]]
  setup_strategy <- options[["setup_strategy"]]

  if (setup_strategy == "parallel") {
    stop("INTERNAL ERROR: launchNodePSOCK() called with setup_strategy='parallel', which should never occur")
  }

  verbose <- as.logical(verbose)
  stop_if_not(length(verbose) == 1L, !is.na(verbose))
  verbose_prefix <- "[local output] "

  is_worker_output_visible <- is.null(outfile)

  if (manual || dryrun) {
    if (!quiet) {
      msg <- c("----------------------------------------------------------------------")
      if (localMachine) {
        msg <- c(msg, sprintf("Manually, start worker #%s on local machine %s with:", rank, sQuote(worker)), sprintf("\n  %s\n", cmd))
      } else {
        msg <- c(msg, sprintf("Manually, (i) login into external machine %s:", sQuote(worker)),
                 sprintf("\n  %s\n", rsh_call))
        msg <- c(msg, sprintf("and (ii) start worker #%s from there:", rank),
                 sprintf("\n  %s\n", cmd))
        msg <- c(msg, sprintf("Alternatively, start worker #%s from the local machine by combining both steps in a single call:", rank),
                 sprintf("\n  %s\n", local_cmd))
      }
      msg <- paste(c(msg, ""), collapse = "\n")
      cat(msg)
      flush.console()
    }
    if (dryrun) return(NULL)
  } else {
    if (verbose) {
      mdebugf("%sStarting worker #%s on %s: %s", verbose_prefix, rank, sQuote(worker), local_cmd)
    }
    input <- if (.Platform[["OS.type"]] == "windows") "" else NULL

    assert_system_is_supported()
    res <- system(local_cmd, wait = FALSE, input = input)
    if (verbose) {
      mdebugf("%s- Exit code of system() call: %s", verbose_prefix, res)
    }
    if (res != 0) {
      stopf("Failed to launch PSOCK node. Reason: system(%s) had a non-zero exit code (%d)", local_cmd, res)
    }
  }

  if (verbose) {
    mdebugf("%sWaiting for worker #%s on %s to connect back", verbose_prefix, rank, sQuote(worker))
    if (is_worker_output_visible) {
      if (.Platform[["OS.type"]] == "windows") {
        mdebugf("%s- Detected 'outfile=NULL' on Windows: this will make the output from the background worker visible when running R from a terminal, but it will most likely not be visible when using a GUI.", verbose_prefix)
      } else {
        mdebugf("%s- Detected 'outfile=NULL': this will make the output from the background worker visible", verbose_prefix)
      }
    }
  }


  con <- local({
     ## Apply connection time limit "only to the rest of the current computation".
     ## NOTE: Regardless of transient = TRUE / FALSE, it still seems we need to
     ##       undo it manually :/  /HB 2016-11-05
     setTimeLimit(elapsed = connectTimeout)
     on.exit(setTimeLimit(elapsed = Inf))

     localhostHostname <- getOption2("parallelly.localhost.hostname", "localhost")
     warnings <- list()
     tryCatch({
       withCallingHandlers({
         socketConnection(localhostHostname, port = port, server = TRUE,
                          blocking = TRUE, open = "a+b", timeout = timeout)
       }, warning = function(w) {
         if (verbose) {
           mdebugf("%sDetected a warning from socketConnection(): %s", verbose_prefix, sQuote(conditionMessage(w)))
         }
         warnings <<- c(warnings, list(w))
       })
     }, error = function(ex) {
       setTimeLimit(elapsed = Inf)
       
       ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ## Post-mortem analysis
       ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       machineType <- if (localMachine) "local" else "remote"
       msg <- sprintf("Failed to launch and connect to R worker on %s machine %s from local machine %s.\n", machineType, sQuote(worker), sQuote(Sys.info()[["nodename"]]))

       ## Inspect and report on the error message
       cmsg <- conditionMessage(ex)
       if (grepl(gettext("reached elapsed time limit"), cmsg)) {
         msg <- c(msg, sprintf(" * The error produced by socketConnection() was: %s (which suggests that the connection timeout of %.0f seconds (argument 'connectTimeout') kicked in)\n", sQuote(cmsg), connectTimeout))
       } else {
         msg <- c(msg, sprintf(" * The error produced by socketConnection() was: %s\n", sQuote(cmsg)))
       }

       ## Inspect and report on any warnings
       if (length(warnings) > 0) {
         msg <- c(msg, sprintf(" * In addition, socketConnection() produced %d warning(s):\n", length(warnings)))
         for (kk in seq_along(warnings)) {
           cmsg <- conditionMessage(warnings[[kk]])
           if (grepl("port [0-9]+ cannot be opened", cmsg)) {
             msg <- c(msg, sprintf("   - Warning #%d: %s (which suggests that this port is either already occupied by another process or blocked by the firewall on your local machine)\n", kk, sQuote(cmsg)))
           } else {
             msg <- c(msg, sprintf("   - Warning #%d: %s\n", kk, sQuote(cmsg)))
           }
         }
       }

       ## Report on how the local socket connect was setup
       msg <- c(msg, sprintf(" * The localhost socket connection that failed to connect to the R worker used port %d using a communication timeout of %.0f seconds and a connection timeout of %.0f seconds.\n", port, timeout, connectTimeout))

       ## Report on how the worker was launched
       msg <- c(msg, sprintf(" * Worker launch call: %s.\n", local_cmd))

       ## Do we know the PID of the worker? If so, try to kill it to avoid
       ## leaving a stray process behind
       ## Comment: readWorkerPID() must be done *after* socketConnection()
       ## on R 3.4.4, otherwise socketConnection() will fail. Not sure why.
       ## /HB 2019-01-24
       pid <- readWorkerPID(pidfile)
       if (!is.null(pid)) {
         if (verbose) mdebugf("Killing worker process (PID %d) if still alive", pid)
         ## WARNING: pid_kill() calls pid_exists() [twice] and on Windows
         ## pid_exists() uses system('tasklist') which can be very very slow
         ## /HB 2019-01-24
         success <- pid_kill(pid)
         if (verbose) mdebugf("Worker (PID %d) was successfully killed: %s", pid, success)
         msg <- c(msg, sprintf(" * Worker (PID %d) was successfully killed: %s\n", pid, success))
       } else if (localMachine) {
         msg <- c(msg, sprintf(" * Failed to kill local worker because it's PID is could not be identified.\n"))
       }

       ## Propose further troubleshooting methods
       suggestions <- NULL

       ## Enable verbose=TRUE?
       if (!verbose) {
         suggestions <- c(suggestions, "Set 'verbose=TRUE' to see more details.")
       }

       ## outfile=NULL?
       if (.Platform[["OS.type"]] == "windows") {
         if (is_worker_output_visible) {
           suggestions <- c(suggestions, "On Windows, to see output from worker, set 'outfile=NULL' and run R from a terminal (not a GUI).")
         } else {
           suggestions <- c(suggestions, "On Windows, output from worker when using 'outfile=NULL' is only visible when running R from a terminal (not a GUI).")
         }
       } else {
         if (!is_worker_output_visible) {
           suggestions <- c(suggestions, "Set 'outfile=NULL' to see output from worker.")
         }
       }

       ## Log file?
       if (is.character(rshlogfile)) {
         smsg <- sprintf("Inspect the content of log file %s for %s.", sQuote(rshlogfile), paste(sQuote(rshcmd), collapse = " "))
         lmsg <- tryCatch(readLines(rshlogfile, n = 15L, warn = FALSE), error = function(ex) NULL)
         if (length(lmsg) > 0) {
           lmsg <- sprintf("     %2d: %s", seq_along(lmsg), lmsg)
           smsg <- sprintf("%s The first %d lines are:\n%s", smsg, length(lmsg), paste(lmsg, collapse = "\n"))
         }
         suggestions <- c(suggestions, smsg)
       } else {
         suggestions <- c(suggestions, sprintf("Set 'rshlogfile=TRUE' to enable logging for %s.", paste(sQuote(rshcmd), collapse = " ")))
       }
       
       ## Special: Windows 10 ssh client may not support reverse tunneling. /2018-11-10
       ## https://github.com/PowerShell/Win32-OpenSSH/issues/1265
       if (!localMachine && revtunnel && isTRUE(attr(rshcmd, "OpenSSH_for_Windows"))) {
         suggestions <- c(suggestions, sprintf("The 'rshcmd' (%s) used may not support reverse tunneling (revtunnel = TRUE). See ?parallelly::makeClusterPSOCK for alternatives.\n", rshcmd_label))
       }
       
       if (length(suggestions) > 0) {
         suggestions <- sprintf("   - Suggestion #%d: %s\n", seq_along(suggestions), suggestions)
         msg <- c(msg, " * Troubleshooting suggestions:\n", suggestions)
       }
       
       msg <- paste(msg, collapse = "")
       ex$message <- msg

       ## Re-signal as an PSOCKConnectionError error
       class(ex) <- c("PSOCKConnectionError", class(ex))
       
       ## Relay error and temporarily avoid truncating the error message
       ## in case it is too long
       local({
         oopts <- options(warning.length = 2000L)
         on.exit(options(oopts))
         stop(ex)
       })
     })
  })
  setTimeLimit(elapsed = Inf)

  if (verbose) {
    mdebugf("%sConnection with worker #%s on %s established", verbose_prefix, rank, sQuote(worker))
  }

  structure(
    list(con = con, host = worker, rank = rank, rshlogfile = rshlogfile),
    options = options,
    calls = sys.calls(),
    class = c("RichSOCKnode", if (useXDR) "SOCKnode" else "SOCK0node")
  )
} ## launchNodePSOCK()
