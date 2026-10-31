#' @tags makeClusterPSOCK

library(parallelly)

message("*** workRPSOCK() ...")

pid_exists <- parallelly:::pid_exists

## Skip, if we cannot tell when the worker process has terminated
if (isTRUE(pid_exists(Sys.getpid()))) {

## Launch a single localhost worker that runs workRPSOCK(), with its
## output written to 'outfile'
launch_worker <- function(outfile) {
  cl <- makeClusterPSOCK(1L, rscript_call = "parallelly:::workRPSOCK()", outfile = outfile)
  pid <- parallel::clusterEvalQ(cl, Sys.getpid())[[1]]
  list(cl = cl, pid = pid)
}

## Wait for the worker process to terminate, and return its output
wait_for_worker <- function(pid, outfile, timeout = 30) {
  t0 <- Sys.time()
  while (isTRUE(pid_exists(pid))) {
    if (difftime(Sys.time(), t0, units = "secs") > timeout) {
      stop(sprintf("Worker (PID %d) did not terminate within %g seconds", pid, timeout))
    }
    Sys.sleep(0.1)
  }
  readLines(outfile, warn = FALSE)
}


message("- worker terminates without an error after stopCluster()")
outfile <- tempfile(fileext = ".log")
w <- launch_worker(outfile)
parallel::stopCluster(w$cl)
out <- wait_for_worker(w$pid, outfile)
print(out)
stopifnot(!any(grepl("Error", out, fixed = TRUE)))
file.remove(outfile)


message("- worker terminates with an informative error if parent disconnects")
outfile <- tempfile(fileext = ".log")
w <- launch_worker(outfile)
## Close the connection without sending "DONE" to the worker, e.g. as
## when the parent R process crashes
close(w$cl[[1]]$con)
out <- wait_for_worker(w$pid, outfile)
print(out)
stopifnot(any(grepl("Error: Worker (PID ", out, fixed = TRUE)))
file.remove(outfile)

}

message("*** workRPSOCK() ... DONE")
