#-------------------------------------------------------
# Unix control groups ("cgroups")
#-------------------------------------------------------
#  @return An character string to an existing cgroups root folder.
#  If no such folder could be found, NA_character_ is returned.
# 
#' @importFrom utils file_test
getCGroupsRoot <- local({
  .cache <- NULL
  
  function() {
    path <- .cache
    if (!is.null(path)) return(path)
    
    path <- "/sys/fs/cgroup"
    if (!file_test("-d", path)) path <- NA_character_
    .cache <<- path

    path
  }
})


#  @return An named character vector of zero or more cgroups parameters.
#  If cgroups is not used, character(0L).
# 
#' @importFrom utils file_test
getCGroups <- local({
  .cache <- NULL
  
  function() {
    if (is.null(.cache)) {
      ## Has cgroups?
      file <- file.path("/proc", Sys.getpid(), "cgroup")
      if (!file_test("-f", file)) {
        .cache <<- character(0L)
        return(.cache)
      }

      ## Parse cgroups
      bfr <- readLines(file, warn = FALSE)
      pattern <- "^([[:digit:]]+):([^:]*):(.*)"
      bfr <- grep(pattern, bfr, value = TRUE)

      idxs <- as.integer(sub(pattern, "\\1", bfr))
      names <- sub(pattern, "\\2", bfr)
      values <- sub(pattern, "\\3", bfr)
      names(values) <- names
      values <- values[order(idxs)]

      ## Split multi-name entries into separate entries,
      ## e.g. 'cpuacct,cpu' -> 'cpuacct' and 'cpu'
      idxs <- grep(",", names)
      if (length(idxs) > 0) {
        values2 <- character(0L)
        for (idx in idxs) {
          name <- names[idx]
          names2 <- strsplit(name, split = ",", fixed = TRUE)[[1]]
          for (name2 in names2) {
	    values2[name2] <- values[[name]]
	  }
        }
        values <- c(values, values2)
      }
      
      .cache <<- values
    }

    .cache
  }
})


# Check whether system has CGroups v2
#
# [1] https://unix.stackexchange.com/a/668244
#
#' @importFrom utils file_test
hasCGroups2 <- local({
  res <- NULL
  
  function() {
    if (!is.null(res)) return(res)

    root <- getCGroupsRoot()
    if (is.na(root)) {
      res <<- NA
      return(res)
    }

    ## e.g. /sys/fs/cgroup/cgroup.controllers
    pathname <- file.path(root, "cgroup.controllers")
    res <<- file_test("-f", pathname)

    res
  }
})


#  @param name A cgroups set.
# 
#  @return An character string to an existing cgroup folder. If no folder
#  could be found, NA_character_ is returned.
# 
#' @importFrom utils file_test
getCGroupsPath <- local({
  .cache <- list()
  
  function(name) {
    path <- .cache[[name]]
    if (!is.null(path)) return(path)
    
    root <- getCGroupsRoot()
    if (is.na(root)) {
      path <- NA_character_
      .cache[[name]] <- path
      return(path)
    }

    root <- file.path(root, name)
    if (!file_test("-d", root)) {
      path <- NA_character_
      .cache[[name]] <- path
      return(path)
    }
    
    set <- getCGroups()[name]
    if (is.na(set)) {
      path <- NA_character_
      .cache[[name]] <- path
      return(path)
    }
  
    path <- file.path(root, set)
    while (set != "/") {
      if (file_test("-d", path)) {
        break
      }
      set_prev <- set
      set <- dirname(set)
      if (set == set_prev) break
      path <- file.path(root, set)
    }
  
    ## Should the following ever happen?
    if (!file_test("-d", path)) {
      path <- NA_character_
      .cache[[name]] <- path
      return(path)
    }
    
    path <- normalizePath(path, mustWork = FALSE)
    .cache[[name]] <- path
    
    path
  }
})

#  @param name A cgroups set.
# 
#  @param field A cgroups field.
# 
#  @return An character string. If the requested cgroups field could not be
#  queried, NA_character_ is returned.
#
#' @importFrom utils file_test
getCGroupsValue <- local({
  .cache <- list()
  
  function(name, field) {
    ## Note, set <- .cache[[name]][[field]] only works in R (>= 4.0.0)
    if (field %in% names(.cache[[name]])) return(.cache[[name]][[field]])
    
    path <- getCGroupsPath(name)
    if (is.na(path)) {
      .cache[[name]][[field]] <<- NA_character_
      return(NA_character_)
    }
    file <- file.path(path, field)
    if (!file_test("-f", file)) {
      .cache[[name]][[field]] <<- NA_character_
      return(NA_character_)
    }
    
    value <- readLines(file, warn = FALSE)
    if (length(value) == 0L) value <- NA_character_
    .cache[[name]][[field]] <<- value
    
    value
  }
})


