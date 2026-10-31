## Kubernetes pod with a CPU limit of 2 set at the pod level, while the
## container's own cgroup is unrestricted (-1). The CPU quota of an
## ancestor cgroup must be respected
value <- parallelly:::getCGroups1CpuQuota()
print(value)
stopifnot(identical(value, 2.0))

ncores <- parallelly::availableCores(which = "all")
print(ncores)

stopifnot(
  "cgroups.cpuquota" %in% names(ncores),
  ncores[["cgroups.cpuquota"]] == 2L,
  "cgroups.cpuset" %in% names(ncores),
  ncores[["cgroups.cpuset"]] == 16L
)
