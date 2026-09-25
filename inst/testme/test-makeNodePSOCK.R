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


## Test HPC job-scheduler 'rshcmd' types using mockup executables
if (.Platform[["OS.type"]] != "windows") {
  message("- rshcmd = '<srun>', '<qrsh>', and '<pjrsh>' ...")

  oenvs <- Sys.getenv("PATH", names = TRUE)

  bin <- tempfile()
  dir.create(bin)
  for (name in c("srun", "qrsh", "pjrsh")) {
    pathname <- file.path(bin, name)
    writeLines(c("#! /bin/sh", "echo 'mockup 1.0'"), con = pathname)
    Sys.chmod(pathname, mode = "0755")
  }
  Sys.setenv(PATH = paste(bin, oenvs[["PATH"]], sep = .Platform[["path.sep"]]))

  worker <- "remote.example.org"
  for (type in c("srun", "qrsh", "pjrsh")) {
    options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = sprintf("<%s>", type), verbose = TRUE)
    print(options)
    stopifnot(
      inherits(options, "makeNodePSOCKOptions"),
      identical(attr(options[["rshcmd"]], "type"), type),
      !options[["revtunnel"]],
      grepl(type, options[["local_cmd"]], fixed = TRUE),
      options[["rscript_sh"]][2] == if (type == "srun") "none" else "sh"
    )
  }

  ## Explicit 'srun' command is also recognized as such
  options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = c("srun", "-w"))
  stopifnot(
    identical(attr(options[["rshcmd"]], "type"), "srun"),
    options[["rscript_sh"]][2] == "none"
  )

  ## An explicit 'rscript_sh' is respected
  options <- makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = "<srun>", rscript_sh = "sh")
  stopifnot(identical(options[["rscript_sh"]], c("sh", "sh")))

  ## 'rshcmd' is not used for localhost workers
  options <- makeNodePSOCK(action = "options", worker = Sys.info()[["nodename"]], port = 12345L, rshcmd = "<srun>")
  stopifnot(
    options[["localMachine"]],
    !grepl("srun", options[["local_cmd"]], fixed = TRUE)
  )

  ## Undo
  unlink(bin, recursive = TRUE)
  do.call(Sys.setenv, as.list(oenvs))

  ## An error is produced if the command is not on the PATH
  if (!nzchar(Sys.which("srun"))) {
    res <- tryCatch({
      makeNodePSOCK(action = "options", worker = worker, port = 12345L, rshcmd = "<srun>")
    }, error = identity)
    print(res)
    stopifnot(inherits(res, "error"))
  }
}

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


## Test with rscript_call
message("- rscript_call ...")
options <- makeNodePSOCK(action = "options", port = 12345L, rscript_call = "message('hello')")
stopifnot(inherits(options, "makeNodePSOCKOptions"))
stopifnot(grepl("message\\([\"']hello[\"']\\)", options$cmd))

options <- makeNodePSOCK(action = "options", port = 12345L, rscript_call = quote(message('hello')))
stopifnot(inherits(options, "makeNodePSOCKOptions"))
stopifnot(grepl("message\\([\\\"']+hello[\\\"']+\\)", options$cmd))

options <- tryCatch(makeNodePSOCK(action = "options", port = 12345L, rscript_call = "foo{"), error = identity)
stopifnot(inherits(options, "error"))

# Test R option customization
options(parallelly.makeNodePSOCK.rscript_call = "message('opt_hello')")
options <- makeNodePSOCK(action = "options", port = 12345L)
stopifnot(inherits(options, "makeNodePSOCKOptions"))
stopifnot(grepl("message\\([\"']opt_hello[\"']\\)", options$cmd))
options(parallelly.makeNodePSOCK.rscript_call = NULL)


## Assert that manual = TRUE skips localhost PID self-test
message("- manual = TRUE must not run the PID self-test ...")
options <- makeNodePSOCK(port = 12345L, manual = TRUE, quiet = TRUE, action = "options")
stopifnot(inherits(options, "makeNodePSOCKOptions"), is.null(options[["pidfile"]]))

options <- makeNodePSOCK(port = 12345L, manual = TRUE, dryrun = TRUE, quiet = TRUE, action = "options")
stopifnot(inherits(options, "makeNodePSOCKOptions"), is.null(options[["pidfile"]]))


message("*** makeNodePSOCK() ... DONE")
