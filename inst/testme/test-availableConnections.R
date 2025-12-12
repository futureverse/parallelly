library(parallelly)

message("availableConnections() ...")

## Test with overriding option
options(parallelly.availableConnections = 200L)
n <- availableConnections()
stopifnot(n == 200L)
options(parallelly.availableConnections = NULL)

## Reset memoized value
assign("max", NULL, envir = environment(availableConnections))

## Test with invalid option
res <- tryCatch({
  options(parallelly.availableConnections = "abc")
  availableConnections()
}, error = function(e) e)
stopifnot(inherits(res, "simpleError"))
options(parallelly.availableConnections = NULL)

## Reset memoized value
assign("max", NULL, envir = environment(availableConnections))

## Test with a small number of tries to trigger +Inf
options(parallelly.availableConnections.tries = 10L)
n <- availableConnections()
stopifnot(is.infinite(n))
options(parallelly.availableConnections.tries = NULL)

## Reset memoized value
assign("max", NULL, envir = environment(availableConnections))

## Test with invalid tries option
res <- tryCatch({
  options(parallelly.availableConnections.tries = -1L)
  availableConnections()
}, error = function(e) e)
stopifnot(inherits(res, "simpleError"))
options(parallelly.availableConnections.tries = NULL)

## Reset memoized value
assign("max", NULL, envir = environment(availableConnections))

## Basic functionality
n <- availableConnections()
stopifnot(is.integer(n) || is.infinite(n), n >= 3L)

f <- freeConnections()
stopifnot(is.integer(f) || is.infinite(f), f <= n)

message("availableConnections() ... done")
