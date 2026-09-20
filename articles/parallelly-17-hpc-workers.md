# Parallel Workers on High-Performance Compute Environments

## Introduction

This vignette illustrates how to launch parallel workers in
high-performance compute (HPC) environments. The examples show how to
launch multi-node workers as allotted by the job schedulers and
reflected by
[`parallelly::availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md).

## Examples

### Example: Launch parallel workers via the Slurm job scheduler

‘Slurm’ is a high-performance compute (HPC) job scheduler where one can
request compute resources on multiple nodes, each running multiple
cores.

Consider the following two files: `script.sh` and `script.R`.

script.sh:

``` sh
#! /usr/bin/env bash
#SBATCH --mem-per-cpu=100M    ## 100 MiB RAM per worker
#SBATCH --time=00:10:00       ## 10 minutes runtime 
#SBATCH --nodes=4             ## 4 compute nodes
#SBATCH --ntasks=16           ## 16 compute tasks
#SBATCH --cpus-per-task=1     ## 1 CPU per task (=> 16 workers)

echo "Information on R:"
Rscript --version

echo "Running R script:"
Rscript script.R
```

script.R:

``` r

library(parallelly)
library(parallel)

cl <- makeClusterPSOCK(
  availableWorkers(),
  rshcmd = c("srun", "--exact", "--overlap", "--nodes=1", "--ntasks=1", "-w"),
  rscript_sh = c("auto", "none")
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
that runs the R script `script.R` when launched. We can submit
`script.sh` as:

``` sh
$ sbatch script.sh
```

This will request 16 tasks (CPU slots) across 4 compute nodes.

Each parallel worker is launched via Slurm’s `srun` command from the
main R session that runs.

Here is the output from one such run, where the scheduler happened to
allot the slots across three machines:

``` sh
Information on R:
Rscript (R) version 4.6.1 (2026-06-24)
Running R script:
Socket cluster with 16 nodes where 10 nodes are on host 'localhost'
(R version 4.6.1 (2026-06-24), platform x86_64-pc-linux-gnu), 2 
nodes are on host 'gcpu2-14' (R version 4.6.1 (2026-06-24), 
platform x86_64-pc-linux-gnu), 2 nodes are on host 'gcpu2-15' (R
version 4.6.1 (2026-06-24), platform x86_64-pc-linux-gnu), 2 nodes
are on host 'gcpu2-16' (R version 4.6.1 (2026-06-24), platform 
x86_64-pc-linux-gnu)
[1] 671.4629
```

### Example: Launch parallel workers via the Grid Engine job scheduler

‘Grid Engine’ is a high-performance compute (HPC) job scheduler where
one can request compute resources on multiple nodes, each running
multiple cores. Examples of Grid Engine schedulers are Oracle Grid
Engine (formerly Sun Grid Engine), Univa Grid Engine, and Son of Grid
Engine - all commonly referred to as SGE schedulers. Each SGE cluster
may have its own configuration with its own way of requesting parallel
slots.

Consider the following two files: `script.sh` and `script.R`.

script.sh:

``` sh
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

``` r

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

``` sh
$ qsub script.sh
```

it will by default request eight slots - on one or more machines, which
then R and **parallelly** will set up a parallel cluster on. Exactly on
which machines depends on where the job scheduler finds these requested
slots.

Here is the output from one such run, where the scheduler happened to
allot the slots across three machines:

``` sh
Information on R:
Rscript (R) version 4.6.1 (2026-06-24)
Running R script:
Socket cluster with 8 nodes where 4 nodes are on host ‘localhost’
(R version 4.6.1 (2026-06-24), platform x86_64-pc-linux-gnu), 3
nodes are on host ‘qb3-id130’ (R version 4.6.1 (2026-06-24), 
platform x86_64-pc-linux-gnu), 1 node is on host ‘qb3-as16’ (R 
version 4.6.1 (2026-06-24), platform x86_64-pc-linux-gnu)
[1] 671.4629
```

### Example: Launch parallel workers via the Fujitsu Technical Computing Suite job scheduler

The ‘Fujitsu Technical Computing Suite’ is a high-performance compute
(HPC) job scheduler where one can request compute resources on multiple
nodes, each running multiple cores.

Consider the following two files: `script.sh` and `script.R`.

script.sh:

``` sh
#! /usr/bin/env bash

echo "Information on R:"
Rscript --version

echo "Running R script:"
Rscript script.R
```

script.R:

``` r

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
that runs the R script `script.R` when launched. We can submit
`script.sh` as:

``` sh
$ pjsub -L vnode=3 -L vnode-core=18 script.sh
```

to request 18 CPU cores on three compute nodes, which in total requests
3\*18=54 compute slots.
