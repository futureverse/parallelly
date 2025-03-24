library(parallelly)
library(parallel)

message("*** makeClusterMPI() ...")

pkg <- "Rmpi"
if (fullTest && requireNamespace(pkg, quietly = TRUE)) {
  cl <- makeClusterMPI(2L)
  str(cl)
  
  res <- parLapply(cl, X = 1:2, fun = function(x) {
    list(
      hostname = Sys.info()[["nodename"]],
      pid      = Sys.getpid(),
      value    = x^2
    )
  })
  utils::str(res)
  y <- vapply(res, FUN = `[[`, "value", FUN.VALUE = NA_real_)
  stopifnot(identical(y, c(1, 4)))

  stopCluster(cl)
  str(cl)
}

message("*** makeClusterMPI() ... DONE")
