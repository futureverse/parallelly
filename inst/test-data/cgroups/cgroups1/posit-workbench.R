ncores <- parallelly::availableCores(which = "all")
print(ncores)

stopifnot(
  "cgroups.cpuset" %in% names(ncores),
  ncores[["cgroups.cpuset"]] == 32L,
  ncores[["cgroups.cpuquota"]] == 2L
)
