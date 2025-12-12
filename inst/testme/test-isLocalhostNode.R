library(parallelly)

message("*** isLocalhostNode() ...")

## Test isLocalhostNode.default
message("- isLocalhostNode.default ...")
res <- isLocalhostNode(list())
print(res)
stopifnot(is.na(res))
message("- isLocalhostNode.default ... DONE")

## Test isLocalhostNode.RichSOCKnode
message("- isLocalhostNode.RichSOCKnode ...")
cl <- makeClusterPSOCK(1L)
node <- cl[[1]]
print(node)
res <- isLocalhostNode(node)
print(res)
stopifnot(isTRUE(res))
parallel::stopCluster(cl)
message("- isLocalhostNode.RichSOCKnode ... DONE")

## Test isLocalhostNode.cluster
message("- isLocalhostNode.cluster ...")
cl <- makeClusterPSOCK(2L)
print(cl)
res <- isLocalhostNode(cl)
print(res)
stopifnot(is.logical(res), length(res) == 2L, all(res))
parallel::stopCluster(cl)
message("- isLocalhostNode.cluster ... DONE")

if (supportsMulticore()) {
  ## Test isLocalhostNode.forknode
  message("- isLocalhostNode.forknode ...")
  cl <- parallel::makeForkCluster(1L)
  node <- cl[[1]]
  print(node)
  res <- isLocalhostNode(node)
  print(res)
  stopifnot(isTRUE(res))
  parallel::stopCluster(cl)
  message("- isLocalhostNode.forknode ... DONE")
}

## Test isLocalhostNode.SOCKnode
message("- isLocalhostNode.SOCKnode ...")
cl <- parallel::makeCluster(1L)
node <- cl[[1]]
print(node)
res <- isLocalhostNode(node)
print(res)
stopifnot(isTRUE(res))
parallel::stopCluster(cl)
message("- isLocalhostNode.SOCKnode ... DONE")

## Test isLocalhostNode.RichSOCKnode with missing 'localhost' attribute
message("- isLocalhostNode.RichSOCKnode (no 'localhost' attr) ...")
cl <- makeClusterPSOCK(1L)
node <- cl[[1]]
attr(node$host, "localhost") <- NULL
print(node)
res <- isLocalhostNode(node)
print(res)
## Should call NextMethod() which calls isLocalhostNode.SOCKnode
stopifnot(isTRUE(res))
parallel::stopCluster(cl)
message("- isLocalhostNode.RichSOCKnode (no 'localhost' attr) ... DONE")

message("*** isLocalhostNode() ... DONE")
