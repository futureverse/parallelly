library(parallelly)

message("*** cloneNode() ...")

## Test cloneNode.default
message("- cloneNode.default ...")
res <- tryCatch(cloneNode(list()), error = identity)
print(res)
stopifnot(inherits(res, "error"))
message("- cloneNode.default ... DONE")


## Test cloneNode.RichSOCKnode
message("- cloneNode.RichSOCKnode ...")
cl <- makeClusterPSOCK(1L)
node <- cl[[1]]

## method = "as-is"
node_asis <- cloneNode(node, method = "as-is")
print(node_asis)
stopifnot(inherits(node_asis, "RichSOCKnode"))

## method = "vanilla"
node_vanilla <- cloneNode(node, method = "vanilla", setup_strategy = "sequential")
print(node_vanilla)
stopifnot(inherits(node_vanilla, "RichSOCKnode"))

## With overridden arguments
node_args <- cloneNode(node, method = "vanilla", setup_strategy = "sequential", user = "testuser")
print(node_args)
stopifnot(inherits(node_args, "RichSOCKnode"))


parallel::stopCluster(cl)

cl_asis <- list(node_asis)
class(cl_asis) <- class(cl)
parallel::stopCluster(cl_asis)

cl_vanilla <- list(node_vanilla)
class(cl_vanilla) <- class(cl)
parallel::stopCluster(cl_vanilla)

cl_args <- list(node_args)
class(cl_args) <- class(cl)
parallel::stopCluster(cl_args)
message("- cloneNode.RichSOCKnode ... DONE")


## Test cloneNode.cluster
message("- cloneNode.cluster ...")
cl <- makeClusterPSOCK(2L)
print(cl)
cl2 <- cloneNode(cl)
print(cl2)
stopifnot(
  inherits(cl2, "cluster"),
  length(cl2) == length(cl)
)
parallel::stopCluster(cl)
parallel::stopCluster(cl2)
message("- cloneNode.cluster ... DONE")

## Test "restarting" a dead node
message("- Restarting a dead node ...")
cl <- makeClusterPSOCK(2)
print(cl)
## Terminate the second cluster node
parallel::stopCluster(cl[2])
## Show that cluster node #2 is no longer alive (wait a bit first)
Sys.sleep(1.0)
print(isNodeAlive(cl))
cl[2] <- cloneNode(cl[2])
print(cl)
print(isNodeAlive(cl))
stopifnot(all(isNodeAlive(cl)))
parallel::stopCluster(cl)
message("- Restarting a dead node ... DONE")

message("*** cloneNode() ... DONE")
