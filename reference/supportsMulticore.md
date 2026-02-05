# Check If Forked Processing ("multicore") is Supported

Certain parallelization methods in R rely on *forked* processing, e.g.
[`parallel::mclapply()`](https://rdrr.io/r/parallel/mclapply.html),
`parallel::makeCluster(n, type = "FORK")`, `doMC::registerDoMC()`, and
`future::plan("multicore")`. Process forking is done by the operating
system and support for it in R is restricted to Unix-like operating
systems such as Linux, Solaris, and macOS. R running on Microsoft
Windows does not support forked processing. In R, forked processing is
often referred to as "multicore" processing, which stems from the 'mc'
of the [`mclapply()`](https://rdrr.io/r/parallel/mclapply.html) family
of functions, which originally was in a package named multicore which
later was incorporated into the parallel package. This function checks
whether or not forked (aka "multicore") processing is supported in the
current R session.

## Usage

``` r
supportsMulticore(...)
```

## Arguments

- ...:

  Internal usage only.

## Value

TRUE if forked processing is supported and not disabled, otherwise
FALSE.

## Support for process forking

While R supports forked processing on Unix-like operating system such as
Linux and macOS, it does not on the Microsoft Windows operating system.

For some R environments it is considered unstable to perform parallel
processing based on *forking*. This is for example the case when using
RStudio, cf. [RStudio Inc. recommends against using forked processing
when running R from within the RStudio
software](https://github.com/rstudio/rstudio/issues/2597#issuecomment-482187011).
This function detects when running in such an environment and returns
`FALSE`, despite the underlying operating system supports forked
processing. A warning will also be produced informing the user about
this the first time time this function is called in an R session. This
warning can be disabled by setting R option
`parallelly.supportsMulticore.unstable`, or environment variable
`R_PARALLELLY_SUPPORTSMULTICORE_UNSTABLE` to `"quiet"`.

## Enable or disable forked processing

It is possible to disable forked processing for futures by setting R
option `parallelly.fork.enable` to `FALSE`. Alternatively, one can set
environment variable `R_PARALLELLY_FORK_ENABLE` to `false`. Analogously,
it is possible to override disabled forking by setting one of these to
`TRUE`.

## Why not forked processing?

One reason for *not* using forked parallel processing in R is that is
not guaranteed to be stable in all environments or in all contexts,
which also depends on which functions are called in the forked
processes. Here is what R Core developer of the
[`parallel::mclapply()`](https://rdrr.io/r/parallel/mclapply.html)
family of functions said on [R-devel
(2020-04-29)](https://stat.ethz.ch/pipermail/r-devel/2020-April/079384.html):

*"Do NOT use
[`mcparallel()`](https://rdrr.io/r/parallel/mcparallel.html) in packages
except as a non-default option that user can set ... Multicore is
intended for HPC applications that need to use many cores for
computing-heavy jobs, but it does not play well with RStudio and more
importantly you \[as the developer\] don't know the resource available
so only the user can tell you when it's safe to use."*

## Examples

``` r
## Check whether or not forked processing is supported
supportsMulticore()
#> [1] TRUE
```
