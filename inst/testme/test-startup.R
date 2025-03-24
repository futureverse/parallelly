library(parallelly)

pkgname <- "parallelly"
.onLoad <- parallelly:::.onLoad

maxCores <- min(2L, availableCores(methods = "system"))


message("*** .onLoad() ...")

message("- .onLoad() w/ parallelly.availableCores.system = 1L ...")
options(parallelly.availableCores.system = 1L)
.onLoad(pkgname, pkgname)
options(parallelly.availableCores.system = NULL)
message("- .onLoad() w/ parallelly.availableCores.system = 1L ... DONE")

message("- .onLoad() w/ R_PARALLELLY_AVAILABLECORES_SYSTEM ...")
Sys.setenv(R_PARALLELLY_AVAILABLECORES_SYSTEM = "1")
.onLoad(pkgname, pkgname)
ncores <- getOption("parallelly.availableCores.system")
print(ncores)
stopifnot(is.integer(ncores), ncores == 1L)
Sys.unsetenv("R_PARALLELLY_AVAILABLECORES_SYSTEM")
options(parallelly.availableCores.system = NULL)

Sys.setenv(R_PARALLELLY_AVAILABLECORES_SYSTEM = "NA")
.onLoad(pkgname, pkgname)
ncores <- getOption("parallelly.availableCores.system")
print(ncores)
stopifnot(is.integer(ncores), is.na(ncores))
Sys.unsetenv("R_PARALLELLY_AVAILABLECORES_SYSTEM")
options(parallelly.availableCores.system = NULL)

Sys.setenv(R_PARALLELLY_AVAILABLECORES_SYSTEM = "NA_real_")
.onLoad(pkgname, pkgname)
ncores <- getOption("parallelly.availableCores.system")
print(ncores)
stopifnot(is.integer(ncores), is.na(ncores))
Sys.unsetenv("R_PARALLELLY_AVAILABLECORES_SYSTEM")
options(parallelly.availableCores.system = NULL)

message("- .onLoad() w/ R_PARALLELLY_AVAILABLECORES_SYSTEM ... DONE")


message("- .onLoad() w/ parallelly.availableCores.fallback = 1L ...")
options(parallelly.availableCores.fallback = 1L)
.onLoad(pkgname, pkgname)
options(parallelly.availableCores.fallback = NULL)
message("- .onLoad() w/ parallelly.availableCores.fallback = 1L ... DONE")

message("- .onLoad() w/ R_PARALLELLY_AVAILABLECORES_FALLBACK ...")
Sys.setenv(R_PARALLELLY_AVAILABLECORES_FALLBACK = "1")
.onLoad(pkgname, pkgname)
ncores <- getOption("parallelly.availableCores.fallback")
print(ncores)
stopifnot(is.integer(ncores), ncores == 1L)
Sys.unsetenv("R_PARALLELLY_AVAILABLECORES_FALLBACK")
options(parallelly.availableCores.fallback = NULL)

Sys.setenv(R_PARALLELLY_AVAILABLECORES_FALLBACK = "NA")
.onLoad(pkgname, pkgname)
ncores <- getOption("parallelly.availableCores.fallback")
print(ncores)
stopifnot(is.integer(ncores), is.na(ncores))
Sys.unsetenv("R_PARALLELLY_AVAILABLECORES_FALLBACK")
options(parallelly.availableCores.fallback = NULL)

Sys.setenv(R_PARALLELLY_AVAILABLECORES_FALLBACK = "NA_real_")
.onLoad(pkgname, pkgname)
ncores <- getOption("parallelly.availableCores.fallback")
print(ncores)
stopifnot(is.integer(ncores), is.na(ncores))
Sys.unsetenv("R_PARALLELLY_AVAILABLECORES_FALLBACK")
options(parallelly.availableCores.fallback = NULL)

message("- .onLoad() w/ R_PARALLELLY_AVAILABLECORES_FALLBACK ... DONE")

message("*** .onLoad() ... DONE")
