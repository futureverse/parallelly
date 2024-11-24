source("incl/start.R")

#file <- system.file(package = "parallelly", "test-data", "cgroups.tar.gz", mustWork = TRUE)
#td <- tempdir()
#res <- untar(file, exdir = td)
#stopifnot(res == 0)
td <- system.file(package = "parallelly", "test-data", mustWork = TRUE)
hosts <- dir(path = file.path(td, "cgroups"), full.names = TRUE)

message("*** cgroups ...")

message("- getCGroups()")
cgroups <- parallelly:::getCGroups()
print(cgroups)
stopifnot(
  is.data.frame(cgroups),
  identical(colnames(cgroups), c("hierarchy_id", "controller", "path")),
  nrow(cgroups) == 0L || !is.null(cgroups$controller)
)

message("- getCGroupsRoot()")
root <- parallelly:::getCGroupsRoot()
cat(sprintf("cgroups root path: %s\n", sQuote(root)))
stopifnot(length(root) == 1L, is.character(root))

message("- getCGroups()")
cgroups <- parallelly:::getCGroups()
print(cgroups)
stopifnot(is.data.frame(cgroups))

message("- getCGroupsPath()")
path <- parallelly:::getCGroupsPath("cpu")
cat(sprintf("cgroups 'cpu' path: %s\n", sQuote(path)))
stopifnot(length(path) == 1L, is.character(path))

path <- parallelly:::getCGroupsPath("cpuset")
cat(sprintf("cgroups 'cpuset' path: %s\n", sQuote(path)))
stopifnot(length(path) == 1L, is.character(path))


message("- getCGroups1Value()")
value <- parallelly:::getCGroups1Value("cpu", "cpu.cfs_quota_us")
cat(sprintf("cgroups v1 'cpu.cfs_quota_us' value: %s\n", sQuote(value)))
stopifnot(length(value) == 1L, is.character(value))

value <- parallelly:::getCGroups1Value("cpu", "cpu.cfs_total_us")
cat(sprintf("cgroups v1 'cpu.cfs_total_us' value: %s\n", sQuote(value)))
stopifnot(length(value) == 1L, is.character(value))

value <- parallelly:::getCGroups1Value("cpuset", "cpuset.cpus")
cat(sprintf("cgroups v1 'cpuset.cpus' value: %s\n", sQuote(value)))
stopifnot(length(value) == 1L, is.character(value))


message("- getCGroups1CpuSet()")
value <- parallelly:::getCGroups1CpuSet()
cat(sprintf("CPU set: [n=%d] %s\n", length(value), paste(sQuote(value), collapse = ", ")))
stopifnot(length(value) >= 0L, is.integer(value), !any(is.na(value)))


message("- getCGroups1CpuQuotaMicroseconds()")
value <- parallelly:::getCGroups1CpuQuotaMicroseconds()
cat(sprintf("CPU quota (ms): %d\n", value))
stopifnot(
  length(value) == 1L,
  is.integer(value),
  is.na(value) || value == -1 || value > 0
)

message("- getCGroups1CpuPeriodMicroseconds()")
value <- parallelly:::getCGroups1CpuPeriodMicroseconds()
cat(sprintf("CPU total (ms): %d\n", value))
stopifnot(
  length(value) == 1L,
  is.integer(value),
  is.na(value) || value > 0
)

message("- getCGroups1CpuQuota()")
value <- parallelly:::getCGroups1CpuQuota()
cat(sprintf("CPU quota (ratio): %g\n", value))
stopifnot(
  length(value) == 1L,
  is.numeric(value),
  !is.infinite(value),
  is.na(value) || value > 0
)

message("- getCGroups2CpuMax()")
value <- parallelly:::getCGroups2CpuMax()
cat(sprintf("CPU quota (ratio): %g\n", value))
stopifnot(
  length(value) == 1L,
  is.numeric(value),
  !is.infinite(value),
  is.na(value) || value > 0
)

message("*** cgroups ... DONE")

unlink(td, recursive = TRUE)

source("incl/end.R")
