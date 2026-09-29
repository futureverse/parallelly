# Summarize the results of submit.sh
#
# Usage: Rscript collect.R <outdir>
#
# Hostnames are anonymized as n1, n2, n3, ... in the summaries, but not
# in the raw results in <outdir>. Use PQ_ANONYMIZE=false to keep them
args <- commandArgs(trailingOnly = TRUE)
outdir <- if (length(args) > 0) args[1] else "."

## Load anonymize_hostnames() from the same folder as this script
here <- dirname(sub("^--file=", "", grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]))
source(file.path(here, "anonymize.R"))

jobs <- read.delim(file.path(outdir, "jobs.tsv"), colClasses = "character")

files <- file.path(outdir, sprintf("%s.dcf", jobs$job_id))
done <- file_test("-f", files)
if (any(!done)) {
  message(sprintf("Skipping %d of %d jobs without results (rejected, pending, or failed)",
          sum(!done), length(done)))
}
jobs <- jobs[done, ]
files <- files[done]

## Read DCF files, with possibly different fields, into one data frame
read_dcfs <- function(files) {
  rows <- lapply(files, FUN = function(f) {
    as.data.frame(read.dcf(f, all = TRUE))
  })
  fields <- unique(unlist(lapply(rows, FUN = colnames)))
  rows <- lapply(rows, FUN = function(row) {
    row[setdiff(fields, colnames(row))] <- NA_character_
    row[fields]
  })
  do.call(rbind, rows)
}

data <- read_dcfs(files)
data <- cbind(spec = jobs$spec, data)

## Per-host view from 'qrsh -inherit', one file per host
inherit_files <- dir(outdir, pattern = "[.]inherit[.].+[.]dcf$", full.names = TRUE)
inherit <- if (length(inherit_files) > 0) read_dcfs(inherit_files) else NULL

## What each parallel worker sees
worker_files <- dir(outdir, pattern = "[.]psock[.][0-9]+[.]dcf$", full.names = TRUE)
workers <- if (length(worker_files) > 0) read_dcfs(worker_files) else NULL

## Anonymize hostnames, using the same aliases in all results
if (as.logical(Sys.getenv("PQ_ANONYMIZE", "true"))) {
  frames <- anonymize_hostnames(
    list(data = data, inherit = inherit, workers = workers),
    host_fields = c("HOSTNAME", "nodename"),
    hostfile_fields = "PE_HOSTFILE.content",
    workers_fields = "availableWorkers"
  )
  data <- frames$data
  inherit <- frames$inherit
  workers <- frames$workers
}

## Settings of the parallel environments (PEs) used
pes <- read.delim(file.path(outdir, "pes.tsv"), colClasses = "character")
data$allocation_rule <- pes$allocation_rule[match(data$PE, pes$pe)]

ncores <- as.integer(data$availableCores)
data$cores_eq_local_workers <- (ncores == as.integer(data$nworkers.local))
data$cores_eq_local_slots   <- (ncores == as.integer(data$slots.local))
data$workers_eq_nslots      <- (as.integer(data$nworkers) == as.integer(data$NSLOTS))

## Per-host view from 'qrsh -inherit'
if (!is.null(inherit)) {
  inherit <- inherit[order(as.integer(inherit$JOB_ID), inherit$nodename), ]
  inherit <- cbind(spec = jobs$spec[match(inherit$JOB_ID, jobs$job_id)], inherit)
  write.csv(inherit, file.path(outdir, "summary-inherit.csv"), row.names = FALSE)

  ## Per-job summaries across hosts, e.g. "8,8"
  per_job <- function(field) {
    vapply(data$JOB_ID, FUN.VALUE = NA_character_, FUN = function(id) {
      x <- inherit[[field]][inherit$JOB_ID == id]
      if (length(x) == 0) NA_character_ else paste(x, collapse = ",")
    })
  }
  data$inherit_cores       <- per_job("availableCores")
  data$inherit_slots_local <- per_job("slots.local")
  data$inherit_nproc       <- per_job("availableCores.nproc")
}

## Launching parallel workers as in the 'parallelly-17-hpc-workers'
## vignette, i.e. via 'qrsh -inherit' for workers on other hosts
psock_files <- file.path(outdir, sprintf("%s.psock.dcf", data$JOB_ID))
has_psock <- file_test("-f", psock_files)
if (any(has_psock)) {
  psock <- read_dcfs(psock_files[has_psock])
  idx <- match(data$JOB_ID, psock$JOB_ID)
  data$psock_status  <- psock$status[idx]
  data$psock_seconds <- psock$seconds[idx]
}

## What each parallel worker sees
if (!is.null(workers)) {
  workers <- workers[order(as.integer(workers$JOB_ID), as.integer(workers$worker)), ]
  workers <- cbind(spec = jobs$spec[match(workers$JOB_ID, jobs$job_id)], workers)
  write.csv(workers, file.path(outdir, "summary-psock.csv"), row.names = FALSE)

  ## Per-job tallies across workers, e.g. "2*8" for 8 workers with two cores
  tally_per_job <- function(field) {
    vapply(data$JOB_ID, FUN.VALUE = NA_character_, FUN = function(id) {
      x <- workers[[field]][workers$JOB_ID == id]
      if (length(x) == 0) return(NA_character_)
      t <- table(x)
      paste(sprintf("%s*%d", names(t), t), collapse = ",")
    })
  }
  data$psock_cores <- tally_per_job("availableCores")
  data$psock_nproc <- tally_per_job("availableCores.nproc")
}

write.csv(data, file.path(outdir, "summary.csv"), row.names = FALSE)

## Print compact table
cols <- c("spec", "allocation_rule", "availableCores", "slots.local",
          "nworkers.local", "availableWorkers", "NSLOTS", "NHOSTS",
          "SGE_BINDING", "availableCores.nproc", "inherit_cores",
          "inherit_slots_local", "inherit_nproc",
          "psock_status", "psock_seconds", "psock_cores", "psock_nproc",
          "cores_eq_local_workers", "cores_eq_local_slots",
          "workers_eq_nslots")
cols <- intersect(cols, colnames(data))
cols <- cols[vapply(data[cols], FUN.VALUE = NA, FUN = function(x) !all(is.na(x)))]
data2 <- data[cols]
options(width = 250L)
print(data2, right = FALSE, row.names = FALSE)

bad <- which(!data$cores_eq_local_workers)
cat(sprintf("\navailableCores() != #local availableWorkers() in %d of %d jobs\n",
            length(bad), nrow(data)))

## Which kinds of allocation rules were covered? A fixed number of slots
## per host, e.g. '2', is reported as '<integer>'
rules <- data$allocation_rule[!is.na(data$allocation_rule)]
rules <- unique(sub("^[[:digit:]]+$", "<integer>", rules))
missing <- setdiff(c("$pe_slots", "$fill_up", "$round_robin", "<integer>"), rules)
cat(sprintf("Allocation rules covered: %s\n", paste(sort(rules), collapse = ", ")))
if (length(missing) > 0) {
  cat(sprintf("Allocation rules not covered: %s\n", paste(missing, collapse = ", ")))
}

## Jobs spanning more than one host, which are needed to see how slots
## are split across hosts
multi <- sum(as.integer(data$NHOSTS) > 1L, na.rm = TRUE)
cat(sprintf("Jobs spanning more than one host: %d of %d\n", multi, nrow(data)))
cat(sprintf("Full results: %s\n", file.path(outdir, "summary.csv")))
