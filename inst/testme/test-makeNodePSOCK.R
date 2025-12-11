library(parallelly)

message("*** makeNodePSOCK() ...")

makeNodePSOCK <- parallelly:::makeNodePSOCK

## Test with default arguments
message("- default arguments ...")
## Port is required, but freePort() calls C code.
## I'll use a fixed port for this test.
options <- makeNodePSOCK(port = 12345L, action = "options")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

## Test action = "options"
message("- action = 'options' ...")
options <- makeNodePSOCK(port = 12345L, action = "options")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

## Test with specific worker and master
message("- specific worker and master ...")
options <- makeNodePSOCK(worker = "remote.server.org", master = "local.server.org", port = 12345L, action = "options")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

## Test with rscript_sh = "cmd"
message("- rscript_sh = 'cmd' ...")
options <- makeNodePSOCK(port = 12345L, rscript_sh = "cmd", action = "options")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

## Test with rscript_sh = c("sh", "cmd")
if (.Platform[["OS.type"]] != "windows") {
  message("- rscript_sh = c('sh', 'cmd') ...")
  options <- makeNodePSOCK(port = 12345L, rscript_sh = c("sh", "cmd"), action = "options")
  print(options)
  stopifnot(inherits(options, "makeNodePSOCKOptions"))
}

## Test with rscript_args
message("- rscript_args ...")
options <- makeNodePSOCK(port = 12345L, rscript_args = c("--vanilla"), action = "options")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

## Test with rscript_envs
message("- rscript_envs ...")
options <- makeNodePSOCK(port = 12345L, rscript_envs = c(FOO = "bar"), action = "options")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

## Test with default_packages
message("- default_packages ...")
options <- makeNodePSOCK(port = 12345L, default_packages = c("stats", "*"), action = "options")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

message("*** makeNodePSOCK() ... DONE")
