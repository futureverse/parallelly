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


message("*** Slurm multi-node scenarios ...")

## Reset Slurm cache
env <- environment(parallelly:::availableCoresSlurm)

## Single-node with SLURM_CPUS_ON_NODE
Sys.unsetenv("SLURM_CPUS_PER_TASK")
Sys.setenv(SLURM_JOB_NUM_NODES = "1", SLURM_CPUS_ON_NODE = "8")
env$n <- NULL
ncores <- availableCores(methods = "Slurm")
print(ncores)
stopifnot(ncores == 8L)

## SLURM_NNODES fallback when SLURM_JOB_NUM_NODES is not set
Sys.unsetenv("SLURM_CPUS_PER_TASK")
Sys.unsetenv("SLURM_JOB_NUM_NODES")
Sys.setenv(SLURM_NNODES = "1", SLURM_CPUS_ON_NODE = "16")
env$n <- NULL
ncores <- availableCores(methods = "Slurm")
print(ncores)
stopifnot(ncores == 16L)

## Multi-node with SLURM_TASKS_PER_NODE (simple format)
Sys.unsetenv("SLURM_CPUS_PER_TASK")
Sys.setenv(SLURM_JOB_NUM_NODES = "2", SLURM_TASKS_PER_NODE = "5,2")
env$n <- NULL
ncores <- availableCores(methods = "Slurm")
print(ncores)
stopifnot(ncores == 5L)  ## Uses first node's count

## Multi-node with SLURM_TASKS_PER_NODE (expanded format)
Sys.unsetenv("SLURM_CPUS_PER_TASK")
Sys.setenv(SLURM_JOB_NUM_NODES = "5", SLURM_TASKS_PER_NODE = "2(x2),1(x3)")
env$n <- NULL
ncores <- availableCores(methods = "Slurm")
print(ncores)
stopifnot(ncores == 2L)  ## Uses first node's count

## Cleanup
Sys.unsetenv(c("SLURM_CPUS_PER_TASK", "SLURM_JOB_NUM_NODES", "SLURM_NNODES",
               "SLURM_CPUS_ON_NODE", "SLURM_TASKS_PER_NODE"))
env$n <- NULL

message("*** Slurm multi-node scenarios ... done")


message("*** PBS NCPUS fallback ...")

## Reset PBS cache
env <- environment(parallelly:::availableCoresPBS)

## Test NCPUS fallback when PBS_NUM_PPN is not set
Sys.unsetenv("PBS_NUM_PPN")
Sys.setenv(NCPUS = "16")
env$n <- NULL
ncores <- availableCores(methods = "PBS")
print(ncores)
stopifnot(ncores == 16L)

## Cleanup
Sys.unsetenv("NCPUS")
env$n <- NULL

message("*** PBS NCPUS fallback ... done")


message("*** BiocParallel method ...")

Sys.setenv(BIOCPARALLEL_WORKER_NUMBER = "4")
ncores <- availableCores(methods = "BiocParallel")
print(ncores)
stopifnot(ncores == 4L)
Sys.unsetenv("BIOCPARALLEL_WORKER_NUMBER")

message("*** BiocParallel method ... done")


message("*** Bioconductor build machine ...")

## IS_BIOC_BUILD_MACHINE (modern, >= 3.16)
Sys.setenv(IS_BIOC_BUILD_MACHINE = "TRUE")
ncores <- availableCores(methods = "Bioconductor")
print(ncores)
stopifnot(ncores == 4L)
Sys.unsetenv("IS_BIOC_BUILD_MACHINE")

## BBS_HOME fallback (legacy, <= 3.15)
Sys.setenv(BBS_HOME = "TRUE")
ncores <- availableCores(methods = "Bioconductor")
print(ncores)
stopifnot(ncores == 4L)
Sys.unsetenv("BBS_HOME")

message("*** Bioconductor build machine ... done")


message("*** Custom function method ...")

## Valid custom function
opts <- options(parallelly.availableCores.custom = function() 3L)
ncores <- availableCores(methods = "custom")
print(ncores)
stopifnot(ncores == 3L)
options(opts)

