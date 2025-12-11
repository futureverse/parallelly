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

message("*** stopf() ... DONE")

message("*** warnf() ...")

res <- tryCatch({
  warnf("Hello %s", "world")
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

message("*** msgf() ... DONE")


message("*** utils,conditions ... DONE")