#  @param field A cgroups v2 field.
# 
#  @return An character string. If the requested cgroups v2 field could not be
#  queried, NA_character_ is returned.
#
#' @importFrom utils file_test
getCGroups2Value <- local({
  .cache <- list()
  
  function(field) {
    if (field %in% names(.cache)) return(.cache[[field]])
    
    root <- getCGroupsRoot()
    if (is.na(root)) {
      .cache[[field]] <<- NA_character_
      return(NA_character_)
    }
    file <- file.path(root, field)
    if (!file_test("-f", file)) {
      .cache[[field]] <<- NA_character_
      return(NA_character_)
    }
    
    value <- readLines(file, warn = FALSE)
    if (length(value) == 0L) value <- NA_character_
    .cache[[field]] <<- value
    
    value
  }
})


#  @return An integer vector of CPU indices. If cgroups field `cpuset.cpus`
#  could not be queried, integer(0) is returned.
#
#  From 'CPUSETS' [1]:
#
#  cpuset.cpus: list of CPUs in that cpuset
#
#  [1] https://www.kernel.org/doc/Documentation/cgroup-v1/cpusets.txt
#
#' @importFrom utils file_test
getCGroupsCpuSet <- local({
  max_cores <- NULL
  cpuset <- NULL
  
  function() {
    ## TEMPORARY: In case the cgroups options causes problems, make
    ## it possible to override their values via hidden options
    cpuset <<- get_package_option("cgroups.cpuset", cpuset)

    if (!is.null(cpuset)) return(cpuset)

    ## e.g. /sys/fs/cgroup/cpuset/cpuset.cpus
    value0 <- getCGroupsValue("cpuset", "cpuset.cpus")
    if (is.na(value0)) {
      cpuset <<- integer(0L)
      return(cpuset)
    }
    
    ## Parse 0-63; 0-7,9; 0-7,10-12; etc.
    code <- gsub("-", ":", value0, fixed = TRUE)
    code <- sprintf("c(%s)", code)
    expr <- tryCatch({
      parse(text = code)
    }, error = function(ex) {
      warning(sprintf("Syntax error parsing %s: %s", sQuote(file), sQuote(value0)))
      integer(0L)
    })

    value <- tryCatch({
      suppressWarnings(as.integer(eval(expr)))
    }, error = function(ex) {
      warning(sprintf("Failed to parse %s: %s", sQuote(file), sQuote(value0)))
      integer(0L)
    })

    ## Sanity checks
    if (is.null(max_cores)) max_cores <<- parallel::detectCores(logical = TRUE)
    if (any(value < 0L | value >= max_cores)) {
      warning(sprintf("[INTERNAL]: Will ignore the cgroups CPU set, because it contains one or more CPU indices that is out of range [0,%d]: %s", max_cores - 1L, value0))
      value <- integer(0L)
    }

    if (any(duplicated(value))) {
      warning(sprintf("[INTERNAL]: Detected and dropped duplicated CPU indices in the cgroups CPU set: %s", value0))
      value <- unique(value)
    }

    cpuset <<- value
    
    ## Should never happen, but just in case
    stop_if_not(length(cpuset) <= max_cores)

    cpuset
  }
})


#
#  From 'CPUSETS' [1]:
# 
# * `cpu.cfs_period_us`: The duration in microseconds of each scheduler
#     period, for bandwidth decisions. This defaults to 100000us or
#     100ms. Larger periods will improve throughput at the expense of
#     latency, since the scheduler will be able to sustain a cpu-bound
#     workload for longer. The opposite of true for smaller
#     periods. Note that this only affects non-RT tasks that are
#     scheduled by the CFS scheduler.
# 
# * `cpu.cfs_quota_us`: The maximum time in microseconds during each
#     `cfs_period_us` in for the current group will be allowed to
#     run. For instance, if it is set to half of `cpu_period_us`, the
#     cgroup will only be able to peak run for 50% of the time. One
#     should note that this represents aggregate time over all CPUs in
#     the system. Therefore, in order to allow full usage of two CPUs,
#     for instance, one should set this value to twice the value of
#     `cfs_period_us`.
#
#  [1] https://www.kernel.org/doc/Documentation/cgroup-v1/cpusets.txt
#
#' @importFrom utils file_test
getCGroupsCpuQuotaMicroseconds <- local({
  value <- NULL
  
  function() {
    if (!is.null(value)) return(value)
    
    value <<- suppressWarnings({
      ## e.g. /sys/fs/cgroup/cpu/cpu.cfs_quota_us
      as.integer(getCGroupsValue("cpu", "cpu.cfs_quota_us"))
    })

    value
  }
})


