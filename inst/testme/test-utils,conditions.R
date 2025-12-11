library(parallelly)

message("*** utils,conditions ...")

stopf <- parallelly:::stopf
warnf <- parallelly:::warnf
msgf <- parallelly:::msgf

message("*** stopf() ...")

res <- tryCatch({
  stopf("Hello %s", "world")
}, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  stopf("Hello %s", "world", call. = quote(a + b))
}, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  stopf("Hello %s", "world", call. = NULL)
}, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  stopf("Hello %s", "world", call. = TRUE)
}, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))
stopifnot(grepl("Hello world", res$message))


f <- function() {
  stopf("Hello %s", "world", call. = sys.call())
}
res <- tryCatch(f(), error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  stopf("Hello %s", "world", domain = "R-futile.options")
}, error = identity)
print(res)
stopifnot(inherits(res, "simpleError"))
stopifnot(grepl("Hello world", res$message))

message("*** stopf() ... DONE")

message("*** warnf() ...")

res <- tryCatch({
  warnf("Hello %s", "world")
}, warning = identity)
print(res)
stopifnot(inherits(res, "simpleWarning"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  warnf("Hello %s", "world", immediate. = TRUE)
}, warning = identity)
print(res)
stopifnot(inherits(res, "simpleWarning"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  warnf("Hello %s", "world", immediate. = TRUE, domain = "R-futile.options")
}, warning = identity)
print(res)
stopifnot(inherits(res, "simpleWarning"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  warnf("Hello %s", "world", call. = quote(a + b))
}, warning = identity)
print(res)
stopifnot(inherits(res, "simpleWarning"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  warnf("Hello %s", "world", call. = NULL)
}, warning = identity)
print(res)
stopifnot(inherits(res, "simpleWarning"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  warnf("Hello %s", "world", call. = TRUE)
}, warning = identity)
print(res)
stopifnot(inherits(res, "simpleWarning"))
stopifnot(grepl("Hello world", res$message))


f <- function() {
  warnf("Hello %s", "world", call. = sys.call())
}
res <- tryCatch(f(), warning = identity)
print(res)
stopifnot(inherits(res, "simpleWarning"))
stopifnot(grepl("Hello world", res$message))


res <- tryCatch({
  warnf("Hello %s", "world", domain = "R-futile.options")
}, warning = identity)
print(res)
stopifnot(inherits(res, "simpleWarning"))
stopifnot(grepl("Hello world", res$message))

message("*** warnf() ... DONE")

message("*** msgf() ...")

msg <- "Hello world"
res <- capture.output({
  msgf("Hello %s", "world")
}, type = "message")
print(res)
stopifnot(identical(res, msg))


msg <- "Hello world"
res <- capture.output({
  msgf("Hello %s", "world", appendLF = TRUE)
}, type = "message")
print(res)
stopifnot(identical(res, msg))


msg <- "Hello world"
res <- capture.output({
  msgf("Hello %s", "world", domain = "R-futile.options")
}, type = "message")
print(res)
stopifnot(identical(res, msg))


msg <- "Hello world"
res <- capture.output({
  msgf("Hello %s", "world", appendLF = TRUE, domain = "R-futile.options")
}, type = "message")
print(res)
stopifnot(identical(res, msg))


message("*** msgf() ... DONE")


message("*** utils,conditions ... DONE")
