message("makeClusterSequential() ...")

## Requires R (>= 4.4.0)
if (getRversion() < "4.4.0") {
  message("Skipping because R version is less than 4.4.0")
  message("makeClusterSequential() ... skipped")
} else {
  library(parallelly)

  ## Temporarily override parallel::makeCluster and parallel::stopCluster
  ## to use the sequential versions
  old_makeCluster <- parallel::makeCluster
  old_stopCluster <- parallel::stopCluster
  on.exit({
    unlockBinding("makeCluster", getNamespace("parallel"))
    assign("makeCluster", old_makeCluster, envir = getNamespace("parallel"))
    unlockBinding("stopCluster", getNamespace("parallel"))
    assign("stopCluster", old_stopCluster, envir = getNamespace("parallel"))
  }, add = TRUE)

  unlockBinding("makeCluster", getNamespace("parallel"))
  assign("makeCluster", makeClusterSequential, envir = getNamespace("parallel"))
  unlockBinding("stopCluster", getNamespace("parallel"))
  assign("stopCluster", function(cl) {
    ## Do nothing for sequential_cluster, as it's not a real parallel cluster
    ## Except for invalidating the node state
    for (node in cl) {
      if (inherits(node, "sequential_node")) {
        node$envir[["...parallelly.valid..."]] <- FALSE
      }
    }
  }, envir = getNamespace("parallel"))

  library(parallel)

  cl <- makeClusterSequential()
  stopifnot(inherits(cl, "sequential_cluster"), length(cl) == 1L)

  ## Test print.sequential_cluster
  capture.output(print(cl))

  ## Test print.sequential_node
  capture.output(print(cl[[1]]))

  ## Test basic parLapply functionality
  y <- parLapply(cl, X = 1:3, fun = sqrt)
  stopifnot(identical(y, lapply(1:3, sqrt)))

  ## Test clusterEvalQ with side effects
  abc <- 3.14
  y <- clusterEvalQ(cl, { abc <- 42; abc })
  stopifnot(identical(y, list(42)), abc == 3.14)

  ## Test stopping the cluster
  stopCluster(cl)

  ## Test accessing an invalid node (after stopCluster)
  res <- tryCatch({
    parallel::sendData(cl[[1]], list(type = "EXEC", data = list(fun = identity, args = list(1))))
  }, error = function(e) e)
  stopifnot(inherits(res, "simpleError"), grepl("node is no longer valid", res$message))


  ## Re-create cluster for other tests
  cl <- makeClusterSequential()
  node <- cl[[1]]

  ## Test sendData with "DONE" type
  parallel::sendData(node, list(type = "DONE"))
  stopifnot(!isTRUE(node$envir[["...parallelly.valid..."]]))

  ## Test sendData with unknown type
  ## Test sendData with unknown type
  ## Re-create cluster for this test, as the previous one was invalidated
  cl_unknown <- makeClusterSequential()
  node_unknown <- cl_unknown[[1]]

  res <- tryCatch({
    parallel::sendData(node_unknown, list(type = "UNKNOWN"))
  }, error = function(e) e)
  message("Error message for UNKNOWN type: ", res$message)
  stopifnot(inherits(res, "simpleError"), grepl("type = ['‘]UNKNOWN['’] not yet implemented", res$message))

  ## Test recvData internal error
  ## Re-create cluster for this test
  cl_internal_error <- makeClusterSequential()
  node_internal_error <- cl_internal_error[[1]]

  ## Manipulate internal state to trigger error
  node_internal_error$envir[["value"]] <- list(type = "BAD_TYPE")

  res <- tryCatch({
    parallel::recvData(node_internal_error)
  }, error = function(e) e)
  stopifnot(inherits(res, "simpleError"), grepl("INTERNAL ERROR", res$message))

  message("makeClusterSequential() ... done")
}