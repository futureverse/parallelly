#!/usr/bin/env bash
# Submit one Grid Engine (SGE) job per combination of parallel
# environment (PE) and number of slots, where each job records what SGE
# sets and what parallelly reports, both in the job script and on each
# host of the job via 'qrsh -inherit'
#
# Usage:
#   ./submit.sh [outdir]
#
# When all jobs have finished, summarize with:
#   Rscript collect.R <outdir>
#
# Options:
#   PQ_DRYRUN=true   Only list the 'qsub' calls
#   PQ_PES           Parallel environments to use, e.g. PQ_PES="smp mpi"
#                    (default: all PEs according to 'qconf -spl')
#   PQ_SLOTS         Number of slots to request (default: "1 2 4 8 16")
#   PQ_QSUB_ARGS     Extra 'qsub' options for all jobs, e.g.
#                    PQ_QSUB_ARGS="-q long.q"
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
outdir=${1:-sweep-$(date +%Y%m%d-%H%M%S)}
mkdir -p "${outdir}"
outdir=$(cd "${outdir}" && pwd)

read -r -a extra_args <<< "${PQ_QSUB_ARGS:-}"

if [[ -n ${PQ_PES:-} ]]; then
  read -r -a pes <<< "${PQ_PES}"
else
  mapfile -t pes < <(qconf -spl)
fi
read -r -a slots_set <<< "${PQ_SLOTS:-1 2 4 8 16}"

## Record the settings of each PE, which are site specific
pes_file="${outdir}/pes.tsv"
printf "pe\tallocation_rule\tcontrol_slaves\tslots\n" > "${pes_file}"
for pe in "${pes[@]}"; do
  if settings=$(qconf -sp "${pe}" 2>/dev/null); then
    get() { awk -v key="$1" '$1 == key { print $2 }' <<< "${settings}"; }
    printf "%s\t%s\t%s\t%s\n" "${pe}" "$(get allocation_rule)" "$(get control_slaves)" "$(get slots)" >> "${pes_file}"
  else
    printf "%s\t\t\t\n" "${pe}" >> "${pes_file}"
  fi
done

## No PE, and each PE with different number of slots
specs=("")
for pe in "${pes[@]}"; do
  for slots in "${slots_set[@]}"; do
    specs+=("-pe ${pe} ${slots}")
  done
  ## A range of slots, and core binding
  specs+=("-pe ${pe} 2-4")
  specs+=("-pe ${pe} 4 -binding linear:4")
done

## Map job ID to its resource specification
jobs="${outdir}/jobs.tsv"
[[ -f ${jobs} ]] || printf "job_id\tspec\n" > "${jobs}"

for spec in "${specs[@]}"; do
  read -r -a spec_args <<< "${spec}"
  args=(
    -terse
    -S /bin/bash
    -N parallelly-query
    -j y
    -o "${outdir}/\$JOB_ID.log"
    -l h_rt=00:05:00
    -l mem_free=300M  ## per slot
    -w e  ## reject jobs that can never be scheduled
    "${extra_args[@]}"
    "${spec_args[@]}"
  )

  if ${PQ_DRYRUN:-false}; then
    echo "qsub ${args[*]} ${here}/probe.sh ${outdir} ${here}"
    continue
  fi

  if job_id=$(qsub "${args[@]}" "${here}/probe.sh" "${outdir}" "${here}"); then
    job_id=${job_id%%.*}  ## drop '.<tasks>' suffix, if any
    printf "%s\t%s\n" "${job_id}" "${spec}" >> "${jobs}"
    echo "Submitted job ${job_id}: ${spec:-(no PE)}"
  else
    echo "Rejected by qsub: ${spec}" >&2
    printf "%s\t%s\n" "rejected" "${spec}" >> "${jobs}"
  fi
done

echo "Results will be written to: ${outdir}"
echo "When done, run: Rscript ${here}/collect.R ${outdir}"
