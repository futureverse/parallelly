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

## Sum of expanded Slurm node counts, e.g. "4(x2),2" -> 10
sum_counts <- function(x) {
  vapply(x, FUN.VALUE = NA_integer_, FUN = function(s) {
    if (is.na(s)) return(NA_integer_)
    parts <- strsplit(s, split = ",", fixed = TRUE)[[1]]
    n <- as.integer(sub("[(].*", "", parts))
    times <- as.integer(sub(".*[(]x([0-9]+)[)]$", "\\1", parts))
    times[!grepl("(x", parts, fixed = TRUE)] <- 1L
    sum(n * times)
  })
}

ncores <- as.integer(data$availableCores)
data$cores_eq_local_workers <- (ncores == as.integer(data$nworkers.local))
data$cores_eq_cpus_on_node  <- (ncores == as.integer(data$SLURM_CPUS_ON_NODE))
data$workers_eq_job_cpus    <- (as.integer(data$nworkers) == sum_counts(data$SLURM_JOB_CPUS_PER_NODE))
data$workers_eq_ntasks      <- (as.integer(data$nworkers) == sum_counts(data$SLURM_TASKS_PER_NODE))

## Per-task view from 'srun', one file per task
srun_files <- dir(outdir, pattern = "[.]srun[.][0-9]+[.]dcf$", full.names = TRUE)
if (length(srun_files) > 0) {
  srun <- read_dcfs(srun_files)
  srun <- srun[order(as.integer(srun$SLURM_JOB_ID), as.integer(srun$SLURM_PROCID)), ]
  srun <- cbind(spec = jobs$spec[match(srun$SLURM_JOB_ID, jobs$job_id)], srun)
  write.csv(srun, file.path(outdir, "summary-srun.csv"), row.names = FALSE)

  ## Per-job summaries across tasks, e.g. "2,2,2,2"
  per_job <- function(field) {
    vapply(data$SLURM_JOB_ID, FUN.VALUE = NA_character_, FUN = function(id) {
      x <- srun[[field]][srun$SLURM_JOB_ID == id]
      if (length(x) == 0) NA_character_ else paste(x, collapse = ",")
    })
  }
  data$srun_cores        <- per_job("availableCores")
  data$srun_cpus_on_node <- per_job("SLURM_CPUS_ON_NODE")
  data$srun_nproc        <- per_job("availableCores.nproc")
}

write.csv(data, file.path(outdir, "summary.csv"), row.names = FALSE)

## Print compact table without the 'SLURM_' prefix
cols <- c("spec", "availableCores", "nworkers.local", "availableWorkers",
          "SLURM_JOB_NODELIST", "SLURM_TASKS_PER_NODE",
          "SLURM_JOB_CPUS_PER_NODE", "SLURM_CPUS_ON_NODE",
          "SLURM_CPUS_PER_TASK", "availableCores.nproc", "srun_cores",
          "srun_cpus_on_node", "srun_nproc",
          "cores_eq_local_workers", "cores_eq_cpus_on_node",
          "workers_eq_job_cpus")
cols <- intersect(cols, colnames(data))
cols <- cols[vapply(data[cols], FUN.VALUE = NA, FUN = function(x) !all(is.na(x)))]
data2 <- data[cols]
colnames(data2) <- sub("^SLURM_", "", colnames(data2))
options(width = 250L)
print(data2, right = FALSE, row.names = FALSE)

bad <- which(!data$cores_eq_local_workers)
cat(sprintf("\navailableCores() != #local availableWorkers() in %d of %d jobs\n",
            length(bad), nrow(data)))
cat(sprintf("Full results: %s\n", file.path(outdir, "summary.csv")))
