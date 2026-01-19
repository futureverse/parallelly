# Terminate one or more cluster nodes using process signaling

Terminate one or more cluster nodes using process signaling

## Usage

``` r
killNode(x, signal = tools::SIGTERM, ...)
```

## Arguments

- x:

  cluster or cluster node to terminate.

- signal:

  An integer that specifies the signal level to be sent to the parallel
  R process. It's only
  [`tools::SIGINT`](https://rdrr.io/r/tools/pskill.html) (2) and
  [`tools::SIGTERM`](https://rdrr.io/r/tools/pskill.html) (15) that are
  supported on all operating systems (i.e. Unix, macOS, and MS Windows).
  All other signals are platform specific, cf.
  [`tools::pskill()`](https://rdrr.io/r/tools/pskill.html).

  With the exception of MS Windows, as explained below, using `SIGINT`
  will trigger an R
  [`interrupt`](https://rdrr.io/r/base/conditions.html) condition that
  can be caught with
  [`tryCatch()`](https://rdrr.io/r/base/conditions.html) and
  [`withCallingHandlers()`](https://rdrr.io/r/base/conditions.html)
  using an `interrupt` calling handler.

  When using `SIGTERM`, there will be no `interrupt` condition signaled,
  meaning your parallel R code does *not* have a chance to exit
  gracefully. Instead, the R process terminates rather abruptly, leaving
  behind its temporary folder.

  Importantly, contrary to Linux and macOS, it is not possible to get a
  cluster node running on MS Windows to exit gracefully. For example,
  despite using `SIGINT`, there is no `interrupt` condition signaled. As
  a matter of fact, on MS Windows, `SIGINT` works identically to
  `SIGTERM`, where they both terminate the cluster node abruptly without
  giving the R process a chance to exit gracefully. This means that R
  will *not* clean up after itself, e.g. its temporary directory will
  remain even after R terminates.

- ...:

  Not used.

## Value

TRUE if the signal was successfully applied, FALSE if not, and NA if
signaling is not supported on the specific cluster or node. *Warning*:
With R (\< 3.5.0), NA is always returned. This is due to a bug in R (\<
3.5.0), where the signaling result cannot be trusted.

## Details

Note that the preferred way to terminate a cluster is via
[`parallel::stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html),
because it terminates the cluster nodes by kindly asking each of them to
nicely shut themselves down. Using `killNode()` is a much more severe
approach. It abruptly terminates the underlying R process, possibly
without giving the parallel worker a chance to terminate gracefully. For
example, it might get terminated in the middle of writing to file.
[`tools::pskill()`](https://rdrr.io/r/tools/pskill.html) is used to send
the signal to the R process hosting the parallel worker.

If `signal = tools::SIGTERM` is used and success, this function will
also close any existing socket connection to the node, if they exist.
Moreover, if the node is running on the local host, this function will
also attempt to remove the node's temporary directory, which is done
because the node's R process might not have been exited gracefully.

## Known limitations

This function works only with cluster nodes of class `RichSOCKnode`,
which were created by
[`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md).
It does not work when using
[`parallel::makeCluster()`](https://rdrr.io/r/parallel/makeCluster.html)
and friends.

## See also

Use
[`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
to check whether one or more cluster nodes are alive.

## Examples

``` r
cl <- makeClusterPSOCK(2)
print(isNodeAlive(cl))  ## [1] TRUE TRUE
#> [1] TRUE TRUE

res <- killNode(cl)
print(res)
#> [1] TRUE TRUE

## It might take a moment before the background
## workers are shutdown after having been signaled
Sys.sleep(1.0)

print(isNodeAlive(cl))  ## [1] FALSE FALSE
#> [1] FALSE FALSE
```
