.packageExclude <- c("MPI", "PSOCK")

## covr: skip=all
.onLoad <- function(libname, pkgname) {
  debug <- isTRUE(as.logical(getEnvVar2("R_PARALLELLY_DEBUG", "FALSE")))
  if (debug) options(parallelly.debug = TRUE)
  debug <- getOption2("parallelly.debug", debug)

  ## Automatically play nice when 'R CMD check' runs?
  if (isTRUE(as.logical(getEnvVar2("R_PARALLELLY_R_CMD_CHECK_NICE", "TRUE"))) && inRCmdCheck()) {
    if (debug) mdebug("Detected 'R CMD check':\n - adjusting defaults to be a good citizen")
    ## To be nicer to test environments (e.g. CRAN, Travis CI and AppVeyor CI),
    ## timeout much earlier than the default 30 days. This will also give a more
    ## informative error message produced by R itself, rather than whatever the
    ## test environment produces.
    ## NOTE: By using environment variables, instead of R options, we can make
    ## sure these settings are also passed down to child processes, including
    ## nested ones.
    Sys.setenv(R_PARALLELLY_MAKENODEPSOCK_CONNECTTIMEOUT = 2 * 60)
    Sys.setenv(R_PARALLELLY_MAKENODEPSOCK_TIMEOUT = 2 * 60)
    
    ## Collect more session details from workers to helps troubleshooting on
    ## remote servers, e.g. CRAN servers
    Sys.setenv(R_PARALLELLY_MAKENODEPSOCK_SESSIONINFO_PKGS = TRUE)

    ## Automatically kill stray cluster workers, if possible
    Sys.setenv(R_PARALLELLY_MAKENODEPSOCK_AUTOKILL = TRUE)

    ## Label cluster workers, if possible
    Sys.setenv(R_PARALLELLY_MAKENODEPSOCK_RSCRIPT_LABEL = TRUE)

    ## Lower the risk for port clashes by using a large pool of random ports.
    ## The default 11000:11999 tend to fail occassionally on CRAN but also
    ## locally.
    if (!nzchar(Sys.getenv("R_PARALLELLY_RANDOM_PORTS", ""))) {
      Sys.setenv(R_PARALLELLY_RANDOM_PORTS = "20000:39999")
    }

    ## Not all CRAN servers have _R_CHECK_LIMIT_CORES_ set [REF?]. Setting it
    ## to 'TRUE' when unset, will better emulate CRAN submission checks.
    if (!nzchar(Sys.getenv("_R_CHECK_LIMIT_CORES_", ""))) {
      ## Possible values: 'TRUE' 'false', 'warn', 'error'
      Sys.setenv("_R_CHECK_LIMIT_CORES_" = "TRUE")
    }
  }

  ## Set package options based on environment variables
  update_package_options(debug = debug)

  ## If neeeded, work around bug in R preventing us from using the 'parallel'
  ## setup strategy of PSOCK cluster nodes
  parallelly_disable_parallel_setup_if_needed()

  if (debug) {
    envs <- Sys.getenv()
    pattern <- sprintf("^R_(FUTURE|%s)_", toupper(.packageName))
    envs <- envs[grep(pattern, names(envs))]
    envs <- sprintf("- %s=%s", names(envs), sQuote(envs))
    mdebug(paste(c("parallelly-specific environment variables:", envs), collapse = "\n"))
  }

  registerClusterTypes()

  ## R CMD build
  register_vignette_engine_during_build_only(pkgname)
}


#' @useDynLib "parallelly", .registration = TRUE, .fixes = "C_"
.onUnload <- function(libpath) {
  library.dynam.unload(.packageName, libpath)
}
