# Create a "parallel" cluster running sequentially in the current session

The created cluster has only one node.

## Usage

``` r
makeClusterSequential()
```

## Details

Expression and function calls are evaluated in a local environment,
inheriting the global environment.

## Requirements

This function is only defined for R (\>= 4.4.0).

## Examples

``` r
library(parallel)

cl <- makeClusterSequential()
print(cl)
#> A ‘sequential_cluster’ cluster with 1 node

y <- parLapply(cl, X = 1:3, fun = sqrt)
str(y)
#> List of 3
#>  $ : num 1
#>  $ : num 1.41
#>  $ : num 1.73

pid <- Sys.getpid()
print(pid)
#> [1] 1080469
y <- clusterEvalQ(cl, Sys.getpid())
str(y)
#> List of 1
#>  $ : int 1080469

abc <- 3.14
y <- clusterEvalQ(cl, { abc <- 42; abc })
str(y)
#> List of 1
#>  $ : num 42
stopifnot(abc == 3.14)

clusterExport(cl, "abc", envir = environment())
rm(abc)
y <- clusterEvalQ(cl, { abc })
str(y)
#> List of 1
#>  $ : num 3.14
stopifnot(y[[1]] == 3.14)
```
