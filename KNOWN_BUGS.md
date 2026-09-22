# Known Bugs

Findings from a code review of `R/` (2026-09-20,
`/code-review high R/`). Not yet fixed. Follow the AGENTS.md bug-fix
workflow when working on any of these: write a reproducing unit test,
fix, verify, add a NEWS.md entry, bump the package version.

## Correctness

- **`R/availableWorkers.R:766`** — `availableWorkersSlurm()` miscomputes
  the replication count when `SLURM_CPUS_PER_TASK > 1`: it uses a CPU
  count instead of a task count, so it overcounts workers (e.g. returns
  9 copies of a hostname instead of 1). The existing test bakes in the
  wrong expected value (`inst/testme/test-availableWorkers.R:369-377`).

- **`R/availableCores.R:550`** — `availableCores(which = "all")` with a
  finite `max` collapses the named per-method vector to an unnamed
  scalar via [`min()`](https://rdrr.io/r/base/Extremes.html) instead of
  clamping element-wise. This breaks name-indexing in
  `availableWorkers.R:236` and `:238`, silently no-oping the min-cap
  whenever `parallelly.availableCores.max` (or `max`) is set to a finite
  value.

- **`R/isNodeAlive.R:110`** (also `R/killNode.R:249`) — don’t support
  function-valued `rshcmd`, unlike `makeNodePSOCK.R`.
  [`shQuote()`](https://rdrr.io/r/base/shQuote.html) gets called on the
  closure instead of invoking it, breaking remote liveness checks and
  kills.

- **`R/makeNodePSOCK.R:743`** — `manual = TRUE` doesn’t gate the
  localhost self-test (guard is `if (localMachine && !dryrun)`; `manual`
  never forces `dryrun <- TRUE`), so a real subprocess launch still
  happens despite the documented “manual” contract.

- **`R/cgroups.R:621`** — `getCGroupsValue()`’s ancestor-directory walk
  returns the first ancestor cgroup with the target field, but never
  aggregates the most restrictive value across the hierarchy. Confirmed
  to affect cgroups v2 `cpu.max` (no kernel-aggregated “effective” file
  exists for it, unlike `cpuset.cpus.effective`). See existing memory
  note `cgroups-hierarchy-not-walked`.

## Resource leaks

- **`R/makeClusterMPI.R:72`** — no
  [`on.exit()`](https://rdrr.io/r/base/on.exit.html)/[`tryCatch()`](https://rdrr.io/r/base/conditions.html)
  cleanup around cluster setup; if `add_cluster_session_info()`
  (line 82) errors after `makeCluster(workers, type = "MPI")` has
  spawned MPI worker processes, they leak.

- **`R/makeClusterPSOCK.R:425`** — in the `setup_strategy = "parallel"`
  branch, a failed `sendCall()`/`recvResult()` handshake only closes the
  connection; the already-spawned OS worker process is left running (no
  PID is tracked here since `options$pidfile <- NULL` at line 404).

- **`R/killNode.R:108`** — `killNode.RichSOCKnode()`’s cleanup (closing
  the socket, removing the temp dir) is gated on `isTRUE(success)`,
  skipped when `success` is `NA` — which is always the case on R \<
  3.5.0 per the function’s own documented Warning (line 223), even when
  `pskill()` actually succeeded.

- **`R/launchNodePSOCK.R:142`** — the worker’s PID file is only
  read/removed via `readWorkerPID()` inside the
  [`socketConnection()`](https://rdrr.io/r/base/connections.html)
  failure handler, never on the normal success path. Orphaned
  `worker.rank=<n>....pid` files accumulate in
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) over long-running
  sessions.

## Minor

- **`R/makeClusterPSOCK.R:408`** —
  [`sys.calls()`](https://rdrr.io/r/base/sys.parent.html) is captured
  unconditionally as a node attribute, bypassing the documented opt-in
  `calls` argument of
  [`makeNodePSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)
  (that argument only gates a separate ps-visibility string). This can
  keep closures (e.g. a custom `rshcmd` function) alive for the
  cluster’s lifetime.

## Smaller / cleanup (not yet prioritized)

- `R/cgroups.R` `cloneCGroups()`: the v2 branch doesn’t filter by
  controller the way the v1 branch does, so on hybrid v1+v2 hosts it can
  pick the wrong mountpoint/cgroup row.
- `R/cgroups.R:574-582` `getCGroupsPath()`: a “should never happen” NA
  branch falls through without
  [`return()`](https://rdrr.io/r/base/function.html) — dead code, not
  provably unreachable.
- `R/utils,cluster.R:~51-53` `is_localhost()`: builds a regex from
  unescaped hostname/worker strings (literal `.` in FQDNs matches any
  character) — narrow false-positive/negative risk.
- `R/utils,cluster.R:370-374` `readWorkerPID()`: off-by-one —
  `tries <= maxTries` runs `maxTries + 1` sleep iterations instead of
  `maxTries`.
- `R/makeClusterPSOCK.R:500`: `try(close(socket), silent = TRUE)`
  references an undefined `socket` variable on the sequential
  setup-strategy path (the default path) — silently swallowed by
  [`try()`](https://rdrr.io/r/base/try.html); currently a no-op,
  suggests this line was never exercised/tested.
- `R/supportsMulticore.R`: the documented one-time RStudio warning
  (gated behind `warn = TRUE`) is never triggered by any in-package
  caller (`availableCores.R:518`, `isForkedChild.R:18` both call it with
  no args) — dead code path relative to its own documentation.
- Duplication: the remote rsh/Rscript-execution-and-timeout-shim logic
  is copy-pasted near-verbatim between `R/isNodeAlive.R` and
  `R/killNode.R`; the cgroups v1/v2 CPU-set and CPU-quota
  parsing/validation logic is copy-pasted between `R/cgroups.R`’s
  `getCGroups1CpuSet`/`getCGroups2CpuSet` and
  `getCGroups1CpuQuota`/`getCGroups2CpuMax`; both would benefit from a
  shared helper.
