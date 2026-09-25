# Record Grid Engine (SGE) environment variables and what parallelly reports
#
# Usage: Rscript probe.R <file.dcf>
args <- commandArgs(trailingOnly = TRUE)
file <- args[1]

envvars <- c(
  "JOB_ID",
  "HOSTNAME",
  "QUEUE",
  "PE",
  "NSLOTS",
  "NHOSTS",
  "NQUEUES",
  "PE_HOSTFILE",
  "SGE_BINDING",
  "OMP_NUM_THREADS"
)
res <- as.list(Sys.getenv(envvars, unset = NA_character_, names = TRUE))
res[["nodename"]] <- Sys.info()[["nodename"]]
res[["parallelly"]] <- as.character(utils::packageVersion("parallelly"))

## Hostnames may or may not be fully qualified
is_local <- function(hosts) {
  me <- res[["nodename"]]
  hosts %in% c("localhost", me) | sub("[.].*", "", hosts) == sub("[.].*", "", me)
}

## The PE hostfile, e.g. "n1 4 all.q@n1 UNDEFINED; n2 4 all.q@n2 UNDEFINED",
## and the number of slots on the current host
pathname <- res[["PE_HOSTFILE"]]
if (!is.na(pathname) && file_test("-f", pathname)) {
  lines <- readLines(pathname, warn = FALSE)
  res[["PE_HOSTFILE.content"]] <- paste(lines, collapse = "; ")
  fields <- strsplit(lines, split = "[[:space:]]+")
  hosts <- vapply(fields, FUN = `[`, 1L, FUN.VALUE = NA_character_)
  slots <- as.integer(vapply(fields, FUN = `[`, 2L, FUN.VALUE = NA_character_))
  res[["slots.local"]] <- sum(slots[is_local(hosts)])
}

## availableCores(), overall and per method
res[["availableCores"]] <- parallelly::availableCores()
all <- parallelly::availableCores(which = "all")
for (name in names(all)) res[[paste0("availableCores.", name)]] <- all[[name]]

## availableWorkers(), e.g. "n1*4, n2*4"
workers <- parallelly::availableWorkers()
t <- table(factor(workers, levels = unique(workers)))
res[["availableWorkers"]] <- paste(sprintf("%s*%d", names(t), t), collapse = ", ")
res[["nworkers"]] <- length(workers)
res[["nworkers.local"]] <- sum(is_local(workers))

res <- lapply(res, FUN = as.character)
write.dcf(as.data.frame(res, check.names = FALSE), file = file)
