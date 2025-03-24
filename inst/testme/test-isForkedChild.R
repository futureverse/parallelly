library(parallelly)
library(parallel)
options(parallelly.debug = FALSE)

message("*** isForkedChild() ...")

stopifnot(!isForkedChild())

if (supportsMulticore()) {
  message("- mcparallel()/mccollect()")
  f <- mcparallel(isForkedChild())
  isForked <- mccollect(f)[[1]]
  stopifnot(isForked)

  message("- makeForkCluster()")
  cl <- makeForkCluster(1L)
  isForked <- clusterEvalQ(cl, { parallelly::isForkedChild() })
  isForked <- unlist(isForked, use.names = FALSE)
  stopifnot(isForked)
  parallel::stopCluster(cl)
}

message("- mclapply()")
isForked <- mclapply(1:2, FUN = function(ii) isForkedChild())
isForked <- unlist(isForked, use.names = FALSE)
if (supportsMulticore()) {
  stopifnot(all(isForked))
} else {
  stopifnot(!any(isForked))
}

message("- makeClusterPSOCK()")
cl <- makeClusterPSOCK(1L)
isForked <- clusterEvalQ(cl, { parallelly::isForkedChild() })
isForked <- unlist(isForked, use.names = FALSE)
stopifnot(!isForked)
parallel::stopCluster(cl)

message("*** isForkedChild() ... DONE")
