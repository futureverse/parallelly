#' Check If Forked Processing ("multicore") is Supported
#'
#' Certain parallelization methods in R rely on _forked_ processing, e.g.
#' `parallel::mclapply()`, `parallel::makeCluster(n, type = "FORK")`,
#' `doMC::registerDoMC()`, and `future::plan("multicore")`.
#' Process forking is done by the operating system and support for it in
#' \R is restricted to Unix-like operating systems such as Linux, Solaris,
#' and macOS.  R running on Microsoft Windows does not support forked
#' processing.
#' In R, forked processing is often referred to as "multicore" processing,
#' which stems from the 'mc' of the `mclapply()` family of functions, which
#' originally was in a package named \pkg{multicore} which later was
#' incorporated into the \pkg{parallel} package.
#' This function checks whether or not forked (aka "multicore") processing
#' is supported in the current \R session.
#'
#' @param \ldots Internal usage only.
#'
#' @return TRUE if forked processing is supported and not disabled,
#'         otherwise FALSE.
#'
#' @section Support for process forking:
#' While R supports forked processing on Unix-like operating system such as
#' Linux and macOS, it does not on the Microsoft Windows operating system.
#'
#' For some R environments it is considered unstable to perform parallel
#' processing based on _forking_.
#' This is for example the case when using RStudio, cf.
#' \href{https://github.com/rstudio/rstudio/issues/2597#issuecomment-482187011}{RStudio Inc. recommends against using forked processing when running R from within the RStudio software}.
#' This function detects when running in such an environment and returns
#' `FALSE`, despite the underlying operating system supports forked processing.
#' A warning will also be produced informing the user about this the first
#' time time this function is called in an \R session.
#' This warning can be disabled by setting R option
#' `parallelly.supportsMulticore.unstable`, or environment variable
#' \env{R_PARALLELLY_SUPPORTSMULTICORE_UNSTABLE} to `"quiet"`.
#'
#' @section Enable or disable forked processing:
#' It is possible to disable forked processing for futures by setting \R
#' option `parallelly.fork.enable` to `FALSE`.  Alternatively, one can
#' set environment variable \env{R_PARALLELLY_FORK_ENABLE} to `false`.
#' Analogously, it is possible to override disabled forking by setting one
#' of these to `TRUE`.
#'
#' @examples
#' ## Check whether or not forked processing is supported
#' supportsMulticore()
#'
#' @export
supportsMulticore <- local({
  supportedByOS <- NA
  
  function(...) {
    if (is.na(supportedByOS)) {
      ns <- getNamespace("parallel")
      supportedByOS <<- exists("mcparallel", mode = "function", envir = ns,
                               inherits = FALSE)
    }

    ## Forked processing is not supported by the OS?
    if (!supportedByOS) return(FALSE)

    ## Is forked processing disabled via R settings?
    value <- getOption2("parallelly.fork.enable", NA)
    stop_if_not(length(value) == 1L)
    value <- as.logical(value)
    if (!is.na(value)) return(value)

    ## Try to decide whether forked processing is safe or not

    ## Forked processing should be avoided when R run from RStudio
    if (!supportsMulticoreAndRStudio(...)) return(FALSE)
    
    TRUE
  }
})


supportsMulticoreAndRStudio <- local({
  alreadyWarned <- FALSE

  function(warn = FALSE) {
    disableOn <- getOption2("parallelly.supportsMulticore.disableOn", c("rstudio_console", "rstudio_terminal"))

    disable <- FALSE
    
    ## Check RStudio?
    ## Forked processing should be avoided within RStudio
    ## [https://github.com/rstudio/rstudio/issues/2597#issuecomment-482187011]
    is_rstudio <- (Sys.getenv("RSTUDIO") == "1")
    if (is_rstudio) {
      if (nzchar(Sys.getenv("RSTUDIO_TERM", ""))) {
        ## Running R via the RStudio Terminal
        disable <- ("rstudio_term" %in% disableOn)
      } else {
        ## Running R via the RStudio Console
        disable <- ("rstudio_console" %in% disableOn)
      }
    }

    if (!disable) return(TRUE)
    
    if (!warn || alreadyWarned) return(FALSE)
    
    action <- getOption2("parallelly.supportsMulticore.unstable", "warn")
    if (action == "warn") {
      warning("[ONE-TIME WARNING] Forked processing ('multicore') is not supported when running R from RStudio because it is considered unstable. For more details, how to control forked processing or not, and how to silence this warning in future R sessions, see ?parallelly::supportsMulticore")
    }
 
    alreadyWarned <<- TRUE
 
    FALSE
  }
})
