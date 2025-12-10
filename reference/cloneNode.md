# Clone one or more nodes

Clone one or more nodes

## Usage

``` r
cloneNode(x, ...)
```

## Arguments

- x:

  A cluster node or a cluster.

- ...:

  Optional arguments overriding the recorded ones.

## Value

An object of class `class(x)`.

## Examples

``` r
# \donttest{
cl <- makeClusterPSOCK(2)
print(cl)
#> Socket cluster with 2 nodes on host ‘localhost’ (R version 4.5.2 (2025-10-31), platform x86_64-pc-linux-gnu)

## Terminate the second cluster node
parallel::stopCluster(cl[2])

## Show that cluster node #2 is no longer alive (wait a bit first)
Sys.sleep(1.0)
print(isNodeAlive(cl))
#> [1]  TRUE FALSE
print(cl)
#> Socket cluster with 2 nodes on host ‘localhost’ (R version 4.5.2 (2025-10-31), platform x86_64-pc-linux-gnu). 1 node (#2) has a broken connection (ERROR: invalid connection)

## "Restart" it
cl[2] <- cloneNode(cl[2])
print(cl)
#> Socket cluster with 2 nodes on host ‘localhost’ (R version 4.5.2 (2025-10-31), platform x86_64-pc-linux-gnu)

## Check all nodes
print(isNodeAlive(cl))
#> [1] TRUE TRUE
# }
```
