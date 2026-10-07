# Parallel Workers on the Local Machine

## Introduction

This vignette illustrates how to launch parallel workers on the current,
local machine. This works the same on all operating systems where R is
supported, e.g. Linux, macOS, and MS Windows.

## Examples

### Example: Launching two parallel workers

The below illustrates how to launch a cluster of two parallel workers on
the current machine, run some basic calculations in parallel, and then
shut down the cluster.

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`parallelly`](https://parallelly.futureverse.org)`)`\
[`library`](https://rdrr.io/r/base/library.html)`(``parallel``)`\
\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(``2``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``cl``)`\
`#> Socket cluster with 2 nodes on host 'localhost' (R version 4.6.1`\
`#> (2026-06-24), platform x86_64-pc-linux-gnu)`\
\
`y`` ``<-`` `[`parLapply`](https://rdrr.io/r/parallel/clusterApply.html)`(``cl``, X ``=`` ``1``:``100``, fun ``=`` ``sqrt``)`\
`y`` ``<-`` `[`unlist`](https://rdrr.io/r/base/unlist.html)`(``y``)`\
`z`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``y``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``z``)`\
`#> [1] 671.4629`\
\
`parallel``::`[`stopCluster`](https://rdrr.io/r/parallel/makeCluster.html)`(``cl``)`

*Comment*: In the **parallel** package, a parallel worker is referred to
a parallel node, or short *node*, which is why we use the same term in
the **parallelly** package.

An alternative to specifying the *number* of parallel workers is to
specify a character vector with that number of `"localhost"` entries,
e.g.

\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"localhost"``, ``"localhost"``)``)`

### Example: Launching as many parallel workers as allotted

The
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
function will return the number of workers that the system allows. It
respects many common settings that control the number of CPU cores that
the current R process is allotted, e.g. R options, environment
variables, and CGroups settings. For details, see
[`help("availableCores")`](https://parallelly.futureverse.org/reference/availableCores.md).
For example,

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`parallelly`](https://parallelly.futureverse.org)`)`\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(`[`availableCores`](https://parallelly.futureverse.org/reference/availableCores.md)`(``)``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``cl``)`\
`#> Socket cluster with 8 nodes on host 'localhost' (R version 4.6.1`\
`#> (2026-06-24), platform x86_64-pc-linux-gnu)`
