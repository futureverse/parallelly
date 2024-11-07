#-------------------------------------------------------
# Unix control groups ("cgroups")
#-------------------------------------------------------
#  @param pid (integer) The ID of an existing process.
#
#  @return A character string to an existing CGroups root folder.
#  If no such folder could be found, NA_character_ is returned.
#
#' @importFrom utils file_test
getCGroupsRoot <- local({
  .cache <- list()
  
  function(pid = Sys.getpid()) {
    stopifnot(is.integer(pid), length(pid) == 1L, pid > 0L)
    pid_str <- as.character(pid)

    path <- .cache[[pid_str]]
    if (!is.null(path)) return(path)

    ## FIXME: Look up the CGroups mount point, e.g.
    ## $ grep cgroup /proc/$$/mounts
    ## cgroup2 /sys/fs/cgroup cgroup2 rw,seclabel,nosuid,nodev,noexec,relatime,nsdelegate 0 0

    file <- file.path("/proc", pid, "mounts")
    if (!file_test("-f", file)) {
      path <- NA_character_
      .cache[[pid_str]] <- path
      return(path)
    }

    bfr <- readLines(file, warn = FALSE)
    bfr <- grep("^cgroup[^[:blank:]]*[[:blank:]]+", bfr, value = TRUE)
    if (length(bfr) == 0) {
      path <- NA_character_
      .cache[[pid_str]] <- path
      return(path)
    }

    if (length(bfr) > 1) {
      bfr <- bfr[1]
      warning("Detected more than one 'cgroup' mount point; using the first one")
    }

    path <- sub("^cgroup[^[:blank:]]*[[:blank:]]+", "", bfr)
    path <- sub("^([^[:blank:]]+)[[:blank:]]+.*", "\\1", path)
    if (!file_test("-d", path)) path <- NA_character_
    
    .cache[[pid_str]] <<- path

    path
  }
})


#  Get the CGroups hierarchy for a specific process
#
#  @param pid (integer) The ID of an existing process.
#
#  @return A data frame with three columns:
#  * `hierarchy_id` (integer): 0 for cgroups v2.
#  * `controller` (string): The controller name for cgroups v1,
#    but empty for cgroups v2.
#  * `path` (string): The path to the CGroup in the hierarchy
#    that the process is part of.
#  If cgroups is not used, the an empty data.frame is returned.
# 
#' @importFrom utils file_test
getCGroups <- local({
  .cache <- list()
  
  function(pid = Sys.getpid()) {
    stopifnot(is.integer(pid), length(pid) == 1L, pid > 0L)
    pid_str <- as.character(pid)

    data <- .cache[[pid_str]]
    if (!is.null(data)) return(data)

    ## Get cgroups
    file <- file.path("/proc", pid, "cgroup")

    ## cgroups is not set?
    if (!file_test("-f", file)) {
      data <- data.frame(hierarchy_id = integer(0L), controller = character(0L), path = character(0L))
      .cache[[pid_str]] <- data
      return(data)
    }

    ## Parse cgroups lines <hierarchy ID>:<controller>:<path>
    bfr <- readLines(file, warn = FALSE)
    pattern <- "^([[:digit:]]+):([^:]*):(.*)"
    bfr <- grep(pattern, bfr, value = TRUE)

    ids <- as.integer(sub(pattern, "\\1", bfr))
    controllers <- sub(pattern, "\\2", bfr)
    paths <- sub(pattern, "\\3", bfr)
    data <- data.frame(hierarchy_id = ids, controller = controllers, path = paths)
      
    ## Split multi-name entries into separate entries,
    ## e.g. 'cpuacct,cpu' -> 'cpuacct' and 'cpu'
    rows <- grep(",", data$controller)
    if (length(rows) > 0) {
      for (row in rows) {
        name <- data$controller[row]
        names <- strsplit(name, split = ",", fixed = TRUE)[[1]]
        data[row, "controller"] <- names[1]
        data2 <- data[row, ]
        for (name in names[-1]) {
          data2$controller <- name
          data <- rbind(data, data2)
        }
      }
    }
    
    ## Order by hierarchy ID
    data <- data[order(data$hierarchy_id), ]
    .cache[[pid_str]] <<- data
    
    data
  }
})


