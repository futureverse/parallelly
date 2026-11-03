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

## Processes killed on Linux may still linger as "zombie" processes.
## When that happens, pskill(pid, signal = 0L) will still return TRUE,
## so we have make sure it's not a zombie in that case.
## (Linux only, because it requires /proc)
if (.Platform[["OS.type"]] == "unix" && file.exists("/proc/self/stat")) {
  job <- parallel::mcparallel(Sys.sleep(60))
  pid <- job[["pid"]]
  stopifnot(isTRUE(pid_exists(pid)))
  ## A killed child process remains a zombie until it is collected
  tools::pskill(pid, tools::SIGKILL)
  timeout <- Sys.time() + 30.0
  while (!parallelly:::is_zombie_process(pid) && Sys.time() < timeout) {
    Sys.sleep(0.1)
  }
  stopifnot(parallelly:::is_zombie_process(pid))
  res <- pid_exists(pid)
  print(res)
  stopifnot(identical(res, FALSE))
  res <- suppressWarnings(parallel::mccollect(job))
  stopifnot(identical(pid_exists(pid), FALSE))
}

message("*** utils,pid ... DONE")
