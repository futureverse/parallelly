message("*** utils,cluster ...")

message("- sQuote()")
cmd <- "foo bar"
stopifnot(parallelly:::shQuote(cmd) == base::shQuote(cmd))

for (type in c("sh", "cmd")) {
  message(sprintf("- sQuote(... type = \"%s\")", type))
  stopifnot(parallelly:::shQuote(cmd, type = type) == base::shQuote(cmd, type = type))
}

message("- sQuote(... type = \"none\")")
stopifnot(parallelly:::shQuote(cmd, type = "none") == cmd)

message("*** utils,cluster ... DONE")
