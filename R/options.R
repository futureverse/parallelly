#' Options Used by the 'parallelly' Package
#'
#' Below are the \R options and environment variables that are used by the
#' \pkg{parallelly} package and packages enhancing it.\cr
#' \cr
#' _WARNING: Note that the names and the default values of these options may
#'  change in future versions of the package.  Please use with care until
#'  further notice._
#'
#' @section Backward compatibility with the \pkg{future} package:
#'
#' The functions in the \pkg{parallelly} package originates from the
#' \pkg{future} package.  Because they are widely used within the future
#' ecosystem, we need to keep them backward compatible for quite a long time,
#' in order for all existing packages and R scripts to have time to adjust.
#' This also goes for the \R options and the environment variables used to
#' configure these functions.
#' All options and environment variables used here have prefixes `parallelly.`
#' and `R_PARALLELLY_`, respectively.  Because of the backward compatibility
#' with the \pkg{future} package, the same settings can also be controlled
#' by options and environment variables with prefixes `future.` and
#' `R_FUTURE_` until further notice, e.g. setting option
#' `future.availableCores.fallback=1` is the same as setting option
#' `parallelly.availableCores.fallback=1`, and setting environment
#' variable \env{R_FUTURE_AVAILABLECORES_FALLBACK=1} is the same as setting
#' \env{R_PARALLELLY_AVAILABLECORES_FALLBACK=1}.
#'
#'
#' @section Configuring number of parallel workers:
#'
#' The below \R options and environment variables control the default results of [availableCores()] and [availableWorkers()].
#'
#' \describe{
#'  \item{`parallelly.availableCores.logical`:}{(logical) The default value of argument `logical` as used by `availableCores()`, `availableWorkers()`, and `availableCores()` for querying `parallel::detectCores(logical = logical)`.  The default is `TRUE` just like it is for [parallel::detectCores()].}
#'
#'  \item{`parallelly.availableCores.methods`:}{(character vector) Default lookup methods for [availableCores()]. (Default: `c("system", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc", "mc.cores", "BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "LSF", "PJM", "PBS", "SGE", "Slurm", "fallback", "custom")`)}
#'
#'  \item{`parallelly.availableCores.custom`:}{(function) If set and a function, then this function will be called (without arguments) by [availableCores()] where its value, coerced to an integer, is interpreted as a number of cores.}
#'
#'  \item{`parallelly.availableCores.fallback`:}{(integer) Number of cores to use when no core-specifying settings are detected other than `"system"` and `"nproc"`.  This options makes it possible to set the default number of cores returned by `availableCores()` / `availableWorkers()` yet allow users and schedulers to override it.  In multi-tenant environment, such as HPC clusters, it is useful to set environment variable \env{R_PARALLELLY_AVAILABLECORES_FALLBACK} to `1`, which will set this option when the package is loaded.}
#' 
#'  \item{`parallelly.availableCores.system`:}{(integer) Number of "system" cores used instead of what is reported by \code{\link{availableCores}(which = "system")}. This option allows you to effectively override what `parallel::detectCores()` reports the system has.}
#'
#'  \item{`parallelly.availableCores.min`:}{(integer) The minimum number of cores [availableCores()] is allowed to return. This can be used to force multiple cores on a single-core environment. If this is limit is applied, the names of the returned value are appended with an asterisk (`*`).  (Default: `1L`)}
#'
#'  \item{`parallelly.availableCores.omit`:}{(integer) Number of cores to set aside, i.e. not to include.}
#'
#'  \item{`parallelly.availableWorkers.methods`:}{(character vector) Default lookup methods for [availableWorkers()]. (Default: `c("mc.cores", "BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "LSF", "PJM", "PBS", "SGE", "Slurm", "custom", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc", "system", "fallback")`)}
#'
#'  \item{`parallelly.availableWorkers.custom`:}{(function) If set and a function, then this function will be called (without arguments) by [availableWorkers()] where its value, coerced to a character vector, is interpreted as hostnames of available workers.}
#' }
#'
#'
#' @section Configuring forked parallel processing:
#'
#' The below \R options and environment variables control the default result of [supportsMulticore()].
#'
#' \describe{
#'  \item{`parallelly.fork.enable`:}{(logical) Enable or disable _forked_ processing.  If `FALSE`, multicore futures becomes sequential futures.  If `NA`, or not set (the default), the a set of best-practices rules decide whether should be supported or not.}
#'
#'  \item{`parallelly.supportsMulticore.disableOn`:}{(character vector)
#"    Controls in what environments multicore processing should be disabled,
#'    because the environment in which R runs is considered unstable for
#'    forked processing.
#'    If this vector contains `"rstudio_console"`, it is disabled when
#'    running R in the RStudio Console.
#'    If this vector contains `"rstudio_terminal"`, it is disabled when
#'    running R in the RStudio Terminal.
#'    (Default: `c("rstudio_console", "rstudio_terminal")`)
#'  }
#'
#'  \item{`parallelly.supportsMulticore.unstable`:}{(character) Controls whether a warning should be produced or not whenever multicore processing is automatically disabled per settings in option `parallelly.supportsMulticore.disableOn`.  If `"warn"` (default), then an informative warning is produces the first time 'multicore' futures are used.  If `"quiet"`, no warning is produced.}
#' }
#'
#'
#' @section Configuring setup of parallel PSOCK clusters:
#'
#' The below \R options and environment variables control the default results of [makeClusterPSOCK()] and its helper function [makeNodePSOCK()] that creates the individual cluster nodes.
#'
#' \describe{
#'  \item{`parallelly.maxWorkers.localhost`:}{(two numerics) Maximum number of localhost workers, relative to `availableCores()`, accepted and allowed. The first element specifies the "soft" limit, which triggers a warning, if exceeded. The second element specifies the "hard" limit, which triggers an error if exceeded. These limits exist to protect against CPU overuse of the current machine, which sometimes happens by mistake without the user causing it being aware. These limits can be disabled by setting them to `+Inf` (not recommended). If only the first exist, no error is produced (defaults to `c(1.0, 3.0)` corresponding to a maximum 100% and 300% use).}
#'  
#'  \item{`parallelly.makeNodePSOCK.setup_strategy`:}{(character) If `"parallel"` (default), the PSOCK cluster nodes are set up concurrently.  If `"sequential"`, they are set up sequentially.}
#'
#'  \item{`parallelly.makeNodePSOCK.validate`:}{(logical) If TRUE (default), after the nodes have been created, they are all validated that they work by inquiring about their session information, which is saved in attribute `session_info` of each node.}
#'
#'  \item{`parallelly.makeNodePSOCK.connectTimeout`:}{(numeric) The maximum time (in seconds) allowed for each socket connection between the master and a worker to be established (defaults to 2*60 seconds = 2 minutes).}
#'
#'  \item{`parallelly.makeNodePSOCK.timeout`:}{(numeric) The maximum time (in seconds) allowed to pass without the master and a worker communicate with each other (defaults to 30*24*60*60 seconds = 30 days).}
#'
#'  \item{`parallelly.makeNodePSOCK.useXDR`:}{(logical) If FALSE (default), the communication between master and workers, which is binary, will use small-endian (faster), otherwise big-endian ("XDR"; slower).}
#'
#'  \item{`parallelly.makeNodePSOCK.socketOptions`:}{(character string) If set to another value than `"NULL"`, then option `socketOptions` is set to this value on the workers during startup. See [base::socketConnection()] for details. (defaults to `"no-delay"`)}
#'
#'  \item{`parallelly.makeNodePSOCK.rshcmd`:}{(character vector) The command to be run on the master to launch a process on another host.}
#'
#'  \item{`parallelly.makeNodePSOCK.rshopts`:}{(character vector) Addition command-line options appended to `rshcmd`.  These arguments are only applied when connecting to non-localhost machines.}
#'
#'  \item{`parallelly.makeNodePSOCK.tries`:}{(integer) The maximum number of attempts done to launch each node.  Only used when setting up cluster nodes using the sequential strategy.}
#'
#'  \item{`parallelly.makeNodePSOCK.tries.delay`:}{(numeric) The number of seconds to wait before trying to launch a cluster node that failed to launch previously.  Only used when setting up cluster nodes using the sequential strategy.}
#' }
#'
#'
#' @section Options for debugging:
#'
#' \describe{
#'  \item{`parallelly.debug`:}{(logical) If `TRUE`, extensive debug messages are generated. (Default: `FALSE`)}
#' }
#'
#'
#' @section Environment variables that set R options:
#' All of the above \R `parallelly.*` options can be set by
#' corresponding environment variables \env{R_PARALLELLY_*} _when the
#' \pkg{parallelly} package is loaded_.
#' For example, if `R_PARALLELLY_MAKENODEPSOCK_SETUP_STRATEGY="sequential"`,
#' then option `parallelly.makeNodePSOCK.setup_strategy` is set to
#' `"sequential"` (character).
#' Similarly, if `R_PARALLELLY_AVAILABLECORES_FALLBACK="1"`, then option
#' `parallelly.availableCores.fallback` is set to `1` (integer).
#'
#'
#' @examples
#' # Set an R option:
#' options(parallelly.availableCores.fallback = 1L)
#' 
#'
#' @seealso
#' To set \R options when \R starts (even before the \pkg{parallelly} package is loaded), see the \link[base]{Startup} help page.  The \href{https://cran.r-project.org/package=startup}{\pkg{startup}} package provides a friendly mechanism for configuring \R's startup process.
#'
#' @aliases
#' parallelly.options 
#' parallelly.debug

