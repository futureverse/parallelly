ncores <- parallelly::availableCores(which = "all")
print(ncores)

stopifnot(
  !grepl("^cgroups", names(ncores))
)
