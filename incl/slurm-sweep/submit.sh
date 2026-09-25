#!/usr/bin/env bash
# Submit one Slurm job per combination of resource options, where
# each job records what Slurm sets and what parallelly reports, both
# in the batch script and in each 'srun' task
#
# Usage:
#   ./submit.sh [outdir]
#
# When all jobs have finished, summarize with:
#   Rscript collect.R <outdir>
#
# Options:
#   PQ_DRYRUN=true   Only list the 'sbatch' calls
#   PQ_SBATCH_ARGS   Extra 'sbatch' options for all jobs, e.g.
#                    PQ_SBATCH_ARGS="--partition=debug"
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
outdir=${1:-sweep-$(date +%Y%m%d-%H%M%S)}
mkdir -p "${outdir}"
outdir=$(cd "${outdir}" && pwd)

read -r -a extra_args <<< "${PQ_SBATCH_ARGS:-}"

## Full grid of (--nodes, --ntasks, --cpus-per-task); "" = not specified
nodes_set=("" 1 2 "1-2")
ntasks_set=("" 1 2 4 16)
cpus_per_task_set=("" 1 2 3 4)

## Additional, hand-picked specifications
extra_specs=(
  "--nodes=2 --ntasks-per-node=2"
  "--nodes=2 --ntasks-per-node=2 --cpus-per-task=2"
  "--nodes=1 --ntasks=4 --threads-per-core=1"
  "--nodes=1 --ntasks=4 --cpus-per-task=2 --threads-per-core=1"
  "--nodes=2 --ntasks=4 --cpus-per-task=2 --distribution=cyclic"
  "--nodes=1 --exclusive"
)

specs=()
for nodes in "${nodes_set[@]}"; do
  for ntasks in "${ntasks_set[@]}"; do
    ## Skip impossible requests, i.e. fewer tasks than (minimum) nodes
    if [[ -n ${nodes} && -n ${ntasks} ]] && (( ntasks < ${nodes%%-*} )); then
      continue
    fi
    for cpus_per_task in "${cpus_per_task_set[@]}"; do
      spec=""
      [[ -n ${nodes}         ]] && spec+=" --nodes=${nodes}"
      [[ -n ${ntasks}        ]] && spec+=" --ntasks=${ntasks}"
      [[ -n ${cpus_per_task} ]] && spec+=" --cpus-per-task=${cpus_per_task}"
      specs+=("${spec# }")
    done
  done
done
specs+=("${extra_specs[@]}")

## Map job ID to its resource specification
jobs="${outdir}/jobs.tsv"
[[ -f ${jobs} ]] || printf "job_id\tspec\n" > "${jobs}"

for spec in "${specs[@]}"; do
  read -r -a spec_args <<< "${spec}"
  args=(
    --parsable
    --job-name=parallelly-query
    --time=00:05:00
    --output="${outdir}/%j.log"
    "${extra_args[@]}"
    "${spec_args[@]}"
  )
  
  if ${PQ_DRYRUN:-false}; then
    echo "sbatch ${args[*]} ${here}/probe.sh ${outdir} ${here}"
    continue
  fi
  
  if job_id=$(sbatch "${args[@]}" "${here}/probe.sh" "${outdir}" "${here}"); then
    job_id=${job_id%%;*}  ## drop ';cluster' suffix, if any
    printf "%s\t%s\n" "${job_id}" "${spec}" >> "${jobs}"
    echo "Submitted job ${job_id}: ${spec:-(defaults)}"
  else
    echo "Rejected by sbatch: ${spec}" >&2
    printf "%s\t%s\n" "rejected" "${spec}" >> "${jobs}"
  fi
done

echo "Results will be written to: ${outdir}"
echo "When done, run: Rscript ${here}/collect.R ${outdir}"