#' parallelly.availableCores.custom
#' parallelly.availableCores.methods
#' parallelly.availableCores.min
#' parallelly.availableCores.fallback
#' parallelly.availableCores.omit
#' parallelly.availableCores.system
#' parallelly.availableWorkers.methods
#' parallelly.availableWorkers.custom
#' parallelly.fork.enable
#' parallelly.maxWorkers.localhost
#' parallelly.supportsMulticore.disableOn
#' parallelly.supportsMulticore.unstable
#' R_PARALLELLY_AVAILABLECORES_FALLBACK
#' R_PARALLELLY_AVAILABLECORES_OMIT
#' R_PARALLELLY_AVAILABLECORES_SYSTEM
#' R_PARALLELLY_AVAILABLECORES_MIN
#' R_PARALLELLY_FORK_ENABLE
#' R_PARALLELLY_SUPPORTSMULTICORE_DISABLEON
#' R_PARALLELLY_SUPPORTSMULTICORE_UNSTABLE
#'
#' future.availableCores.custom
#' future.availableCores.methods
#' future.availableCores.fallback
#' future.availableCores.system
#' future.availableWorkers.methods
#' future.availableWorkers.custom
#' future.fork.enable
#' future.supportsMulticore.unstable
#' R_FUTURE_AVAILABLECORES_FALLBACK
#' R_FUTURE_AVAILABLECORES_SYSTEM
#' R_FUTURE_FORK_ENABLE
#' R_FUTURE_SUPPORTSMULTICORE_UNSTABLE
#'
#' parallelly.makeNodePSOCK.setup_strategy
#' parallelly.makeNodePSOCK.validate
#' parallelly.makeNodePSOCK.connectTimeout
#' parallelly.makeNodePSOCK.timeout
#' parallelly.makeNodePSOCK.useXDR
#' parallelly.makeNodePSOCK.socketOptions
#' parallelly.makeNodePSOCK.rshcmd
#' parallelly.makeNodePSOCK.rshopts
#' parallelly.makeNodePSOCK.tries
#' parallelly.makeNodePSOCK.tries.delay
#' R_PARALLELLY_MAKENODEPSOCK_SETUP_STRATEGY
#' R_PARALLELLY_MAKENODEPSOCK_VALIDATE
#' R_PARALLELLY_MAKENODEPSOCK_CONNECTTIMEOUT
#' R_PARALLELLY_MAKENODEPSOCK_TIMEOUT
#' R_PARALLELLY_MAKENODEPSOCK_USEXDR
#' R_PARALLELLY_MAKENODEPSOCK_SOCKETOPTIONS
#' R_PARALLELLY_MAKENODEPSOCK_RSHCMD
#' R_PARALLELLY_MAKENODEPSOCK_RSHOPTS
#' R_PARALLELLY_MAKENODEPSOCK_TRIES
#' R_PARALLELLY_MAKENODEPSOCK_TRIES_DELAY
#'
## Internal options and environment variables _not_ documented here:
## parallelly.localhost.hostname
## parallelly.makeNodePSOCK.master.localhost.hostname
## parallelly.makeNodePSOCK.rscript_label
## parallelly.makeNodePSOCK.sessionInfo.pkgs
## parallelly.makeNodePSOCK.autoKill
## parallelly.makeNodePSOCK.port.increment
## parallelly.makeNodePSOCK.tries.port
## R_PARALLELLY_LOCALHOST_HOSTNAME
## R_PARALLELLY_MAKENODEPSOCK_MASTER_LOCALHOST_HOSTNAME
## R_PARALLELLY_MAKENODEPSOCK_RSCRIPT_LABEL
## R_PARALLELLY_MAKENODEPSOCK_SESSIONINFO_PKGS
## R_PARALLELLY_MAKENODEPSOCK_AUTOKILL
## R_PARALLELLY_MAKENODEPSOCK_PORT_INCREMENT
## R_PARALLELLY_MAKENODEPSOCK_TRIES_PORT
#'
#' @name zzz-parallelly.options
NULL


