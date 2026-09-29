#!/usr/bin/env bash
# Grid Engine (SGE) job script submitted by submit.sh
#
# Usage: qsub [options] probe.sh <outdir> <scriptdir>
set -euo pipefail

outdir=${1:?Usage: probe.sh <outdir> <scriptdir>}
here=${2:?Usage: probe.sh <outdir> <scriptdir>}

## The job-script view, i.e. what a plain R script sees
Rscript "${here}/probe.R" "${outdir}/${JOB_ID}.dcf"

## The per-host view, i.e. what a process launched on each host of the
## job sees. This requires a PE with 'control_slaves TRUE', otherwise
## 'qrsh -inherit' fails, which is recorded in the log file
if [[ -n ${PE_HOSTFILE:-} && -f ${PE_HOSTFILE} ]]; then
  rscript=$(command -v Rscript)
  ## 'qrsh -inherit' does not pass on the job's environment, so pass on
  ## the R library path explicitly
  libs=$("${rscript}" -e 'cat(.libPaths(), sep = ":")')
  ## A host may be listed more than once, e.g. once per queue
  while read -r host; do
    qrsh -inherit -nostdin "${host}" env R_LIBS="${libs}" "${rscript}" "${here}/probe.R" "${outdir}/${JOB_ID}.inherit.${host}.dcf" \
      || echo "qrsh -inherit ${host} failed (exit code $?)" >&2
  done < <(awk '{ print $1 }' "${PE_HOSTFILE}" | sort -u)

  ## The per-worker view, when launching parallel workers as in the
  ## 'parallelly-17-hpc-workers' vignette. Give up after four minutes,
  ## in case launching the workers stalls
  timeout 240 Rscript "${here}/cluster.R" "${outdir}" \
    || echo "cluster.R failed (exit code $?)" >&2
fi
