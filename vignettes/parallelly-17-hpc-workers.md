<!--
%\VignetteIndexEntry{Parallel Workers on High-Performance Compute Environments}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteKeyword{HPC}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

This vignettes illustrates how to launch parallel workers via job
schedulers running in high-performance compute (HPC) environments.


# Examples

## Example: Launch parallel workers via the Grid Engine job scheduler

'Grid Engine' is a high-performance compute (HPC) job scheduler where
one can request compute resources on multiple nodes, each running
multiple cores. Examples of Grid Engine schedulers are Oracle Grid
Engine (formerly Sun Grid Engine), Univa Grid Engine, and Son of Grid
Engine - all commonly referred to as SGE schedulers. Each SGE cluster
may have its own configuration with their own way of requesting
parallel slots.

Consider the following two files: `script.sh` and `script.R`.

script.sh:

```sh
#! /usr/bin/env bash
#$ -cwd               ## Run in current working directory
#$ -j y               ## Merge stdout and stderr
#$ -l mem_free=100M   ## 100 MiB RAM per slot
#$ -l h_rt=00:10:00   ## 10 minutes runtime 
#$ -pe mpi 8          ## 8 compute slots

echo "Information on R:"
Rscript --version

echo "Running R script:"
Rscript script.R
```

script.R:

```r
library(parallelly)
library(parallel)

cl <- makeClusterPSOCK(
  availableWorkers(),
  rshcmd = "qrsh", rshopts = c("-inherit", "-nostdin", "-V")
)
print(cl)

# Perform calculations in parallel
X <- 1:100
y <- parLapply(cl = cl, X, fun = sqrt)
y <- unlist(y)
z <- sum(y)
print(z)

stopCluster(cl)
```

The `script.sh` file is a job script that we submit to the scheduler
that runs the R script `script.R` when launched. If we submit
`script.sh` as:

```sh
$ qsub script.sh
```

it will by default request eight slots - on one more more machines,
which then R and **parallelly** will set up a parallel cluster on. On
how many, and on which machines, the parallel workers will run on
depends on where the job scheduler finds these requested slots on. 

Here is the output from one such run, where the scheduler happened to
allot the slots across three machines:

```sh
Information on R:
Rscript (R) version 4.4.2 (2024-10-31)
Running R script:
Socket cluster with 8 nodes where 4 nodes are on host ‘localhost’
(R version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu), 3
nodes are on host ‘qb3-id130’ (R version 4.4.2 (2024-10-31), 
platform x86_64-pc-linux-gnu), 1 node is on host ‘qb3-as16’ (R 
version 4.4.2 (2024-10-31), platform x86_64-pc-linux-gnu)
[1] 671.4629
```



## Example: Launch parallel workers via the'Fujitsu Technical Computing Suite job scheduler

The 'Fujitsu Technical Computing Suite' is a high-performance compute
(HPC) job scheduler where one can request compute resources on
multiple nodes, each running multiple cores. 

Consider the following two files: `script.sh` and `script.R`.

script.sh:

```sh
#! /usr/bin/env bash

echo "Information on R:"
Rscript --version

echo "Running R script:"
Rscript script.R
```

script.R:

```r
library(parallelly)
library(parallel)

cl <- makeClusterPSOCK(
  availableWorkers(),
  rshcmd = "pjrsh"
)
print(cl)

# Perform calculations in parallel
X <- 1:100
y <- parLapply(cl = cl, X, fun = sqrt)
y <- unlist(y)
z <- sum(y)
print(z)

stopCluster(cl)
```

The `script.sh` file is a job script that we submit to the scheduler
that runs the R script `script.R` when launched. Wee can submit
`script.sh` as:

```sh
$ pjsub -L vnode=3 -L vnode-core=18 script.sh
```

to request 18 CPU cores on three compute nodes, which in total
requests 3*18=54 compute slots.
