# Changelog

## Version (development version)

### New Features

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  gained argument `fraction`, which allows you to specify that a certain
  fraction of the detected CPU cores should be returned,
  e.g. `availableCores(fraction = 0.5)`.

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  queries also Linux CGroups v2 CPU affinity values `cpuset.cpus` and
  `cpuset.cpus.effective`.\`

- Give more information on invalid ‘RichSOCKnode’ connections.

### Bug Fixes

- `availableWorkers(method = "Slurm")` expands the compressed hostname
  representation given by environment variable `SLURM_JOB_NODELIST` to a
  vector of hostnames. For this it uses `scontrol show hostnames`. If
  `scontrol` is not available, it falls back to an internal parsing
  algorithm. This internal algorithm would incorrectly pad some
  hostnames with zero, e.g. `n[09-10]` would become `c("n09", "n010")`
  whereas it should be `c("n09", "n10")`.

- `availableWorkers(method = "Slurm")` did not, as documented, fall back
  to legacy environment variable `SLURM_NODELIST` when
  `SLURM_JOB_NODELIST` is not set

- `availableWorkers(method = "Slurm")` could return the wrong set of
  hostnames if environment variables `SLURM_JOB_NODELIST`,
  `SLURM_JOB_CPUS_PER_NODE` and `SLURM_CPUS_PER_TASK` were all set,
  because `SLURM_CPUS_PER_TASK` was treated as a string, not an integer,
  in comparisons.

- `makeClusterPSOCK(..., setup_strategy = "sequential")` would not
  respect internal R options for how to retry with another TCP port, if
  failing to start a cluster node.

## Version 1.46.1

CRAN release: 2026-01-08

### Bug Fixes

- Loading the package in the Positron Console would incorrectly set
  environment variable `_R_CHECK_LIMIT_CORES_` to TRUE, which in turn
  would result in
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  being limited to a maximum of two (2) CPU cores. This bug was
  introduced in **parallelly** 1.46.0 (2025-12-12).

- [`parallel::clusterExport()`](https://rdrr.io/r/parallel/clusterApply.html)
  on a
  [`makeClusterSequential()`](https://parallelly.futureverse.org/reference/makeClusterSequential.md)
  cluster would export to the global environment rather than the local
  environment of the cluster nodes.

- Argument `user` of
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  did not recycle across workers when `length(user) == 1`.

- `makeClusterPSOCK(default_packages = "*")` with an empty R option
  `defaultPackages` gave an error.

## Version 1.46.0

CRAN release: 2025-12-12

### New Features

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  returns 2 also when package vignettes are built by `R CMD build` or
  `R CMD check`. This helps to prevent package vignettes from overusing
  the CPU cores when building and checking R packages.

- Functions
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md),
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md),
  [`cpuLoad()`](https://parallelly.futureverse.org/reference/cpuLoad.md),
  and
  [`freePort()`](https://parallelly.futureverse.org/reference/freePort.md)
  can now be called directly from the command line,
  e.g. `Rscript -e parallelly::availableCores --omit=1` and
  `Rscript -e parallelly::freePort`.

### Documentation

- Option `parallelly.supportsMulticore.disableOn` was documented to
  disable forked (“multicore”) processing in the RStudio Terminal, but
  that was not the case due to a thinko. Default options and the
  documentation have now been updated to reflect that it is only
  disabled in the RStudio Console.

### Bug Fixes

- Setting option `parallelly.supportsMulticore.disableOn` to hold
  `"rstudio_terminal"` had no effect.

## Version 1.45.1

CRAN release: 2025-07-24

### Miscellaneous

- Now [`print()`](https://rdrr.io/r/base/print.html) for
  `RichSOCKcluster` outputs a more concise summary, which is also
  grammatically correct for single-node clusters.

### Deprecated and Defunct

- In the previous version,
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  started to collect session information on each parallel worker, which
  included [`capabilities()`](https://rdrr.io/r/base/capabilities.html).
  However, for unknown reasons,
  [`capabilities()`](https://rdrr.io/r/base/capabilities.html) caused
  the cluster creation to fail on GitHub Actions running macOS. The
  problem could be reproduced neither locally, on the mac-builder, nor
  on the CRAN macOS servers. Because this feature is non-critical and
  was only introduced in the previous version, I decided to remove the
  collection of
  [`capabilities()`](https://rdrr.io/r/base/capabilities.html) again.

## Version 1.45.0

CRAN release: 2025-06-02

### New Features

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  gained argument `max`, which limits the maximum number of cores
  returned after everything else is applied, i.e.
  `availableCores(..., max = n)` is short for
  `min(n, availableCores(...), na.rm = TRUE)`.

- [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  gained argument `...`, which passes any additional arguments to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md),
  if specified.

- If `killNode(..., signal = tools::SIGTERM)` successfully signaled the
  cluster node, it will now close any existing socket connection to the
  node. If the node is running on the local host, it will also remove
  its temporary directory, because the node’s R process might not have
  exited gracefully.

- The session information collected by
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now contains more details on each worker, e.g. the
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) folder,
  [`capabilities()`](https://rdrr.io/r/base/capabilities.html), and
  [`extSoftVersion()`](https://rdrr.io/r/base/extSoftVersion.html).

- Cluster nodes created by
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  gained attribute `calls`, which record the
  [`sys.calls()`](https://rdrr.io/r/base/sys.parent.html). This can be
  useful when troubleshooting from where a cluster was created.
  Analogously, setting R option `parallelly.makeNodePSOCK.calls` to TRUE
  will relay the call stack in the system call that launched the cluster
  node.

### Bug Fixes

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  would not respect `method = "fallback"` if `constraints` specified
  `"connections"` or `"connections-N"`.

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  would produce an error on
  `Error in scan(file = file, what = what, ...)` on systems that have a
  `/proc/self/mounts` file with syntax errors. Such files have been
  reported on Windows Subsystem for Linux version 2 (WSL 2), where
  spaces in Windows paths have not been properly escaped for some
  entries. Now such invalid entries are skipped, before parsing the
  mount table.

## Version 1.44.0

CRAN release: 2025-05-07

### New Features

- Add support to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  to specify `constraints = "connections-N"`, where `N` specifies the
  number of connections to leave free after launching a PSOCK cluster
  with this number of cores.

- Add [`all.equal()`](https://rdrr.io/r/base/all.equal.html) for
  `connection`, which can distinguish between two connections that share
  the same connection index, but are not the same connection, e.g. when
  one was created, then closed, and another one of the same kind is
  created.

### Bug Fixes

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  would not respect `method = "fallback"`, since v1.41.0 (2024-12-18),
  on a system with a value for `method = "/proc/self/status"`.

## Version 1.43.0

CRAN release: 2025-03-24

### Significant Changes

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  memoizes the values of all its components. This means that as soon as
  it has been called, environment variables such as `NSLOTS` will no
  longer be queried.

- Starting with R 4.5.0, one can use
  `parallel::makeCluster(n, type = parallelly::RPSOCK)` as an
  alternative to `parallelly::makeClusterPSOCK(n)`. Similarly,
  `type = parallelly::RMPI` creates a cluster using
  [`parallelly::makeClusterMPI()`](https://parallelly.futureverse.org/reference/makeClusterMPI.md),
  and `type = parallelly::SEQ` creates a cluster using
  [`parallelly::makeClusterSequential()`](https://parallelly.futureverse.org/reference/makeClusterSequential.md).
  This was first introduced in **parallelly** 1.38.0, but here we rename
  `PSOCK` to `RPSOCK` and `MPI` to `RMPI` to minimize the risk for
  mistaking them from the built-in types in the **parallel** package.
  The `R` stands for “Rich”.

### Documentation

- Add more help on the R option `parallelly.maxWorkers.localhost`
  limits. Improved the warning and error messages that are produced when
  these settings are exceeded.

### Miscellaneous

- R option `future.debug` is no longer used as a fallback for option
  `parallelly.debug`.

### Bug Fixes

- [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  could produce warnings on
  `doTryCatch(return(expr), name, parentenv, handler) : NAs introduced by coercion`
  on MS Windows. Improved the internal `tasklist` parsers used to test
  whether a process is alive.

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  could produce
  `Error: Error in cache_controller[[field]] : subscript out of bounds`
  in `... getCGroups1CpuQuota -> getCGroups1CpuPeriodMicroseconds`.

## Version 1.42.0

CRAN release: 2025-01-30

### New Features

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  support also when both CGroups v1 and CGroups v2 are enabled on the
  machine. Previously, such configurations were completely ignored.

### Bug Fixes

- Calling
  [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  and
  [`killNode()`](https://parallelly.futureverse.org/reference/killNode.md)
  on cluster nodes running on external machines would produce
  `Error in match.arg(type, choices = known_types, several.ok = FALSE) : 'arg' must be of length 1`.
  This bug was introduced in version 1.38.0 (2024-07-27), when adding
  richer support for the `rscript_sh` argument.

- Calling
  [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  and
  [`killNode()`](https://parallelly.futureverse.org/reference/killNode.md)
  on cluster nodes running on external machines would produce
  `Error: ‘length(rsh_call) == 1L’ is not TRUE` if option `rshopts` were
  specified during creation.

- The value of
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  was numeric rather than integer as documented. This harmless bug was
  introduced in version 1.31.0 (2022-04-07).

## Version 1.41.0

CRAN release: 2024-12-18

### New Features

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  queries also `/proc/self/status` for CPU affinity allotments.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  will now produce an error, rather than a warning, when the local
  system command used to launch the parallel worker failed with a
  non-zero exit code.

- Now
  [`serializedSize()`](https://parallelly.futureverse.org/reference/serializedSize.md)
  always returns a double. Previously, it would return an integer, if
  the value could be represented by an integer. However, it turned out
  that returning an integer increased the risk for integer overflow
  later on if, say, two such values were added together.

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  on MS Windows failed to launch remote workers, with warnings on
  `"In system(local_cmd, wait = FALSE, input = input) : 'C:\WINDOWS\System32\OpenSSH\ssh.exe' not found"`.
  This bug was introduced in version 1.38.0 (2024-07-27), when adding
  richer support for the `rscript_sh` argument.

## Version 1.40.1

CRAN release: 2024-12-04

### Bug Fixes

- The internal vignette engine wrote files to user’s home directory.
  They were due to a brief debugging of the vignette engine and then
  forgotten about.

## Version 1.40.0

CRAN release: 2024-12-03

### New Features

- Argument `user` of
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  may now be a vector of usernames - one for each worker specified.

### Documentation

- Add vignettes on how to setup a cluster of parallel workers on the
  local machine, on external machines, in the cloud, in HPC
  environments, and more.

### Bug Fixes

- Querying of cgroups v1 ‘cpuquota’ CPU limits broke in the previous
  release (v1.39.0).

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  could produce error
  `Failed to identify mount point for CGroups v1 controller 'cpuset'` on
  some systems.

- [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  would produce invalid warning on
  `Identified 8 workers from the ‘PE_HOSTFILE’ file (...), which is more than environment variable ‘NSLOTS’ = 8`
  when running via a Grid Engine job scheduler.

## Version 1.39.0

CRAN release: 2024-11-07

### New Features

- Environment variables `R_PARALLELLY_RANDOM_PORTS` now supports
  multiple, comma-separated port specifications, e.g. `"20001:20999"`
  and `"1068:1099,20001:20999,40530"`.

### Documentation

- Add example to
  [`help("makeClusterPSOCK")`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  on how to use `systemd-run` to limit workers’ CPU quota and memory
  allowances.

### Miscellaneous

- Improved how cgroups v1 and v2 settings are queried.

### Bug Fixes

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  does a better job detecting cgroups v2 `cpu.max` CPU restrictions.

## Version 1.38.0

CRAN release: 2024-07-27

### New Features

- Now argument `rshcmd` of
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  can be a function. It must accept at least two arguments named
  `rshopts` and `worker`. The `rshopts` argument is a character vector
  of length zero or more. The `worker` argument is a string hostname.
  The function must return a single string.

- Now
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  accepts `rscript_sh = "none"`, which skips quoting the Rscript call.

- Now
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  accepts `rscript_sh` of length one or two. If
  `length(rscript_sh) == 2`, then `rscript_sh[1]` is for the inner and
  `rscript_sh[2]` is for the outer shell quoting of the Rscript call.
  More precisely, `rscript_sh[1]` is for Rscript arguments that need
  shell quoting (e.g. `Rscript -e "<expr>"`), and `rscript_sh[2]` is for
  the whole `Rscript ...` call.

- Add
  [`makeClusterSequential()`](https://parallelly.futureverse.org/reference/makeClusterSequential.md)
  available for R (\>= 4.4.0).

- Starting with R 4.5.0 (currently R-devel), one can use
  `parallel::makeCluster(n, type = parallelly::PSOCK)` as an alternative
  to `parallelly::makeClusterPSOCK(n)`. Similarly,
  `type = parallelly::MPI` creates a cluster using
  [`parallelly::makeClusterMPI()`](https://parallelly.futureverse.org/reference/makeClusterMPI.md),
  and `type = parallelly::SEQ` creates a cluster using
  [`parallelly::makeClusterSequential()`](https://parallelly.futureverse.org/reference/makeClusterSequential.md).

- Add
  [`serializedSize()`](https://parallelly.futureverse.org/reference/serializedSize.md)
  for calculating the size of an object by counting the number of bytes
  required to serialize it.

### Bug Fixes

- Environment variable `R_PARALLELLY_MAXWORKERS_LOCALHOST` was
  interpreted as integers rather than doubles.

## Version 1.37.1

CRAN release: 2024-02-29

### Bug Fixes

- Version 1.37.0 would not install on FreeBSD.

## Version 1.37.0

CRAN release: 2024-02-14

### New Features

- `makeClusterPSOCK(nworkers)` gained protection against setting up too
  many localhost workers relative to number of available CPU cores. If
  `nworkers / availableCores()` is greater than 1.0 (100%), then a
  warning is produced. If greater than 3.0 (300%), an error is produced.
  These limits can be configured by R option
  `parallelly.maxWorkers.localhost`. These checks are skipped if
  `nworkers` inherits from `AsIs`, e.g. `makeClusterPSOCK(I(16))`. The
  current 3.0 (300%) limit is likely to be decreased in a future
  release. A few packages fail `R CMD check --as-cran` with this
  validation enabled. For example, one package uses 8 parallel workers
  in its examples, while `R CMD check --as-cran` only allows for two. To
  give such packages time to be fixed, the CRAN-enforced limits are
  ignored for now.

### Miscellaneous

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  could produce a confusing error `Invalid port: NA` if a non-available
  port was requested. Now the error message is more informative, e.g.
  `Argument 'port' specifies non-available port(s): 80`.

### Bug Fixes

- The internal method for checking if a TCP port is available has been
  improved. Previously, it could incorrectly conclude a port was
  available, when it was not.

## Version 1.36.0

CRAN release: 2023-05-26

### New Features

- [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  and
  [`killNode()`](https://parallelly.futureverse.org/reference/killNode.md)
  now support also worker processes that run on remote machines. They do
  this by connecting to the remote machine using the same method used to
  launch the worker, which is typically SSH, and do their R calls that
  way.

- [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  and
  [`killNode()`](https://parallelly.futureverse.org/reference/killNode.md)
  gained argument `timeout` for controlling the maximum time, in
  seconds, before giving up and returning NA.

- Add
  [`cloneNode()`](https://parallelly.futureverse.org/reference/cloneNode.md),
  which can be used to “restart” `RichSOCKnode` cluster nodes.

- Argument `worker` for
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now takes the optional, logical attribute `localhost` to manually
  specify that the worker is a localhost worker.

- Add [`print()`](https://rdrr.io/r/base/print.html) for `RichSOCKnode`,
  which gives more details than
  [`print()`](https://rdrr.io/r/base/print.html) for `SOCKnode`.

- [`print()`](https://rdrr.io/r/base/print.html) for `RichSOCKnode` and
  `RichSOCKcluster` report on nodes with broken connections.

- Add
  [`as.cluster()`](https://parallelly.futureverse.org/reference/as.cluster.md)
  for `RichSOCKnode`, which returns a `RichSOCKcluster`.

- Introduce R option `parallelly.supportsMulticore.disableOn` to control
  where multicore processing is disabled by default.

### Bug Fixes

- Calling
  [`killNode()`](https://parallelly.futureverse.org/reference/killNode.md)
  on `RichSOCKnode` node could theoretically kill a process on the
  current machine with the same process ID (PID), although the parallel
  worker (node) is running on another machine.

- [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  on `RichSOCKnode` node could theoretically return TRUE because there
  was a process with the same process ID (PID) on the current machine,
  although the parallel worker (node) is running on another machine.

- `isLocalHost()` for `SOCK0node` was not declared an S3 method.

## Version 1.35.0

CRAN release: 2023-03-22

### New Features

- Now
  [`freePort()`](https://parallelly.futureverse.org/reference/freePort.md)
  defaults to `default = NA_integer_`, so that `NA_integer_` is returned
  when no free port could be found. However, in R (\< 4.0.0), which does
  not support port querying, we use `default = "random"`.

### Documentation

- Mention in
  [`help("makeClusterPSOCK")`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  that `rscript_sh = "cmd"` is needed if the remote machines run MS
  Windows.

### Bug Fixes

- `makeClusterPSOCK(..., verbose = TRUE)` would not show verbose output.
  One still had to set option `parallelly.debug` to TRUE.

- [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  could produce false sanity-check warnings on mismatching ‘PE_HOSTFILE’
  content and ‘NSLOTS’ for certain SGE-cluster configurations.

## Version 1.34.0

CRAN release: 2023-01-13

### New Features

- Add support for `availableWorkers(constraints = "connections")`, which
  limits the number of workers that can be be used to the current number
  of free R connections according to
  [`freeConnections()`](https://parallelly.futureverse.org/reference/availableConnections.md).
  This is the maximum number of PSOCK, SOCK, and MPI **parallel**
  cluster nodes we can open without running out of available R
  connections.

### Bug Fixes

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  would produce a warning
  `In is.na(constraints) : is.na() applied to non-(list or vector) of type 'NULL'`
  when running with R (\< 4.0.0).

- [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  did not acknowledge the `"cgroups2.cpu.max"` and `"Bioconductor"`
  methods added to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  in **parallelly** 1.33.0 (2022-12-13). It also did not acknowledge
  methods `"cgroups.cpuset"` and `"cgroups.cpuquota"` added in
  **parallelly** 1.31.0 (2022-04-07), and `"nproc"` added in
  **parallelly** 1.26.1 (2021-06-29).

- When
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  failed to connect to all parallel workers within the `connectTimeout`
  time limit, could either produce
  `Error in sprintf(ngettext(failed, "Cluster setup failed (connectTimeout=%.1f seconds). %d worker of %d failed to connect.", : invalid format '%d'; use format %f, %e, %g or %a for numeric objects`
  instead of an informative error message, or an error message with the
  incorrect information.

## Version 1.33.0

CRAN release: 2022-12-14

### New Features

- Add
  [`killNode()`](https://parallelly.futureverse.org/reference/killNode.md)
  to terminate cluster nodes via process signaling. Currently, this is
  only supported for parallel workers on the local machine, and only
  those created by
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md).

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  and likes now assert the running R session has enough permissions on
  the operating system to do system calls such as
  `system2("Rscript --version")`. If not, an informative error message
  is produced.

- On Unix,
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  queries also control groups v2 (cgroups v2) field `cpu.max` for a
  possible CPU quota allocation. If a CPU quota is set, then the number
  of CPUs is rounded to the nearest integer, unless its less that 0.5,
  in case it’s rounded up to a single CPU. An example, where cgroups CPU
  quotas can be set to limit the total CPU load, is with Linux
  containers, e.g. `docker run --cpus=3.5 ...`.

- Add support for `availableCores(methods = "connections")`, which
  returns the current number of free R connections per
  [`freeConnections()`](https://parallelly.futureverse.org/reference/availableConnections.md).
  This is the maximum number of PSOCK, SOCK, and MPI **parallel**
  cluster nodes we can open without running out of available R
  connections. A convenient way to use this and all other methods is
  `availableCores(constraints = "connections")`.

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  recognizes environment variable `IS_BIOC_BUILD_MACHINE`, which is set
  to true by the Bioconductor (\>= 3.16) check servers. If true, then a
  maximum of four (4) cores is returned. This new environment variable
  replaces legacy variable `BBS_HOME` used in Bioconductor (\<= 3.15).

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  splits up method `"BiocParallel"` into two; `"BiocParallel"` and
  `"Bioconductor"`. The former queries environment variable
  `BIOCPARALLEL_WORKER_NUMBER` and the latter `IS_BIOC_BUILD_MACHINE`.
  This means `availableCores(which = "all")` now reports on both.

- [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  will now produce a once-per-session informative warning when it
  detects that it is not possible to check whether another process is
  alive on the current machine.

### Documentation

- Add section to
  [`help("makeClusterPSOCK", package = "parallelly")`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  explaining why `R CMD check` may produce “checking for detritus in the
  temp directory … NOTE” and how to avoid them.

- Add section ‘For package developers’ to
  [`help("makeClusterPSOCK", package = "parallelly")`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  reminding us that we need to stop all clusters we created in package
  examples, tests, and vignettes.

### Bug Fixes

- [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  failed to record which method works for testing if a process exists or
  not, which meant it would keep trying all methods each time.
  Similarly, if none works, it would still keep trying each time instead
  of returning NA immediately. On some systems, failing to check whether
  a process exists could result in one or more warnings, in which case
  those warnings would be produced for each call to
  [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md).

## Version 1.32.1

CRAN release: 2022-07-21

### Bug Fixes

- The `host` element of the `SOCK0node` or `SOCKnode` objects created by
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  lost attribute `localhost` for localhost workers. This made some error
  messages from the **future** package less informative.

## Version 1.32.0

CRAN release: 2022-06-07

### Significant Changes

- The default for argument `revtunnel` of
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  and therefore also of
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  is now `NA`, which means it’s agile to whether `rshcmd[1]` specifies
  an SSH client, or not. If SSH is used, then it will resolve to
  `revtunnel = TRUE`, otherwise to `revtunnel = FALSE`. This removed the
  need for setting `revtunnel = FALSE`, when non-SSH clients are used.

### New Features

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  gained support for the ‘Fujitsu Technical Computing Suite’ job
  scheduler. Specifically, they acknowledges environment variables
  `PJM_VNODE_CORE`, `PJM_PROC_BY_NODE`, and `PJM_O_NODEINF`. See
  [`help("makeClusterPSOCK", package = "parallelly")`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  for an example.

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  would fail with
  `Error: node$session_info$process$pid == pid is not TRUE` when running
  R in Simplified Chinese (`LANGUAGE=zh_CN`), Traditional Chinese
  (Taiwan) (`LANGUAGE=zh_TW`), or Korean (`LANGUAGE=ko`) locales.

- Some warnings and errors showed the wrong call.

## Version 1.31.1

CRAN release: 2022-04-22

### Bug Fixes

- Changes to option `parallelly.availableCores.system` would be ignored
  if done after the first call to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md).

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  with option `parallelly.availableCores.system` set to less that
  [`parallel::detectCores()`](https://rdrr.io/r/parallel/detectCores.html)
  would produce a warning, e.g. “\[INTERNAL\]: Will ignore the cgroups
  CPU set, because it contains one or more CPU indices that is out of
  range \[0,0\]: 0-7”.

## Version 1.31.0

CRAN release: 2022-04-07

### Significant Changes

- Changed the default for argument default of
  [`freePort()`](https://parallelly.futureverse.org/reference/freePort.md)
  to `"random"`, which used to be `"first"`. The main reason for this is
  to make sure the default behavior is to return a random port also on R
  (\< 4.0.0) where we cannot test whether or not a port is available.

### New Features

- On Unix,
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  now queries also control groups (cgroups) fields `cpu.cfs_quota_us`
  and `cpu.cfs_period_us`, for a possible CPU quota allocation. If a CPU
  quota is set, then the number of CPUs is rounded to the nearest
  integer, unless its less that 0.5, in case it’s rounded up to a single
  CPU. An example, where cgroups CPU quotas can be set to limit the
  total CPU load, is with Linux containers,
  e.g. `docker run --cpus=3.5 ...`.

- In addition to cgroups CPU quotas,
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  also queries cgroups for a possible CPU affinity, which is available
  in field `cpuset.set`. This should give the same result as what the
  already existing ‘nproc’ method gives. However, not all systems have
  the `nproc` tool installed, in which case this new approach should
  work. Some high-performance compute (HPC) environments set the CPU
  affinity so that jobs do not overuse the CPUs. It may also be set by
  Linux containers, e.g. `docker run --cpuset-cpus=0-2,8 ...`.

- The minimum value returned by
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  is one (1). This can be overridden by new option
  `parallelly.availableCores.min`. This can be used to test
  parallelization methods on single-core machines,
  e.g. `options(parallelly.availableCores.min = 2L)`.

### Bug Fixes

- The ‘nproc’ result for
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  was ignored if nproc \> 9.

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  would return the ‘fallback’ value when only ‘system’ and ‘nproc’
  information was available. However, in this case, we do want it to
  return ‘nproc’ when ‘nproc’ != ‘system’, because that is a strong
  indication that the number of CPU cores is limited by control groups
  (cgroups) on Linux. If ‘nproc’ == ‘system’, we cannot tell whether
  cgroups is enabled or not, which means we will fall back to the
  ‘fallback’ value if there is no other evidence that another number of
  cores are available to the current R process.

- Technically, `canPortBeUsed()` could falsely return FALSE if the port
  check was interrupted by, say, a user interrupt.

- `freePort(ports, default = "random")` would always use return
  `ports[1]` if the system does not allow testing if a port is available
  or not, or if none of the specified ports are available.

## Version 1.30.0

CRAN release: 2021-12-17

### New Features

- [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  and therefore also
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  gained argument `rscript_sh`, which controls how `Rscript` arguments
  are shell quoted. The default is to make a best guess on what type of
  shell is used where each cluster node is launched. If launched
  locally, then it whatever platform the current R session is running,
  i.e. either a POSIX shell (`"sh"`) or MS Windows (`"cmd"`). If
  remotely, then the assumption is that a POSIX shell (`"sh"`) is used.

- [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  and therefore also
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  gained argument `default_packages`, which controls the default set of
  R packages to be attached on each cluster node at startup. Moreover,
  if argument `rscript` specifies an ‘Rscript’ executable, then argument
  `default_packages` is used to populate Rscript command-line option
  `--default-packages=...`. If `rscript` specifies something else,
  e.g. an ‘R’ or ‘Rterm’ executable, then environment variable
  `R_DEFAULT_PACKAGES=...` is set accordingly when launching each
  cluster node.

- Argument `rscript_args` of
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now supports `"*"` values. When used, the corresponding element will
  be replaced with the internally added Rscript command-line options. If
  not specified, such options are appended at the end.

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  did not support backslashes (`\`) in `rscript_libs`, backslashes that
  may originate from, for example, Windows network drives. The result
  was that the worker would silently ignore any `rscript_libs`
  components with backslashes.

- The package detects when `R CMD check` runs and adjust default
  settings via environment variables in order to play nicer with the
  machine where the checks are running. Some of these environment
  variables were in this case ignored since **parallelly** 1.26.0.

## Version 1.29.0

CRAN release: 2021-11-21

### Significant Changes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  launches parallel workers with option `socketOptions` set to
  `"no-delay"` by default. This decreases the communication latency
  between workers and the main R session, significantly so on Unix. This
  option requires R (\>= 4.1.0) and has no effect in early versions of
  R.

### New Features

- Added argument `socketOptions` to
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  which sets the corresponding R option on each cluster node when they
  are launched.

- Argument `rscript_envs` of
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  can also be used to unset environment variables cluster nodes. Any
  named element with value `NA_character_` will be unset.

- Argument `rscript` of
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now supports `"*"` values. When used, the corresponding element will
  be replaced with the `"Rscript"`, or if `homogenous = TRUE`, then
  absolute path to current ‘Rscript’.

### Documentation

- Add
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  example on how to launch workers distributed across multiple CPU
  Groups on MS Windows 10.

### Bug Fixes

- [`isForkedChild()`](https://parallelly.futureverse.org/reference/isForkedChild.md)
  would only return TRUE in a forked child process, if and only if, it
  had already been called in the parent R process.

- Using argument `rscript_startup` would cause
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  to fail in R-devel (\>= r80666).

## Version 1.28.1

CRAN release: 2021-09-09

### CRAN Policies

- `example("isNodeAlive")` now uses `\donttest{}` to avoid long (\> 10
  19. elapsed run times on MS Windows.

## Version 1.28.0

### New Features

- Add
  [`isNodeAlive()`](https://parallelly.futureverse.org/reference/isNodeAlive.md)
  to check whether a cluster and cluster nodes are alive or not.

- Add
  [`isForkedChild()`](https://parallelly.futureverse.org/reference/isForkedChild.md)
  to check whether or not the current R process is a forked child
  process.

### Bug Fixes

- Environment variable `R_PARALLELLY_SUPPORTSMULTICORE_UNSTABLE` was
  incorrectly parsed as a logical instead of a character string. If the
  variables was set to, say, `"quiet"`, this would cause an error when
  the package was loaded.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  failed to fall back to `setup_strategy = "sequential"`, when not
  supported by the current R version.

## Version 1.27.0

CRAN release: 2021-07-19

### New Features

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  now respects environment variable `BIOCPARALLEL_WORKER_NUMBER`
  introduced in **BiocParallel** (\>= 1.27.2). They also respect
  `BBS_HOME` which is set on the Bioconductor check servers to limit the
  number of parallel workers while checking Bioconductor packages.

### Workaround

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  and
  [`parallel::makeCluster()`](https://rdrr.io/r/parallel/makeCluster.html)
  failed with error “Cluster setup failed. of workers failed to
  connect.” when using the new default `setup_strategy = "parallel"` and
  when the **tcltk** package is loaded when running R (\>= 4.0.0 && \<=
  4.1.0) on macOS. Now **parallelly** forces
  `setup_strategy = "sequential"` when the **tcltk** package is loaded
  on these R versions.

### Bug Fixes

- `makeClusterPSOCK(..., setup_strategy = "parallel")` would forget to
  close an socket connection used to set up the workers. This socket
  connection would be closed by the garbage collector eventually with a
  warning.

- [`parallelly::makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  would fail with “Error in freePort(port) : Unknown value on argument
  ‘port’: ‘auto’” if environment variable `R_PARALLEL_PORT` was set to a
  port number.

- [`parallelly::availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  would produce ‘Error in if (grepl(“^ \[1-9\]\$”, res))
  return(as.integer(res)) : argument is of length zero’ on Linux systems
  without `nproc` installed.

## Version 1.26.1

CRAN release: 2021-06-30

### New Features

- [`print()`](https://rdrr.io/r/base/print.html) on `RichSOCKcluster`
  mentions when the cluster is registered to be automatically stopped by
  the garbage collector.

### Workaround

- Depending on R version used, the RStudio Console does not support the
  new `setup_strategy = "parallel"` when using
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  or
  [`parallel::makeCluster()`](https://rdrr.io/r/parallel/makeCluster.html).
  The symptom is that they, after a long wait, result in “Error in
  makeClusterPSOCK(workers, …) : Cluster setup failed. of workers failed
  to connect.” This is due to a bug in R, which has been fixed for R
  (\>= 4.1.1) but also in a recent R 4.1.0 Patched. For R (\>= 4.0.0) or
  R (\<= 4.1.0), this release works around the problem by forcing
  `setup_strategy = "sequential` for **parallelly** and **parallel**
  when running in the RStudio Console. If you wish to override this
  behavior, you can always set option
  `parallelly.makeNodePSOCK.setup_strategy` to `"parallel"`, e.g. in
  your `~/.Rprofile` file. Alternatively, you can set the environment
  variable `R_PARALLELLY_MAKENODEPSOCK_SETUP_STRATEGY=parallel`, e.g. in
  your `~/.Renviron` file.

### Bug Fixes

- On systems with `nproc` installed,
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  would be limited by environment variables `OMP_NUM_THREADS` and
  `OMP_THREAD_LIMIT`, if set. For example, on conservative systems that
  set `OMP_NUM_THREADS=1` as the default,
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  would pick this up via `nproc` and return 1. This was not the intended
  behavior. Now those environment variables are temporarily unset before
  querying `nproc`.

## Version 1.26.0

CRAN release: 2021-06-09

### Significant Changes

- `R_PARALLELLY_*` (and `R_FUTURE_*`) environment variables are now only
  read when the **parallelly** package is loaded, where they set the
  corresponding `parallelly.*` option. Previously, some of these
  environment variables were queried by different functions as a
  fallback to when an option was not set. By only parsing them when the
  package is loaded, it decrease the overhead in functions, and it
  clarifies that options can be changed at runtime whereas environment
  variables should only be set at startup.

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now support setting up cluster nodes in parallel similarly to how
  [`parallel::makePSOCKcluster()`](https://rdrr.io/r/parallel/makeCluster.html)
  does it. This significantly reduces the setup turnaround time. This is
  only supported in R (\>= 4.0.0). To revert to the sequential setup
  strategy, set R option `parallelly.makeNodePSOCK.setup_strategy` to
  `"sequential"`.

- Add
  [`freePort()`](https://parallelly.futureverse.org/reference/freePort.md)
  to get a random TCP port that can be opened.

### Documentation

- Documenting more R options and environment variables used by this
  package.

### Bug Fixes

- R option `parallelly.availableCores.fallback` and environment variable
  `R_PARALLELLY_AVAILABLECORES_FALLBACK` was ignored since
  **parallelly** 1.22.0, when support for ‘nproc’ was added to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md).

## Version 1.25.0

CRAN release: 2021-04-30

### Significant Changes

- The default SSH client on MS Windows 10 is now the built in `ssh`
  client. This means that regardless whether you are on Linux, macOS, or
  Windows 10, setting up parallel workers on external machines over SSH
  finally works out of the box without having to install PuTTY or other
  SSH clients. This was possible because a workaround was found for a
  Windows 10 bug preventing us from using reverse tunneling over SSH. It
  turns out the bug reveals itself when using hostname ‘localhost’ but
  not ‘127.0.0.1’, so we use the latter.

### New Features

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  gained argument `omit` to make it easier to put aside zero or more
  cores from being used in parallel processing. For example, on a system
  with four cores, `availableCores(omit = 1)` returns 3. Importantly,
  since
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  is guaranteed to always return a positive integer,
  `availableCores(omit = 4) == 1`, even on systems with four or fewer
  cores. Using `availableCores() - 4` on such systems would return a
  non-positive value, which would give an error downstream.

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  or actually
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  did not accept all types of environment variable names when using
  `rscript_envs`, e.g. it would give an error if we tried to pass
  `_R_CLASS_MATRIX_ARRAY_`.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  had a “length \> 1 in coercion to logical” bug that could affect
  especially MS Windows 10 users.

## Version 1.24.0

CRAN release: 2021-03-14

### Significant Changes

- The default SSH client on MS Windows is now, in order of
  availability: (i) `plink` of the PuTTY software, (ii) `ssh` in the
  RStudio distribution, and (iii) `ssh` of Windows 10. Previously, the
  latter was considered first but that still has a bug preventing us
  from using reverse tunneling.

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  or actually
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  gained argument `quiet`, which can be used to silence output produced
  by `manual = TRUE`.

- [`c()`](https://rdrr.io/r/base/c.html) for `cluster` objects now warns
  about duplicated cluster nodes.

- Add
  [`isForkedNode()`](https://parallelly.futureverse.org/reference/isForkedNode.md)
  to test if a cluster node runs in a forked process.

- Add
  [`isLocalhostNode()`](https://parallelly.futureverse.org/reference/isLocalhostNode.md)
  to test if a cluster node runs on the current machine.

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  avoid recursive calls to the custom function given by options
  `parallelly.availableCores.custom` and
  `parallelly.availableWorkers.custom`, respectively.

- [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  now recognizes the Slurm environment variable `SLURM_JOB_NODELIST`,
  e.g. `"dev1,n[3-4,095-120]"`. It will use
  `scontrol show hostnames "$SLURM_JOB_NODELIST"` to expand it, if
  supported on the current machine, otherwise it will attempt to parse
  and expand the nodelist specification using R. If either of
  environment variable `SLURM_JOB_CPUS_PER_NODE` or
  `SLURM_TASKS_PER_NODE` is set, then each node in the nodelist will be
  represented that number of times. If in addition, environment variable
  `SLURM_CPUS_PER_TASK` (always a scalar), then that is also respected.

### Miscellaneous

- All code is now using the `parallelly.` prefix for options and the
  `R_PARALLELLY_` prefix for environment variables. Settings that use
  the corresponding `future.` and `R_FUTURE_` prefixes are still
  recognized.

### Bug Fixes

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  did not respect environment variable `SLURM_TASKS_PER_NODE` when the
  job was allocated more than one node.

- Above argument `quiet` was introduced in **future** 1.19.1 but was
  mistakenly dropped from **parallelly** 1.20.0 when that was released,
  and therefore also from **future** (\>= 1.20.0).

## Version 1.23.0

CRAN release: 2021-01-04

### New Features

- [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md),
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md),
  and
  [`freeCores()`](https://parallelly.futureverse.org/reference/freeCores.md)
  gained argument `logical`, which is passed down to
  [`parallel::detectCores()`](https://rdrr.io/r/parallel/detectCores.html)
  as-is. The default is TRUE but it can be changed by setting the R
  option `parallelly.availableCores.logical`. This option can in turn be
  set via environment variable `R_PARALLELLY_AVAILABLECORES_LOGICAL`
  which is applied (only) when the package is loaded.

- Now
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  asserts that there are enough free connections available before
  attempting to create the parallel workers. If too many workers are
  requested, an informative error message is produced.

- Add
  [`availableConnections()`](https://parallelly.futureverse.org/reference/availableConnections.md)
  and
  [`freeConnections()`](https://parallelly.futureverse.org/reference/availableConnections.md)
  to infer the maximum number of connections that the current R
  installation can have open at any time and how many of those are
  currently free to be used. This limit is typically 128 but may be
  different in custom R installations that are built from source.

## Version 1.22.0

CRAN release: 2020-12-13

### New Features

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  queries also Unix command `nproc`, if available. This will make it
  respect the number of CPU/cores limited by ‘cgroups’ and Linux
  containers.

- PSOCK cluster workers are now set up to communicate using little
  endian (`useXDR = FALSE`) instead of big endian (`useXDR = TRUE`).
  Since most modern systems use little endian, `useXDR = FALSE` speeds
  up the communication noticeably (10-15%) on those systems. The default
  value of this argument can be controlled by the R option
  `parallelly.makeNodePSOCK.useXDR` or the corresponding environment
  variable `R_PARALLELLY_MAKENODEPSOCK_USEXDR`.

### Beta Features

- Add
  [`cpuLoad()`](https://parallelly.futureverse.org/reference/cpuLoad.md)
  for querying the “average” system load on Unix-like systems.

- Add
  [`freeCores()`](https://parallelly.futureverse.org/reference/freeCores.md)
  for estimating the average number of unused cores based on the average
  system load as given by
  [`cpuLoad()`](https://parallelly.futureverse.org/reference/cpuLoad.md).

### Bug Fixes

- Except for environment variables `R_FUTURE_AVAILABLECORES_FALLBACK`
  and `R_FUTURE_AVAILABLECORES_SYSTEM`, none of the `R_PARALLELLY_*` and
  `R_FUTURE_*` ones where recognized.

## Version 1.21.0

CRAN release: 2020-10-27

### Significant Changes

- Removed
  [`find_rshcmd()`](https://parallelly.futureverse.org/reference/find_rshcmd.md)
  which was never meant to be exported.

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  gained argument `validate` to control whether or not the nodes should
  be tested after they’ve been created. The validation is done by
  querying each node for its session information, which is then saved as
  attribute `session_info` on the cluster node object. This information
  is also used in error messages, if available. This validation has been
  done since version 1.5.0 but now it can be disabled. The default of
  argument `validate` can be controlled via an R options and an
  environment variable.

- Now `makeNodePSOCK(..., rscript_envs = "UNKNOWN")` produces an
  informative warning on non-existing environment variables that was
  skipped.

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  would produce an error on ‘one node produced an error: could not find
  function “getOptionOrEnvVar”’ if **parallelly** is not available on
  the node.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  would attempt to load **parallelly** on the worker. If it’s not
  available on the worker, it would result in a silent warning on the
  worker. Now **parallelly** is not loaded.

- `makeClusterPSOCK(..., tries = n)` would retry to setup a cluster node
  also on errors that were unrelated to node setup or node connection
  errors.

- The error message on using an invalid `rscript_envs` argument for
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  reported on the value of `rscript_libs` (sic!).

- `makeNodePSOCK(..., rscript_envs = "UNKNOWN")` would result in an
  error when trying to launch the cluster node.

### Deprecated and Defunct

- Removed
  [`find_rshcmd()`](https://parallelly.futureverse.org/reference/find_rshcmd.md)
  which was never meant to be exported.

## Version 1.20.0

CRAN release: 2020-10-20

### Significant Changes

- Add
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md),
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md),
  [`supportsMulticore()`](https://parallelly.futureverse.org/reference/supportsMulticore.md),
  [`as.cluster()`](https://parallelly.futureverse.org/reference/as.cluster.md),
  [`autoStopCluster()`](https://parallelly.futureverse.org/reference/autoStopCluster.md),
  [`makeClusterMPI()`](https://parallelly.futureverse.org/reference/makeClusterMPI.md),
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  and
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  from the **future** package.

### New Features

- Add
  [`isConnectionValid()`](https://parallelly.futureverse.org/reference/isConnectionValid.md)
  and
  [`connectionId()`](https://parallelly.futureverse.org/reference/isConnectionValid.md)
  adopted from internal code of the **future** package.

### Bug Fixes

- Renamed environment variable `R_FUTURE_MAKENODEPSOCK_tries` used by
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  to `R_FUTURE_MAKENODEPSOCK_TRIES`.

- [`connectionId()`](https://parallelly.futureverse.org/reference/isConnectionValid.md)
  did not return `-1L` on Solaris for connections with internal ‘nil’
  pointers because they were reported as ‘0’ - not ‘nil’ or ‘0x0’.

### History

- Below is an excerpt of the **future**’s NEWS entries that are related
  to the functions in this package.

## Version 1.19.0

### Significant Changes

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  better supports Slurm. Specifically, if environment variable
  `SLURM_CPUS_PER_TASK` is not set, which requires that option
  `--slurm-cpus-per-task=n` is specified and `SLURM_JOB_NUM_NODES=1`,
  then it falls back to using `SLURM_CPUS_ON_NODE`, e.g. when using
  `--ntasks=n`.

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  supports LSF/OpenLava. Specifically, they acknowledge environment
  variable `LSB_DJOB_NUMPROC` and `LSB_HOSTS`, respectively.

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  will now retry to create a cluster node up to `tries` (default: 3)
  times before giving up. If argument `port` species more than one port
  (e.g. `port = "random"`) then it will also attempt find a valid random
  port up to `tries` times before giving up. The pre-validation of the
  random port is only supported in R (\>= 4.0.0) and skipped otherwise.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  skips shell quoting of the elements in `rscript` if it inherits from
  `AsIs`.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  or actually
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  gained argument `quiet`, which can be used to silence output produced
  by `manual = TRUE`.

### Performance

- Now `plan(multisession)`, `plan(cluster, workers = <number>)`, and
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  which they both use internally, sets up localhost workers twice as
  fast compared to versions since **future** 1.12.0, which brings it
  back to par with a bare-bone
  `parallel::makeCluster(..., setup_strategy = "sequential")` setup. The
  slowdown was introduced in **future** 1.12.0 (2019-03-07) when
  protection against leaving stray R processes behind from failed worker
  startup was implemented. This protection now makes use of memoization
  for speedup.

## Version 1.18.0

### New Features

- [`print()`](https://rdrr.io/r/base/print.html) on `RichSOCKcluster`
  gives information not only on the name of the host but also on the
  version of R and the platform of each node (“worker”), e.g. “Socket
  cluster with 3 nodes where 2 nodes are on host ‘localhost’ (R version
  4.0.0 (2020-04-24), platform x86_64-w64-mingw32), 1 node is on host
  ‘n3’ (R version 3.6.3 (2020-02-29), platform x86_64-pc-linux-gnu)”.

- It is now possible to set environment variables on workers before they
  are launched by
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  by specify them as as `<name>=<value>` as part of the `rscript` vector
  argument, e.g. `rscript=c("ABC=123", "DEF='hello world'", "Rscript")`.
  This works because elements in `rscript` that match regular expression
  `"^ [[:alpha:]_][[:alnum:]_]*=.*"` are no longer shell quoted.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now returns a cluster that in addition to inheriting from
  `SOCKcluster` it will also inherit from `RichSOCKcluster`.

### Bug Fixes

- Made
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  and
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  agile to the name change from `parallel:::.slaveRSOCK()` to
  `parallel:::.workRSOCK()` in R (\>= 4.1.0).

- `makeClusterPSOCK(..., rscript)` will not try to locate `rscript[1]`
  if argument `homogeneous` is FALSE (or inferred to be FALSE).

- `makeClusterPSOCK(..., rscript_envs)` would result in a syntax error
  when starting the workers due to non-ASCII quotation marks if option
  `useFancyQuotes` was not set to FALSE.

## Version 1.17.0

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  gained argument `rscript_envs` for setting environment variables in
  workers on startup, e.g. `rscript_envs = c(FOO = "3.14", "BAR")`.

### Miscellaneous

- Not all CRAN servers have `_R_CHECK_LIMIT_CORES_` set. To better
  emulate CRAN submission checks, the **future** package will, when
  loaded, set this environment variable to TRUE if unset and if
  `R CMD check` is running. Note that
  [`future::availableCores()`](https://parallelly.futureverse.org/reference/availableCores.html)
  respects `_R_CHECK_LIMIT_CORES_` and returns at most `2L` (two cores)
  if detected.

## Version 1.15.1

### New Features

- The default range of ports that
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  draws a random port from (when argument `port` is not specified) can
  now be controlled by environment variable `R_FUTURE_RANDOM_PORTS`. The
  default range is still `11000:11999` as with the **parallel** package.

## Version 1.15.0

### Documentation

- Added ‘Troubleshooting’ section to
  [`?makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  with instructions on how to troubleshoot when the setup of local and
  remote clusters fail.

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  could produce warnings like “cannot open file
  ‘/tmp/alice/Rtmpi69yYF/future.parent=2622.a3e32bc6af7.pid’: No such
  file”, e.g. when launching R workers running in Docker containers.

- [`makeClusterMPI()`](https://parallelly.futureverse.org/reference/makeClusterMPI.md)
  did not work for MPI clusters with ‘comm’ other than ‘1’.

## Version 1.13.0

### New Features

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  also recognizes PBS environment variable `NCPUS`, because the PBSPro
  scheduler does not set `PBS_NUM_PPN`.

- If, option `future.availableCores.custom` is set to a function, then
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  will call that function and interpret its value as number of cores.
  Analogously, option `future.availableWorkers.custom` can be used to
  specify a hostnames of a set of workers that
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  sees. These new options provide a mechanism for anyone to customize
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  in case they do not (yet) recognize, say, environment variables that
  are specific the user’s compute environment or HPC scheduler.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  gained support for argument `rscript_startup` for evaluating one or
  more R expressions in the background R worker prior to the worker
  event loop launching. This provides a more convenient approach than
  having to use, say, `rscript_args = c("-e", sQuote(code))`.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  gained support for argument `rscript_libs` to control the R package
  library search path on the workers. For example, to *prepend* the
  folder `~/R-libs` on the workers, use
  `rscript_libs = c("~/R-libs", "*")`, where `"*"` will be resolved to
  the current [`.libPaths()`](https://rdrr.io/r/base/libPaths.html) on
  the workers.

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  did not shell quote the Rscript executable when running its pre-tests
  checking whether localhost Rscript processes can be killed by their
  PIDs or not.

## Version 1.12.0

### New Features

- If
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  fails to create one of many nodes, then it will attempt to stop any
  nodes that were successfully created. This lowers the risk for leaving
  R worker processes behind.

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  in **future** (\>= 1.11.1) produced warnings when argument `rscript`
  had `length(rscript) > 1`.

## Version 1.11.1.1

### Bug Fixes

- When
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  fails to connect to a worker, it produces an error with detailed
  information on what could have happened. In rare cases, another error
  could be produced when generating the information on what the workers
  PID is.

## Version 1.11.1

### New Features

- The defaults of several arguments of
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  and
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  can now be controlled via environment variables in addition to R
  options that was supported in the past. An advantage of using
  environment variables is that they will be inherited by child
  processes, also nested ones.

### Software Quality

- TESTS: When the **future** package is loaded, it checks whether
  `R CMD check` is running or not. If it is, then a few future-specific
  environment variables are adjusted such that the tests play nice with
  the testing environment. For instance, it sets the socket connection
  timeout for PSOCK cluster workers to 120 seconds (instead of the
  default 30 days!). This will lower the risk for more and more zombie
  worker processes cluttering up the test machine (e.g. CRAN servers) in
  case a worker process is left behind despite the main R processes is
  terminated. Note that these adjustments are applied automatically to
  the checks of any package that depends on, or imports, the **future**
  package.

### Bug Fixes

- Whenever
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  would fail to connect to a worker, for instance due to a port clash,
  then it would leave the R worker process running - also after the main
  R process terminated. When the worker is running on the same machine,
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  will now attempt to kill such stray R processes. Note that
  [`parallel::makePSOCKcluster()`](https://rdrr.io/r/parallel/makeCluster.html)
  still has this problem.

## Version 1.11.0

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  produces more informative error messages whenever the setup of R
  workers fails. Also, its verbose messages are now prefixed with
  “\[local output\]” to help distinguish the output produced by the
  current R session from that produced by background workers.

- It is now possible to specify what type of SSH clients
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  automatically searches for and in what order,
  e.g. `rshcmd = c("<rstudio-ssh>", "<putty-plink>")`.

- Now
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  preserves the global RNG state (`.Random.seed`) also when it draws a
  random port number.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  gained argument `rshlogfile`.

### Bug Fixes

- `makeClusterPSOCK(..., rscript = "my_r")` would in some cases fail to
  find the intended `my_r` executable.

## Version 1.10.0

### New Features

- Add `makeClusterMPI(n)` for creating MPI-based clusters of a similar
  kind as `parallel::makeCluster(n, type = "MPI")` but that also
  attempts to workaround issues where
  [`parallel::stopCluster()`](https://rdrr.io/r/parallel/makeCluster.html)
  causes R to stall.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  and
  [`makeClusterMPI()`](https://parallelly.futureverse.org/reference/makeClusterMPI.md)
  gained argument `autoStop` for controlling whether the cluster should
  be automatically stopped when garbage collected or not.

## Version 1.9.0

### Bug Fixes

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  produced a warning when environment variable `R_PARALLEL_PORT` was set
  to `random` (e.g. as on CRAN).

## Version 1.8.1

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now produces a more informative warning if environment variable
  `R_PARALLEL_PORT` specifies a non-numeric port.

## Version 1.7.0

### New Features

- On Windows,
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  and therefore `plan(multisession)` and `plan(multiprocess)`, will use
  the SSH client distributed with RStudio as a fallback if neither `ssh`
  nor `plink` is available on the system `PATH`.

### Bug Fixes

- `makeClusterPSOCK(..., renice = 19)` would launch each PSOCK worker
  via `nice +19` resulting in the error “nice: ‘+19’: No such file or
  directory”. This bug was inherited from
  [`parallel::makePSOCKcluster()`](https://rdrr.io/r/parallel/makeCluster.html).
  Now using `nice --adjustment=19` instead.

## Version 1.5.0

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now defaults to use the Windows PuTTY software’s SSH client
  `plink -ssh`, if `ssh` is not found.

- Argument `homogeneous` of
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  a helper function of
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md),
  will default to FALSE also if the hostname is a fully qualified domain
  name (FQDN), that is, it “contains periods”. For instance,
  `c('node1', 'node2.server.org')` will use `homogeneous = TRUE` for the
  first worker and `homogeneous = FALSE` for the second.

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  now asserts that each cluster node is functioning by retrieving and
  recording the node’s session information including the process ID of
  the corresponding R process.

### Documentation

- Help on
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  gained more detailed descriptions on arguments and what their defaults
  are.

## Version 1.4.0

### New Features

- The default values for arguments `connectTimeout` and `timeout` of
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  can now be controlled via global options.

### Deprecated and Defunct

- `availableCores(method = "mc.cores")` is now defunct in favor of
  `"mc.cores+1"`.

## Version 1.3.0

### New Features

- [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  treats workers that refer to a local machine by its local or canonical
  hostname as `"localhost"`. This avoids having to launch such workers
  over SSH, which may not be supported on all systems / compute cluster.

- Added
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md).
  By default it returns localhost workers according to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md).
  In addition, it detects common HPC allocations given in environment
  variables set by the HPC scheduler.

- Option `future.availableCores.fallback`, which defaults to environment
  variable `R_FUTURE_AVAILABLECORES_FALLBACK` can now be used to specify
  the default number of cores / workers returned by
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  and
  [`availableWorkers()`](https://parallelly.futureverse.org/reference/availableWorkers.md)
  when no other settings are available. For instance, if
  `R_FUTURE_AVAILABLECORES_FALLBACK=1` is set system wide in an HPC
  environment, then all R processes that uses
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  to detect how many cores can be used will run as single-core
  processes. Without this fallback setting, and without other
  core-specifying settings, the default will be to use all cores on the
  machine, which does not play well on multi-user systems.

### Bug Fixes

- Creation of cluster futures (including multisession ones) would time
  out already after 40 seconds if all workers were busy. New default
  timeout is 30 days (option `future.wait.timeout`).

- `availableCores(methods = "_R_CHECK_LIMIT_CORES_")` would give an
  error if not running `R CMD check`.

## Version 1.2.0

### New Features

- Added
  [`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md) -
  a version of
  [`parallel::makePSOCKcluster()`](https://rdrr.io/r/parallel/makeCluster.html)
  that allows for more flexible control of how PSOCK cluster workers are
  set up and how they are launched and communicated with if running on
  external machines.

- Added generic
  [`as.cluster()`](https://parallelly.futureverse.org/reference/as.cluster.md)
  for coercing objects to cluster objects to be used as in
  `plan(cluster, workers = as.cluster(x))`. Also added a
  [`c()`](https://rdrr.io/r/base/c.html) implementation for cluster
  objects such that multiple cluster objects can be combined into a
  single one.

### Bug Fixes

- Argument `user` to `remote()` was ignored (since 1.1.0).

## Version 1.1.1

### Bug Fixes

- For the special case where ‘remote’ futures use
  `workers = "localhost"` they (again) use the exact same R executable
  as the main / calling R session (in all other cases it uses whatever
  `Rscript` is found on the `PATH`). This was already indeed implemented
  in 1.0.1, but with the added support for reverse SSH tunnels in 1.1.0
  this default behavior was lost.

## Version 1.1.0

### New Features

- REMOTE CLUSTERS: It is now very simple to use `cluster()` and
  `remote()` to connect to remote clusters / machines. As long as you
  can connect via SSH to those machines, it works also with these
  future. The new code completely avoids incoming firewall and incoming
  port forwarding issues previously needed. This is done by using
  reverse SSH tunneling. There is also no need to worry about internal
  or external IP numbers.

## Version 0.15.0

### New Features

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  also acknowledges environment variable `NSLOTS` set by Sun/Oracle Grid
  Engine (SGE).

## Version 0.12.0

### Bug Fixes

- FIX: Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  returns `3L` (=`2L+1L`) instead of `2L` if `_R_CHECK_LIMIT_CORES_` is
  set.

## Version 0.10.0

### New Features

- Now
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  also acknowledges the number of CPUs allotted by Slurm.

## Version 0.8.0

### New Features

- `availableCores("mc.cores")` returns `getOption("mc.cores") + 1L`,
  because option `mc.cores` specifies “allowed number of *additional* R
  processes” to be used in addition to the main R process.
