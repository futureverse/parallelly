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
  rshcmd = c("srun", "--exact", "--overlap", "--overcommit", "--nodes=1",
             "--ntasks=1", "--cpus-per-task=1", "-w"),
  rscript_sh = c("auto", "none"),
  rscript_startup = quote(options(mc.cores = 1L))
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

Parallel workers on other machines are launched via Slurm’s `srun`
command from the main R session, whereas workers on the machine running
the main R session are launched directly.

The `--cpus-per-task=1` Slurm option makes sure each worker launched via
`srun` is allotted a single CPU. The `--overcommit` option is needed for
older versions of Slurm, e.g. Slurm 21.08, where otherwise a worker
waits for the CPUs of the other workers on the same machine, despite
`--overlap`.

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

What
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
and
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
return depends on what we request from Slurm. Here are a few examples of
what they return in the job script, where `n1` is the machine running
the job script:

| Slurm options | [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md) | [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md) |
|----|----|----|
| `--nodes=1 --ntasks=4` | 4 | 4 × `n1` |
| `--nodes=1 --ntasks=4 --cpus-per-task=2` | 8 | 8 × `n1` |
| `--nodes=2 --ntasks-per-node=2` | 2 | 2 × `n1`, 2 × `n2` |
| `--nodes=2 --ntasks=4 --cpus-per-task=2` | 6 | 6 × `n1`, 2 × `n2` |

Note how
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
returns one worker per CPU allotted, not one per task, and how
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
returns the number of CPUs allotted on the current machine. The last
example shows that Slurm does not necessarily spread the tasks evenly
across machines. Also, on machines with hyperthreading, Slurm allots
whole CPU cores, meaning that, for instance, `--cpus-per-task=3` may
result in four CPUs.

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
  rshcmd = "qrsh", rshopts = c("-inherit", "-nostdin", "-V"),
  rscript_startup = quote(options(mc.cores = 1L))
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

How SGE distributes the requested slots across machines depends on the
`allocation_rule` setting of the parallel environment (PE), which we can
inspect using `qconf -sp <pe>`. Here are a few examples of what
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
and
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
return in the job script, where `n1` is the machine running the job
script:

| SGE options | Allocation rule | [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md) | [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md) |
|----|----|----|----|
| (none) | \- | 1 | `localhost` |
| `-pe smp 4` | `$pe_slots` | 4 | 4 × `n1` |
| `-pe mpi 8` | `$fill_up` | 4 | 4 × `n1`, 3 × `n2`, 1 × `n3` |
| `-pe mpi-2 8` | `2` | 2 | 2 × `n1`, 2 × `n2`, 2 × `n3`, 2 × `n4` |

The `$pe_slots` rule places all slots on a single machine, `$fill_up`
fills up one machine before moving on to the next one, as in the above
example run, and a fixed number, here two, places that many slots on
each machine. In all cases,
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
returns the number of slots on the current machine. This is also true
for workers launched on the other machines via `qrsh -inherit`.

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
  rshcmd = "pjrsh",
  rscript_startup = quote(options(mc.cores = 1L))
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

## Avoid overusing the CPUs via nested parallelism

In all of the above examples, the parallel workers are set up with
`rscript_startup = quote(options(mc.cores = 1L))`. This sets R option
`mc.cores` to one in each worker, which makes
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
report a single CPU core when called in a worker.

This matters for workers running on the same machine as the main R
session. They are launched directly, rather than via the job scheduler,
which means they inherit the settings of the main R session. For
example, if the job scheduler allotted eight CPU cores on that machine,
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
would report eight cores in each of the eight workers there. If the code
evaluated by the workers parallelizes further based on
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md),
e.g.

``` r

y <- parLapply(cl = cl, X, fun = function(x) {
  parallel::mclapply(x, FUN = slow_fcn, mc.cores = parallelly::availableCores())
})
```

then there could be up to 64 R processes competing for eight CPU cores.
With `mc.cores = 1L`,
[`mclapply()`](https://rdrr.io/r/parallel/mclapply.html) runs
sequentially in each worker, which avoids overusing the CPUs.

This is not needed when using the cluster via the
**[future](https://future.futureverse.org)** framework,
e.g. `plan(cluster, workers = cl)`, because futures are evaluated with
`mc.cores` set to one on parallel workers.
