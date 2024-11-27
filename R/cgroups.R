#-------------------------------------------------------
# Utility functions with option to override for testing
#-------------------------------------------------------
procPath <- local({
  .path <- NULL
  
  function(path = NULL) {
    ## Set new path?
    if (!is.null(path)) {
      ## Reset?
      if (is.na(path)) path <- NULL
      old_path <- .path
      .path <<- path

      ## Reset caches
      environment(getCGroupsRoot)$.cache <- NULL
      environment(getCGroups)$.data <- NULL

      return(old_path)
    }

    ## Update cache?
    if (is.null(.path)) .path <<- "/proc"
    
    .path
  }
})


getUID <- local({
  .uid <- NULL
  
  function() {
    if (!is.null(.uid)) return(.uid)
    res <- system2("id", args = "-u", stdout = TRUE)
    uid <- as.integer(res)
    if (is.na(uid)) stop("id -u returned a non-integer: ", sQuote(res))
    .uid <<- uid
    uid
  }
})


#' @importFrom utils file_test tar
cloneCGroups <- function(tarfile = "cgroups.tar.gz") {
  ## Temporarily reset overrides
  old_path <- procPath(NA)
  on.exit({
    procPath(old_path)
  })

  ## Create a temporary directory
  dest <- tempfile()
  dir.create(dest)
  stopifnot(file_test("-d", dest))

  ## Record current UID
  uid <- getUID()
  file <- file.path(dest, "uid")
  cat(uid, file = file)

  ## Cgroups controller
  controller <- NA_character_
  
  ## Record /proc/self/
  src <- "/proc/self"
  path <- file.path(dest, src)
  dir.create(path, recursive = TRUE)
  files <- c("mounts", "cgroup")
  files <- files[file_test("-f", file.path(src, files))]
  for (file in files) {
    bfr <- readLines(file.path(src, file), warn = FALSE)
    if (file == "mounts") {
      bfr <- grep("^cgroup[^[:blank:]]*[[:blank:]]+", bfr, value = TRUE)
      ## Identify CGroups version
      types <- gsub("[[:blank:]].*", "", bfr)
      utypes <- unique(types)
      if (length(utypes) > 1) {
        stop("Mixed CGroups versions are not supported: ", paste(sQuote(utypes), collapse = ", "))	
      }
      if (utypes == "cgroup") {
        controller <- "cpuset"
      } else if (utypes == "cgroup2") {
        controller <- ""
      } else {
        stop("Unknown CGroups version: ", sQuote(utypes))
      }
    }
    writeLines(bfr, con = file.path(path, file))
  }


  ## Record CGroups root folder for controller of interest
  root <- getCGroupsRoot(controller = controller)
  path <- file.path(dest, root)
  dir.create(path, recursive = TRUE)
  
  cgroups <- getCGroups()
  paths <- character(0)
  for (dir in cgroups$path) {
    paths <- c(paths, dir)
    while (nzchar(dir) && dir != "/") {
      dir <- dirname(dir)
      paths <- c(paths, dir)
    }
  }
  paths <- unique(paths)

  ## Copy file structure
  for (dir in paths) {
    src <- file.path(root, dir)
    if (!file_test("-d", src)) next
    path <- file.path(dest, src)
    if (!file_test("-d", path)) dir.create(path, recursive = TRUE)
    files <- dir(path = src)
    files <- files[file_test("-f", file.path(src, files))]
    for (file in files) {
      file.copy(file.path(src, file), file.path(path, file))
    }
  }

  
  local({
    opwd <- setwd(dest)
    on.exit(setwd(opwd))
    tar(file.path(opwd, tarfile), compression = "gzip")
  })
  unlink(dest, recursive = TRUE)
  
  tarfile
}


