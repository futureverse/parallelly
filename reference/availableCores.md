# Get Number of Available Cores on The Current Machine

The current/main R session counts as one, meaning the minimum number of
cores available is always at least one.

## Usage

``` r
availableCores(
  constraints = NULL,
  methods = getOption2("parallelly.availableCores.methods", c("system",
    "/proc/self/status", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max",
    "nproc", "mc.cores", "BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "LSF",
    "PJM", "PBS", "SGE", "Slurm", "fallback", "custom")),
  na.rm = TRUE,
  logical = getOption2("parallelly.availableCores.logical", TRUE),
  default = c(current = 1L),
  which = c("min", "max", "all"),
  omit = getOption2("parallelly.availableCores.omit", 0L),
  max = getOption2("parallelly.availableCores.max", Inf)
)
```

## Arguments

- constraints:

  An optional character specifying under what constraints ("purposes")
  we are requesting the values. For instance, on systems where multicore
  processing is not supported (i.e. Windows), using
  `constraints = "multicore"` will force a single core to be reported.
  Using `constraints = "connections"`, will append `"connections"` to
  the `methods` argument. It is possible to specify multiple
  constraints, e.g. `constraints = c("connections", "multicore")`.

- methods:

  A character vector specifying how to infer the number of available
  cores.

- na.rm:

  If TRUE, only non-missing settings are considered/returned.

