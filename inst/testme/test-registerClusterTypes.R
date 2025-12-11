library(parallelly)

message("registerClusterTypes() ...")

## Local functions
ns <- getNamespace("parallel")

## Skip if parallel::registerClusterType() is not supported
if (!exists("registerClusterType", envir = ns)) {
  message("Skipping, parallel::registerClusterType() is not available")
} else {
  ## (a) Reset
  env <- environment(registerClusterTypes)
  stopifnot(is.environment(env))
  env$done <- FALSE
  
  ## (b) Register
  registerClusterTypes()
  
  ## (c) Reset again
  env$done <- FALSE
  
  ## (d) Register again
  registerClusterTypes()

  ## (e) Trying to use a registered cluster type
  cl <- parallel::makeCluster(1L, type = RPSOCK)
  print(cl)
  stopifnot(inherits(cl, "RichSOCKcluster"))
  parallel::stopCluster(cl)
} ## if (!exists("registerClusterType", ...))

message("registerClusterTypes() ... DONE")
