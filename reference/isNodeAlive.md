# Check whether or not the cluster nodes are alive

Check whether or not the cluster nodes are alive

## Usage

``` r
isNodeAlive(x, ...)
```

## Arguments

- x:

  A cluster or a cluster node ("worker").

- ...:

  Not used.

## Value

A logical vector of length `length(x)` with values FALSE, TRUE, and NA.
If it can be established that the process for a cluster node is running,
then TRUE is returned. If it does not run, then FALSE is returned. If
neither can be inferred, or it times out, then NA is returned.

## Details

This function works by checking whether the cluster node process is
running or not. This is done by querying the system for its process ID
(PID), which is registered by
[`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
when the node starts. If the PID is not known, the NA is returned. On
Unix and macOS, the PID is queried using
[`tools::pskill()`](https://rdrr.io/r/tools/pskill.html) with fallback
to `system("ps")`. On MS Windows, `system2("tasklist")` is used, which
may take a long time if there are a lot of processes running. For
details, see the *internal*
[`pid_exists()`](https://parallelly.futureverse.org/reference/pid_exists.md)
function.

## See also

Use
[`parallel::stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html)
to shut down cluster nodes. If that's not sufficient,
[`killNode()`](https://parallelly.futureverse.org/reference/killNode.md)
may be attempted.

## Examples

``` r
# \donttest{
cl <- makeClusterPSOCK(2)

## Check if cluster node #2 is alive
print(isNodeAlive(cl[[2]]))
#> [1] TRUE

## Check all nodes
print(isNodeAlive(cl))
#> [1] TRUE TRUE
# }
```
