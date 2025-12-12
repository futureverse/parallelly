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


message("*** isNodeAlive() ... DONE")
