ncores <- parallelly::availableCores(which = "all")
print(ncores)

## Drop 'cgroups2.cpuset.cpus.effective'
ncores <- ncores[setdiff(names(ncores), "cgroups2.cpuset.cpus.effective")]
print(ncores)

stopifnot(
  !any(grepl("^cgroups", names(ncores)))
)
