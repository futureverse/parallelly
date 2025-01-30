source("incl/start.R")

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

root <- system.file(package = "parallelly", "test-data", mustWork = TRUE)
for (dir in c("no-cgroups", "mixed-cgroups", "cgroups1", "cgroups2")) {
  message(sprintf("%s - real-world ...", dir))
  path <- file.path(root, dir)
  stopifnot(file_test("-d", path))
  tarballs <- dir(path = path, pattern = ".*[.]tar[.]gz", full.names = TRUE)
  names(tarballs) <- sub("[.]tar[.]gz$", "", basename(tarballs))

  for (name in names(tarballs)) {
    parallelly:::withCGroups(tarballs[name], {
        file <- file.path(path, sprintf("%s.R", name))
        if (file_test("-f", file)) {
          source(file, local = FALSE)
        }
    })
  }
  message(sprintf("%s - real-world ... done", dir))
}

message("cgroups - real-world ... DONE")

source("incl/end.R")