- logical:

  Passed to
  [`detectCores`](https://rdrr.io/r/parallel/detectCores.html)`(logical = logical)`,
  which, *if supported*, returns the number of logical CPUs (TRUE) or
  physical CPUs/cores (FALSE). At least as of R 4.2.2, `detectCores()`
  ignores this argument on Linux. This argument is only used if argument
  `methods` includes `"system"`.

- default:

  The default number of cores to return if no non-missing settings are
  available.

- which:

  A character specifying which settings to return. If `"min"` (default),
  the minimum value is returned. If `"max"`, the maximum value is
  returned (be careful!) If `"all"`, all values are returned.

- omit:

  (integer; non-negative) Number of cores to not include.

- max:

  (integer; positive) Maximum number of cores returned.
  `availableCores(..., max = n)` is short for
  `min(n, availableCores(...), na.rm = TRUE)`.

## Value

Return a positive (\>= 1) integer. If `which = "all"`, then more than
one value may be returned. Together with `na.rm = FALSE` missing values
may also be returned.

## Details

The following settings ("methods") for inferring the number of cores are
supported:

- `"system"` - Query
  [`detectCores`](https://rdrr.io/r/parallel/detectCores.html)`(logical = logical)`.

- `"/proc/self/status"` - Query `Cpus_allowed_list` of
  `/proc/self/status`.

- `"cgroups.cpuset"` - On Unix, query control group (cgroup v1) value
  `cpuset.set`.

- `"cgroups.cpuquota"` - On Unix, query control group (cgroup v1) value
  `cpu.cfs_quota_us` / `cpu.cfs_period_us`.

- `"cgroups2.cpu.max"` - On Unix, query control group (cgroup v2) values
  `cpu.max`.

- `"nproc"` - On Unix, query system command `nproc`.

- `"mc.cores"` - If available, returns the value of option
  [`mc.cores`](https://rdrr.io/r/base/options.html). Note that
  `mc.cores` is defined as the number of *additional* R processes that
  can be used in addition to the main R process. This means that with
  `mc.cores = 0` all calculations should be done in the main R process,
  i.e. we have exactly one core available for our calculations. The
  `mc.cores` option defaults to environment variable `MC_CORES` (and is
  set accordingly when the parallel package is loaded). The `mc.cores`
  option is used by for instance `mclapply()` of the parallel package.

- `"connections"` or `"connections-N"` - Query the current number of
  available R connections per
  [`freeConnections()`](https://parallelly.futureverse.org/reference/availableConnections.md).
  This is the maximum number of socket-based **parallel** cluster nodes
  that are possible to launch, because each one needs its own R
  connection. The `"connections-N"` form (e.g. `connections-16`) works
  like `"connections"` but uses `freeConnections() - N` as the upper
  limit, leaving `N` connections free for other purposes. The exception
  is when the result is zero or less, then `1L` is still returned,
  because `availableCores()` should always return a positive integer.

- `"BiocParallel"` - Query environment variable
  `BIOCPARALLEL_WORKER_NUMBER` (integer), which is defined and used by
  **BiocParallel** (\>= 1.27.2). If the former is set, this is the
  number of cores considered.

- `"_R_CHECK_LIMIT_CORES_"` - Query environment variable
  `_R_CHECK_LIMIT_CORES_` (logical or `"warn"`) used by `R CMD check`
  and set to true by `R CMD check --as-cran`. In addition, package
  parallelly sets `_R_CHECK_LIMIT_CORES_=true` when *loaded* if it
  detects that `R CMD` is running and *builds* package vignettes via
  `R CMD build` and `R CMD check`, which is something `R CMD check` does
  not do itself. If `_R_CHECK_LIMIT_CORES_` is set to a non-false value,
  then a maximum of 2 cores is considered.

- `"Bioconductor"` - Query environment variable `IS_BIOC_BUILD_MACHINE`
  (logical) used by the Bioconductor (\>= 3.16) build and check system.
  If set to true, then a maximum of 4 cores is considered.

- `"LSF"` - Query Platform Load Sharing Facility (LSF)/OpenLava
  environment variable `LSB_DJOB_NUMPROC`. Jobs with multiple (CPU)
  slots can be submitted on LSF using
  `bsub -n 2 -R "span[hosts=1]" < hello.sh`.

- `"PJM"` - Query Fujitsu Technical Computing Suite (that we choose to
  shorten as "PJM") environment variables `PJM_VNODE_CORE` and
  `PJM_PROC_BY_NODE`. The first is set when submitted with
  `pjsub -L vnode-core=8 hello.sh`.

- `"PBS"` - Query TORQUE/PBS environment variables `PBS_NUM_PPN` and
  `NCPUS`. Depending on PBS system configuration, these *resource*
  parameters may or may not default to one. An example of a job
  submission that results in this is `qsub -l nodes=1:ppn=2`, which
  requests one node with two cores.

- `"SGE"` - Query the "Grid Engine" scheduler environment variable
  `NSLOTS`. An example of a job submission that results in this is
  `qsub -pe smp 2` (or `qsub -pe by_node 2`), which requests two cores
  on a single machine. Known Grid Engine schedulers are Oracle Grid
  Engine (OGE; acquired Sun Microsystems in 2010), Univa Grid Engine
  (UGE; fork of open-source SGE 6.2u5), Altair Grid Engine (AGE;
  acquires Univa Corporation in 2020), Son of Grid Engine (SGE aka SoGE;
  open-source fork of SGE 6.2u5), and

- `"Slurm"` - Query Simple Linux Utility for Resource Management (Slurm)
  environment variable `SLURM_CPUS_PER_TASK`. This may or may not be
  set. It can be set when submitting a job, e.g.
  `sbatch --cpus-per-task=2 hello.sh` or by adding
  `#SBATCH --cpus-per-task=2` to the `hello.sh` script. If
  `SLURM_CPUS_PER_TASK` is not set, then it will fall back to use
  `SLURM_CPUS_ON_NODE` if the job is a single-node job
  (`SLURM_JOB_NUM_NODES` is 1), e.g. `sbatch --ntasks=2 hello.sh`. To
  make sure all tasks are assigned to a single node, specify
  `--nodes=1`, e.g. `sbatch --nodes=1 --ntasks=16 hello.sh`.

- `"custom"` - If option
  [`parallelly.availableCores.custom`](https://parallelly.futureverse.org/reference/zzz-parallelly.options.md)
  is set and a function, then this function will be called (without
  arguments) and it's value will be coerced to an integer, which will be
  interpreted as a number of available cores. If the value is NA, then
  it will be ignored. It is safe for this custom function to call
  `availableCores()`; if done, the custom function will *not* be
  recursively called.

For any other value of a `methods` element, the R option with the same
name is queried. If that is not set, the system environment variable is
queried. If neither is set, a missing value is returned.

## Avoid ending up with zero cores

Note that some machines might have a limited number of cores, or the R
process runs in a container or a cgroup that only provides a small
number of cores. A real-world example is when you run R in webR – webR
is single-core by design. Another example are free Posit Cloud accounts,
which are limited to a single core. In such cases

    ncores <- availableCores() - 1

may return zero, which is often not intended and is likely to give an
error downstream. Instead, use:

    ncores <- availableCores(omit = 1)

to put aside one of the cores from being used. Regardless how many cores
you put aside, this function is guaranteed to return at least one core.

## Advanced usage for package developers

It is possible to emulate a larger number of CPU cores than what the
machine has. This can be useful to reproduce errors reported by users on
large system. For instance, even if your machine only has 16 cores, you
can trick `availableCores()` to believe there are 192 cores, by:

    options(parallelly.availableCores.methods = "system")
    options(parallelly.availableCores.system = 192)
    availableCores()
    #> system
    #>    192
    freeConnections()
    availableCores(constraints = "connections-16")
    #> connections-16
    #>            109

To achieve the same from outside of R, for instance, when running
`R CMD check`, set the the corresponding environment variables, e.g.

    $ export R_PARALLELLY_AVAILABLECORES_SYSTEM=192
    $ export R_PARALLELLY_AVAILABLECORES_METHODS=system
    $ Rscript -e parallelly::availableCores
    system
       192
    $ Rscript -e parallelly::availableCores --constraints="connections-16"
    connections-16
               109

## See also

To get the set of available workers regardless of machine, see
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md).

## Examples

``` r
message(paste("Number of cores available:", availableCores()))
#> Number of cores available: 192

if (FALSE) { # \dontrun{
options(mc.cores = 2L)
message(paste("Number of cores available:", availableCores()))
} # }

if (FALSE) { # \dontrun{
## IMPORTANT: availableCores() may return 1L
options(mc.cores = 1L)
ncores <- availableCores() - 1      ## ncores = 0
ncores <- availableCores(omit = 1)  ## ncores = 1
message(paste("Number of cores to use:", ncores))
} # }

if (FALSE) { # \dontrun{
## Use 75% of the cores on the system but never more than four
options(parallelly.availableCores.custom = function() {
  ncores <- max(parallel::detectCores(), 1L, na.rm = TRUE)
  ncores <- min(as.integer(0.75 * ncores), 4L)
  max(1L, ncores)
})
message(paste("Number of cores available:", availableCores()))

## Use 50% of the cores according to availableCores(), e.g.
## allocated by a job scheduler or cgroups.
## Note that it is safe to call availableCores() here.
options(parallelly.availableCores.custom = function() {
  0.50 * parallelly::availableCores()
})
message(paste("Number of cores available:", availableCores()))
} # }
```
