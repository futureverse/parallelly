# Parallel Workers on High-Performance Compute Environments

## Introduction

This vignette illustrates how to launch parallel workers in
high-performance compute (HPC) environments. The examples show how to
launch both single-node and multi-node workers as allotted by the job
schedulers and reflected by
[`parallelly::availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md).

On many HPC clusters, SSH access to compute nodes is disabled. Instead,
parallel workers on other compute nodes that are part of the same job
are launched via the job scheduler. All examples below use
`rshcmd = "<hpc>"` for this. It identifies the job scheduler from the
environment variables of the job that R runs in, and uses the
corresponding launcher:

- `"<srun>"` (Slurm), if `SLURM_JOB_ID` is set
- `"<qrsh>"` (Grid Engine), if `PE_HOSTFILE` is set
- `"<pjrsh>"` (Fujitsu Technical Computing Suite), if `PJM_JOBID` is set

If none of them are set, `rshcmd = "<hpc>"` produces an error. Use
`rshcmd = c("<hpc>", "<ssh>")` to have it fall back to SSH.

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
  rshcmd = "<hpc>",
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

Note how `rshcmd = "<hpc>"` makes parallel workers to be launched via
Slurm’s `srun` command from the main R session. Since R runs in a Slurm
job, `SLURM_JOB_ID` is set, and `"<hpc>"` therefore resolves to
`"<srun>"`. By design, argument `rshcmd` is only used for workers
running on *other* machines - the argument is ignored for the workers
that are launched on the current machine. This is what makes the above
setup to work regardless whether the workers are on the current or other
machines, or a mix.

Note also that the default, built-in approach to connect to other
machines via SSH does not work on HPC clusters where SSH to compute
nodes is disabled. In contrast, `srun` establishes the connection for
us.

Specifically, `"<srun>"` launches each worker using:

``` sh
srun --exact --overlap --overcommit --nodes=1 --ntasks=1 --cpus-per-task=1 -w <hostname> ...
```

The `--cpus-per-task=1` Slurm option makes sure each worker launched via
`srun` is allotted a single CPU. The `--overcommit` option is needed for
older versions of Slurm, e.g. Slurm 21.08, where otherwise a worker
waits for the CPUs of the other workers on the same machine, despite
`--overlap`. If you need different `srun` options, you can specify them
explicitly,
e.g. `rshcmd = c("srun", "--exact", "--overlap", "--nodes=1", "--ntasks=1", "--cpus-per-task=1", "-w")`.
Note that if you are on an older version of Slurm, e.g. Slurm 21.08, you
need to include `--overcommit` as well.

Here is the output from one such run, where the scheduler happened to
allot the slots across 3 machines:

``` sh
Information on R:
Rscript (R) version 4.6.1 (2026-06-24)
Running R script:
Socket cluster with 16 nodes where 10 nodes are on host 'localhost'
(R version 4.6.1 (2026-06-24), platform x86_64-pc-linux-gnu), 2 
nodes are on host 'node14' (R version 4.6.1 (2026-06-24), 
platform x86_64-pc-linux-gnu), 2 nodes are on host 'node15' (R
version 4.6.1 (2026-06-24), platform x86_64-pc-linux-gnu), 2 nodes
are on host 'node16' (R version 4.6.1 (2026-06-24), platform 
x86_64-pc-linux-gnu)
[1] 671.4629
```

What
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
and
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
return depends on what we request from Slurm, and on where R runs,
i.e. in the job script, in the interactive shell of `salloc`, or in a
task launched by `srun`. Here is what they returned on real Slurm
clusters, where `n1` is the machine running the job script:

| Slurm options | Where R runs | [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md) | [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md) |
|----|----|----|----|
| (none), hyperthreaded | job script | 2 | 2 × `n1` |
| (none), not hyperthreaded | job script | 1 | 1 × `n1` |
| `--ntasks=16 --cpus-per-task=1` | job script | 16 | 16 × `n1` |
| `--nodes=1 --ntasks=4` | job script | 4 | 4 × `n1` |
| `--nodes=1 --ntasks=4 --cpus-per-task=2` | job script | 8 | 8 × `n1` |
| `--ntasks=1 --cpus-per-task=4` | job script | 4 | 4 × `n1` |
| `--cpus-per-task=3`, hyperthreaded | job script | 4 | 4 × `n1` |
| `--cpus-per-task=3`, not hyperthreaded | job script | 3 | 3 × `n1` |
| `--nodes=1 --exclusive` | job script | all CPUs on `n1`, e.g. 336 | all CPUs × `n1` |
| `--nodes=2 --ntasks=2`, hyperthreaded | job script | 2 | 2 × `n1`, 2 × `n2` |
| `--nodes=2 --ntasks=2`, not hyperthreaded | job script | 1 | 1 × `n1`, 1 × `n2` |
| `--nodes=2 --ntasks-per-node=2` | job script | 2 | 2 × `n1`, 2 × `n2` |
| `--nodes=2 --ntasks=4 --cpus-per-task=2` | job script | 6 | 6 × `n1`, 2 × `n2` |
| `--nodes=2 --ntasks=16` | job script | 9 | 9 × `n1`, 8 × `n2` |
| `--nodes=2 --ntasks=16`, another cluster | job script | 2 | 2 × `n1`, 14 × `n2` |
| `--nodes=2 --ntasks=16 --cpus-per-task=3` | job script | 46 | 46 × `n1`, 4 × `n2` |
| `--nodes=4 --ntasks=16 --cpus-per-task=1` | job script | 2 | 2 × `n1`, 10 × `n2`, 2 × `n3`, 2 × `n4` |
| `--nodes=2 --ntasks=4` | `salloc` shell | 2 | 2 × `n1`, 2 × `n2` |
| `--nodes=2` | `srun` task | 2 | 2 × `n1`, 2 × `n2` |
| `--nodes=1-2 --ntasks=16` | `srun` task | 1 | 16 × `n1`, 2 × `n2` |
| `--nodes=2 --ntasks=4 --cpus-per-task=3` | `srun` task | 3 | 9 × `n1`, 4 × `n2` |

Note how
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
returns 1 worker per CPU allotted, not 1 per task, and how
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
returns the number of CPUs allotted on the current machine. Slurm does
not necessarily spread the CPUs evenly across machines, and the machine
running the job script does not necessarily get the most. For instance,
`--nodes=2 --ntasks=16` gave 9 + 8 CPUs on one cluster and 2 + 14 on
another. Also, on machines with hyperthreading, Slurm allots whole CPU
cores, meaning that, for instance, `--cpus-per-task=3` may result in 4
CPUs. In a task launched by `srun`,
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
returns the number of CPUs of that task, whereas
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
still returns all the workers of the job.

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
  rshcmd = "<hpc>",
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

it will by default request 8 slots - on one or more machines, which then
R and **parallelly** will set up a parallel cluster on. Exactly on which
machines depends on where the job scheduler finds these requested slots.

Note how `rshcmd = "<hpc>"` makes parallel workers to be launched via
SGE’s `qrsh` command from the main R session. Since R runs in a parallel
environment of an SGE job, `PE_HOSTFILE` is set, and `"<hpc>"` therefore
resolves to `"<qrsh>"`, which launches each worker using
`qrsh -inherit -nostdin -V <hostname> ...`. By design, argument `rshcmd`
is only used for workers running on *other* machines - the argument is
ignored for the workers that are launched on the current machine. This
is what makes the above setup to work regardless whether the workers are
on the current or other machines, or a mix.

Note also that the default, built-in approach to connect to other
machines via SSH does not work on HPC clusters where SSH to compute
nodes is disabled. In contrast, `qrsh` establishes the connection for
us.

Here is the output from one such run, where the scheduler happened to
allot the slots across 3 machines:

``` sh
Information on R:
Rscript (R) version 4.6.1 (2026-06-24)
Running R script:
Socket cluster with 8 nodes where 4 nodes are on host ‘localhost’
(R version 4.6.1 (2026-06-24), platform x86_64-pc-linux-gnu), 3
nodes are on host ‘node130’ (R version 4.6.1 (2026-06-24), 
platform x86_64-pc-linux-gnu), 1 node is on host ‘node16’ (R 
version 4.6.1 (2026-06-24), platform x86_64-pc-linux-gnu)
[1] 671.4629
```

How SGE distributes the requested slots across machines depends on the
`allocation_rule` setting of the parallel environment (PE), which we can
inspect using `qconf -sp <pe>`. Here is what
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
and
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
returned on a real SGE cluster, where `n1` is the machine running the
job script. The last two rows are for processes launched via
`qrsh -inherit`, e.g. parallel workers launched using
`rshcmd = "<qrsh>"`:

| SGE options | Allocation rule | Where R runs | [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md) | [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md) |
|----|----|----|----|----|
| (none) | \- | job script | 1 | `localhost` |
| `-pe smp 1` | `$pe_slots` | job script | 1 | 1 × `n1` |
| `-pe smp 4` | `$pe_slots` | job script | 4 | 4 × `n1` |
| `-pe smp 16` | `$pe_slots` | job script | 16 | 16 × `n1` |
| `-pe smp 4 -binding linear:4` | `$pe_slots` | job script | 4 | 4 × `n1` |
| `-pe mpi 8`, fits on 1 machine | `$fill_up` | job script | 8 | 8 × `n1` |
| `-pe mpi 4`, spans 2 machines | `$fill_up` | job script | 2 | 2 × `n1`, 2 × `n2` |
| `-pe mpi 16`, spans 4 machines | `$fill_up` | job script | 3 | 3 × `n1`, 10 × `n2`, 1 × `n3`, 2 × `n4` |
| `-pe mpi-2 4` | `2` | job script | 2 | 2 × `n1`, 2 × `n2` |
| `-pe mpi-2 8` | `2` | job script | 2 | 2 × `n1`, 2 × `n2`, 2 × `n3`, 2 × `n4` |
| `-pe mpi-2 16` | `2` | job script | 2 | 2 × `n1`, 2 × `n2`, …, 2 × `n8` |
| `-pe mpi-2 16` | `2` | `qrsh -inherit` on `n1` | 2 | 2 × `localhost` |
| `-pe mpi-2 16` | `2` | `qrsh -inherit` on another machine | 2 | 2 × `localhost` |

Per `man sge_pe`, the `$pe_slots` rule places all slots on a single
machine, `$fill_up` fills up one machine before moving on to the next
one, as in the above example run, and a fixed number, here 2, places
that many slots on each machine. In all cases,
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
returns the number of slots on the current machine. This is also true
for processes launched via `qrsh -inherit`, both on the machine running
the job script and on the other machines, where
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
returns that many workers on `localhost`.

Although they look like ones, note that `$pe_slots` and `$fill_up` are
*not* environment variables, but SGE allocation rules. SGE allocation
rules are described in `man sge_pe`.

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
  rshcmd = "<hpc>",
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

to request 18 CPU cores on 3 compute nodes, which in total requests
3\*18=54 compute slots.

Note how `rshcmd = "<hpc>"` makes parallel workers to be launched via
the Fujitsu Technical Computing Suite’s `pjrsh` command from the main R
session. Since R runs in a PJM job, `PJM_JOBID` is set, and `"<hpc>"`
therefore resolves to `"<pjrsh>"`, which launches each worker using
`pjrsh <hostname> ...`. As in the above examples, argument `rshcmd` is
only used for workers running on *other* machines.

## Avoid overusing the CPUs via nested parallelism

In all of the above examples, the parallel workers are set up with
`rscript_startup = quote(options(mc.cores = 1L))`. This sets R option
`mc.cores` to 1 in each worker, which makes
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
report a single CPU core when called in a worker.

This matters for workers running on the same machine as the main R
session. They are launched directly, rather than via the job scheduler,
which means they inherit the settings of the main R session. For
example, if the job scheduler allotted 8 CPU cores on that machine,
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
would report 8 cores in each of the 8 workers there. If the code
evaluated by the workers parallelizes further based on
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md),
e.g.

``` r

y <- parLapply(cl = cl, X, fun = function(x) {
  parallel::mclapply(x, FUN = slow_fcn, mc.cores = parallelly::availableCores())
})
```

then there could be up to 64 R processes competing for 8 CPU cores. With
`mc.cores = 1L`,
[`mclapply()`](https://rdrr.io/r/parallel/mclapply.html) runs
sequentially in each worker, which avoids overusing the CPUs.

This is not needed when using the cluster via the
**[future](https://future.futureverse.org)** framework,
e.g. `plan(cluster, workers = cl)`, because futures are evaluated with
`mc.cores` set to 1 on parallel workers.
