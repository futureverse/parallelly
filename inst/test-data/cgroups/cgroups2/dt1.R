ncores <- parallelly::availableCores(which = "all")
print(ncores)

stopifnot(
  "cgroups2.cpu.max" %in% names(ncores),
  ncores[["cgroups2.cpu.max"]] == 2L
)