#  Get the path to a specific cgroups controller
#
#  @param controller (character) A cgroups v1 set or `""` for cgroups v2.
# 
#  @param pid (integer) The ID of an existing process.
#
#  @return An character string to an existing cgroups folder.
#  If no folder could be found, `NA_character_` is returned.
# 
#' @importFrom utils file_test
getCGroupsPath <- function(controller, pid = Sys.getpid()) {
  root <- getCGroupsRoot(pid = pid)
  if (is.na(root)) return(NA_character_)

  data <- getCGroups(pid = pid)

  set <- data[data$controller == controller, ]
  if (nrow(set) == 0L) {
    return(NA_character_)
  }

  set <- set$path
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
    return(NA_character_)
  }
  
  path <- normalizePath(path, mustWork = FALSE)
  
  path
}


#  Get all cgroups fields for a specific controller
#
#  @param controller (character) A cgroups v1 set or `""` for cgroups v2.
# 
#  @param pid (integer) The ID of an existing process.
#
#  @return An character vector of cgroups fields.
#  If no folder could be found, a`NA_character_` is returned.
getCGroupsFields <- function(controller, pid = Sys.getpid()) {
  path <- getCGroupsPath(controller = controller, pid = pid)
  if (is.na(path)) return(character(0L))
  dir(path = path)
}


getCGroups1Fields <- function(controller, pid = Sys.getpid()) {
  getCGroupsFields(controller = controller, pid = pid)
}

getCGroups2Fields <- function(pid = Sys.getpid()) {
  getCGroupsFields(controller = "", pid = pid)
}


#  Get the value of specific cgroups controller and field
#
#  @param controller (character) A cgroups v1 set, or `""` for cgroups v2.
# 
#  @param field (character) A cgroups field.
# 
#  @param pid (integer) The ID of an existing process.
#
#  @return An character string.
#  If the requested cgroups controller and field could not be queried,
#  NA_character_ is returned.
#
#' @importFrom utils file_test
getCGroupsValue <- function(controller, field, pid = Sys.getpid()) {
  path <- getCGroupsPath(controller, pid = pid)
  if (is.na(path)) return(NA_character_)

  file <- file.path(path, field)
  if (!file_test("-f", file)) return(NA_character_)
  
  value <- readLines(file, warn = FALSE)
  if (length(value) == 0L) value <- NA_character_
  
  value
}


#  Get the value of specific cgroups v1 field
#
#  @param controller (character) A cgroups v1 set.
#
#  @param field (character) A cgroups v1 field.
# 
#  @param pid (integer) The ID of an existing process.
#
#  @return An character string. If the requested cgroups v1 field could not be
#  queried, NA_character_ is returned.
getCGroups1Value <- function(controller, field, pid = Sys.getpid()) {
  stop_if_not(
    length(controller) == 1L,
    is.character(controller),
    !is.na(controller),
    nzchar(controller)
  )
  getCGroupsValue(controller = controller, field = field, pid = pid)
}


#  Get the value of specific cgroups v2 field
#
#  @param field (character) A cgroups v2 field.
# 
#  @param pid (integer) The ID of an existing process.
#
#  @return An character string. If the requested cgroups v2 field could not be
#  queried, NA_character_ is returned.
getCGroups2Value <- function(field, pid = Sys.getpid()) {
  path <- getCGroupsPath("", pid = pid)
  if (is.na(path)) return(NA_character_)

  path_prev <- ""
  while (path != path_prev) {
    file <- file.path(path, field)
    if (file_test("-f", file)) {
      value <- readLines(file, warn = FALSE)
      if (length(value) == 0L) value <- NA_character_
      attr(value, "path") <- path
      return(value)
    }
    path_prev <- path
    path <- dirname(path)
  }
  
  NA_character_
}


#  Get cgroups version
#
#  @param pid (integer) The ID of an existing process.
#
#  @return
#  If the current process is under cgroups v1, then `1L` is returned.
#  If it is under cgroups v2, then `2L` is returned.
#  If not under cgroups control, then `-1L` is returned.
getCGroupsVersion <- function(pid = Sys.getpid()) {
  cgroups <- getCGroups(pid = pid)
  if (nrow(cgroups) == 0) return(-1L)
  if (nzchar(cgroups$controller)) return(1L)
  2L
}



