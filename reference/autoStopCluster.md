# Automatically Stop a Cluster when Garbage Collected

Registers a finalizer to a cluster such that the cluster will be stopped
when garbage collected

## Usage

``` r
autoStopCluster(cl, debug = FALSE)
```

## Arguments

- cl:

  A cluster object created by for instance
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  or
  [`parallel::makeCluster()`](https://rdrr.io/r/parallel/makeCluster.html).

- debug:

  If TRUE, then debug messages are produced when the cluster is garbage
  collected.

## Value

The cluster object with attribute `gcMe` set.

## Details

The cluster is stopped using
[`stopCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(cl)`. An
alternative to explicitly call this function on an existing `cluster`
object, is to create the `cluster` object using
[`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
with argument `autoStop = TRUE`.

## Examples

``` r
cl <- makeClusterPSOCK(2, dryrun = TRUE)
#> ----------------------------------------------------------------------
#> Manually, start worker #1 on local machine ‘localhost’ with:
#> 
#>   '/home/hb/shared/software/CBI/_ubuntu24_04/R-4.5.2-gcc13/lib/R/bin/Rscript' --default-packages=datasets,utils,grDevices,graphics,stats,methods -e 'options(socketOptions="no-delay")' -e 'workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()' MASTER=localhost PORT=11833 OUT=/dev/null TIMEOUT=2592000 XDR=FALSE SETUPTIMEOUT=120 SETUPSTRATEGY=sequential
#> 
#> ----------------------------------------------------------------------
#> Manually, start worker #2 on local machine ‘localhost’ with:
#> 
#>   '/home/hb/shared/software/CBI/_ubuntu24_04/R-4.5.2-gcc13/lib/R/bin/Rscript' --default-packages=datasets,utils,grDevices,graphics,stats,methods -e 'options(socketOptions="no-delay")' -e 'workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()' MASTER=localhost PORT=11833 OUT=/dev/null TIMEOUT=2592000 XDR=FALSE SETUPTIMEOUT=120 SETUPSTRATEGY=sequential
#> 
cl <- autoStopCluster(cl)
print(cl)
#> Socket cluster with 2 nodes on host ‘NA’ (R version and platform not queried). This cluster is registered to be automatically stopped by the garbage collector
rm(list = "cl")
gc()
#>           used (Mb) gc trigger  (Mb) max used  (Mb)
#> Ncells 1025005 54.8    1999108 106.8  1999108 106.8
#> Vcells 1887537 14.5    8388608  64.0  5104343  39.0
```
