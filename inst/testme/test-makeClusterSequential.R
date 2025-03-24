if (getRversion() >= "4.4.0") {
  library(parallelly)
  library(parallel)
  
  cl <- makeClusterSequential()
  print(cl)

  y_truth <- lapply(X = 1:3, FUN = sqrt)
  y <- parLapply(cl, X = 1:3, fun = sqrt)
  str(y)
  stopifnot(identical(y, y_truth))
  
  pid <- Sys.getpid()
  print(pid)
  y <- clusterEvalQ(cl, Sys.getpid())
  str(y)
  stopifnot(identical(y[[1]], pid))
  
  y <- clusterEvalQ(cl, { abc <- 42; abc })
  str(y)
  stopifnot(!exists("abc", inherits = FALSE))

  stopCluster(cl)
  print(cl)

  res <- tryCatch({
    y <- clusterEvalQ(cl, { 42 })
  }, error = identity)
  print(res)
  stopifnot(inherits(res, "error"))
} ## if (getRversion() >= "4.4.0")