## Custom function returning NA (should be ignored)
opts <- options(parallelly.availableCores.custom = function() NA_integer_)
ncores <- availableCores(methods = c("system", "custom"), which = "all", na.rm = FALSE)
print(ncores)
stopifnot("custom" %in% names(ncores), is.na(ncores["custom"]))
options(opts)

## Custom function calling availableCores() (recursion protection)
opts <- options(parallelly.availableCores.custom = function() {
  availableCores(methods = "system") - 1L
})
ncores <- availableCores(methods = "custom")
print(ncores)
stopifnot(ncores >= 1L)
options(opts)

## Error: custom function returns non-single value
opts <- options(parallelly.availableCores.custom = function() c(1L, 2L))
res <- tryCatch(availableCores(methods = "custom"), error = identity)
stopifnot(inherits(res, "error"))
options(opts)

## Custom option is not a function (should be skipped)
opts <- options(parallelly.availableCores.custom = "not a function")
ncores <- availableCores(methods = c("system", "custom"), which = "all")
print(ncores)
stopifnot(!("custom" %in% names(ncores)))
options(opts)

message("*** Custom function method ... done")


message("*** Fallback method ...")

## Test fallback option
opts <- options(parallelly.availableCores.fallback = 2L)
ncores <- availableCores(methods = "fallback")
print(ncores)
stopifnot(ncores == 2L)
options(opts)

## Fallback is used when only "special" methods are present
opts <- options(parallelly.availableCores.fallback = 2L)
ncores <- availableCores(methods = c("system", "fallback"))
print(ncores)
## Fallback should be used if system agrees or is higher
stopifnot(ncores >= 1L)
options(opts)

message("*** Fallback method ... done")


message("*** parallelly.availableCores.min validation ...")

## Error: non-numeric min
opts <- options(parallelly.availableCores.min = "two")
res <- tryCatch(availableCores(), error = identity)
stopifnot(inherits(res, "error"))
options(opts)

## Error: min < 1
opts <- options(parallelly.availableCores.min = 0L)
res <- tryCatch(availableCores(), error = identity)
stopifnot(inherits(res, "error"))
options(opts)

## Error: min is not finite (Inf)
opts <- options(parallelly.availableCores.min = Inf)
res <- tryCatch(availableCores(), error = identity)
stopifnot(inherits(res, "error"))
options(opts)

## Error: min > detectCores()
opts <- options(parallelly.availableCores.min = parallel::detectCores() + 1L)
res <- tryCatch(availableCores(), error = identity)
stopifnot(inherits(res, "error"))
options(opts)

## Error: min has wrong length
opts <- options(parallelly.availableCores.min = c(1L, 2L))
res <- tryCatch(availableCores(), error = identity)
stopifnot(inherits(res, "error"))
options(opts)

message("*** parallelly.availableCores.min validation ... done")


message("*** Input validation edge cases ...")

## Invalid default (< 1)
res <- tryCatch(availableCores(default = 0L), error = identity)
stopifnot(inherits(res, "error"))

## Invalid default (not finite)
res <- tryCatch(availableCores(default = Inf), error = identity)
stopifnot(inherits(res, "error"))

## Invalid omit (negative)
res <- tryCatch(availableCores(omit = -1L), error = identity)
stopifnot(inherits(res, "error"))

## Invalid omit (not finite)
res <- tryCatch(availableCores(omit = Inf), error = identity)
stopifnot(inherits(res, "error"))

## Invalid max (< 1)
res <- tryCatch(availableCores(max = 0L), error = identity)
stopifnot(inherits(res, "error"))

## Invalid max (NA)
res <- tryCatch(availableCores(max = NA), error = identity)
stopifnot(inherits(res, "error"))

## Invalid constraints (NA values)
res <- tryCatch(availableCores(constraints = c("multicore", NA)), error = identity)
stopifnot(inherits(res, "error"))

message("*** Input validation edge cases ... done")


message("*** checkNumberOfLocalWorkers() ...")

checkNumberOfLocalWorkers <- parallelly:::checkNumberOfLocalWorkers

## AsIs bypass - should not warn or error
result <- tryCatch({
  checkNumberOfLocalWorkers(I(1000L))
  TRUE
}, warning = function(w) FALSE, error = function(e) FALSE)
stopifnot(result)

