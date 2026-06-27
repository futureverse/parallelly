# Options Used by the 'parallelly' Package

Below are the R options and environment variables that are used by the
parallelly package and packages enhancing it.\
\
*WARNING: Note that the names and the default values of these options
may change in future versions of the package. Please use with care until
further notice.*

## Configuring number of parallel workers

The below R options and environment variables control the default
results of
[`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
and
[`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md).

- `parallelly.availableCores.logical`::

  (logical) The default value of argument `logical` as used by
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md),
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md),
  and
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  for querying `parallel::detectCores(logical = logical)`. The default
  is `TRUE` just like it is for
  [`parallel::detectCores()`](https://rdrr.io/r/parallel/detectCores.html).

- `parallelly.availableCores.methods`::

  (character vector) Default lookup methods for
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md).
  (Default:
  `c("system", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc", "mc.cores", "BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "LSF", "PJM", "PBS", "SGE", "Slurm", "fallback", "custom")`)

- `parallelly.availableCores.custom`::

  (function) If set and a function, then this function will be called
  (without arguments) by
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  where its value, coerced to an integer, is interpreted as a number of
  cores.

- `parallelly.availableCores.fallback`::

  (integer) The default number of cores to use when no core-specifying
  settings are detected other than `"system"` and `"nproc"`. This
  options makes it possible to set the default number of cores returned
  by
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  /
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  yet allow users and schedulers to override it. In multi-tenant
  environment, such as HPC clusters, it is useful to set environment
  variable `R_PARALLELLY_AVAILABLECORES_FALLBACK` to `1`, which will set
  this option when the package is loaded.

