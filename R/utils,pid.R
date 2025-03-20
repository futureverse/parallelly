#' Check whether a process PID exists or not
#'
#' @param pid A positive integer.
#'
#' @return Returns `TRUE` if a process with the given PID exists,
#' `FALSE` if a process with the given PID does not exists, and
#' `NA` if it is not possible to check PIDs on the current system.
#'
#' @details
#' There is no single go-to function in \R for testing whether a PID exists
#' or not.  Instead, this function tries to identify a working one among
#' multiple possible alternatives.  A method is considered working if the
#' PID of the current process is successfully identified as being existing
#' such that `pid_exists(Sys.getpid())` is `TRUE`.  If no working
#' approach is found, `pid_exists()` will always return `NA`
#' regardless of PID tested.
#' On Unix, including macOS, alternatives `tools::pskill(pid, signal = 0L)`
#' and `system2("ps", args = pid)` are used.
#' On MS Windows, various alternatives of `system2("tasklist", ...)` are used.
#' Note, some MS Windows machines are configures to not allow using
#' `tasklist` on other process IDs than the current one.
#'
#' @references
#' 1. The Open Group Base Specifications Issue 7, 2018 edition,
#'    IEEE Std 1003.1-2017 (Revision of IEEE Std 1003.1-2008)
#'    \url{https://pubs.opengroup.org/onlinepubs/9699919799/functions/kill.html}
#'
#' 2. Microsoft, tasklist, 2021-03-03,
#'    \url{https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tasklist}
#'
#' 3. R-devel thread 'Detecting whether a process exists or not by its PID?',
#'    2018-08-30.
#'    \url{https://stat.ethz.ch/pipermail/r-devel/2018-August/076702.html}
#'
#' @seealso
#' \code{\link[tools]{pskill}()} and \code{\link[base]{system2}()}.
#'
#' @importFrom tools pskill
#' @importFrom utils str
#' @keywords internal
pid_exists <- local({
  os <- .Platform$OS.type

  ## The value of tools::pskill() is incorrect in R (< 3.5.0).
  ## This was fixed in R (>= 3.5.0).
  ## https://github.com/HenrikBengtsson/Wishlist-for-R/issues/62
  if (getRversion() >= "3.5.0") {
    pid_exists_by_pskill <- function(pid, debug = FALSE) {
      tryCatch({
        ## "If sig is 0 (the null signal), error checking is performed but no 
        ##  signal is actually sent. The null signal can be used to check the 
        ##  validity of pid." [1]
        res <- pskill(pid, signal = 0L)
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat(sprintf("Call: tools::pskill(%s, signal = 0L)\n", pid))
          print(res)
        }
        as.logical(res)
      }, error = function(ex) NA)
    }
  } else {
    pid_exists_by_pskill <- function(pid, debug = FALSE) NA
  }

  pid_exists_by_ps <- function(pid, debug = FALSE) {
    tryCatch({
      ## 'ps <pid> is likely to be supported by more 'ps' clients than
      ## 'ps -p <pid>' and 'ps --pid <pid>'
      out <- suppressWarnings({
        system2("ps", args = pid, stdout = TRUE, stderr = FALSE)
      })
      if (debug) {
        ## FIXME: Turn these into messages going to stderr
        cat(sprintf("Call: ps %s\n", pid))
        print(out)
        str(out)
      }
      status <- attr(out, "status")
      if (is.numeric(status) && status < 0) return(NA)
      out <- gsub("(^[ ]+|[ ]+$)", "", out)
      out <- out[nzchar(out)]
      if (debug) {
        ## FIXME: Turn these into messages going to stderr
        cat("Trimmed:\n")
        print(out)
        str(out)
      }
      out <- strsplit(out, split = "[ ]+", fixed = FALSE)
      out <- lapply(out, FUN = function(x) x[1])
      out <- unlist(out, use.names = FALSE)
      if (debug) {
        ## FIXME: Turn these into messages going to stderr
        cat("Extracted: ", paste(sQuote(out), collapse = ", "), "\n", sep = "")
      }
      out <- suppressWarnings(as.integer(out))
      if (debug) {
        ## FIXME: Turn these into messages going to stderr
        cat("Parsed: ", paste(sQuote(out), collapse = ", "), "\n", sep = "")
      }
      any(out == pid)
    }, error = function(ex) NA)
  }

  pid_exists_by_tasklist_filter <- function(pid, debug = FALSE) {
    ## Example: tasklist /FI "PID eq 12345" /NH  [2]
    ## Try multiple times, because 'tasklist' seems to be unreliable, e.g.
    ## I've observed on win-builder that two consecutive calls filtering
    ## on Sys.getpid() once found a match while the second time none.
    for (kk in 1:5) {
      res <- tryCatch({
        args = c("/FI", shQuote(sprintf("PID eq %.0f", pid)), "/NH")
        out <- system2("tasklist", args = args, stdout = TRUE, stderr = "")
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat(sprintf("Call: tasklist %s\n", paste(args, collapse = " ")))
          print(out)
          str(out)
        }
        out <- gsub("(^[ ]+|[ ]+$)", "", out)
        out <- out[nzchar(out)]
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat("Trimmed:\n")
          print(out)
          str(out)
        }
        out <- grepl(sprintf(" %.0f ", pid), out)
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat("Contains PID: ", paste(out, collapse = ", "), "\n", sep = "")
        }
        any(out)
      }, error = function(ex) NA)
      if (isTRUE(res)) return(res)
      Sys.sleep(0.1)
    }
    res
  }

  pid_exists_by_tasklist <- function(pid, debug = FALSE) {
    ## Example: tasklist [2]
    for (kk in 1:5) {
      res <- tryCatch({
        out <- system2("tasklist", stdout = TRUE, stderr = "")
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat("Call: tasklist\n")
          print(out)
          str(out)
        }
        out <- gsub("(^[ ]+|[ ]+$)", "", out)
        out <- out[nzchar(out)]
        skip <- grep("^====", out)[1]
        if (!is.na(skip)) out <- out[seq(from = skip + 1L, to = length(out))]
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat("Trimmed:\n")
          print(out)
          str(out)
        }
        out <- strsplit(out, split = "[ ]+", fixed = FALSE)
        ## WORKAROUND: The 'Image Name' column may contain spaces, making
        ## it hard to locate the second column.  Instead, we will identify
        ## the most common number of column (typically six) and the count
        ## how many columns we should drop at the end in order to find the
        ## second as the last
        ## 
        n <- lengths(out)
        n <- sort(n)[round(length(n) / 2)] ## "median" without using 'stats'
        drop <- n - 2L
        out <- lapply(out, FUN = function(x) rev(x)[-seq_len(drop)][1])
        out <- unlist(out, use.names = FALSE)
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat("Extracted: ", paste(sQuote(out), collapse = ", "), "\n", sep = "")
        }
        out <- as.integer(out)
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat("Parsed: ", paste(sQuote(out), collapse = ", "), "\n", sep = "")
        }
        out <- (out == pid)
        if (debug) {
          ## FIXME: Turn these into messages going to stderr
          cat("Equals PID: ", paste(out, collapse = ", "), "\n", sep = "")
        }
        any(out)
      }, error = function(ex) NA)
      if (isTRUE(res)) return(res)
      Sys.sleep(0.1)
    }
    res
  }

  cache <- list()

  function(pid, debug = getOption("parallelly.debug", FALSE)) {
    stop_if_not(is.numeric(pid), length(pid) == 1L, is.finite(pid), pid > 0L)

    pid_check <- cache$pid_check
    
    ## Does a working pid_check() exist?
    if (!is.null(pid_check)) return(pid_check(pid, debug = debug))

    if (debug) mdebug("Attempting to find a working pid_exists_*() function ...")

    ## Muffle warnings, but record them all in case of no success
    warnings <- list()
    withCallingHandlers({
      ## Try to find a working pid_check() function, i.e. one where
      ## pid_check(Sys.getpid()) == TRUE
      if (os == "unix") {  ## Unix, Linux, and macOS
        if (isTRUE(pid_exists_by_pskill(Sys.getpid(), debug = debug))) {
          pid_check <- pid_exists_by_pskill
        } else if (isTRUE(pid_exists_by_ps(Sys.getpid(), debug = debug))) {
          pid_check <- pid_exists_by_ps
        }
      } else if (os == "windows") {  ## Microsoft Windows
        if (isTRUE(pid_exists_by_tasklist(Sys.getpid(), debug = debug))) {
          pid_check <- pid_exists_by_tasklist
        } else if (isTRUE(pid_exists_by_tasklist_filter(Sys.getpid(), debug = debug))) {
          pid_check <- pid_exists_by_tasklist_filter
        }
      }
    }, warning = function(w) {
      warnings <<- c(warnings, list(w))
      invokeRestart("muffleWarning")
    })

    ## Signal any collected warnings, but only the unique ones
    if (length(warnings) > 0) {
      warnings <- unique(warnings)
      lapply(warnings, FUN = warning)
    }

    if (is.null(pid_check)) {
      if (debug) mdebug("- failed; pid_check() will always return NA")
      si <- Sys.info()
      warnf("The %s package is not capable of checking whether a process is alive based on its process ID, on this machine [%s, platform %s, %s %s (%s), %s@%s]",
        sQuote(.packageName),
        R.Version()$version.string,
        R.Version()$platform,
        si[["sysname"]],
        si[["release"]],
        si[["version"]],
        si[["user"]],
        si[["nodename"]]
      )
      ## Default to NA
      pid_check <- function(pid, ...) NA
    } else {
      ## Sanity check
      stop_if_not(isTRUE(pid_check(Sys.getpid(), debug = debug)))
      if (debug) mdebug("- success")
    }

    ## Record
    cache <<- list(pid_check = pid_check)

    if (debug) mdebug("Attempting to find a working pid_exists_*() function ... done")

    pid_check(pid)
  }
})


#' @importFrom tools pskill
pid_kill <- function(pid, wait = 0.5, timeout = 30, debug = TRUE) {
  pid <- as.integer(pid)
  stop_if_not(length(pid), !is.na(pid), pid >= 0L)

  setTimeLimit(elapsed = timeout)
  on.exit(setTimeLimit(elapsed = Inf))

  tryCatch({
    ## Always try to kill, because pid_exists() can be very slow on Windows
    pskill(pid)
  
    ## Wait a bit before checking whether process was successfully
    ## killed or not
    Sys.sleep(wait)

    ## WARNING: pid_exists() can be very slow on Windows
    !isTRUE(pid_exists(pid))
  }, error = function(ex) NA)
}
