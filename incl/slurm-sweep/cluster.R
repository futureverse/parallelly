# Launch parallel workers as in the 'parallelly-17-hpc-workers' vignette,
# i.e. one 'srun --exact --overlap --nodes=1 --ntasks=1 --cpus-per-task=1'
# job step per worker, and record whether it succeeded and what each
# worker sees. Option '--overcommit' is needed on Slurm 21.08, where
# otherwise a job step waits for the CPUs of other job steps on the same
# node, although '--overlap' is specified
#
# Usage: Rscript cluster.R <outdir>
#
# Writes <outdir>/<jobid>.psock.dcf with a summary of the launch, and
# <outdir>/<jobid>.psock.<worker>.dcf for each worker. The output from
# 'srun' when launching the workers is written to <outdir>/<jobid>.psock.out
library(parallelly)

args <- commandArgs(trailingOnly = TRUE)
outdir <- args[1]
jobid <- Sys.getenv("SLURM_JOB_ID")

## Skip jobs with too many workers, e.g. --exclusive, which would take
## too long to launch
max_workers <- as.integer(Sys.getenv("PQ_MAX_WORKERS", "128"))

workers <- availableWorkers()
res <- list(
  SLURM_JOB_ID = jobid,
  nworkers = length(workers),
  nnodes = length(unique(workers))
)

## What a worker sees
probe <- function() {
  res <- list(
    nodename = Sys.info()[["nodename"]],
    pid = Sys.getpid(),
    availableCores = parallelly::availableCores()
  )
  all <- parallelly::availableCores(which = "all")
  for (name in names(all)) res[[paste0("availableCores.", name)]] <- all[[name]]
  envs <- Sys.getenv()
  envs <- envs[grep("^SLURM", names(envs))]
  for (name in names(envs)) res[[name]] <- envs[[name]]
  lapply(res, FUN = as.character)
}

if (length(workers) > max_workers) {
  res$status <- sprintf("skipped (more than %d workers)", max_workers)
} else {
  t0 <- Sys.time()
  cl <- tryCatch({
    makeClusterPSOCK(
      workers,
      rshcmd = c("srun", "--exact", "--overlap", "--overcommit", "--nodes=1",
                 "--ntasks=1", "--cpus-per-task=1", "-w"),
      rscript_sh = c("auto", "none"),
      connectTimeout = 60,
      outfile = file.path(outdir, sprintf("%s.psock.out", jobid))
    )
  }, error = identity)
  res$seconds <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), digits = 1)

  if (inherits(cl, "error")) {
    res$status <- "failed"
    res$error <- conditionMessage(cl)
  } else {
    res$status <- "ok"
    infos <- parallel::clusterCall(cl, fun = probe)
    parallel::stopCluster(cl)
    for (kk in seq_along(infos)) {
      info <- c(list(worker = kk), infos[[kk]])
      if (is.null(info$SLURM_JOB_ID)) info$SLURM_JOB_ID <- jobid
      file <- file.path(outdir, sprintf("%s.psock.%d.dcf", jobid, kk))
      write.dcf(as.data.frame(info, check.names = FALSE), file = file)
    }
  }
}

res <- lapply(res, FUN = as.character)
write.dcf(as.data.frame(res, check.names = FALSE), file = file.path(outdir, sprintf("%s.psock.dcf", jobid)))
