ncores <- parallelly::availableCores(which = "all")
print(ncores)

stopifnot(
  !any(grepl("^cgroups", names(ncores)))
)