get_package_option <- function(name, default = NULL, package = .packageName) {
  if (!is.null(package)) {
    name <- paste(package, name, sep = ".")
  }
  getOption2(name, default = default)
}

# Set an R option from an environment variable
update_package_option <- function(name, mode = "character", default = NULL, package = .packageName, split = NULL, trim = TRUE, disallow = c("NA"), force = FALSE, debug = FALSE) {
  if (debug) {
    mdebugf_push("update_package_option('%s', ...) ...", name)
    on.exit(mdebugf_pop("update_package_option('%s', ...) ... done", name))
  }
  
  if (!is.null(package)) {
    name <- paste(package, name, sep = ".")
  }
  
  if (debug) mdebugf("Set package option %s", sQuote(name))

  ## Already set? Nothing to do?
  value <- getOption2(name, NULL)
  if (!force && !is.null(value)) {
    if (debug) mdebugf("Already set: %s", sQuote(value))
    return(value)
  }

  ## name="Pkg.foo.Bar" => env="R_PKG_FOO_BAR"
  env <- gsub(".", "_", toupper(name), fixed = TRUE)
  env <- paste("R_", env, sep = "")

  env_value <- value <- getEnvVar2(env, default = NA_character_)
  if (is.na(value)) {  
    if (debug) mdebugf("Environment variable %s not set", sQuote(env))
    
    ## Nothing more to do?
    if (is.null(default)) return(getOption2(name))

    if (debug) mdebugf("Use argument 'default': ", sQuote(default))
    value <- default
  }

  if (debug) mdebugf("%s=%s", env, sQuote(value))

  ## Trim?
  if (trim) value <- trim(value)

  ## Nothing to do?
  if (!nzchar(value)) return(getOption2(name, default = default))

  ## Split?
  if (!is.null(split)) {
    value <- strsplit(value, split = split, fixed = TRUE)
    value <- unlist(value, use.names = FALSE)
    if (trim) value <- trim(value)
  }

  ## Coerce?
  mode0 <- storage.mode(value)
  if (mode0 != mode) {
    suppressWarnings({
      storage.mode(value) <- mode
    })
    if (debug) {
      mdebugf("Coercing from %s to %s: %s", mode0, mode, commaq(value))
    }
  }

  if (length(disallow) > 0) {
    if ("NA" %in% disallow) {
      if (anyNA(value)) {
        stopf("Coercing environment variable %s=%s to %s would result in missing values for option %s: %s", sQuote(env), sQuote(env_value), sQuote(mode), sQuote(name), commaq(value))
      }
    }
    if (is.numeric(value)) {
      if ("non-positive" %in% disallow) {
        if (any(value <= 0, na.rm = TRUE)) {
          stopf("Environment variable %s=%s specifies a non-positive value for option %s: %s", sQuote(env), sQuote(env_value), sQuote(name), commaq(value))
        }
      }
      if ("negative" %in% disallow) {
        if (any(value < 0, na.rm = TRUE)) {
          stopf("Environment variable %s=%s specifies a negative value for option %s: %s", sQuote(env), sQuote(env_value), sQuote(name), commaq(value))
        }
      }
    }
  }
  
  if (debug) {
    mdebugf("=> options(%s = %s) [n=%d, mode=%s]",
            dQuote(name), commaq(value),
            length(value), storage.mode(value))
  }

  do.call(options, args = structure(list(value), names = name))
  
  getOption2(name, default = default)
}


