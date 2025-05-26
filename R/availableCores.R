#' Get Number of Available Cores on The Current Machine
#'
#' The current/main \R session counts as one, meaning the minimum
#' number of cores available is always at least one.
#'
#' @param constraints An optional character specifying under what
#' constraints ("purposes") we are requesting the values.
#' For instance, on systems where multicore processing is not supported
#' (i.e. Windows), using `constraints = "multicore"` will force a
#' single core to be reported.
#' Using `constraints = "connections"`, will append `"connections"` to
#' the `methods` argument.
#' It is possible to specify multiple constraints, e.g.
#' `constraints = c("connections", "multicore")`.
#'
#' @param methods A character vector specifying how to infer the number
#' of available cores.
#'
#' @param na.rm If TRUE, only non-missing settings are considered/returned.
#'
#' @param logical Passed to
#' \code{\link[parallel]{detectCores}(logical = logical)}, which,
#' _if supported_, returns the number of logical CPUs (TRUE) or physical
#' CPUs/cores (FALSE).
#' At least as of R 4.2.2, `detectCores()` this argument on Linux.
#' This argument is only if argument `methods` includes `"system"`.
#'
#' @param default The default number of cores to return if no non-missing
#' settings are available.
#'
#' @param which A character specifying which settings to return.
#' If `"min"` (default), the minimum value is returned.
#' If `"max"`, the maximum value is returned (be careful!)
#' If `"all"`, all values are returned.
#'
#' @param omit (integer; non-negative) Number of cores to not include.
#'
#' @param max (integer; positive) Maximum number of cores returned.
#' `availableCores(..., max = n)` is short for
#' `min(n, availableCores(...), na.rm = TRUE)`.
#'
#' @return Return a positive (>= 1) integer.
#' If `which = "all"`, then more than one value may be returned.
#' Together with `na.rm = FALSE` missing values may also be returned.
#'
#' @details
#' The following settings ("methods") for inferring the number of cores
#' are supported:
#' \itemize{
#'  \item `"system"` -
#'    Query \code{\link[parallel]{detectCores}(logical = logical)}.
#'
#'  \item `"/proc/self/status"` -
#'    Query \code{Cpus_allowed_list} of `/proc/self/status`.
#'
#'  \item `"cgroups.cpuset"` -
#'    On Unix, query control group (cgroup v1) value \code{cpuset.set}.
#'
#'  \item `"cgroups.cpuquota"` -
#'    On Unix, query control group (cgroup v1) value
#'    \code{cpu.cfs_quota_us} / \code{cpu.cfs_period_us}.
#'
#'  \item `"cgroups2.cpu.max"` -
#'    On Unix, query control group (cgroup v2) values \code{cpu.max}.
#'
#'  \item `"nproc"` -
#'    On Unix, query system command \code{nproc}.
#'
#'  \item `"mc.cores"` -
#'    If available, returns the value of option
#'    \code{\link[base:options]{mc.cores}}.
#'    Note that `mc.cores` is defined as the number of
#'    _additional_ \R processes that can be used in addition to the
#'    main \R process.  This means that with `mc.cores = 0` all
#'    calculations should be done in the main \R process, i.e. we have
#'    exactly one core available for our calculations.
#'    The `mc.cores` option defaults to environment variable
#'    \env{MC_CORES} (and is set accordingly when the \pkg{parallel}
#'    package is loaded).  The `mc.cores` option is used by for
#'    instance \code{\link[=mclapply]{mclapply}()} of the \pkg{parallel}
#'    package.
#'
#'  \item `"connections"` or `"connections-N"` -
#'    Query the current number of available R connections per
#'    [freeConnections()].  This is the maximum number of socket-based
#'    **parallel** cluster nodes that are possible launch, because each
#'    one needs its own R connection.
#'    The `"connections-N"` form (e.g. `connections-16`) works like
#'    `"connections"` but uses `freeConnections() - N` as the upper limit,
#'    leaving `N` connections free for other purposes.
#'    The exception is when the result is zero or less, then `1L` is
#'    still returned, because `availableCores()` should always return a
#'    positive integer.
#'
#'  \item `"BiocParallel"` -
#'    Query environment variable \env{BIOCPARALLEL_WORKER_NUMBER} (integer),
#'    which is defined and used by **BiocParallel** (>= 1.27.2).
#'    If the former is set, this is the number of cores considered.
#'
#'  \item `"_R_CHECK_LIMIT_CORES_"` -
#'    Query environment variable \env{_R_CHECK_LIMIT_CORES_} (logical or
#'    `"warn"`) used by `R CMD check` and set to true by
#'    `R CMD check --as-cran`. If set to a non-false value, then a maximum
#'    of 2 cores is considered.
#'    Note that `_R_CHECK_LIMIT_CORES_` is _not_ set when `R CMD build`
#'    builds vignettes or when `R CMD check --as-cran` re-builds then as
#'    part of the package checks.
#'
#'  \item `"Bioconductor"` -
#'    Query environment variable \env{IS_BIOC_BUILD_MACHINE} (logical)
#'    used by the Bioconductor (>= 3.16) build and check system. If set to
#'    true, then a maximum of 4 cores is considered.
#'
#'  \item `"LSF"` - 
#'    Query Platform Load Sharing Facility (LSF)/OpenLava environment variable
#'    \env{LSB_DJOB_NUMPROC}.
#'    Jobs with multiple (CPU) slots can be submitted on LSF using
#'    `bsub -n 2 -R "span[hosts=1]" < hello.sh`.
#'
#'  \item `"PJM"` - 
#'    Query Fujitsu Technical Computing Suite (that we choose to shorten
#'    as "PJM") environment variables \env{PJM_VNODE_CORE} and
#'    \env{PJM_PROC_BY_NODE}.
#'    The first is set when submitted with `pjsub -L vnode-core=8 hello.sh`.
#'
#'  \item `"PBS"` -
#'    Query TORQUE/PBS environment variables \env{PBS_NUM_PPN} and \env{NCPUS}.
#'    Depending on PBS system configuration, these _resource_
#'    parameters may or may not default to one.
#'    An example of a job submission that results in this is
#'    `qsub -l nodes=1:ppn=2`, which requests one node with two cores.
#'
#'  \item `"SGE"` -
#'    Query the "Grid Engine" scheduler environment variable \env{NSLOTS}.
#'    An example of a job submission that results in this is
#'    `qsub -pe smp 2` (or `qsub -pe by_node 2`), which
#'    requests two cores on a single machine.
#'    Known Grid Engine schedulers are
#     Sun Grid Engine (SGE; open source; acquired Gridware, Inc. in 2000),
#'    Oracle Grid Engine (OGE; acquired Sun Microsystems in 2010),
#'    Univa Grid Engine (UGE; fork of open-source SGE 6.2u5),
#'    Altair Grid Engine (AGE; acquires Univa Corporation in 2020),
#'    Son of Grid Engine (SGE aka SoGE; open-source fork of SGE 6.2u5), and
#     Open Grid Scheduler (OGS; open-source fork of SGE 6.2u5).
#'
#'  \item `"Slurm"` -
#'    Query Simple Linux Utility for Resource Management (Slurm)
#'    environment variable \env{SLURM_CPUS_PER_TASK}.
#'    This may or may not be set.  It can be set when submitting a job,
#'    e.g. `sbatch --cpus-per-task=2 hello.sh` or by adding
#'    `#SBATCH --cpus-per-task=2` to the \file{hello.sh} script.
#'    If \env{SLURM_CPUS_PER_TASK} is not set, then it will fall back to
#'    use \env{SLURM_CPUS_ON_NODE} if the job is a single-node job
#'    (\env{SLURM_JOB_NUM_NODES} is 1), e.g. `sbatch --ntasks=2 hello.sh`.
#'    To make sure all tasks are assign to a single node, specify
#'    `--nodes=1`, e.g. `sbatch --nodes=1 --ntasks=16 hello.sh`.
#'
#'  \item `"custom"` -
#'    If option
#'    \code{\link[=parallelly.options]{parallelly.availableCores.custom}}
#'    is set and a function,
#'    then this function will be called (without arguments) and it's value
#'    will be coerced to an integer, which will be interpreted as a number
#'    of available cores.  If the value is NA, then it will be ignored.
#'    It is safe for this custom function to call `availableCores()`; if
#'    done, the custom function will _not_ be recursively called.
#' }
#' For any other value of a `methods` element, the \R option with the
#' same name is queried.  If that is not set, the system environment
#' variable is queried.  If neither is set, a missing value is returned.
#'
#' @section Avoid ending up with zero cores:
#' Note that some machines might have a limited number of cores, or the R
#' process runs in a container or a cgroup that only provides a small number
#' of cores.  In such cases:
#'
#' ```r
#' ncores <- availableCores() - 1
#' ```
#'
#' may return zero, which is often not intended and is likely to give an
#' error downstream.  Instead, use:
#'
#' ```r
#' ncores <- availableCores(omit = 1)
#' ```
#'
#' to put aside one of the cores from being used.  Regardless how many cores
#' you put aside, this function is guaranteed to return at least one core.
#'
#' @section Advanced usage:
#' It is possible to override the maximum number of cores on the machine
#' as reported by `availableCores(methods = "system")`.  This can be
#' done by first specifying
#' `options(parallelly.availableCores.methods = "mc.cores")` and
#' then the number of cores to use, e.g. `options(mc.cores = 8)`.
#'
#' @examples
#' message(paste("Number of cores available:", availableCores()))
#'
#' \dontrun{
#' options(mc.cores = 2L)
#' message(paste("Number of cores available:", availableCores()))
#' }
#'
#' \dontrun{
#' ## IMPORTANT: availableCores() may return 1L
#' options(mc.cores = 1L)
#' ncores <- availableCores() - 1      ## ncores = 0
#' ncores <- availableCores(omit = 1)  ## ncores = 1
#' message(paste("Number of cores to use:", ncores))
#' }
#'
#' \dontrun{
#' ## Use 75% of the cores on the system but never more than four
#' options(parallelly.availableCores.custom = function() {
#'   ncores <- max(parallel::detectCores(), 1L, na.rm = TRUE)
#'   ncores <- min(as.integer(0.75 * ncores), 4L)
#'   max(1L, ncores)
#' })
#' message(paste("Number of cores available:", availableCores()))
#'
#' ## Use 50% of the cores according to availableCores(), e.g.
#' ## allocated by a job scheduler or cgroups.
#' ## Note that it is safe to call availableCores() here.
#' options(parallelly.availableCores.custom = function() {
#'   0.50 * parallelly::availableCores()
#' })
#' message(paste("Number of cores available:", availableCores()))
#' }
#'
#' @seealso
#' To get the set of available workers regardless of machine,
#' see [availableWorkers()].
#'
#' @importFrom parallel detectCores
#' @export
availableCores <- function(constraints = NULL, methods = getOption2("parallelly.availableCores.methods", c("system", "/proc/self/status", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc", "mc.cores", "BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "LSF", "PJM", "PBS", "SGE", "Slurm", "fallback", "custom")), na.rm = TRUE, logical = getOption2("parallelly.availableCores.logical", TRUE), default = c(current = 1L), which = c("min", "max", "all"), omit = getOption2("parallelly.availableCores.omit", 0L), max = getOption2("parallelly.availableCores.max", Inf)) {
  stop_if_not(
    is.null(constraints) || is.character(constraints), !anyNA(constraints)
  )

  pattern_connections <- "^connections(|-[[:digit:]]+)$"
  idxs <- grep(pattern_connections, constraints)
  if (length(idxs) > 0) {
    methods <- unique(c(methods, constraints[idxs]))
  }

  which <- match.arg(which, choices = c("min", "max", "all"))
  stop_if_not(length(default) == 1, is.finite(default), default >= 1L)

  stop_if_not(length(omit) == 1L, is.numeric(omit),
              is.finite(omit), omit >= 0L)
  omit <- as.integer(omit)

  stop_if_not(length(max) == 1L, is.numeric(max), !is.na(max), max >= 1L)

  ncores <- rep(NA_integer_, times = length(methods))
  names(ncores) <- methods
  for (kk in seq_along(methods)) {
    method <- methods[kk]
    if (method == "Slurm") {
      ## Number of cores assigned by Slurm
      n <- availableCoresSlurm()
    } else if (method == "PBS") {
      n <- availableCoresPBS()
    } else if (method == "SGE") {
      n <- availableCoresSGE()
    } else if (method == "LSF") {
      n <- availableCoresLSF()
    } else if (method == "PJM") {
      n <- availableCoresPJM()
    } else if (method == "mc.cores") {
      ## Number of cores by option defined by 'parallel' package
      n <- getopt_int("mc.cores")
      if (!is.na(n) && n == 0) n <- 1L  ## Because options(mc.cores = 0) may be set
    } else if (method == "mc.cores+1") {
      ## Number of cores by option defined by 'parallel' package
      n <- getopt_int("mc.cores") + 1L
    } else if (grepl(pattern_connections, method)) {
      ## Number of available connections, which are needed by PSOCK clusters
      n <- freeConnections()
      if (!is.na(n)) {
        delta <- sub(pattern_connections, "\\1", method)
        if (nzchar(delta) && nzchar(omit)) {
          delta <- as.integer(delta)
          n <- max(0L, n + delta)
        }
        ## Return at least one
        if (n <= 0L) n <- 1L
      }
    } else if (method == "BiocParallel") {
      n <- getenv_int("BIOCPARALLEL_WORKER_NUMBER")
    } else if (method == "_R_CHECK_LIMIT_CORES_") {
      ## A flag set by R CMD check for constraining number of
      ## cores allowed to be use in package tests.  Here we
      ## acknowledge this and sets number of cores to the
      ## maximum two allowed.  This way we don't have to explicitly
      ## use options(mc.cores = 2L) in example code, which may be
      ## misleading to the reader.
      chk <- tolower(Sys.getenv("_R_CHECK_LIMIT_CORES_", ""))
      chk <- (nzchar(chk) && (chk != "false"))
      n <- if (chk) 2L else NA_integer_
    } else if (method == "Bioconductor") {
      n <- NA_integer_
      ## Bioconductor (>= 3.16)
      use <- Sys.getenv("IS_BIOC_BUILD_MACHINE", NA_character_)
      if (isTRUE(as.logical(use))) n <- min(n, 4L, na.rm = TRUE)
      ## Legacy: Bioconductor (<= 3.15)
      if (is.na(n)) {
        use <- Sys.getenv("BBS_HOME", NA_character_)
        if (isTRUE(as.logical(use))) n <- min(n, 4L, na.rm = TRUE)
      }
    } else if (method == "system") {
      ## Number of cores available according to parallel::detectCores()
      n <- detectCores(logical = logical)
    } else if (method == "/proc/self/status") {
      pathname <- "/proc/self/status"
      if (file_test("-f", pathname)) {
        bfr <- readLines(pathname, warn = FALSE)
        bfr <- grep("^Cpus_allowed_list:", bfr, value = TRUE)
        if (length(bfr) == 1) {
          bfr <- sub("^Cpus_allowed_list:\t", "", bfr)
          if (nzchar(bfr)) {
            bfr <- slurm_expand_nodelist(sprintf("[%s]", bfr))
            n <- length(bfr)
          }
        }
      }
    } else if (method == "cgroups.cpuset") {
      ## Number of cores according to Unix cgroups v1 CPU set
      n <- length(getCGroups1CpuSet())
      if (n == 0L) n <- NA_integer_
    } else if (method == "cgroups.cpuquota") {
      ## Number of cores according to Unix cgroups v1 CPU quota
      n <- getCGroups1CpuQuota()
      if (is.na(n)) {
        n <- NA_integer_
      } else {
        n <- as.integer(floor(n + 0.5))
	if (n == 0L) n <- 1L  ## If CPU quota < 0.5, round up to one CPU
      }
    } else if (method == "cgroups2.cpu.max") {
      ## Number of cores according to Unix cgroups v2 CPU max quota
      n <- getCGroups2CpuMax()
      if (is.na(n)) {
        n <- NA_integer_
      } else {
        n <- as.integer(floor(n + 0.5))
	if (n == 0L) n <- 1L  ## If CPU max quota < 0.5, round up to one CPU
      }
    } else if (method == "nproc") {
      ## Number of cores according to Unix 'nproc'
      n <- getNproc()
    } else if (method == "fallback") {
      ## Number of cores available according to parallelly.availableCores.fallback
      n <- getOption2("parallelly.availableCores.fallback", NA_integer_)
      n <- as.integer(n)
    } else if (method == "custom") {
      fcn <- getOption2("parallelly.availableCores.custom", NULL)
      if (!is.function(fcn)) next
      n <- local({
        ## Avoid calling the custom function recursively
        oopts <- options(parallelly.availableCores.custom = NULL)
        on.exit(options(oopts))
        fcn()
      })
      if (length(n) != 1L) {
        stop("Function specified by option 'parallelly.availableCores.custom' does not a single value")
      }
      n <- as.integer(n)
    } else {
      ## covr: skip=3
      ## Fall back to querying option and system environment variable
      ## with the given name
      n <- getopt_int(method)
      if (is.na(n)) n <- getenv_int(method)
    }
    ncores[kk] <- n
  } ## for (kk in seq_along(methods))

  ## Validate settings
  ncoresT <- ncores[!is.na(ncores)]
  ncoresT <- ncoresT[ncoresT <= 0]
  if (length(ncoresT) > 0) {
    msg <- sprintf("Detected invalid (zero or less) core settings: %s",
         paste(paste0(sQuote(names(ncoresT)), " = ", ncoresT), collapse = ", "))
    stop(msg)
  }

  ## Drop missing values?
  if (na.rm) {
    ncores <- ncores[!is.na(ncores)]
  }

  ## Fall back to the default?
  if (length(ncores) == 0) ncores <- default

  ## Keep only one
  if (length(ncores) >= 2 && (which %in% c("min", "max"))) {
    ## SPECIAL: The 'fallback' should only be used as a fallback if no other
    ## options are explicitly set / available.
    idx_fallback <- which(names(ncores) == "fallback")
    if (length(idx_fallback) == 1) {
      ## Use 'fallback' if and only there are only "special" options specified
      special <- c("system", "/proc/self/status", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc")
      ## 'connections' and 'connections-N' are also "special" options
      special <- c(special, grep(pattern_connections, constraints, value = TRUE))
      others <- setdiff(names(ncores), c("fallback", special))
      use_fallback <- (length(others) == 0L)

      ## ... and all the "special" options agree. If one of them disagree,
      ## it's likely that cgroups limits the CPUs
      if (use_fallback && any(ncores[special] < ncores["system"], na.rm = TRUE)) {
        use_fallback <- FALSE
      }
      
      if (use_fallback) {
        ncores <- ncores[idx_fallback]
      } else {
        ncores <- ncores[-idx_fallback]
      }
    }
    
    if (which == "min") {
      ## which.min() to preserve name
      ncores <- ncores[which.min(ncores)]
    } else if (which == "max") {
      ## which.max() to preserve name
      ncores <- ncores[which.max(ncores)]
    }
  }

  if (length(constraints) > 0L) {
    if ("multicore" %in% constraints) {
      ## SPECIAL: On some OSes such as Windows, multicore processing
      ## is not supported.  If so, we should override all values to
      ## to reflect that only a single core is available
      if (!supportsMulticore()) ncores[] <- 1L
    }
  }

  ## Override the minimum of one (1) core?
  min <- getOption2("parallelly.availableCores.min", 1L)
  if (length(min) != 1L || !is.numeric(min)) {
    stop(sprintf("Option %s is not numeric: %s", sQuote("parallelly.availableCores.min"), mode(min)))
  } else if (!is.finite(min) || min < 1L) {
    stop(sprintf("Option %s must be an integer greater than one: %d", sQuote("parallelly.availableCores.min"), min))
  } else if (min > detectCores(logical = logical)) {
    stop(sprintf("Option %s must not be greater than the number cores on the system: %d > %d", sQuote("parallelly.availableCores.min"), min, detectCores(logical = logical)))
  } else {
    idxs <- which(ncores < min)
    ncores[idxs] <- as.integer(floor(min))
    names(ncores)[idxs] <- paste(names(ncores)[idxs], "*", sep = "")
  }

  ## Omit some of the cores?
  if (omit > 0L) {
    ncores <- ncores - omit
    ncores[ncores < 1L] <- 1L
  }

  ## Upper limit?
  if (is.finite(max)) {
    ncores <- min(max, ncores, na.rm = TRUE)
    ncores <- as.integer(ncores)
  }

  ## Sanity check
  stop_if_not(all(ncores >= 1L, na.rm = TRUE))

  ncores
} # availableCores()


getNproc <- local({
  res <- NULL
  
  function(ignore = c("OMP_NUM_THREADS", "OMP_THREAD_LIMIT")) {
    if (!is.null(res)) return(res)
    
    ## 'nproc' is limited by 'OMP_NUM_THREADS' and 'OMP_THREAD_LIMIT', if set.
    ## However, that is not what we want for availableCores().  Because of
    ## this, we unset those while querying 'nproc'.
    if (length(ignore) > 0) {
      ignore <- intersect(ignore, names(Sys.getenv()))
      if (length(ignore) > 0) {
        oignore <- Sys.getenv(ignore, names = TRUE)
        oignore <- as.list(oignore)
        on.exit(do.call(Sys.setenv, args = oignore), add = TRUE)
        Sys.unsetenv(ignore)
      }
    }
    
    systems <- list(linux = "nproc 2>/dev/null")
    os <- names(systems)
    m <- pmatch(os, table = R.version$os, nomatch = NA_integer_)
    m <- os[!is.na(m)]
    if (length(m) == 0L) {
      res <<- NA_integer_
      return(res)
    }
  
    for (cmd in systems[[m]]) {
      tryCatch({
        value <- suppressWarnings(system(cmd, intern=TRUE))
        value <- gsub("(^[[:space:]]+|[[:space:]]+$)", "", value[1])
        if (grepl("^[[:digit:]]+$", value)) {
          res <<- as.integer(value)
          return(res)
        }
      }, error = identity)
    }
    
    res <<- NA_integer_
    
    res
  }
})


checkNumberOfLocalWorkers <- function(workers) {
  if (inherits(workers, "AsIs")) return()
  
  limits <- getOption("parallelly.maxWorkers.localhost", c(1.0, 3.0))
  if (length(limits) == 0) return()

  ## FIXME: Temporarily, ignore _R_CHECK_LIMIT_CORES_ limits
  ## This will give a few packages time to be fixed. /HB 2024-02-09
  ignore <- c("_R_CHECK_LIMIT_CORES_")
  ignore <- getOption("parallelly.maxWorkers.localhost.ignore", ignore)
  if (length(ignore) > 0) {
    methods <- eval(formals(availableCores)$methods)
    methods <- setdiff(methods, ignore)
    ncores <- availableCores(methods = methods)
  } else {
    ncores <- availableCores()
  }
  reason <- names(ncores)
  if (is.null(reason)) reason <- "N/A"
  
  rho <- workers / ncores

  if (length(limits) >= 2) {
    ## Produce an error?
    if (rho > limits[2]) {
      msg <- sprintf("Attempting to set up %d localhost parallel workers with only %d CPU cores available for this R process (per %s), which could result in a %.0f%% load", workers, ncores, sQuote(reason), 100 * workers / ncores)
      msg <- sprintf("%s. The hard limit is set to %.0f%%", msg, 100 * limits[2])
      msg <- sprintf("%s. Overusing the CPUs has negative impact on the current R process, but also on all other processes of yours and others running on the same machine", msg)
      msg <- sprintf("%s. See help(\"parallelly.maxWorkers.localhost\", package = \"parallelly\") for further explanations and how to override the hard limit that triggered this error", msg)
      stop(msg)
    }
  }
  
  ## Warn?
  if (rho > limits[1]) {
    msg <- sprintf("Careful, you are setting up %d localhost parallel workers with only %d CPU cores available for this R process (per %s), which could result in a %.0f%% load", workers, ncores, sQuote(reason), 100 * workers / ncores)
    msg <- sprintf("%s. The soft limit is set to %.0f%%", msg, 100 * limits[1])
    msg <- sprintf("%s. Overusing the CPUs has negative impact on the current R process, but also on all other processes of yours and others running on the same machine", msg)
    msg <- sprintf("%s. See help(\"parallelly.maxWorkers.localhost\", package = \"parallelly\") for further explanations and how to override the soft limit that triggered this warning", msg)
    warning(msg)
  }
} ## checkNumberOfLocalWorkers()

  
# --------------------------------------------------------------------------
# Utility functions
# --------------------------------------------------------------------------
getenv_int <- function(name, mode = "integer") {
  value <- trim(getEnvVar2(name, default = NA_character_))
  storage.mode(value) <- mode
  value
} # getenv_int()

getopt_int <- function(name, mode = "integer") {
  value <- getOption2(name, default = NA_integer_)
  storage.mode(value) <- mode
  value
} # getopt_int()


# --------------------------------------------------------------------------
# High-Performance Compute (HPC) Schedulers
# --------------------------------------------------------------------------
## Number of slots assigned by LSF
availableCoresLSF <- local({
  n <- NULL
  function() {
    if (!is.null(n)) return(n)
    n <<- getenv_int("LSB_DJOB_NUMPROC")
    n
  }
})


## Number of cores assigned by TORQUE/PBS
availableCoresPBS <- local({
  n <- NULL
  function() {
    n <<- getenv_int("PBS_NUM_PPN")
    if (is.na(n)) {
      ## PBSPro sets 'NCPUS' but not 'PBS_NUM_PPN'
      n <<- getenv_int("NCPUS")
    }
    n
  }
})


## Number of slots assigned by Fujitsu Technical Computing Suite
## We choose to call this job scheduler "PJM" based on the prefix
## it's environment variables use.
availableCoresPJM <- local({
  n <- NULL
  function() {
    ## PJM_VNODE_CORE: e.g. pjsub -L vnode-core=8
    ## "This environment variable is set only when virtual nodes
    ##  are allocated, and it is not set when nodes are allocated."
    n <<- getenv_int("PJM_VNODE_CORE")
    if (is.na(n)) {
      ## PJM_PROC_BY_NODE: e.g. pjsub -L vnode-core=8
      ## "Maximum number of processes that are generated per node by
      ##  an MPI program. However, if a single node (node=1) or virtual
      ##  node (vnode=1) is allocated and the mpi option of the pjsub
      ##  command is not specified, this environment variable is not set."
      n <<- getenv_int("PJM_PROC_BY_NODE")
    }
    n
  }
})


## Number of cores assigned by Oracle/Son/Sun/Univa Grid Engine (SGE/UGE)
availableCoresSGE <- local({
  n <- NULL
  function() {
    n <<- getenv_int("NSLOTS")
    n
  }
})


## Number of cores assigned by Slurm
availableCoresSlurm <- local({
  n <- NULL
  function() {
    ## The assumption is that the following works regardless of
    ## number of nodes requested /HB 2020-09-18
    ## Example: --cpus-per-task={n}
    n <<- getenv_int("SLURM_CPUS_PER_TASK")
    if (is.na(n)) {
      ## Example: --nodes={nnodes} (defaults to 1, short: -N {nnodes})
      ## From 'man sbatch':
      ## SLURM_JOB_NUM_NODES (and SLURM_NNODES for backwards compatibility)
      ## Total number of nodes in the job's resource allocation.
      nnodes <- getenv_int("SLURM_JOB_NUM_NODES")
      if (is.na(nnodes)) nnodes <- getenv_int("SLURM_NNODES")
      if (is.na(nnodes)) nnodes <- 1L  ## Can this happen? /HB 2020-09-18
  
      if (nnodes == 1L) {
        ## Example: --nodes=1 --ntasks={n} (short: -n {n})
        ## IMPORTANT: 'SLURM_CPUS_ON_NODE' appears to be rounded up when nodes > 1.
        ## Example 1: With --nodes=2 --cpus-per-task=3 we see SLURM_CPUS_ON_NODE=4
        ## although SLURM_CPUS_PER_TASK=3. 
        ## Example 2: With --nodes=2 --ntasks=7, we see SLURM_CPUS_ON_NODE=6,
        ## SLURM_JOB_CPUS_PER_NODE=6,2, no SLURM_CPUS_PER_TASK, and
        ## SLURM_TASKS_PER_NODE=5,2.
        ## Conclusions: We can only use 'SLURM_CPUS_ON_NODE' for nnodes = 1.
        n <<- getenv_int("SLURM_CPUS_ON_NODE")
      } else {
        ## Parse `SLURM_TASKS_PER_NODE`
        nodecounts <- getenv_int("SLURM_TASKS_PER_NODE", mode = "character")
        if (!is.na(nodecounts)) {
          ## Examples:
          ## SLURM_TASKS_PER_NODE=5,2
          ## SLURM_TASKS_PER_NODE=2(x2),1(x3)  # Source: 'man sbatch'
          n <<- slurm_expand_nodecounts(nodecounts)
          if (anyNA(n)) {
            n <<- NA_real_
            return(n)
          }
  
          ## ASSUMPTION: We assume that it is the first component on the list that
          ## corresponds to the current machine. /HB 2021-03-05
          n <<- n[1]
        }
      }
    }
  
    ## TODO?: Can we validate above assumptions/results? /HB 2020-09-18
    if (FALSE && !is.na(n)) {
      ## Is any of the following useful?
  
      ## Example: --ntasks={ntasks} (no default, short: -n {ntasks})
      ## From 'man sbatch':
      ## SLURM_NTASKS (and SLURM_NPROCS for backwards compatibility)
      ## Same as -n, --ntasks
      ntasks <- getenv_int("SLURM_NTASKS")
      if (is.na(ntasks)) ntasks <- getenv_int("SLURM_NPROCS")
    }

    n
  }
}) ## availableCoresSlurm()