## Save current options
opts <- options(parallelly.maxWorkers.localhost = c(1.0, 3.0))

## Test warning at soft limit (workers/ncores > 1.0)
ncores <- availableCores()
if (ncores >= 1L) {
  workers <- ncores + 1L  ## Just above soft limit
  res <- tryCatch({
    checkNumberOfLocalWorkers(workers)
    "none"
  }, warning = function(w) "warning", error = function(e) "error")
  message(sprintf("  workers=%d, ncores=%d -> %s", workers, ncores, res))
  stopifnot(res == "warning")
}

## Test error at hard limit (workers/ncores > 3.0)
if (ncores >= 1L) {
  workers <- ncores * 4L  ## Above hard limit
  res <- tryCatch({
    checkNumberOfLocalWorkers(workers)
    "none"
  }, warning = function(w) "warning", error = function(e) "error")
  message(sprintf("  workers=%d, ncores=%d -> %s", workers, ncores, res))
  stopifnot(res == "error")
}

## Restore options
options(opts)

## Test with empty limits (disabled)
## Note: NULL returns default, so use numeric(0) to disable
opts <- options(parallelly.maxWorkers.localhost = numeric(0))
result <- tryCatch({
  checkNumberOfLocalWorkers(1000L)
  TRUE
}, warning = function(w) FALSE, error = function(e) FALSE)
stopifnot(result)
options(opts)

message("*** checkNumberOfLocalWorkers() ... done")


message("*** detectCoresHint() ...")

detectCoresHint <- parallelly:::detectCoresHint
sysCores <- parallel::detectCores()

## Hint for detectCores() pattern
hint <- detectCoresHint(sysCores)
message(sprintf("  detectCoresHint(%d): %s", sysCores, hint))
stopifnot(!is.null(hint), grepl("detectCores", hint))

## Hint for detectCores() - 1 pattern
hint <- detectCoresHint(sysCores - 1L)
message(sprintf("  detectCoresHint(%d): %s", sysCores - 1L, hint))
stopifnot(!is.null(hint), grepl("detectCores", hint), grepl("- 1", hint))

## Hint for detectCores() - 2 pattern
hint <- detectCoresHint(sysCores - 2L)
message(sprintf("  detectCoresHint(%d): %s", sysCores - 2L, hint))
stopifnot(!is.null(hint), grepl("detectCores", hint), grepl("- 2", hint))

## No hint when delta > 2
hint <- detectCoresHint(1L)
message(sprintf("  detectCoresHint(1): %s", if (is.null(hint)) "NULL" else hint))
if (sysCores > 3L) {
  stopifnot(is.null(hint))
}

message("*** detectCoresHint() ... done")


message("*** logical parameter ...")

## Test logical = TRUE (logical/hyperthreaded cores)
n_logical <- availableCores(methods = "system", logical = TRUE)
print(n_logical)
stopifnot(is.integer(n_logical), n_logical >= 1L)

## Test logical = FALSE (physical cores)
n_physical <- availableCores(methods = "system", logical = FALSE)
print(n_physical)
stopifnot(is.integer(n_physical), n_physical >= 1L)

## Physical cores should be <= logical cores
stopifnot(n_physical <= n_logical)

message("*** logical parameter ... done")


message("*** connections-N delta tests ...")

## Get baseline
n_conn <- freeConnections()
message(sprintf("  freeConnections() = %d", n_conn))

## Test various connection deltas
n0 <- availableCores(methods = "connections")
print(n0)
stopifnot(n0 >= 1L)

n5 <- availableCores(methods = "connections-5")
print(n5)
stopifnot(n5 >= 1L)
if (n0 > 5L) {
  stopifnot(n5 == n0 - 5L)
}

## Large delta should still return at least 1
n_large <- availableCores(methods = "connections-1000")
print(n_large)
stopifnot(n_large >= 1L)

message("*** connections-N delta tests ... done")


message("*** na.rm = FALSE with missing values ...")

## Verify NA values are preserved when na.rm = FALSE
ns <- availableCores(methods = c("system", "nonexistent_method_xyz123"),
                     na.rm = FALSE, which = "all")
