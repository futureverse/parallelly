## Kubernetes pod with a CPU limit of 2.0 set at the pod level,
## with the container's own CGroup is unrestricted ("max")
value <- parallelly:::getCGroups2CpuMax()
print(value)
stopifnot(identical(value, 2.0))

ncores <- parallelly::availableCores(which = "all")
print(ncores)

stopifnot(
  "cgroups2.cpu.max" %in% names(ncores),
  ncores[["cgroups2.cpu.max"]] == 2L
)
