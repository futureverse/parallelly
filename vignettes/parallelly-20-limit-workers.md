<!--
%\VignetteIndexEntry{Parallel Workers with CPU and Memory Limited}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

This vignette gives examples how to restrict CPU and memory usage of
parallel workers. This can useful for optimizing the performance of
the parallel workers, but also lower the risk that they overuse the
CPU and memory on the machines they are running on.


# Examples

## Example: Linux parallel workers with a lower process priority ("nice")

On Unix, we can run any process with a lower CPU priority using the
`nice` command. This can be used when we want to lower the risk of
negatively affecting other users and processes that run on the same
machine from our R workers overusing the CPUs by mistake. To achieve
this, we can prepend `nice` to the `Rscript` call via the `rscript`
argument using. This works both on local and remote Linux machines,
e.g.

```r
library(parallelly)
cl <- makeClusterPSOCK(2, rscript = c("nice", "*"))
```

```r
library(parallelly)
workers <- rep("n1.remote.org", 2)
cl <- makeClusterPSOCK(2, rscript = c("nice", "*"))
```

The special `*` value expands to the proper `Rscript` on the machine
where the parallel workers are launched.



## Example: Linux parallel workers CPU and memory limited by CGroups

This example launches two parallel workers each limited to 100% CPU
quota and 50 MiB of memory using Linux CGroups management. The 100%
CPU quota limit constrain each worker to use at most one CPU worth of
processing preventing them from overusing the machine, e.g.  through
unintended nested parallelization. For more details, see `man
systemd.resource-control`.

```r
library(parallelly)
cl <- makeClusterPSOCK(
  2L,
  rscript = c(
    "systemd-run", "--user", "--scope",
    "-p", "CPUQuota=100%",
    "-p", "MemoryMax=50M", "-p", "MemorySwapMax=50M",
    "*"
  )
)
```

Note, depending on your CGroups configuration, a non-privileged user
may or may not be able to set the CPU quota. If not, the `-p
CPUQuota=100%` will be silently ignored.

The 50 MiB memory limit is strict - if a worker use more than this,
the operating system will terminate the worker instantly. To
illustrate what happens, we first start by generating 1 million
numeric values each consuming 8 bytes, which in total consumes ~8 MB,
and then calculate the mean, the memory consumption is within 50-MiB
memory limit that each parallel worker has available;

```r
library(parallel)
mu <- clusterEvalQ(cl, { x <- rnorm(n = 1e6); mean(x) })
mu <- unlist(mu)
print(mu)
#> [1]  0.0008072657 -0.0019693992
```

However, if we generate 10 times more values, the memory consumption
will grow to at least 80 MB, which is over then 50-MiB memory limit,
and we will get an error:

```r
mu <- clusterEvalQ(cl, { x <- rnorm(n = 10e6); mean(x) })
#> Error in unserialize(node$con) : error reading from connection
```

This is because the operating system terminated the two background R
processes, because they overused the memory. This is why the main R
process no longer can communicate with the parallel workers.  We can
see that both workers are down, by calling:

```r
isNodeAlive(cl)
#> [1] FALSE FALSE
```

We can use `cloneNode()` to relaunch workers that are no longer
alive, e.g.

```r
is_down <- !isNodeAlive(cl)
cl[is_down] <- cloneNode(cl[is_down])
isNodeAlive(cl)
#> [1] TRUE TRUE
```


## Example: MS Windows parallel workers with specific CPU affinities

This example, works only on MS Windows machines. It launches four
local workers, where two are running on CPU Group #0 and two on CPU
Group #1.

```r
library(parallelly)
rscript <- I(c(
  Sys.getenv("COMSPEC"), "/c", 
  "start", "/B",
  "/NODE", cpu_group=NA_integer_, 
  "/AFFINITY", "0xFFFFFFFFFFFFFFFE", 
  "*")
)

rscript["cpu_group"] <- 0
cl_0 <- makeClusterPSOCK(2, rscript = rscript)

rscript["cpu_group"] <- 1
cl_1 <- makeClusterPSOCK(2, rscript = rscript)

cl <- c(cl_0, cl_1)
```

The special `*` value expands to the proper `Rscript` on the machine
where the parallel workers are launched.

<!-- See also: https://lovickconsulting.com/2021/11/18/running-r-clusters-on-an-amd-threadripper-3990x-in-windows-10-2/ -->
