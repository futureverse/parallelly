library(parallelly)

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

message("- freePort('auto')")

Sys.unsetenv("R_PARALLEL_PORT")
port <- freePort("auto")
message("A random free TCP port: ", port)

message("- freePort('auto') with env var R_PARALLEL_PORT = 8888")
Sys.setenv(R_PARALLEL_PORT = 8888L)
port <- freePort("auto")
message("A free TCP port: ", port)
stopifnot(port == 8888L)

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

# Test if a specific port is free
isPortFree <- function(port) !is.na(freePort(port, default = NA_integer_))
message("TCP port 1024 is free: ", isPortFree(1024))

# Undo changes
Sys.setenv(R_PARALLELLY_RANDOM_PORTS = oenv)


message("*** freePort() ... DONE")
