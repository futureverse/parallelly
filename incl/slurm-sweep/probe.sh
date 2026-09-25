#!/usr/bin/env bash
# Slurm job script submitted by submit.sh
#
# Usage: sbatch [options] probe.sh <outdir> <scriptdir>
set -euo pipefail

outdir=${1:?Usage: probe.sh <outdir> <scriptdir>}
here=${2:?Usage: probe.sh <outdir> <scriptdir>}

## The batch-step view, i.e. what a plain R script sees
Rscript "${here}/probe.R" "${outdir}/${SLURM_JOB_ID}.dcf"

## The per-task view, i.e. what each 'srun' task sees
srun Rscript "${here}/probe.R" "${outdir}/${SLURM_JOB_ID}.srun.%t.dcf"
