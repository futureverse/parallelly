#' @tags detrius-files

library(parallelly)

if (on_windows) {
  killNode <- function(cl) {
    parallel::stopCluster(cl)
    rep(TRUE, times = length(cl))
  }
}

options(parallelly.debug = TRUE)

message("*** killNode() and isNodeAlive() ...")

isNodeAliveSupported <- isTRUE(parallelly:::pid_exists(Sys.getpid()))
message("isNodeAlive() works: ", isNodeAliveSupported)

cl <- makeClusterPSOCK(2L, autoStop = FALSE)
names(cl) <- sprintf("Node %d", seq_along(cl))
print(cl)

## WORKAROUND: On MS Windows, each R process creates a temporary Rscript<hexcode>
## file. In this test we terminate the workers such that these temporary files
## are not cleaned up, which will trigger a NOTE by 'R CMD check'. Because of
## this, we have to make sure to remove such files manually in this test.
if (on_windows) {
  files <- setdiff(dir(path = tempdir(), all.files = TRUE), c(".", ".."))
  files <- file.path(tempdir(), files)
  tmpfiles <- files
  files <- parallel::clusterEvalQ(cl, {
    files <- setdiff(dir(path = tempdir(), all.files = TRUE), c(".", ".."))
    file.path(tempdir(), files)
  })
  files <- unlist(files)
  tmpfiles <- unique(c(tmpfiles, files))
  message(sprintf("- files: [n=%d] %s", length(tmpfiles),
                    paste(sQuote(tmpfiles), collapse = ", ")))
}

alive <- isNodeAlive(cl)
print(alive)
stopifnot(
  length(alive) == length(cl),
  is.logical(alive)
)
if (isNodeAliveSupported) {
  stopifnot(
    !anyNA(alive),
    isTRUE(alive[[1]]), isTRUE(alive[[2]]),
    all(alive)
  )
}

message("- Terminate cluster nodes")
signaled <- killNode(cl)
print(signaled)
stopifnot(
  length(signaled) == length(cl),
  is.logical(signaled)
)
## The value of tools::pskill() is incorrect in R (< 3.5.0)
if (getRversion() >= "3.5.0") {
  stopifnot(
    isTRUE(signaled[[1]]), isTRUE(signaled[[2]]),
    all(signaled)
  )
}

message("- Waiting for cluster nodes to terminate")
## It might take a moment before the background
## workers are shutdown after having been signaled
timeout <- Sys.time() + 30.0
repeat {
  alive <- isNodeAlive(cl)
  print(alive)
  stopifnot(
    length(alive) == length(cl),
    is.logical(alive)
  )
  if (!any(alive, na.rm = TRUE)) break
  if (Sys.time() > timeout) {
    stop("One or more cluster nodes are still running after 30 seconds")
  }
  Sys.sleep(0.5)
}

## Remove any stray Rscript<hexcode> files
if (on_windows) {
  if (!isNodeAliveSupported) Sys.sleep(5.0)
  tmpfiles <- tmpfiles[utils::file_test("-f", tmpfiles)]
  if (length(tmpfiles) > 0L) {
    warning(sprintf("Cleaning up temporary left-over files: [n=%d] %s",
                    length(tmpfiles),
                    paste(sQuote(tmpfiles), collapse = ", ")))
    file.remove(tmpfiles)
    tmpfiles <- tmpfiles[utils::file_test("-f", tmpfiles)]
    if (length(tmpfiles) > 0L) {
      stop(sprintf("Failed to remove some temporary left-over files: [n=%d] %s",
                   length(tmpfiles),
                   paste(sQuote(tmpfiles), collapse = ", ")))
    }
  }
}

cl <- NULL

message("*** killNode() and isNodeAlive() ... done")