# --------------------------------------------------------------------------
# CGroups v1 CPU settings
# --------------------------------------------------------------------------
#  Get cgroups v1 'cpuset.cpus'
#
#  @return An integer vector of CPU indices. If cgroups v1 field
#  `cpuset.cpus` could not be queried, integer(0) is returned.
#
#  From 'CPUSETS' [1]:
#
#  cpuset.cpus: list of CPUs in that cpuset
#
#  [1] https://www.kernel.org/doc/Documentation/cgroup-v1/cpusets.txt
#
#' @importFrom utils file_test
getCGroups1CpuSet <- function() {
  ## TEMPORARY: In case the cgroups options causes problems, make
  ## it possible to override their values via hidden options
  cpuset <- get_package_option("cgroups.cpuset", NULL)

  if (!is.null(cpuset)) return(cpuset)

  ## e.g. /sys/fs/cgroup/cpuset/cpuset.cpus
  value0 <- getCGroups1Value("cpuset", "cpuset.cpus")
  if (is.na(value0)) {
    return(integer(0L))
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
  if (is.null(max_cores)) max_cores <- parallel::detectCores(logical = TRUE)
  if (any(value < 0L | value >= max_cores)) {
    warning(sprintf("[INTERNAL]: Will ignore the cgroups CPU set, because it contains one or more CPU indices that is out of range [0,%d]: %s", max_cores - 1L, value0))
    value <- integer(0L)
  }

  if (any(duplicated(value))) {
    warning(sprintf("[INTERNAL]: Detected and dropped duplicated CPU indices in the cgroups CPU set: %s", value0))
    value <- unique(value)
  }

  cpuset <- value
  
  ## Should never happen, but just in case
  stop_if_not(length(cpuset) <= max_cores)

  cpuset
}


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
getCGroups1CpuQuotaMicroseconds <- function(pid = Sys.getpid()) {
  value <- suppressWarnings({
    ## e.g. /sys/fs/cgroup/cpu/cpu.cfs_quota_us
    as.integer(getCGroups1Value("cpu", "cpu.cfs_quota_us"))
  })

  value
}


#' @importFrom utils file_test
getCGroups1CpuPeriodMicroseconds <- function() {
  value <- suppressWarnings({
    ## e.g. /sys/fs/cgroup/cpu/cpu.cfs_period_us
    as.integer(getCGroups1Value("cpu", "cpu.cfs_period_us"))
  })

  value
}


#  @return A non-negative numeric.
#  If cgroups is not in use, or could not be queried, NA_real_ is returned.
#
#' @importFrom utils file_test
getCGroups1CpuQuota <- function() {
  ## TEMPORARY: In case the cgroups options causes problems, make
  ## it possible to override their values via hidden options
  quota <- get_package_option("cgroups.cpuquota", NULL)
  
  if (!is.null(quota)) return(quota)

  ms <- getCGroups1CpuQuotaMicroseconds()
  if (!is.na(ms) && ms < 0) ms <- NA_integer_
  
  total <- getCGroups1CpuPeriodMicroseconds()
  if (!is.na(total) && total < 0) total <- NA_integer_
  
  value <- ms / total

  if (!is.na(value)) {
    if (is.null(max_cores)) max_cores <- parallel::detectCores(logical = TRUE)
    if (!is.finite(value) || value <= 0.0 || value > max_cores) {
      warning(sprintf("[INTERNAL]: Will ignore the cgroups CPU quota, because it is out of range [1,%d]: %s", max_cores, value))
      value <- NA_real_
    }
  }

  quota <- value
  
  quota
}


# --------------------------------------------------------------------------
# CGroups v2 CPU settings
# --------------------------------------------------------------------------
#  @return A non-negative numeric.
#  If cgroups is not in use, or could not be queried, NA_real_ is returned.
#
#  From 'Control Group v2' documentation [1]:
#
#  `cpu.max`:
#   A read-write two value file which exists on non-root cgroups.
#   The default is "max 100000".
#
#   The maximum bandwidth limit.  It's in the following format:
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
getCGroups2CpuMax <- function(pid = Sys.getpid()) {
  ## TEMPORARY: In case the cgroups options causes problems, make
  ## it possible to override their values via hidden options
  quota <- get_package_option("cgroups2.cpu.max", NULL)
  
  if (!is.null(quota)) return(quota)

  raw <- suppressWarnings({
    ## e.g. /sys/fs/cgroup/cpu.max
    getCGroups2Value("cpu.max", pid = pid)
  })

  if (is.na(raw)) {
    return(NA_real_)
  }
  
  values <- strsplit(raw, split = "[[:space:]]+")[[1]]
  if (length(values) != 2L) {
    return(NA_real_)
  }

  period <- as.integer(values[2])
  if (is.na(period) && period <= 0L) {
    return(NA_real_)
  }
  
  max <- values[1]
  if (max == "max") {
    return(NA_real_)
  }
  
  max <- as.integer(max)
  value <- max / period
  if (!is.na(value)) {
    max_cores <- parallel::detectCores(logical = TRUE)
    if (!is.finite(value) || value <= 0.0 || value > max_cores) {
      warning(sprintf("[INTERNAL]: Will ignore the cgroups v2 CPU quota, because it is out of range [1,%d]: %s", max_cores, value))
      value <- NA_real_
    }
  }

  quota <- value
  
  quota
}
