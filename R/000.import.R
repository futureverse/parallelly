## 'parallelly' is currently importing the following non-exported functions:
## * makeClusterPSOCK():
##   - parallel:::sendCall()
##   - parallel:::recvResult()
## * isForkedChild():
##   - parallel:::isChild()
##
## This function is also used by 'future', which in addition imports:
## * cluster futures:
##   - parallel:::defaultCluster()  ## non-critical / not really needed /
##                                  ## can be dropped in R (>= 3.5.0)
##   - parallel:::sendCall()        ## future::run()
##   - parallel:::recvResult()      ## future::value()
## * multicore futures:
##   - parallel:::selectChildren()  ## future::resolved()
##   - parallel:::rmChild()         ## future::value()
## As well as the following ones (because they are not exported on MS Windows):
## * multicore futures:
##   - parallel::mcparallel()       ## future::run()
##   - parallel::mccollect()        ## future::value()
importParallel <- local({
  ns <- NULL
  cache <- list()
  
  function(name = NULL) {
    res <- cache[[name]]
    if (is.null(res)) {
      ns <<- getNamespace("parallel")

      ## SPECIAL: parallel::getDefaultCluster() was added in R 3.5.0.  The
      ## fallback in R (< 3.5.0) is to use parallel:::defaultCluster().
      ## /HB 2017-11-11
      if (name == "getDefaultCluster") {
        if (!exists(name, mode = "function", envir = ns, inherits = FALSE)) {
          name <- "defaultCluster"
        }
      }

      if (!exists(name, mode = "function", envir = ns, inherits = FALSE)) {
        ## covr: skip=3
        msg <- sprintf("parallel:::%s() is not available in R %s on this system (%s)", name, getRversion(), sQuote(.Platform[["OS.type"]]))
        mdebug(msg)
        stop(msg, call. = FALSE)
      }

      res <- get(name, mode = "function", envir = ns, inherits = FALSE)

      if (name %in% c("mccollect", "selectChildren") &&
          getRversion() >= "3.5.0" && getRversion() <= "3.5.1") {
        ## Suppress warnings produced by parallel::mccollect() and
        ## parallel::selectChildren() in R 3.5.0 and and R 3.5.1
        ## (https://github.com/HenrikBengtsson/future/issues/218), e.g.
        ##
        ##  "Warning in selectChildren(pids[!fin], -1) :
        ##   cannot wait for child 32193 as it does not exist"
        ##
        res_org <- res
        res <- function(...) suppressWarnings(res_org(...))
      }
      
      cache[[name]] <<- res
    }
    res
  }
})
