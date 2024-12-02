<!--
%\VignetteIndexEntry{parallelly: Limit CPU and memory for parallel workers}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

...


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
unintended nested parallelization. The 50 MiB memory limit is strict -
if a worker use more than this, the operating system will terminate
the worker instantly.

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

For more details, see `man systemd.resource-control`.



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
print(cl)
```

The special `*` value expands to the proper `Rscript` on the machine
where the parallel workers are launched.

<!-- See also: https://lovickconsulting.com/2021/11/18/running-r-clusters-on-an-amd-threadripper-3990x-in-windows-10-2/ -->