print(ns)
stopifnot("nonexistent_method_xyz123" %in% names(ns))
stopifnot(is.na(ns["nonexistent_method_xyz123"]))

message("*** na.rm = FALSE with missing values ... done")


message("*** SGE method ...")

## Reset SGE cache
env <- environment(parallelly:::availableCoresSGE)

Sys.setenv(NSLOTS = "24")
env$n <- NULL
ncores <- availableCores(methods = "SGE")
print(ncores)
stopifnot(ncores == 24L)
Sys.unsetenv("NSLOTS")
env$n <- NULL

message("*** SGE method ... done")


message("*** _R_CHECK_LIMIT_CORES_ method ...")

## When set to true-ish value, should return 2
Sys.setenv(`_R_CHECK_LIMIT_CORES_` = "TRUE")
ncores <- availableCores(methods = "_R_CHECK_LIMIT_CORES_")
print(ncores)
stopifnot(ncores == 2L)

## When set to "warn", should also return 2
Sys.setenv(`_R_CHECK_LIMIT_CORES_` = "warn")
ncores <- availableCores(methods = "_R_CHECK_LIMIT_CORES_")
print(ncores)
stopifnot(ncores == 2L)

## When set to "false", should return NA
Sys.setenv(`_R_CHECK_LIMIT_CORES_` = "false")
ncores <- availableCores(methods = "_R_CHECK_LIMIT_CORES_", na.rm = FALSE)
print(ncores)
stopifnot(is.na(ncores))

## Cleanup
Sys.unsetenv("_R_CHECK_LIMIT_CORES_")

message("*** _R_CHECK_LIMIT_CORES_ method ... done")


message("*** nproc method ...")

## Check if nproc is available
has_nproc <- nzchar(Sys.which("nproc"))
message(sprintf("  - nproc available: %s", has_nproc))

if (has_nproc) {
  ## Reset getNproc cache
  env <- environment(parallelly:::getNproc)
  env$res <- NULL

  ## Test nproc method
  ncores <- availableCores(methods = "nproc")
  print(ncores)
  stopifnot(length(ncores) == 1L, is.integer(ncores), ncores >= 1L)

  ## Test OMP variable handling
  message("  - Testing OMP variable handling")

  ## Reset cache
  env$res <- NULL

  ## Set OMP variables that could influence nproc
  old_omp_threads <- Sys.getenv("OMP_NUM_THREADS", unset = NA)
  old_omp_limit <- Sys.getenv("OMP_THREAD_LIMIT", unset = NA)

  Sys.setenv(OMP_NUM_THREADS = "2", OMP_THREAD_LIMIT = "4")

  ## getNproc should ignore these when querying
  env$res <- NULL
  n <- parallelly:::getNproc()
  message(sprintf("  - getNproc() with OMP vars set: %s",
                  if (is.na(n)) "NA" else as.character(n)))

  ## Verify OMP variables are restored after call
  stopifnot(Sys.getenv("OMP_NUM_THREADS") == "2")
  stopifnot(Sys.getenv("OMP_THREAD_LIMIT") == "4")

  ## Restore original OMP values
  if (is.na(old_omp_threads)) {
    Sys.unsetenv("OMP_NUM_THREADS")
  } else {
    Sys.setenv(OMP_NUM_THREADS = old_omp_threads)
  }
  if (is.na(old_omp_limit)) {
    Sys.unsetenv("OMP_THREAD_LIMIT")
  } else {
    Sys.setenv(OMP_THREAD_LIMIT = old_omp_limit)
  }

  ## Reset cache for other tests
  env$res <- NULL
}

message("*** nproc method ... done")


message("*** /proc/self/status method ...")

## Test /proc/self/status method on Linux
if (file.exists("/proc/self/status")) {
  ncores <- availableCores(methods = "/proc/self/status")
  print(ncores)
  stopifnot(length(ncores) == 1L, is.integer(ncores))
  if (!is.na(ncores)) {
    stopifnot(ncores >= 1L)
  }
}

message("*** /proc/self/status method ... done")


message("*** availableCores() ... DONE")
