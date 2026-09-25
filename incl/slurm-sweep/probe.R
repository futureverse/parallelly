# Record Slurm environment variables and what parallelly reports
#
# Usage: Rscript probe.R <file.dcf>
#
# Any '%t' in <file.dcf> is replaced by the task ID (SLURM_PROCID), so
# that each 'srun' task writes its own file.
args <- commandArgs(trailingOnly = TRUE)
file <- gsub("%t", Sys.getenv("SLURM_PROCID", "NA"), args[1], fixed = TRUE)

envvars <- c(
  "SLURM_JOB_ID",
  "SLURMD_NODENAME",
  "SLURM_JOB_NUM_NODES",
  "SLURM_JOB_NODELIST",
  "SLURM_NTASKS",
  "SLURM_NTASKS_PER_NODE",
  "SLURM_TASKS_PER_NODE",
  "SLURM_CPUS_PER_TASK",
  "SLURM_JOB_CPUS_PER_NODE",
  "SLURM_CPUS_ON_NODE",
  "SLURM_THREADS_PER_CORE",
  ## Set within 'srun' job steps
  "SLURM_STEP_ID",
  "SLURM_STEP_NUM_TASKS",
  "SLURM_STEP_NODELIST",
  "SLURM_STEP_TASKS_PER_NODE",
  "SLURM_PROCID",
  "SLURM_LOCALID"
)
res <- as.list(Sys.getenv(envvars, unset = NA_character_, names = TRUE))
res[["hostname"]] <- Sys.info()[["nodename"]]
res[["parallelly"]] <- as.character(utils::packageVersion("parallelly"))

## availableCores(), overall and per method
res[["availableCores"]] <- parallelly::availableCores()
all <- parallelly::availableCores(which = "all")
for (name in names(all)) res[[paste0("availableCores.", name)]] <- all[[name]]

## availableWorkers(), e.g. "n1*4, n2*4"
workers <- parallelly::availableWorkers()
t <- table(factor(workers, levels = unique(workers)))
res[["availableWorkers"]] <- paste(sprintf("%s*%d", names(t), t), collapse = ", ")
res[["nworkers"]] <- length(workers)
res[["nworkers.local"]] <- sum(workers == res[["SLURMD_NODENAME"]])

res <- lapply(res, FUN = as.character)
write.dcf(as.data.frame(res, check.names = FALSE), file = file)