#' @importFrom utils file_test
getCGroupsCpuPeriodMicroseconds <- local({
  value <- NULL
  
  function() {
    if (!is.null(value)) return(value)
    
    value <<- suppressWarnings({
      ## e.g. /sys/fs/cgroup/cpu/cpu.cfs_period_us
      as.integer(getCGroupsValue("cpu", "cpu.cfs_period_us"))
    })

    value
  }
})


#  @return A non-negative numeric.
#  If cgroups is not in use, or could not be queried, NA_real_ is returned.
#
#' @importFrom utils file_test
getCGroupsCpuQuota <- local({
  max_cores <- NULL
  quota <- NULL
  
  function() {
    ## TEMPORARY: In case the cgroups options causes problems, make
    ## it possible to override their values via hidden options
    quota <<- get_package_option("cgroups.cpuquota", quota)
    
    if (!is.null(quota)) return(quota)

    ms <- getCGroupsCpuQuotaMicroseconds()
    if (!is.na(ms) && ms < 0) ms <- NA_integer_
    
    total <- getCGroupsCpuPeriodMicroseconds()
    if (!is.na(total) && total < 0) total <- NA_integer_
    
    value <- ms / total

    if (!is.na(value)) {
      if (is.null(max_cores)) max_cores <<- parallel::detectCores(logical = TRUE)
      if (!is.finite(value) || value <= 0.0 || value > max_cores) {
        warning(sprintf("[INTERNAL]: Will ignore the cgroups CPU quota, because it is out of range [1,%d]: %s", max_cores, value))
        value <- NA_real_
      }
    }

    quota <<- value
    
    quota
  }
})


#  @return A non-negative numeric.
#  If cgroups is not in use, or could not be queried, NA_real_ is returned.
#
#  From 'Control Group v2' documentation [1]:
#
#  `cpu.max`:
#   A read-write two value file which exists on non-root cgroups.
#   The default is "max 100000".
#
#   The maximum bandwidth limit.  It's in the following format::
#
#     $MAX $PERIOD
#
#   which indicates that the group may consume upto $MAX in each
#   $PERIOD duration.  `"max"` for $MAX indicates no limit.  If only
#   one number is written, $MAX is updated.
#
#  [1] https://docs.kernel.org/admin-guide/cgroup-v2.html
#
#' @importFrom utils file_test
getCGroups2CpuMax <- local({
  max_cores <- NULL
  quota <- NULL
  
  function() {
    ## TEMPORARY: In case the cgroups options causes problems, make
    ## it possible to override their values via hidden options
    quota <<- get_package_option("cgroups2.cpu.max", quota)
    
    if (!is.null(quota)) return(quota)

    raw <- suppressWarnings({
      ## e.g. /sys/fs/cgroup/cpu.max
      getCGroups2Value("cpu.max")
    })

    if (is.na(raw)) {
      quota <<- NA_real_
      return(quota)
    }
    
    values <- strsplit(raw, split = "[[:space:]]+")[[1]]
    if (length(values) != 2L) {
      quota <<- NA_real_
      return(quota)
    }

    period <- as.integer(values[2])
    if (is.na(period) && period <= 0L) {
      quota <<- NA_real_
      return(quota)
    }
    
    max <- values[1]
    if (max == "max") {
      quota <<- NA_real_
      return(quota)
    }
    
    max <- as.integer(max)
    value <- max / period
    if (!is.na(value)) {
      if (is.null(max_cores)) max_cores <<- parallel::detectCores(logical = TRUE)
      if (!is.finite(value) || value <= 0.0 || value > max_cores) {
        warning(sprintf("[INTERNAL]: Will ignore the cgroups CPU quota, because it is out of range [1,%d]: %s", max_cores, value))
        value <- NA_real_
      }
    }

    quota <<- value
    
    quota
  }
})
