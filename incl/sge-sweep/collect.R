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
## Status of jobs without results, i.e. rejected by 'qsub', still
## pending or running, in an error state, or ended without results. The
## status is looked up using 'qstat' and 'qacct', if available. Hostnames
## are not anonymized here
job_status <- function(ids) {
  status <- rep("unknown", times = length(ids))
  reason <- rep("", times = length(ids))
  run <- function(cmd, args) {
    if (!nzchar(Sys.which(cmd))) return(character(0L))
    suppressWarnings(system2(cmd, args = shQuote(args), stdout = TRUE, stderr = FALSE))
  }

  ## Jobs still in the queue, e.g. "123 0.5 parallelly-query alice qw ..."
  lines <- run("qstat", c("-u", Sys.getenv("USER")))
  for (x in strsplit(trimws(lines), split = "[[:space:]]+")) {
    idx <- which(ids == x[1])
    if (length(idx) == 0L || length(x) < 5L) next
    state <- x[5]
    status[idx] <- if (grepl("E", state, fixed = TRUE)) {
      sprintf("error (%s)", state)  ## e.g. 'Eqw', which never starts
    } else if (grepl("h", state, fixed = TRUE)) {
      sprintf("on hold (%s)", state)
    } else if (grepl("qw", state, fixed = TRUE)) {
      "pending"
    } else {
      sprintf("running (%s)", state)
    }
    ## Why? Requires 'schedd_job_info true' for pending jobs
    info <- run("qstat", c("-j", x[1]))
    info <- grep("^(error reason|scheduling info)", info, value = TRUE)
    if (length(info) > 0L) reason[idx] <- trimws(sub("^[^:]*:", "", info[1]))
  }

  ## Jobs no longer in the queue
  for (kk in which(status == "unknown")) {
    info <- run("qacct", c("-j", ids[kk]))
    get <- function(key) {
      value <- grep(sprintf("^%s[[:space:]]", key), info, value = TRUE)
      if (length(value) == 0L) NA_character_ else trimws(sub(sprintf("^%s", key), "", value[1]))
    }
    failed <- get("failed")
    if (is.na(failed)) next
    if (failed != "0") {
      status[kk] <- "failed"
      reason[kk] <- failed
    } else {
      status[kk] <- "finished without results"
      reason[kk] <- sprintf("exit status %s", get("exit_status"))
    }
  }

  data.frame(status = status, reason = reason)
}

if (any(!done)) {
  message(sprintf("Skipping %d of %d jobs without results:", sum(!done), length(done)))
  todo <- jobs[!done, ]
  status <- data.frame(status = rep("rejected by qsub", times = nrow(todo)), reason = "")
  submitted <- (todo$job_id != "rejected")
  if (any(submitted)) status[submitted, ] <- job_status(todo$job_id[submitted])
  todo <- cbind(todo, status)
  todo$spec[!nzchar(todo$spec)] <- "(no PE)"
  print(todo, right = FALSE, row.names = FALSE)
  stuck <- todo$job_id[todo$status == "pending" | grepl("^(error|on hold)", todo$status)]
  if (length(stuck) > 0L) {
    cat(sprintf("\nTo delete the %d pending, on-hold, or failed-to-start jobs: qdel %s\n\n", length(stuck), paste(stuck, collapse = " ")))
  }
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
## With 'job_is_first_task TRUE', the job script uses one of the slots,
## e.g. 'qrsh -inherit' to the job's own host fails for '-pe <pe> 1'.
## Not recorded by older versions of submit.sh
if (!is.null(pes$job_is_first_task)) {
  data$job_is_first_task <- pes$job_is_first_task[match(data$PE, pes$pe)]
}

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
  ## Could the PE hostfile be found via SGE_JOB_SPOOL_DIR, e.g. "yes,no"?
  if (!is.null(inherit$spool.pe_hostfile)) {
    inherit$spool_found <- ifelse(is.na(inherit$spool.pe_hostfile), NA,
                             ifelse(inherit$spool.pe_hostfile == "(none)", "no", "yes"))
    data$inherit_spool_pe_hostfile <- per_job("spool_found")
  }
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
cols <- c("spec", "allocation_rule", "job_is_first_task", "availableCores", "slots.local",
          "nworkers.local", "availableWorkers", "NSLOTS", "NHOSTS",
          "SGE_BINDING", "availableCores.nproc", "inherit_cores",
          "inherit_slots_local", "inherit_nproc",
          "psock_status", "psock_seconds", "psock_cores", "psock_nproc",
          "inherit_spool_pe_hostfile",
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
