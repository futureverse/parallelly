message("isForkedNode() ...")

# 1. Test with a default object
x <- 123
res <- isForkedNode(x)
stopifnot(is.na(res))

x <- list(a = 1, b = 2)
res <- isForkedNode(x)
stopifnot(is.na(res))


# 2. Test with a forknode object
## Create a dummy forknode object
## It's enough to set its class attribute
node <- structure(list(), class = "forknode")
res <- isForkedNode(node)
stopifnot(res)


# 3. Test with a cluster object
## Create dummy cluster objects
node1 <- structure(list(), class = "forknode")
node2 <- structure(list(), class = "notforknode") ## A dummy node that is not a forknode
node3 <- structure(list(), class = "forknode")

cluster_obj <- list(node1, node2, node3)
class(cluster_obj) <- "cluster"

res <- isForkedNode(cluster_obj)
stopifnot(is.logical(res), length(res) == 3)
stopifnot(res[1])
stopifnot(is.na(res[2]))
stopifnot(res[3])

message("isForkedNode() ... done")
