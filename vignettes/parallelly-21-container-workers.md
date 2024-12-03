<!--
%\VignetteIndexEntry{Parallel Workers Running in Linux Containers}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteKeyword{Docker}
%\VignetteKeyword{Apptainer}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

This vignette shows how to set up parallel workers running in Linux
containers, e.g. Docker (<https://www.docker.com/>), Apptainer
(<https://apptainer.org/>), and udocker
(<https://indigo-dc.github.io/udocker/>).



# Examples

## Example: Two parallel workers running in Docker

This example sets up two parallel workers running Docker image
'rocker/r-parallel' (<https://hub.docker.com/r/rocker/r-parallel>).

```r
library(parallelly)
cl <- makeClusterPSOCK(
  rep("localhost", times = 2L),
  ## Launch Rscript inside Linux container via Docker
  rscript = c(
    "docker", "run", "--net=host", "rocker/r-parallel",
    "Rscript"
  ),
  ## IMPORTANT: Because Docker runs inside a virtual machine (VM) on macOS
  ## and MS Windows (not Linux), when the R worker tries to connect back to
  ## the default 'localhost' it will fail, because the main R session is
  ## not running in the VM, but outside on the host.  To reach the host on
  ## macOS and MS Windows, make sure to use master = "host.docker.internal"
  master = if (.Platform$OS.type == "unix") NULL else "host.docker.internal",
)
print(cl)
#> Socket cluster with 2 nodes where 2 nodes are on host 'localhost'
#> (R version 4.3.3 (2024-02-29), platform x86_64-pc-linux-gnu)
```


## Example: Two parallel workers running in Apptainer

This example shows how to set up two parallel workers running Docker
image 'rocker/r-parallel'
(<https://hub.docker.com/r/rocker/r-parallel>) via Apptainer
(<<https://apptainer.org/>).

```r
library(parallelly)
cl <- makeClusterPSOCK(
  rep("localhost", times = 2L),
  ## Launch Rscript inside Linux container via Apptainer
  rscript = c(
    "apptainer", "exec", "docker://rocker/r-parallel",
    "Rscript"
  )
)
print(cl)
#> Socket cluster with 2 nodes where 2 nodes are on host 'localhost'
#> (R version 3.6.1 (2019-07-05), platform x86_64-pc-linux-gnu)
```


## Example: Two parallel workers running in udocker

This example shows how to set up two parallel workers running Docker
image 'rocker/r-parallel'
(<https://hub.docker.com/r/rocker/r-parallel>) via udocker
(<https://indigo-dc.github.io/udocker/>).

```r
library(parallelly)
cl <- makeClusterPSOCK(
  rep("localhost", times = 2L),
  ## Launch Rscript inside Linux container via Docker
  rscript = c(
    "udocker", "--quiet", "run", "rocker/r-parallel",
    "Rscript"
  )
)
print(cl)
#> Socket cluster with 2 nodes where 2 nodes are on host 'localhost'
#> (R version 3.6.1 (2019-07-05), platform x86_64-pc-linux-gnu)
```
