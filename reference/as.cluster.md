# Coerce an Object to a Cluster Object

Coerce an Object to a Cluster Object

## Usage

``` r
as.cluster(x, ...)

# S3 method for class 'cluster'
as.cluster(x, ...)

# S3 method for class 'list'
as.cluster(x, ...)

# S3 method for class 'SOCKnode'
as.cluster(x, ...)

# S3 method for class 'SOCK0node'
as.cluster(x, ...)

# S3 method for class 'RichSOCKnode'
as.cluster(x, ...)

# S3 method for class 'cluster'
c(..., recursive = FALSE)
```

## Arguments

- x:

  An object to be coerced.

- recursive:

  Not used.

- ...:

  Additional arguments passed to the underlying coercion method. For
  `c(...)`, the clusters and cluster nodes to be combined.

## Value

An object of class `cluster`.

`c(...)` combine multiple clusters and / or cluster nodes into one
cluster returned as an of class `cluster`. A warning will be produced if
there are duplicated nodes in the resulting cluster.

## Examples

``` r
cl1 <- makeClusterPSOCK(2, dryrun = TRUE)
#> ----------------------------------------------------------------------
#> Manually, start worker #1 on local machine ‘localhost’ with:
#> 
#>   '/home/hb/shared/software/CBI/_ubuntu24_04/R-4.5.3-gcc13/lib/R/bin/Rscript' --default-packages=datasets,utils,grDevices,graphics,stats,methods -e 'options(socketOptions="no-delay")' -e 'workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()' MASTER=localhost PORT=11362 OUT=/dev/null TIMEOUT=2592000 XDR=FALSE SETUPTIMEOUT=120 SETUPSTRATEGY=sequential
#> 
#> ----------------------------------------------------------------------
#> Manually, start worker #2 on local machine ‘localhost’ with:
#> 
#>   '/home/hb/shared/software/CBI/_ubuntu24_04/R-4.5.3-gcc13/lib/R/bin/Rscript' --default-packages=datasets,utils,grDevices,graphics,stats,methods -e 'options(socketOptions="no-delay")' -e 'workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()' MASTER=localhost PORT=11362 OUT=/dev/null TIMEOUT=2592000 XDR=FALSE SETUPTIMEOUT=120 SETUPSTRATEGY=sequential
#> 
cl2 <- makeClusterPSOCK(c("n1", "server.remote.org"), dryrun = TRUE)
#> ----------------------------------------------------------------------
#> Manually, (i) login into external machine ‘n1’:
#> 
#>   '/usr/bin/ssh' -R 11202:localhost:11202 n1
#> 
#> and (ii) start worker #1 from there:
#> 
#>   '/home/hb/shared/software/CBI/_ubuntu24_04/R-4.5.3-gcc13/lib/R/bin/Rscript' --default-packages=datasets,utils,grDevices,graphics,stats,methods -e 'options(socketOptions="no-delay")' -e 'workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()' MASTER=localhost PORT=11202 OUT=/dev/null TIMEOUT=2592000 XDR=FALSE SETUPTIMEOUT=120 SETUPSTRATEGY=sequential
#> 
#> Alternatively, start worker #1 from the local machine by combining both steps in a single call:
#> 
#>   '/usr/bin/ssh' -R 11202:localhost:11202 n1 "'/home/hb/shared/software/CBI/_ubuntu24_04/R-4.5.3-gcc13/lib/R/bin/Rscript' --default-packages=datasets,utils,grDevices,graphics,stats,methods -e 'options(socketOptions=\"no-delay\")' -e 'workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()' MASTER=localhost PORT=11202 OUT=/dev/null TIMEOUT=2592000 XDR=FALSE SETUPTIMEOUT=120 SETUPSTRATEGY=sequential"
#> 
#> ----------------------------------------------------------------------
#> Manually, (i) login into external machine ‘server.remote.org’:
#> 
#>   '/usr/bin/ssh' -R 11203:localhost:11202 server.remote.org
#> 
#> and (ii) start worker #2 from there:
#> 
#>   'Rscript' --default-packages=datasets,utils,grDevices,graphics,stats,methods -e 'options(socketOptions="no-delay")' -e 'workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()' MASTER=localhost PORT=11203 OUT=/dev/null TIMEOUT=2592000 XDR=FALSE SETUPTIMEOUT=120 SETUPSTRATEGY=sequential
#> 
#> Alternatively, start worker #2 from the local machine by combining both steps in a single call:
#> 
#>   '/usr/bin/ssh' -R 11203:localhost:11202 server.remote.org "'Rscript' --default-packages=datasets,utils,grDevices,graphics,stats,methods -e 'options(socketOptions=\"no-delay\")' -e 'workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()' MASTER=localhost PORT=11203 OUT=/dev/null TIMEOUT=2592000 XDR=FALSE SETUPTIMEOUT=120 SETUPSTRATEGY=sequential"
#> 
cl <- c(cl1, cl2)
#> Warning: The combined cluster contains 3 duplicated nodes
print(cl)
#> Socket cluster with 4 nodes on host ‘NA’ (R version and platform not queried)
```
