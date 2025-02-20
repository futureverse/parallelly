## Register makeClusterMPI() and makeClusterPSOCK() as a cluster types
## such that they can be created using parallel::makeCluster(), e.g.
## cl <- parallel::makeCluster(..., type = parallelly::RPSOCK)

#' @rawNamespace export(RMPI)
RMPI   <- "parallelly::RMPI"

#' @rawNamespace export(RPSOCK)
RPSOCK <- "parallelly::RPSOCK"
 
#' @rawNamespace if (getRversion() >= "4.4") export(SEQ)
SEQ <- "parallelly::SEQ"

registerClusterTypes <- local({
  done <- FALSE
  
  function() {
    if (done) return()
    
    ns <- getNamespace("parallel")
    ## Only available in R (>= 4.5.0)
    if (!exists("registerClusterType", envir = ns)) return()
    
    registerClusterType <- get("registerClusterType", envir = ns)

    ## WORKAROUND: 'R CMD build' somehow creates and calls this function
    ## twice, resulting in warnings from parallel::registerClusterType().
    suppressWarnings({
      registerClusterType(RMPI,   makeClusterMPI,        make.default = FALSE)
      registerClusterType(RPSOCK, makeClusterPSOCK,      make.default = FALSE)
      registerClusterType(SEQ,    makeClusterSequential, make.default = FALSE)
    })
    done <<- TRUE
  }
})
