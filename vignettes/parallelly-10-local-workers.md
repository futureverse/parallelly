<!--
%\VignetteIndexEntry{Parallel Workers on the Local Machine}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

This vignettes illustrates how to launch parallel workers on the
current, local machine. This works the same on all operating systems
where R is supported, e.g. Linux, macOS, and MS Windows.


# Examples

## Example: Launching two parallel workers

The below illustrates how to launch a cluster of two parallel workers
on the current machine, run some basic calculations in paralllel, and
then shut down the cluster.

```r
library(parallelly)
library(parallel)

cl <- makeClusterPSOCK(2)
print(cl)
#> Socket cluster with 2 nodes where 2 nodes are on host 'localhost'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu)

y <- parLapply(cl, X = 1:100, fun = sqrt)
y <- unlist(y)
z <- sum(y)
print(z)
#> [1] 671.4629

parallel::stopCluster(cl)
```

_Comment_: In the **parallel** package, a parallel worker is referred
to a parallel node, or short _node_, which is why we use the same term
in the **parallelly** package.


An alternative to specifying the _number_ of parallel workers is to
specify a character vector with that number of `"localhost"` entries,
e.g.

```r
cl <- makeClusterPSOCK(c("localhost", "localhost"))
```


## Example: Launching as many parallel workers as allotted

The `availableCores()` function will return the number of workers that
the system allows. It respects many common settings that controls the
number of CPU cores that the current R process is alloted, e.g. R
options, environment variables, and CGroups settings. For details, see
`help("availableCores")`. For example,

```r
library(parallelly)
cl <- makeClusterPSOCK(availableCores())
print(cl)
#> Socket cluster with 8 nodes where 8 nodes are on host 'localhost'
#> (R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu)
```