## Set package options based on environment variables
update_package_options <- function(debug = FALSE) {
  if (debug) {
    mdebug_push("update_package_options() ...")
    on.exit(mdebug_pop("update_package_options() ... done"))
  }

  update_package_option("availableCores.methods", mode = "character", split = ",", debug = debug)
  update_package_option("availableCores.fallback", mode = "integer", disallow = NULL, debug = debug)
  update_package_option("availableCores.min", mode = "integer", disallow = "NA", debug = debug)
  update_package_option("availableCores.system", mode = "integer", disallow = NULL, debug = debug)
  update_package_option("availableCores.logical", mode = "logical", debug = debug)
  update_package_option("availableCores.omit", mode = "integer", debug = debug)

  update_package_option("availableWorkers.methods", mode = "character", split = ",", debug = debug)

  update_package_option("maxWorkers.localhost", mode = "double", split = ",", debug = debug)
  update_package_option("maxWorkers.localhost.ignore", mode = "character", split = ",", debug = debug)

  update_package_option("fork.enable", mode = "logical", debug = debug)

  update_package_option("supportsMulticore.disableOn", mode = "character", split = ",", debug = debug)
  update_package_option("supportsMulticore.unstable", mode = "character", debug = debug)

  update_package_option("makeNodePSOCK.setup_strategy", mode = "character", debug = debug)
  update_package_option("makeNodePSOCK.validate", mode = "logical", debug = debug)
  update_package_option("makeNodePSOCK.connectTimeout", mode = "numeric", debug = debug)
  update_package_option("makeNodePSOCK.timeout", mode = "numeric", debug = debug)
  update_package_option("makeNodePSOCK.useXDR", mode = "logical", debug = debug)
  update_package_option("makeNodePSOCK.socketOptions", mode = "character", debug = debug)
  update_package_option("makeNodePSOCK.rshcmd", mode = "character", split = ",", debug = debug)
  update_package_option("makeNodePSOCK.rshopts", mode = "character", split = ",", debug = debug)
  update_package_option("makeNodePSOCK.tries", mode = "integer", debug = debug)
  update_package_option("makeNodePSOCK.tries.delay", mode = "numeric", debug = debug)
  update_package_option("makeNodePSOCK.rscript_label", mode = "character", debug = debug)
  update_package_option("makeNodePSOCK.sessionInfo.pkgs", mode = "character", split = ",", debug = debug)
  update_package_option("makeNodePSOCK.autoKill", mode = "logical", debug = debug)
  update_package_option("makeNodePSOCK.master.localhost.hostname", mode = "character", debug = debug)
  update_package_option("makeNodePSOCK.port.increment", mode = "logical", debug = debug)
}
