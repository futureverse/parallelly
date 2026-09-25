# Summarize the results of submit.sh
#
# Usage: Rscript collect.R <outdir>
args <- commandArgs(trailingOnly = TRUE)
outdir <- if (length(args) > 0) args[1] else "."

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

## Settings of the parallel environments (PEs) used
pes <- read.delim(file.path(outdir, "pes.tsv"), colClasses = "character")
data$allocation_rule <- pes$allocation_rule[match(data$PE, pes$pe)]

ncores <- as.integer(data$availableCores)
data$cores_eq_local_workers <- (ncores == as.integer(data$nworkers.local))
data$cores_eq_local_slots   <- (ncores == as.integer(data$slots.local))
data$workers_eq_nslots      <- (as.integer(data$nworkers) == as.integer(data$NSLOTS))

## Per-host view from 'qrsh -inherit', one file per host
inherit_files <- dir(outdir, pattern = "[.]inherit[.].+[.]dcf$", full.names = TRUE)
if (length(inherit_files) > 0) {
  inherit <- read_dcfs(inherit_files)
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

write.csv(data, file.path(outdir, "summary.csv"), row.names = FALSE)

## Print compact table
cols <- c("spec", "allocation_rule", "availableCores", "slots.local",
          "nworkers.local", "availableWorkers", "NSLOTS", "NHOSTS",
          "SGE_BINDING", "availableCores.nproc", "inherit_cores",
          "inherit_slots_local", "inherit_nproc",
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
cat(sprintf("Full results: %s\n", file.path(outdir, "summary.csv")))
