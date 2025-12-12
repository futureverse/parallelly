library(parallelly)

message("*** utils,pid ...")

pid_exists <- parallelly:::pid_exists

## Test with current process
res <- pid_exists(Sys.getpid())
print(res)
stopifnot(isTRUE(res))

## Test with current process
res <- pid_exists(Sys.getpid(), debug = TRUE)
print(res)
stopifnot(isTRUE(res))

## Exceptions
res <- tryCatch(pid_exists(0L), error = identity)
stopifnot(inherits(res, "error"))

message("*** utils,pid ... DONE")
