library(parallelly)

message("*** availableCores() ...")

## detectCores() may return NA_integer_
n <- parallel::detectCores()
message(sprintf("detectCores() = %d", n))
stopifnot(length(n) == 1, is.numeric(n))

## Default
n <- availableCores()
message(sprintf("availableCores() = %d", n))
stopifnot(length(n) == 1, is.integer(n), n >= 1)
n0 <- n

n <- availableCores(omit = 1L)
stopifnot(length(n) == 1, is.integer(n), n >= 1, n == max(1L, n0 - 1L))

n <- availableCores(max = 1L)
stopifnot(length(n) == 1, is.integer(n), n == 1L)

## Minimium of all known settings (default)
print(availableCores(which = "min"))

## Maximum of all known settings (should never be used)
print(availableCores(which = "max"))

## All known settings
ns <- availableCores(na.rm = FALSE, which = "all")
stopifnot(length(ns) >= 1, is.integer(ns), all(is.na(ns) | ns >= 0L))

## System settings
n <- availableCores(methods = "system")
print(n)
stopifnot(length(n) == 1, is.integer(n), n >= 1)

## Contrain by number of available connections
opts <- options(mc.cores = availableConnections())
n <- availableCores(constraints = "connections", method = "mc.cores")
print(n)
stopifnot(length(n) == 1, is.integer(n), n >= 1)
n0 <- n
n <- availableCores(constraints = "connections-1", method = "mc.cores")
print(n)
stopifnot(length(n) == 1, is.integer(n), n >= 1, n == n0 - 1L)
n <- availableCores(constraints = "connections-2", method = "mc.cores")
print(n)
stopifnot(length(n) == 1, is.integer(n), n >= 1, n == n0 - 2L)
n <- availableCores(method = "connections")
print(n)
stopifnot(length(n) == 1, is.integer(n), n >= 1, n == n0)
n <- availableCores(method = "connections-1")
print(n)
stopifnot(length(n) == 1, is.integer(n), n >= 1, n == n0 - 1L)
n <- availableCores(method = "connections-2")
print(n)
stopifnot(length(n) == 1, is.integer(n), n >= 1, n == n0 - 2L)
options(opts)

## Contrain by support for multicore
n <- availableCores(constraints = "multicore")
print(n)
stopifnot(length(n) == 1, is.integer(n), n >= 1)

## Special case: mc.cores = 0L
opts <- options(mc.cores = 0L)
n <- availableCores(method = "mc.cores")
print(n)
stopifnot(length(n) == 1, is.integer(n), n == 1L)
n <- availableCores(method = "mc.cores+1")
print(n)
stopifnot(length(n) == 1, is.integer(n), n == 1L)
options(opts)

## Predefined ones for known cluster schedulers
print(availableCores(methods = "PBS"))
print(availableCores(methods = "SGE"))
print(availableCores(methods = "Slurm"))
print(availableCores(methods = "LSF"))

## Any R options and system environment variable
print(availableCores(methods = c("width", "FOO_BAR_ENV"),
                     na.rm = FALSE, which = "all"))

## Exception handling
Sys.setenv("FOO_BAR_ENV" = "0")
res <- try(availableCores(methods = "FOO_BAR_ENV"), silent = TRUE)
stopifnot(inherits(res, "try-error"))


ncores0 <- 42L

message("*** LSF ...")
message(" - LSB_DJOB_NUMPROC")
Sys.setenv(LSB_DJOB_NUMPROC = as.character(ncores0))
env <- environment(parallelly:::availableCoresLSF)
env$n <- NULL
ncores <- availableCores(methods = "LSF")
print(ncores)
stopifnot(ncores == ncores0)
message("*** LSF ... done")

message("*** PJM (Fujitsu Technical Computing Suite) ...")
message(" - PJM_VNODE_CORE")
Sys.setenv(PJM_VNODE_CORE = as.character(ncores0))
env <- environment(parallelly:::availableCoresPJM)
env$n <- NULL
ncores <- availableCores(methods = "PJM")
print(ncores)
stopifnot(ncores == ncores0)
Sys.unsetenv("PJM_VNODE_CORE")

message(" - PJM_PROC_BY_NODE")
Sys.setenv(PJM_PROC_BY_NODE = as.character(ncores0))
env <- environment(parallelly:::availableCoresPJM)
env$n <- NULL
ncores <- availableCores(methods = "PJM")
print(ncores)
stopifnot(ncores == ncores0)
Sys.unsetenv("PJM_PROC_BY_NODE")
message("*** PJM (Fujitsu Technical Computing Suite) ... done")


message("*** Internal detectCores() ...")

## Option 'parallelly.availableCores.system'

## Reset internal cache
env <- environment(parallelly:::detectCores)
env$cache <- list(NULL, NULL)

options(parallelly.availableCores.system = 2L)
n <- detectCores()
print(n)
stopifnot(is.integer(n), is.finite(n), n >= 1, n == 2L)
options(parallelly.availableCores.system = NULL)

## Reset
env <- environment(parallelly:::detectCores)
env$cache <- list(NULL, NULL)

n <- detectCores()
print(n)
stopifnot(is.integer(n), is.finite(n), n >= 1)

message("*** Internal detectCores() ... DONE")


message("*** availableCores() ... DONE")
