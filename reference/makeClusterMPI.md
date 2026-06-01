# Create a Rich Message Passing Interface (MPI) Cluster of R Workers for Parallel Processing

The `makeClusterMPI()` function creates an MPI cluster of R workers for
parallel processing. This function utilizes
`makeCluster(..., type = "MPI")` of the parallel package and tweaks the
cluster in an attempt to avoid
[`stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html) from
hanging (1). *WARNING: This function is very much in a beta version and
should only be used if `parallel::makeCluster(..., type = "MPI")`
fails.*

## Usage

``` r
makeClusterMPI(
  workers,
  ...,
  autoStop = FALSE,
  verbose = isTRUE(getOption("parallelly.debug"))
)
```

## Arguments

- workers:

  The number workers (as a positive integer).

- autoStop:

  If TRUE, the cluster will be automatically stopped using
  [`stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html) when it
  is garbage collected, unless already stopped. See also
  [`autoStopCluster()`](https://parallelly.futureverse.org/reference/autoStopCluster.md).

- verbose:

  If TRUE, informative messages are outputted.

- ...:

  Optional arguments passed to
  [`makeCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(workers, type = "MPI", ...)`.

## Value

An object of class `c("RichMPIcluster", "MPIcluster", "cluster")`
consisting of a list of `"MPInode"` workers.

## Details

*Creating MPI clusters requires that the Rmpi and snow packages are
installed.*

## Alternative usage

In R (\>= 4.5.0), an alternative to using
`cl <- parallelly::makeClusterMPI(workers)` is:

    cl <- parallel::makeCluster(workers, type = parallelly::RMPI)

## References

1.  R-sig-hpc thread [Rmpi: mpi.close.Rslaves()
    'hangs'](https://stat.ethz.ch/pipermail/r-sig-hpc/2017-September/002065.html)
    on 2017-09-28.

## See also

[`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
and
[`parallel::makeCluster()`](https://rdrr.io/r/parallel/makeCluster.html).

## Examples

``` r
if (FALSE) { # \dontrun{
if (requireNamespace("Rmpi") && requireNamespace("snow")) {
  cl <- makeClusterMPI(2, autoStop = TRUE)
  print(cl)
  y <- parLapply(cl, X = 1:3, fun = sqrt)
  print(y)
  rm(list = "cl")
}
} # }
```
