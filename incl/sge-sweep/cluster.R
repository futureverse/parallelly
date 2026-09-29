# Launch parallel workers as in the 'parallelly-17-hpc-workers' vignette,
# i.e. using rshcmd = "<hpc>", which resolves to "<qrsh>", and record
# whether it succeeded and what each worker sees. "<qrsh>" launches
# each worker on another host via 'qrsh -inherit -nostdin -V'.
# Contrary to the vignette, 'rscript_startup' does not set 'mc.cores',
# so that we can see what availableCores() reports in each worker
#
# Usage: Rscript cluster.R <outdir>
#
# Writes <outdir>/<jobid>.psock.dcf with a summary of the launch, and
# <outdir>/<jobid>.psock.<worker>.dcf for each worker. The output from
# 'qrsh' when launching the workers is written to <outdir>/<jobid>.psock.out
library(parallelly)

args <- commandArgs(trailingOnly = TRUE)
outdir <- args[1]
jobid <- Sys.getenv("JOB_ID")

## Skip jobs with too many workers, which would take too long to launch
max_workers <- as.integer(Sys.getenv("PQ_MAX_WORKERS", "128"))

workers <- availableWorkers()
res <- list(
  JOB_ID = jobid,
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
  envs <- Sys.getenv(c("JOB_ID", "HOSTNAME", "NSLOTS", "NHOSTS", "PE", "PE_HOSTFILE"), unset = NA_character_, names = TRUE)
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
      rshcmd = "<hpc>",
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
      if (is.na(info$JOB_ID)) info$JOB_ID <- jobid
      file <- file.path(outdir, sprintf("%s.psock.%d.dcf", jobid, kk))
      write.dcf(as.data.frame(info, check.names = FALSE), file = file)
    }
  }
}

res <- lapply(res, FUN = as.character)
write.dcf(as.data.frame(res, check.names = FALSE), file = file.path(outdir, sprintf("%s.psock.dcf", jobid)))
