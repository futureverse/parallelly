library(parallelly)

message("*** initialize_internet() ...")
initialize_internet <- parallelly:::initialize_internet
environment(initialize_internet)$done <- FALSE
message("*** initialize_internet() ... DONE")

message("*** freePort() ...")

# Make sure to undo any changes at the end
oenv <- Sys.getenv("R_PARALLELLY_RANDOM_PORTS")
Sys.setenv(R_PARALLELLY_DEBUG = "TRUE")

set.seed(42)
rng <- .Random.seed

for (kk in 1:5) {
  port <- freePort()
  message("A random free TCP port: ", port)
  stopifnot(is.integer(port), length(port) == 1L)
  if (!is.na(port)) stopifnot(port >= 0L, port <= 65535L)
  stopifnot(identical(.Random.seed, rng))
}

# Assert that 'default' is a valid TCP port
port <- freePort(default = 1024L)
stopifnot(is.integer(port), length(port) == 1L)

port <- tryCatch(freePort(default = -1L), error = identity)
stopifnot(inherits(port, "error"))

port <- freePort(ports = integer(0L), default = 1024L)
stopifnot(is.integer(port), length(port) == 1L, port == 1024L)


message("- freePort('auto')")

Sys.unsetenv("R_PARALLEL_PORT")
port <- freePort("auto")
message("A random free TCP port: ", port)

message("- freePort('auto') with env var R_PARALLEL_PORT = 8888")
Sys.setenv(R_PARALLEL_PORT = 8888L)
port <- freePort("auto")
message("A free TCP port: ", port)
stopifnot(port == 8888L)

Sys.setenv(R_PARALLEL_PORT = "invalid")
cond <- NULL
withCallingHandlers({
  port <- freePort("auto")
}, warning = function(c) {
  cond <<- c
})
stopifnot(is.integer(port), length(port) == 1L)
stopifnot(inherits(cond, "warning"))

Sys.unsetenv("R_PARALLEL_PORT")


# Get a random, free TCP port in 1024:65535
port <- freePort()
message("A free TCP port: ", port)


# Get a random, free TCP port in 11000:11999, which is what
# parallelly::makeClusterPSOCK() and parallel::makePSOCKcluster()
# default to (but the latter does not make sure it is available)
Sys.unsetenv("R_PARALLELLY_RANDOM_PORTS")
port <- freePort("random")
message("A free TCP port: ", port)
stopifnot(is.integer(port), length(port) == 1L, port %in% 11000:11999)

# Customize the range of ports to sample from to 30000:50000
Sys.setenv(R_PARALLELLY_RANDOM_PORTS = "30000:50000")
port <- freePort("random")
message("A free TCP port: ", port)
stopifnot(is.integer(port), length(port) == 1L, port %in% 30000:50000)

# Customize the range of ports to sample from to invalid port range
Sys.setenv(R_PARALLELLY_RANDOM_PORTS = "invalid:50000")
cond <- NULL
withCallingHandlers({
  port <- freePort("random")
}, warning = function(c) {
  cond <<- c
})
stopifnot(is.integer(port), length(port) == 1L)
stopifnot(inherits(cond, "warning"))

# Customize the range of ports to sample from to ports out of range
Sys.setenv(R_PARALLELLY_RANDOM_PORTS = "99999:99999")
cond <- NULL
withCallingHandlers({
  port <- freePort("random")
}, warning = function(c) {
  cond <<- c
})
stopifnot(is.integer(port), length(port) == 1L)
stopifnot(inherits(cond, "warning"))


# Test if a specific port is free
isPortFree <- function(port) !is.na(freePort(port, default = NA_integer_))

Sys.setenv("R_PARALLELLY_DEBUG" = "true")
Sys.unsetenv("_R_PARALLELLY_CHECK_AVAILABLE_PORTS_")
free <- isPortFree(1024)
message("TCP port 1024 is free: ", free)
stopifnot(is.logical(free), length(free) == 1L, !is.na(free))

# Fake port availability
Sys.setenv("_R_PARALLELLY_CHECK_AVAILABLE_PORTS_" = "any")
free <- isPortFree(1)
message("TCP port 1 is free: ", free)
stopifnot(is.logical(free), length(free) == 1L, !is.na(free), isTRUE(free))

Sys.setenv("_R_PARALLELLY_CHECK_AVAILABLE_PORTS_" = "invalid")
free <- tryCatch(isPortFree(1), error = identity)
stopifnot(inherits(free, "error"))

Sys.unsetenv("R_PARALLELLY_DEBUG")

# Undo changes
Sys.setenv(R_PARALLELLY_RANDOM_PORTS = oenv)

message("*** freePort() ... DONE")