- `parallelly.availableCores.system`::

  (integer) The default number of "system" cores used instead of what is
  reported by
  [`availableCores`](https://parallelly.futureverse.org/reference/availableCores.md)`(which = "system")`.
  This option allows you to effectively override what
  [`parallel::detectCores()`](https://rdrr.io/r/parallel/detectCores.html)
  reports the system has.

- `parallelly.availableCores.min`::

  (integer) The default minimum number of cores
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  is allowed to return. This can be used to force multiple cores on a
  single-core environment. If this is limit is applied, the names of the
  returned value are appended with an asterisk (`*`). (Default: `1L`)

- `parallelly.availableCores.fraction`::

  (numeric; in `[0,1]`) The default fraction of cores to keep.

- `parallelly.availableCores.omit`::

  (integer; non-negative) The default number of cores to set aside, i.e.
  not to include.

- `parallelly.availableCores.max`::

  (integer; positive) The default maximum number of cores to return.

- `parallelly.availableWorkers.methods`::

  (character vector) Default lookup methods for
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md).
  (Default:
  `c("mc.cores", "BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "LSF", "PJM", "PBS", "SGE", "Slurm", "custom", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc", "system", "fallback")`)

- `parallelly.availableWorkers.custom`::

  (function) If set and a function, then this function will be called
  (without arguments) by
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  where its value, coerced to a character vector, is interpreted as
  hostnames of available workers.

## Configuring forked parallel processing

The below R options and environment variables control the default result
of
[`supportsMulticore()`](https://parallelly.futureverse.org/reference/supportsMulticore.md).

- `parallelly.fork.enable`::

  (logical) Enable or disable *forked* processing. If `FALSE`, multicore
  futures becomes sequential futures. If `NA`, or not set (the default),
  the a set of best-practices rules decide whether should be supported
  or not.

- `parallelly.supportsMulticore.disableOn`::

  (character vector) because the environment in which R runs is
  considered unstable for forked processing. If this vector contains
  `"rstudio_console"`, it is disabled when running R in the RStudio
  Console. If this vector contains `"rstudio_terminal"`, it is disabled
  when running R in the RStudio Terminal. (Default:
  `c("rstudio_console")`)

- `parallelly.supportsMulticore.unstable`::

  (character) Controls whether a warning should be produced or not
  whenever multicore processing is automatically disabled per settings
  in option `parallelly.supportsMulticore.disableOn`. If `"warn"`
  (default), then an informative warning is produces the first time
  'multicore' futures are used. If `"quiet"`, no warning is produced.

## Configuring setup of parallel PSOCK clusters

The below R options and environment variables control the default
results of
[`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
and its helper function
[`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
that creates the individual cluster nodes.

- `parallelly.maxWorkers.localhost`::

  (two numerics) Maximum number of localhost workers, relative to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md),
  accepted and allowed. The first element specifies the "soft" limit,
  which triggers a warning, if exceeded. The second element specifies
  the "hard" limit, which triggers an error if exceeded. These limits
  exist to protect against CPU overuse of the current machine, which
  sometimes happens by mistake without the user causing it being aware.
  These limits can be disabled by setting them to `+Inf` (not
  recommended). If only the first exist, no error is produced (defaults
  to `c(1.0, 3.0)` corresponding to a maximum 100% and 300% use).

- `parallelly.makeNodePSOCK.setup_strategy`::

  (character) If `"parallel"` (default), the PSOCK cluster nodes are set
  up concurrently. If `"sequential"`, they are set up sequentially.

- `parallelly.makeNodePSOCK.validate`::

  (logical) If TRUE (default), after the nodes have been created, they
  are all validated that they work by inquiring about their session
  information, which is saved in attribute `session_info` of each node.

- `parallelly.makeNodePSOCK.connectTimeout`::

  (numeric) The maximum time (in seconds) allowed for each socket
  connection between the master and a worker to be established (defaults
  to 2\*60 seconds = 2 minutes).

- `parallelly.makeNodePSOCK.timeout`::

  (numeric) The maximum time (in seconds) allowed to pass without the
  master and a worker communicate with each other (defaults to
  30*24*60\*60 seconds = 30 days).

- `parallelly.makeNodePSOCK.useXDR`::

  (logical) If FALSE (default), the communication between master and
  workers, which is binary, will use small-endian (faster), otherwise
  big-endian ("XDR"; slower).

- `parallelly.makeNodePSOCK.socketOptions`::

  (character string) If set to another value than `"NULL"`, then option
  `socketOptions` is set to this value on the workers during startup.
  See
  [`base::socketConnection()`](https://rdrr.io/r/base/connections.html)
  for details. (defaults to `"no-delay"`)

- `parallelly.makeNodePSOCK.rscript_call`::

  (character string or R expression) The R expression that is used to
  start the R worker event loop on the worker node. (defaults to
  `"workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()"`)

- `parallelly.makeNodePSOCK.rshcmd`::

  (character vector) The command to be run on the master to launch a
  process on another host.

- `parallelly.makeNodePSOCK.rshopts`::

  (character vector) Addition command-line options appended to `rshcmd`.
  These arguments are only applied when connecting to non-localhost
  machines.

- `parallelly.makeNodePSOCK.tries`::

  (integer) The maximum number of attempts done to launch each node.
  Only used when setting up cluster nodes using the sequential strategy.

- `parallelly.makeNodePSOCK.tries.delay`::

  (numeric) The number of seconds to wait before trying to launch a
  cluster node that failed to launch previously. Only used when setting
  up cluster nodes using the sequential strategy.

## Options for debugging

- `parallelly.debug`::

  (logical) If `TRUE`, extensive debug messages are generated. (Default:
  `FALSE`)

- `parallelly.makeNodePSOCK.calls`::

  (logical) If TRUE, then the call stack that launched the cluster node
  is revealed as a string part of the system call such that it can be
  viewed using tools such as `ps`. (Default: `FALSE`)

## Environment variables that set R options

All of the above R `parallelly.*` options can be set by corresponding
environment variables `R_PARALLELLY_*` *when the parallelly package is
loaded*. For example, if
`R_PARALLELLY_MAKENODEPSOCK_SETUP_STRATEGY="sequential"`, then option
`parallelly.makeNodePSOCK.setup_strategy` is set to `"sequential"`
(character). Similarly, if `R_PARALLELLY_AVAILABLECORES_FALLBACK="1"`,
then option `parallelly.availableCores.fallback` is set to `1`
(integer).

## Backward compatibility with the future package

The functions in the parallelly package originates from the future
package. Because they are widely used within the future ecosystem, we
need to keep them backward compatible for quite a long time, in order
for all existing packages and R scripts to have time to adjust. This
also goes for the R options and the environment variables used to
configure these functions. All options and environment variables used
here have prefixes `parallelly.` and `R_PARALLELLY_`, respectively.
Because of the backward compatibility with the future package, the same
settings can also be controlled by options and environment variables
with prefixes `future.` and `R_FUTURE_` until further notice, e.g.
setting option `future.availableCores.fallback=1` is the same as setting
option `parallelly.availableCores.fallback=1`, and setting environment
variable `R_FUTURE_AVAILABLECORES_FALLBACK=1` is the same as setting
`R_PARALLELLY_AVAILABLECORES_FALLBACK=1`.

## See also

To set R options when R starts (even before the parallelly package is
loaded), see the [Startup](https://rdrr.io/r/base/Startup.html) help
page. The [startup](https://cran.r-project.org/package=startup) package
provides a friendly mechanism for configuring R's startup process.

## Examples

``` r
# Set an R option:
options(parallelly.availableCores.fallback = 1L)

```
