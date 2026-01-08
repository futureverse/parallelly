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


message("- rshcmd = '' ...")
options <- makeNodePSOCK(action = "options", port = 12345L, rshcmd = "")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

message("- rshcmd = 'ssh' ...")
options <- makeNodePSOCK(action = "options", port = 12345L, rshcmd = "ssh")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

## Test with custom 'rshcmd' function
message("- rshcmd = <function> ...")
options <- makeNodePSOCK(action = "options", port = 12345L, rshcmd = function(rshopts, worker) { })
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rshcmd = function(rshopts, worker) { }, worker = "remote.example.org", user = "alice")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- tryCatch({
  makeNodePSOCK(action = "options", port = 12345L, rshcmd = function() { })
}, error = identity)
stopifnot(inherits(options, "error"))

options <- tryCatch({
  makeNodePSOCK(action = "options", port = 12345L, rshcmd = function(a, worker) { })
}, error = identity)
stopifnot(inherits(options, "error"))

options <- tryCatch({
  makeNodePSOCK(action = "options", port = 12345L, rshcmd = function(rshopts, b) { })
}, error = identity)
stopifnot(inherits(options, "error"))

message("- rshopts = '' ...")
options <- makeNodePSOCK(action = "options", port = 12345L, rshopts = "")
print(options)
stopifnot(inherits(options, "makeNodePSOCKOptions"))


worker <- "remote.example.org"
options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = NULL, verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

worker <- structure("remote.example.org", localhost = FALSE)
options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = NULL, verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

worker <- structure("remote.example.org", localhost = TRUE)
options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = NULL, verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

worker <- "remote.example.org"
options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = "<ssh>", verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

worker <- "remote.example.org"
options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = "rsh", verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

worker <- "remote.example.org"
options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = "unknown", verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rshlogfile = FALSE, verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rshlogfile = TRUE, verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rshlogfile = tempfile(fileext = ".log"), verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, default_packages = c("*"), verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

oopts <- options(defaultPackages = character(0L))
options <- makeNodePSOCK(action = "options", port = 12345L, default_packages = c("*"), verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))
options(oopts)

myrscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "R.exe" else "R")
options <- makeNodePSOCK(action = "options", port = 12345L, default_packages = c("base"), rscript = myrscript, verbose = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- tryCatch(makeNodePSOCK(action = "options", port = 12345L, default_packages = c("invalid-pkg-name"), verbose = TRUE), error = identity)
stopifnot(inherits(options, "error"))


options <- makeNodePSOCK(action = "options", port = 12345L, rscript = "Rscript")
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript = "*")
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript = "*", homogeneous = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- tryCatch(makeNodePSOCK(action = "options", port = 12345L, rscript = "unknown-Rscript-file", homogenous = TRUE), error = identity)
stopifnot(inherits(options, "error"))

options <- tryCatch(makeNodePSOCK(action = "options", port = 12345L, rscript = 42L, homogenous = TRUE), error = identity)
stopifnot(inherits(options, "error"))


options <- makeNodePSOCK(action = "options", port = 12345L, rscript_startup = "x <- 42")
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript_startup = list(quote(x <- 42)))
stopifnot(inherits(options, "makeNodePSOCKOptions"))


options <- makeNodePSOCK(action = "options", port = 12345L, rscript_libs = "*")
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, socketOptions = "NULL")
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options(parallelly.makeNodePSOCK.rscript_label = TRUE)
options <- makeNodePSOCK(action = "options", port = 12345L)
stopifnot(inherits(options, "makeNodePSOCKOptions"))
options(parallelly.makeNodePSOCK.rscript_label = NULL)


options <- makeNodePSOCK(action = "options", port = 12345L, rscript_envs = "USER")
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript_envs = c(USER = "alice"))
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript_envs = c("NON-EXISTING-ENVVAR-1234567890" = "abc123"))
stopifnot(inherits(options, "makeNodePSOCKOptions"))


cond <- NULL
withCallingHandlers({
  options <- makeNodePSOCK(action = "options", port = 12345L, rscript_envs = "NON-EXISTING-ENVVAR-0987654321")
}, warning = function(c) {
  cond <<- c
})
stopifnot(inherits(options, "makeNodePSOCKOptions"))
stopifnot(inherits(cond, "warning"))

options <- tryCatch(makeNodePSOCK(action = "options", port = 12345L, rscript_envs = ""), error = identity)
stopifnot(inherits(options, "error"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript_envs = c("ABC" = NA_character_))
stopifnot(inherits(options, "makeNodePSOCKOptions"))


options <- makeNodePSOCK(action = "options", port = 12345L, calls = TRUE)
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript_args = "*")
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript_args = c("first", "*"))
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript_args = c("first", "*", "last"))
stopifnot(inherits(options, "makeNodePSOCKOptions"))

options <- tryCatch(makeNodePSOCK(action = "options", port = 12345L, rscript_args = c("*", "*")), error = identity)
stopifnot(inherits(options, "error"))

options <- makeNodePSOCK(action = "options", port = 12345L, renice = 19L)
stopifnot(inherits(options, "makeNodePSOCKOptions"))


message("*** makeNodePSOCK() ... DONE")
