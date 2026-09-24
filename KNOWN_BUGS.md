# Known Bugs / TODO

Findings from a code review of `R/` (2026-09-20,
`/code-review high R/`). Follow the AGENTS.md bug-fix workflow when
working on any of these: write a reproducing unit test, fix, verify, add
a NEWS.md entry, bump the package version.

All items found in the original review have been fixed and committed,
**except** the one below, which is intentionally held back.

## Deferred to a later release

- **`R/cgroups.R:621`** — `getCGroupsValue()`‘s ancestor-directory walk
  returns the first ancestor cgroup with the target field, but never
  aggregates the most restrictive value across the hierarchy. Confirmed
  to affect cgroups v2 `cpu.max` (no kernel-aggregated “effective” file
  exists for it, unlike `cpuset.cpus.effective`): on a “hybrid”
  pod/container setup where a CPU quota is set at a parent cgroup level
  but the leaf (the process’ own cgroup) is left at its default `"max"`,
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md)
  incorrectly reports the full machine core count instead of the
  actually allotted (restricted) one.

  **Status:** root-caused and reproduced (synthetic pod/container
  hierarchy with a parent quota of `"50000 100000"` and a leaf of
  `"max 100000"` incorrectly returned `NA`/unlimited instead of `0.5`).
  A fix was designed and verified working, but the code was **reverted**
  and this item is **deliberately held back** — Henrik wants to hold off
  on this for the next release, since that release already bundles
  several updates that may be breaking, and he wants to hear back from
  the community on those first before adding another behavioral change
  on top.

  **Fix design, for whenever this is picked back up:**

  1.  Add `getCGroupsValues(controller, field)` next to the existing
      `getCGroupsValue()` in `R/cgroups.R` — same ancestor-directory
      walk, but instead of returning at the first match, it collects and
      returns *every* value found from the process’ own cgroup up to the
      mount root (character vector; empty if none found).
  2.  Add `getCGroups2Values(field)` as a `""`-controller convenience
      wrapper, mirroring `getCGroups2Value()`.
  3.  Rewrite `getCGroups2CpuMax()` to call
      `getCGroups2Values("cpu.max")` instead of
      `getCGroups2Value("cpu.max")`, parse each raw `"$MAX $PERIOD"`
      string into a ratio (`"max"` → `Inf`, i.e. no restriction at that
      level; unparseable → `NA_real_`, dropped), and use
      [`min()`](https://rdrr.io/r/base/Extremes.html) over the finite
      ratios as the effective quota. If no level has a finite (real)
      quota, return `NA_real_` as before.
  4.  Verify against: (a) a synthetic hierarchy with a restrictive
      parent and an unrestricted leaf (should now report the parent’s
      quota, not unlimited); (b) a hierarchy unrestricted at every level
      (should still report `NA`); (c) the existing
      `inst/testme/test-cgroups.R`, `test-availableCores.R`, and
      `test-availableWorkers.R` suites.