#' @importFrom utils file_test untar
withCGroups <- function(tarball, expr = NULL, envir = parent.frame(), tmpdir = NULL) {
   stopifnot(file_test("-f", tarball))
   expr <- substitute(expr)

   name <- sub("[.]tar[.]gz$", "", basename(tarball))
   message(sprintf("CGroups for system %s ...", sQuote(name)))

   ## Create a temporary temporary directory?
   if (is.null(tmpdir)) {
       tmpdir <- tempfile()
       dir.create(tmpdir)
       on.exit(unlink(tmpdir, recursive = TRUE))
   }
   message(" - Using temporary folder: ", sQuote(tmpdir))
   
   untar(tarball, exdir = tmpdir)

   ## Read the UID
   file <- file.path(tmpdir, "uid")
   uid <- scan(file.path(tmpdir, "uid"), what = "integer", n = 1L, quiet = TRUE)
   uid <- as.integer(uid)
   message(sprintf(" - UID: %d", uid))

   ## Adjust /proc accordingly
   old_procPath <- procPath(file.path(tmpdir, "proc"))
   on.exit(procPath(old_procPath), add = TRUE)
   message(sprintf(" - procPath(): %s", sQuote(procPath())))

   ## Adjust /sys/fs/cgroup root accordingly
   message(" - Adjust /proc/self/mounts accordingly:")
   file <- file.path(tmpdir, "proc", "self", "mounts")
   bfr <- readLines(file, warn = FALSE)
   bfr <- gsub("/sys/fs/cgroup", normalizePath(file.path(tmpdir, "sys/fs/cgroup"), winslash = "/"), bfr)
   writeLines(bfr, con = file)
   bfr <- readLines(file, warn = FALSE)
   bfr <- sprintf("   %02d: %s", seq_along(bfr), bfr)
   writeLines(bfr)
   
   message(sprintf(" - getCGroupsRoot(): %s", sQuote(getCGroupsRoot())))

   message(" - getCGroups():")
   cgroups <- getCGroups()
   print(cgroups)

   message(" - getCGroupsVersion(): ", getCGroupsVersion())

   message(" - length(getCGroups1CpuSet()): ", length(getCGroups1CpuSet()))
   message(" - getCGroups1CpuQuota(): ", getCGroups1CpuQuota())
   message(" - getCGroups2CpuMax(): ", getCGroups2CpuMax())

   message(" - availableCores(which = 'all'):")
   cores <- availableCores(which = "all")
   print(cores)

   if (is.null(envir)) {
     res <- eval(expr)
   } else {
     res <- eval(expr, envir = envir)
   }
   
   message(sprintf("CGroups for system %s ... done", sQuote(name)))
   
   invisible(res)
}


#-------------------------------------------------------
# Unix control groups ("cgroups")
#-------------------------------------------------------
#  @return A character string to an existing CGroups root folder.
#  If no such folder could be found, NA_character_ is returned.
#
#' @importFrom utils file_test
getCGroupsRoot <- local({
  .cache <- list()
  
  function(controller = "") {
    stopifnot(is.character(controller), length(controller) == 1L, !is.na(controller))

    path <- .cache[[controller]]
    if (!is.null(path)) return(path)

    ## Look up the CGroups mount point, e.g.
    ## $ grep cgroup /proc/$$/mounts
    ## cgroup2 /sys/fs/cgroup cgroup2 rw,seclabel,nosuid,nodev,noexec,relatime,nsdelegate 0 0

    file <- file.path(procPath(), "self", "mounts")
    if (!file_test("-f", file)) {
      path <- NA_character_
      .cache[[controller]] <<- path
      return(path)
    }

    ## Read all mount points
    bfr <- readLines(file, warn = FALSE)
    
    ## Keep CGroups mount points
    bfr <- grep("^cgroup[^[:blank:]]*[[:blank:]]+", bfr, value = TRUE)
    if (length(bfr) == 0) {
      path <- NA_character_
      .cache[[controller]] <<- path
      return(path)
    }

    ## Identify CGroups version
    types <- gsub("[[:blank:]].*", "", bfr)
    utypes <- unique(types)
    if (length(utypes) > 1) {
      warning("Mixed CGroups versions are not supported: ", paste(sQuote(utypes), collapse = ", "))
      path <- NA_character_
      .cache[[controller]] <<- path
      return(path)
    }
    
    ## Filter by CGroups v1 or v2?
    if (nzchar(controller)) {
      bfr <- grep("^cgroup[[:blank:]]+", bfr, value = TRUE)
    } else {
      bfr <- grep("^cgroup2[[:blank:]]+", bfr, value = TRUE)
    }
    if (length(bfr) == 0) {
      path <- NA_character_
      .cache[[controller]] <<- path
      return(path)
    }

    if (length(bfr) > 1) {
      ## CGroups v1 or v2?
      if (nzchar(controller)) {
        ## CGroups v1
        pattern <- sprintf("\\b%s\\b", controller)
        bfr <- grep(pattern, bfr, value = TRUE)
        if (length(bfr) == 0) {
          stop(sprintf("Failed to identify mount point for CGroups v1 controller %s", sQuote(controller)))
        } else if (length(bfr) > 1) {
          bfr <- bfr[1]
          warning(sprintf("Detected more than one 'cgroup' mount point for CGroups v1 controller %s; using the first one",
                  sQuote(controller)))
        }
      } else {
        ## CGroups v2
        print(bfr)
        bfr <- bfr[1]
        warning("Detected more than one 'cgroup2' mount point for CGroups v2; using the first one")
      }
    }
    
    path <- sub("^cgroup[^[:blank:]]*[[:blank:]]+", "", bfr)
    path <- sub("^([^[:blank:]]+)[[:blank:]]+.*", "\\1", path)
    if (!file_test("-d", path)) {
      path <- NA_character_
    }
    
    .cache[[controller]] <<- path

    path
  }
})


