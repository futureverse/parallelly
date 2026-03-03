# Get Set of Available Workers

Get Set of Available Workers

## Usage

``` r
availableWorkers(
  constraints = NULL,
  methods = getOption2("parallelly.availableWorkers.methods", c("mc.cores",
    "BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "LSF", "PJM", "PBS", "SGE",
    "Slurm", "custom", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc",
    "system", "fallback")),
  na.rm = TRUE,
  logical = getOption2("parallelly.availableCores.logical", TRUE),
  default = getOption2("parallelly.localhost.hostname", "localhost"),
  which = c("auto", "min", "max", "all"),
  ...
)
```

## Arguments

- constraints:

  An optional character specifying under what constraints ("purposes")
  we are requesting the values. Using `constraints = "connections"`,
  will append `"connections"` to the `methods` argument.

- methods:

  A character vector specifying how to infer the number of available
  cores.

- na.rm:

  If TRUE, only non-missing settings are considered/returned.

- logical:

  Passed as-is to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md).

- default:

  The default set of workers.

- which:

  A character specifying which set / sets to return. If `"auto"`
  (default), the first non-empty set found. If `"min"`, the minimum
  value is returned. If `"max"`, the maximum value is returned (be
  careful!) If `"all"`, all values are returned.

- ...:

  Additional named arguments pass to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md).

## Value

Return a character vector of workers, which typically consists of names
of machines / compute nodes, but may also be IP numbers.

## Details

The default set of workers for each method is
`rep("localhost", times = availableCores(methods = method, logical = logical))`,
which means that each will at least use as many parallel workers on the
current machine that
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
allows for that method.

In addition, the following settings ("methods") are also acknowledged:

- `"LSF"` - Query Platform Load Sharing Facility (LSF)/OpenLava
  environment variable `LSB_HOSTS`.

- `"PJM"` - Query Fujitsu Technical Computing Suite (that we choose to
  shorten as "PJM") the hostname file given by environment variable
  `PJM_O_NODEINF`. The `PJM_O_NODEINF` file lists the hostnames of the
  nodes allotted. This function returns those hostnames each repeated
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  times, where
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  reflects `PJM_VNODE_CORE`. For example, for
  `pjsub -L vnode=2 -L vnode-core=8 hello.sh`, the `PJM_O_NODEINF` file
  gives two hostnames, and `PJM_VNODE_CORE` gives eight cores per host,
  resulting in a character vector of 16 hostnames (for two unique
  hostnames).

- `"PBS"` - Query TORQUE/PBS environment variable `PBS_NODEFILE`. If
  this is set and specifies an existing file, then the set of workers is
  read from that file, where one worker (node) is given per line. An
  example of a job submission that results in this is
  `qsub -l nodes=4:ppn=2`, which requests four nodes each with two
  cores.

- `"SGE"` - Query the "Grid Engine" scheduler environment variable
  `PE_HOSTFILE`. An example of a job submission that results in this is
  `qsub -pe mpi 8` (or `qsub -pe ompi 8`), which requests eight cores on
  any number of machines. Known Grid Engine schedulers are Oracle Grid
  Engine (OGE; acquired Sun Microsystems in 2010), Univa Grid Engine
  (UGE; fork of open-source SGE 6.2u5), Altair Grid Engine (AGE;
  acquired Univa Corporation in 2020), Son of Grid Engine (SGE aka SoGE;
  open-source fork of SGE 6.2u5), and

- `"Slurm"` - Query Slurm environment variable `SLURM_JOB_NODELIST`
  (fallback to legacy `SLURM_NODELIST`) and parse set of nodes. Then
  query Slurm environment variable `SLURM_JOB_CPUS_PER_NODE` (fallback
  `SLURM_TASKS_PER_NODE`) to infer how many CPU cores Slurm has allotted
  to each of the nodes. If `SLURM_CPUS_PER_TASK` is set, which is always
  a scalar, then that is respected too, i.e. if it is smaller, then that
  is used for all nodes. For example, if `SLURM_NODELIST="n1,n[03-05]"`
  (expands to `c("n1", "n03", "n04", "n05")`) and
  `SLURM_JOB_CPUS_PER_NODE="2(x2),3,2"` (expands to `c(2, 2, 3, 2)`),
  then `c("n1", "n1", "n03", "n03", "n04", "n04", "n04", "n05", "n05")`
  is returned. If in addition, `SLURM_CPUS_PER_TASK=1`, which can happen
  depending on hyperthreading configurations on the Slurm cluster, then
  `c("n1", "n03", "n04", "n05")` is returned.

- `"custom"` - If option
  [`parallelly.availableWorkers.custom`](https://parallelly.futureverse.org/reference/zzz-parallelly.options.md)
  is set and a function, then this function will be called (without
  arguments) and it's value will be coerced to a character vector, which
  will be interpreted as hostnames of available workers. It is safe for
  this custom function to call `availableWorkers()`; if done, the custom
  function will *not* be recursively called.

## Known limitations

`availableWorkers(methods = "Slurm")` will expand `SLURM_JOB_NODELIST`
using `scontrol show hostnames "$SLURM_JOB_NODELIST"`, if available. If
not available, then it attempts to parse the compressed nodelist based
on a best-guess understanding on what the possible syntax may be. One
known limitation is that "multi-dimensional" ranges are not supported,
e.g. `"a[1-2]b[3-4]"` is expanded by `scontrol` to
`c("a1b3", "a1b4", "a2b3", "a2b4")`. If `scontrol` is not available,
then any components that failed to be parsed are dropped with an
informative warning message. If no components could be parsed, then the
result of `methods = "Slurm"` will be empty.

## See also

To get the number of available workers on the current machine, see
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md).

## Examples

``` r
message(paste("Available workers:",
        paste(sQuote(availableWorkers()), collapse = ", ")))
#> Available workers: ‘localhost’, ‘localhost’, ‘localhost’, ‘localhost’, ‘localhost’, ‘localhost’, ‘localhost’, ‘localhost’

if (FALSE) { # \dontrun{
options(mc.cores = 2L)
message(paste("Available workers:",
        paste(sQuote(availableWorkers()), collapse = ", ")))
} # }

if (FALSE) { # \dontrun{
## Always use two workers on host 'n1' and one on host 'n2'
options(parallelly.availableWorkers.custom = function() {
  c("n1", "n1", "n2")
})
message(paste("Available workers:",
        paste(sQuote(availableWorkers()), collapse = ", ")))
} # }

if (FALSE) { # \dontrun{
## A 50% random subset of the available workers.
## Note that it is safe to call availableWorkers() here.
options(parallelly.availableWorkers.custom = function() {
  workers <- parallelly::availableWorkers()
  sample(workers, size = 0.50 * length(workers))
})
message(paste("Available workers:",
        paste(sQuote(availableWorkers()), collapse = ", ")))
} # }
```
