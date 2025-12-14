library(parallelly)

message("*** isNodeAlive() ...")

## Test default isNodeAlive()
res <- isNodeAlive(list())
print(res)
stopifnot(is.na(res))

## Test on a cluster object
cl <- makeClusterPSOCK(1L)
print(cl)
res <- isNodeAlive(cl)
print(res)
stopifnot(is.logical(res), length(res) == 1L)
parallel::stopCluster(cl)

## Test isNodeAlive() for RichSOCKnode with missing PID
cl <- makeClusterPSOCK(1L)
node <- cl[[1]]
node$session_info$process$pid <- NULL
res <- isNodeAlive(node)
print(res)
stopifnot(is.na(res))
parallel::stopCluster(cl)

## Test isNodeAlive() for RichSOCKnode with missing hostname
cl <- makeClusterPSOCK(1L)
node <- cl[[1]]
node$session_info$system$nodename <- NULL
res <- isNodeAlive(node)
print(res)
stopifnot(is.na(res))
parallel::stopCluster(cl)

## Test isNodeAlive() for RichSOCKnode with timeout
cl <- makeClusterPSOCK(1L)
node <- cl[[1]]
res <- isNodeAlive(node, timeout = 1.0)
print(res)
stopifnot(is.logical(res), length(res) == 1L)
parallel::stopCluster(cl)
message("- isNodeAlive.RichSOCKnode (with timeout) ... DONE")

## Test isNodeAlive() for RichSOCKnode with invalid PID (triggers error handler)
message("- isNodeAlive.RichSOCKnode (with invalid PID) ...")
cl <- makeClusterPSOCK(1L)
node <- cl[[1]]
## Set an invalid PID to trigger error in pid_exists()
node$session_info$process$pid <- -1L
res <- tryCatch({
  isNodeAlive(node)
}, warning = function(w) {
  message("  Caught expected warning: ", conditionMessage(w))
  NA
})
print(res)
stopifnot(is.na(res))
parallel::stopCluster(cl)
message("- isNodeAlive.RichSOCKnode (with invalid PID) ... DONE")

## Remote host tests use 'echo' as a fake rshcmd, which behaves differently
## on Windows vs Unix. Run these tests only on Unix/macOS.
if (.Platform[["OS.type"]] != "windows") {

  ## Test isNodeAlive() for RichSOCKnode on "remote" host (triggers remote code path)
  message("- isNodeAlive.RichSOCKnode (remote host path) ...")
  cl <- makeClusterPSOCK(1L)
  node <- cl[[1]]
  ## Set a fake remote hostname to trigger the remote host code path
  node$session_info$system$nodename <- "fake-remote-host.invalid"
  ## Set up rshcmd so the system() call runs but returns invalid output
  ## This exercises the result parsing code (lines 135-156)
  options <- attr(node, "options")
  options$rshcmd <- "echo"  ## 'echo' will just print the command, not execute it
  options$rscript_sh <- c("sh", "sh")
  attr(node, "options") <- options
  ## Use a short timeout to avoid long waits
  res <- tryCatch({
    suppressWarnings(isNodeAlive(node, timeout = 1.0))
  }, warning = function(w) {
    message("  Caught expected warning: ", conditionMessage(w))
    NA
  }, error = function(e) {
    message("  Caught error: ", conditionMessage(e))
    NA
  })
  print(res)
  stopifnot(is.na(res))
  parallel::stopCluster(cl)
  message("- isNodeAlive.RichSOCKnode (remote host path) ... DONE")

  ## Test remote host path with user option (covers line 108)
  message("- isNodeAlive.RichSOCKnode (remote host with user) ...")
  cl <- makeClusterPSOCK(1L)
  node <- cl[[1]]
  node$session_info$system$nodename <- "fake-remote-host.invalid"
  options <- attr(node, "options")
  options$rshcmd <- "echo"
  options$rscript_sh <- c("sh", "sh")
  options$arguments$user <- "testuser"  ## Triggers line 108
  attr(node, "options") <- options
  res <- tryCatch({
    suppressWarnings(isNodeAlive(node, timeout = 1.0))
  }, warning = function(w) NA, error = function(e) NA)
  print(res)
  stopifnot(is.na(res))
  parallel::stopCluster(cl)
  message("- isNodeAlive.RichSOCKnode (remote host with user) ... DONE")

  ## Test remote host path with small timeout (covers line 119)
  message("- isNodeAlive.RichSOCKnode (remote host with small timeout) ...")
  cl <- makeClusterPSOCK(1L)
  node <- cl[[1]]
  node$session_info$system$nodename <- "fake-remote-host.invalid"
  options <- attr(node, "options")
  options$rshcmd <- "echo"
  options$rscript_sh <- c("sh", "sh")
  attr(node, "options") <- options
  ## Use a timeout less than 1 second to trigger line 119
  res <- tryCatch({
    suppressWarnings(isNodeAlive(node, timeout = 0.5))
  }, warning = function(w) NA, error = function(e) NA)
  print(res)
  stopifnot(is.na(res))
  parallel::stopCluster(cl)
  message("- isNodeAlive.RichSOCKnode (remote host with small timeout) ... DONE")

  ## Test remote host path with debug mode (covers debug lines)
  message("- isNodeAlive.RichSOCKnode (remote host with debug) ...")
  cl <- makeClusterPSOCK(1L)
  node <- cl[[1]]
  node$session_info$system$nodename <- "fake-remote-host.invalid"
  options <- attr(node, "options")
  options$rshcmd <- "echo"
  options$rscript_sh <- c("sh", "sh")
  attr(node, "options") <- options
  ## Enable debug mode to cover debug lines
  opts <- options(parallelly.debug = TRUE)
  res <- tryCatch({
    suppressWarnings(isNodeAlive(node, timeout = 1.0))
  }, warning = function(w) NA, error = function(e) NA)
  options(opts)
  print(res)
  stopifnot(is.na(res))
  parallel::stopCluster(cl)
  message("- isNodeAlive.RichSOCKnode (remote host with debug) ... DONE")

} ## if (.Platform[["OS.type"]] != "windows")


message("*** isNodeAlive() ... DONE")
