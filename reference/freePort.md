# Find a TCP port that can be opened

Find a TCP port that can be opened

## Usage

``` r
freePort(ports = 1024:65535, default = "random", randomize = TRUE)
```

## Arguments

- ports:

  (integer vector, or character string) Zero or more TCP ports in \[0,
  65535\] to scan. If `"random"`, then a random set of ports is
  considered. If `"auto"`, then the port given by environment variable
  `R_PARALLEL_PORT` is used, which may also specify `"random"`. If
  `R_PARALLEL_PORT` is not set, the default is `"random"`. The `"auto"`
  alternative is used for full backward compatibility with the
  **parallelly** package.

- default:

  (integer) `NA_integer_` or a port to returned if an available port
  could not be found. If `"first"`, then `ports[1]`. If `"random"`, then
  a random port among `ports` is used. If `length(ports) == 0`, then
  `NA_integer_`.

- randomize:

  (logical) If TRUE, `ports` is randomly shuffled before searched. This
  shuffle does *not* forward the RNG seed.

## Value

Returns an integer representing the first port among `ports` *that can
be opened*. If none can be opened, then `default` is returned.

## Validation of TCP port returned

This function attempts to validate that the TCP port returned is
available and can be be opened. Thus, it is likely that this port is
available momentarily after `freePort()` returns. However, due to race
conditions, there is always a risk that the port is taken by another
process on the same system after `freePort()` returns but before, say,
[`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
opens it.

## Controlling the random set of TCP ports

For backward compatibility with the **parallel** package, the default
set of of ports `freePort("random")`, or `freePort("auto")` with
environment variable `R_PARALLEL_PORT=random` samples from is
`11000:11999`. The set can be overriden by setting environment variable
`R_PARALLELLY_RANDOM_PORTS`, e.g.
`R_PARALLELLY_RANDOM_PORTS="10001:10010,11000:54000"`.

## Examples

``` r
# Make sure to undo any changes at the end
oenv <- Sys.getenv("R_PARALLELLY_RANDOM_PORTS")

# Get a random, free TCP port in 1024:65535
port <- freePort()
message("A free TCP port: ", port)
#> A free TCP port: 17117

# Get a random, free TCP port in 11000:11999, which is what
# parallelly::makeClusterPSOCK() and parallel::makePSOCKcluster()
# default to (but the latter does not make sure it is available)
Sys.unsetenv("R_PARALLELLY_RANDOM_PORTS")
port <- freePort("random")
message("A free TCP port: ", port)
#> A free TCP port: 11405

# Customize the range of ports to sample from to 30000:50000
Sys.setenv(R_PARALLELLY_RANDOM_PORTS = "30000:50000")
port <- freePort("random")
message("A free TCP port: ", port)
#> A free TCP port: 38618

# Test if a specific port is free
isPortFree <- function(port) !is.na(freePort(port, default = NA_integer_))
message("TCP port 1024 is free: ", isPortFree(1024))
#> TCP port 1024 is free: TRUE

# Undo changes
Sys.setenv(R_PARALLELLY_RANDOM_PORTS = oenv)
```
