library(parallelly)

message("*** freePort() ...")

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


message("*** freePort() ... DONE")