#  Get the CGroups hierarchy for a specific process
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
  .data <- NULL
  
  function() {
    data <- .data
    if (!is.null(data)) return(data)

    ## Get cgroups
    file <- file.path(procPath(), "self", "cgroup")

    ## cgroups is not set?
    if (!file_test("-f", file)) {
      data <- data.frame(hierarchy_id = integer(0L), controller = character(0L), path = character(0L), stringsAsFactors = FALSE)
      .data <<- data
      return(data)
    }

    ## Parse cgroups lines <hierarchy ID>:<controller>:<path>
    bfr <- readLines(file, warn = FALSE)
    pattern <- "^([[:digit:]]+):([^:]*):(.*)"
    bfr <- grep(pattern, bfr, value = TRUE)

    ids <- as.integer(sub(pattern, "\\1", bfr))
    controllers <- sub(pattern, "\\2", bfr)
    paths <- sub(pattern, "\\3", bfr)
    data <- data.frame(hierarchy_id = ids, controller = controllers, path = paths, stringsAsFactors = FALSE)
      
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
    .data <<- data
    
    data
  }
})


#  Get the path to a specific cgroups controller
#
#  @param controller (character) A cgroups v1 set or `""` for cgroups v2.
# 
#  @return An character string to an existing cgroups folder.
#  If no folder could be found, `NA_character_` is returned.
# 
#' @importFrom utils file_test
getCGroupsPath <- function(controller) {
  root <- getCGroupsRoot(controller = controller)
  if (is.na(root)) return(NA_character_)

  data <- getCGroups()

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
    ## Should this ever happen?
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


#  Get the value of specific cgroups controller and field
#
#  @param controller (character) A cgroups v1 set, or `""` for cgroups v2.
# 
#  @param field (character) A cgroups field.
# 
#  @return An character string.
#  If the requested cgroups controller and field could not be queried,
#  NA_character_ is returned.
#
#' @importFrom utils file_test
getCGroupsValue <- function(controller, field) {
  path <- getCGroupsPath(controller = controller)
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


#  Get the value of specific cgroups v1 field
#
#  @param controller (character) A cgroups v1 set.
#
#  @param field (character) A cgroups v1 field.
# 
#  @return An character string. If the requested cgroups v1 field could not be
#  queried, NA_character_ is returned.
#
getCGroups1Value <- function(controller, field) {
  getCGroupsValue(controller, field = field)
}


#  Get the value of specific cgroups v2 field
#
#  @param field (character) A cgroups v2 field.
# 
#  @return An character string. If the requested cgroups v2 field could not be
#  queried, NA_character_ is returned.
getCGroups2Value <- function(field) {
  getCGroupsValue("", field = field)
}


#  Get cgroups version
#
#  @return
#  If the current process is under cgroups v1, then `1L` is returned.
#  If it is under cgroups v2, then `2L` is returned.
#  If not under cgroups control, then `-1L` is returned.
#
getCGroupsVersion <- function() {
  cgroups <- getCGroups()
  if (nrow(cgroups) == 0) return(-1L)
  if (nrow(cgroups) == 1 && cgroups$controller == "") return(2L)
  1L
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
  max_cores <- parallel::detectCores(logical = TRUE)
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
getCGroups1CpuQuotaMicroseconds <- function() {
  value <- suppressWarnings({
    ## e.g. /sys/fs/cgroup/cpu/cpu.cfs_quota_us
    as.integer(getCGroups1Value("cpu", "cpu.cfs_quota_us"))
  })

  value
}


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
getCGroups2CpuMax <- function() {
  ## TEMPORARY: In case the cgroups options causes problems, make
  ## it possible to override their values via hidden options
  quota <- get_package_option("cgroups2.cpu.max", NULL)
  
  if (!is.null(quota)) return(quota)

  raw <- suppressWarnings({
    ## e.g. /sys/fs/cgroup/cpu.max
    getCGroups2Value("cpu.max")
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
