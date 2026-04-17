library(parallelly)

message("*** freeCores() ...")

free <- freeCores()
print(free)

stopifnot(
  is.integer(free),
  length(free) == 1L,
  !is.na(free), free >= 1L
)

## Attributes
stopifnot(
  !is.null(attr(free, "loadavg")),
  !is.null(attr(free, "maxCores")),
  !is.null(attr(free, "memory")),
  !is.null(attr(free, "fraction"))
)

for (memory in c("1min", "5min", "15min")) {
  message(sprintf("- freeCores(memory = '%s')", memory))
  free <- freeCores(memory = memory)
  print(free)
  stopifnot(
    is.integer(free),
    length(free) == 1L,
    !is.na(free), free >= 1L,
    identical(attr(free, "memory"), memory)
  )
}

message("- freeCores(fraction = 0.5)")
free_half <- freeCores(fraction = 0.5)
print(free_half)
stopifnot(
  is.integer(free_half),
  length(free_half) == 1L,
  !is.na(free_half), free_half >= 1L,
  identical(attr(free_half, "fraction"), 0.5)
)


message("- freeCores() - exceptions")

res <- tryCatch(freeCores(fraction = 0), error = identity)
stopifnot(inherits(res, "error"))

res <- tryCatch(freeCores(fraction = 1.5), error = identity)
stopifnot(inherits(res, "error"))

res <- tryCatch(freeCores(fraction = NA_real_), error = identity)
stopifnot(inherits(res, "error"))

message("*** freeCores() ... DONE")
