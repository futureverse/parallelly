library(parallelly)

message("*** availableWorkers() ...")

## The default
w <- availableWorkers()
print(w)
stopifnot(is.character(w), length(w) >= 1)

## Minimium of all known settings (default)
print(availableWorkers(which = "min"))

## Maximum of all known settings (should never be used)
print(availableWorkers(which = "max"))

## All known settings
print(availableWorkers(na.rm = FALSE, which = "all"))

## System settings
w <- availableWorkers(methods = "system")
print(w)
stopifnot(is.character(w), length(w) >= 1)

## Predefined ones for known cluster schedulers
print(availableWorkers(methods = "PBS"))
print(availableWorkers(methods = "SGE"))
print(availableWorkers(methods = "Slurm"))
print(availableWorkers(methods = "LSF"))
print(availableWorkers(methods = "PJM"))


message("*** HPC related ...")

sge_expand_node_count_pairs <- parallelly:::sge_expand_node_count_pairs
read_pbs_nodefile <- parallelly:::read_pbs_nodefile
read_pjm_nodefile <- parallelly:::read_pjm_nodefile
read_pe_hostfile <- parallelly:::read_pe_hostfile

workers0 <- c("n1", "n2", "n3", "n1", "n6", "n3", "n3", "n5")
data0 <- as.data.frame(table(workers0), stringsAsFactors = FALSE)
colnames(data0) <- c("node", "count")
data0 <- data0[order(data0$node, data0$count), ]


message("*** LSF ...")

Sys.setenv(LSB_HOSTS = paste(workers0, collapse = " "))
workers <- availableWorkers(methods = "LSF")
print(workers)
stopifnot(length(workers) == length(workers0))

message("*** LSF ... done")



message("*** read_pbs_nodefile() ...")

workers <- workers0
pathname <- tempfile()
writeLines(workers, con = pathname)

data <- read_pbs_nodefile(pathname)
str(data)
stopifnot(
  c("node") %in% colnames(data),
  is.character(data$node),
  !anyNA(data$node),
  nrow(data$node) == length(workers),
  all(sort(data$node) == sort(workers))
)

Sys.setenv(PBS_NODEFILE = pathname)
Sys.setenv(PBS_NP = length(workers),
           PBS_NUM_NODES = length(workers) / 2,
           PBS_NUM_PPN = 2)
workers <- availableWorkers(methods = "PBS")
print(workers)
stopifnot(length(workers) == length(workers0), all(workers == sort(workers0)))

Sys.setenv(PBS_NUM_PPN = 3)
res <- tryCatch({
  workers <- availableWorkers(methods = "PBS")
}, warning = identity)
stopifnot(inherits(res, "warning"))

Sys.setenv(PBS_NP = length(workers) + 1)
res <- tryCatch({
  workers <- availableWorkers(methods = "PBS")
}, warning = identity)
stopifnot(inherits(res, "warning"))

## Exceptions
workersE <- c(workers, "n 3")
pathname <- tempfile()
writeLines(workersE, con = pathname)
res <- tryCatch(read_pbs_nodefile(pathname), error = identity)
print(res)
stopifnot(inherits(res, "error"))

Sys.setenv(PBS_NODEFILE = "<non-existing-file>")
res <- tryCatch({
  workers <- availableWorkers(methods = "PBS")
}, warning = identity)
stopifnot(inherits(res, "warning"))

message("*** read_pbs_nodefile() ... DONE")




message("*** read_pjm_nodefile() ...")

workersT <- unique(workers0)
pathname <- tempfile()
writeLines(workersT, con = pathname)

data <- read_pjm_nodefile(pathname)
str(data)
stopifnot(
  c("node") %in% colnames(data),
  is.character(data$node),
  !anyNA(data$node),
  nrow(data$node) == length(workersT),
  all(sort(data$node) == sort(workersT)),
  identical(data$node, unique(data$node))
)

Sys.setenv(PJM_O_NODEINF = pathname)

message("- PJM_VNODE_CORE=1")
Sys.setenv(PJM_VNODE_CORE = "1")
workers <- availableWorkers(methods = "PJM")
print(workers)
stopifnot(
  length(workers) == length(workersT),
  all(sort(workers) == sort(workersT))
)

message("- PJM_VNODE=", length(workersT))
message("- PJM_VNODE_CORE=2")
Sys.setenv(PJM_VNODE = length(workersT))
Sys.setenv(PJM_VNODE_CORE = "2")
workers <- availableWorkers(methods = "PJM")
print(workers)
stopifnot(
  length(workers) == 2L * length(workersT),
  all(workers %in% workersT),
  all(workersT %in% workers)
)


message("- PJM_VNODE=1 (incompatible => warning)")
message("- PJM_VNODE_CORE=2")
Sys.setenv(PJM_VNODE = "1")
Sys.setenv(PJM_VNODE_CORE = "2")
workers <- availableWorkers(methods = "PJM")
print(workers)
stopifnot(
  length(workers) == 2L * length(workersT),
  all(workers %in% workersT),
  all(workersT %in% workers)
)


message("- PJM_O_NODEINF = <non-existing-file>")
Sys.setenv(PJM_O_NODEINF = "<non-existing-file>")
res <- tryCatch({
  workers <- availableWorkers(methods = "PJM")
}, warning = identity)
stopifnot(inherits(res, "warning"))

message("*** read_pjm_nodefile() ... DONE")



message("*** read_pe_hostfile() ...")

workers <- workers0
pathname <- tempfile()
write.table(data0, file = pathname, quote = FALSE, row.names = FALSE, col.names = FALSE)
lines <- readLines(pathname)
print(lines)
data <- read_pe_hostfile(pathname, expand = FALSE)
print(data)
stopifnot(
  is.character(data$node),
  !anyNA(data$node),
  is.integer(data$count),
  !anyNA(data$count),
  all(is.finite(data$count)),
  all(data$count > 0),
  nrow(data) == nrow(data0),
  all.equal(data[, c("node", "count")], data0[, c("node", "count")])
)

workers <- sge_expand_node_count_pairs(data)
stopifnot(length(workers) == length(workers0), all(workers == sort(workers0)))

Sys.setenv(PE_HOSTFILE = pathname)
Sys.setenv(NSLOTS = length(workers0))  ## Use to validate results
workers <- availableWorkers(methods = "SGE")
print(workers)
stopifnot(length(workers) == length(workers0), all(workers == sort(workers0)))

## Test validation
Sys.setenv(NSLOTS = length(workers0) + 1L)
workers <- tryCatch(availableWorkers(methods = "SGE"), warning = identity)
print(workers)
stopifnot(inherits(workers, "warning"))

Sys.setenv(PE_HOSTFILE = "<non-existing-file>")
res <- tryCatch({
  workers <- availableWorkers(methods = "SGE")
}, warning = identity)
stopifnot(inherits(res, "warning"))

message("*** read_pe_hostfile() ... DONE")


message("*** Slurm w/ SLURM_JOB_NODELIST ...")

slurm_expand_nodelist <- parallelly:::slurm_expand_nodelist

specs <- list(
  "n1" = c("n1"),
  "  n1" = c("n1"),
  "n1,,  n3" = c("n1", "n3"),
  "n1,  n3" = c("n1", "n3"),
  "n3  n1" = c("n3", "n1"),
  "n[1-13]" = sprintf("n%d", c(1:13)),
  ## scontrol show hostname treats "n[1,3-4,  11-13]" == "n[1,3-4,0011-13]"
  "n[1,3-4,  11-13]" = c("n1", "n3", "n4", "n0011", "n0012", "n0013"),
  "a1,b[   02-04,6-7]" = c("a1", "b00002", "b00003", "b00004", "b6", "b7")
)

## All combined
all <- list(unlist(specs, use.names = FALSE))
names(all) <- paste(names(specs), collapse = ",")
specs <- c(specs, all)

## Again, all combined but in reverse order 
all <- list(unlist(rev(specs), use.names = FALSE))
names(all) <- paste(rev(names(specs)), collapse = ",")
specs <- c(specs, all)

for (kk in seq_along(specs)) {
  message(sprintf("- Specification #%d of %d", kk, length(specs)))
  nodelist <- names(specs)[kk]
  truth <- specs[[kk]]
  cat(sprintf("nodelist: %s\n", sQuote(nodelist)))
  expanded <- slurm_expand_nodelist(nodelist, manual = TRUE)
  cat(sprintf("expanded: c(%s)\n", paste(sQuote(expanded), collapse = ", ")))
  cat(sprintf("truth: c(%s)\n", paste(sQuote(truth), collapse = ", ")))
  stopifnot(
    is.character(expanded),
    !any(is.na(expanded)),
    length(expanded) == length(truth),
    identical(expanded, truth)
  )

  Sys.unsetenv(c("SLURM_JOB_NODELIST", "SLURM_NODELIST",
                 "SLURM_JOB_CPUS_PER_NODE", "SLURM_TASKS_PER_NODE"))

  ## Test without SLURM_JOB_CPUS_PER_NODE/SLURM_TASKS_PER_NODE
  Sys.setenv(SLURM_JOB_NODELIST = nodelist)
  for (name in c("SLURM_JOB_NODELIST", "SLURM_JOB_CPUS_PER_NODE")) {
    cat(sprintf("%s = %s\n", name, sQuote(Sys.getenv(name))))
  }
  workers <- availableWorkers(methods = "Slurm")
  cat(sprintf("workers: c(%s)\n", paste(sQuote(workers), collapse = ", ")))
  stopifnot(identical(workers, truth))


  ## Test with SLURM_JOB_CPUS_PER_NODE/SLURM_TASKS_PER_NODE
  nhosts <- length(expanded)
  ncores_per_host <- sample(1:10, size = nhosts, replace = TRUE)

  ## Handle the case when 'nodelist' result in a non-ordered 'expanded'
  expanded2 <- as.list(expanded)
  for (kk in seq_along(expanded2)) {
    expanded2[[kk]] <- rep(expanded2[[kk]], times = ncores_per_host[kk])
  }
  expanded2 <- unlist(expanded2, use.names = FALSE)

  Sys.setenv(SLURM_JOB_NODELIST = nodelist)
  Sys.setenv(SLURM_JOB_CPUS_PER_NODE = paste(ncores_per_host, collapse = ","))

  for (name in c("SLURM_JOB_NODELIST", "SLURM_JOB_CPUS_PER_NODE")) {
    cat(sprintf("%s = %s\n", name, sQuote(Sys.getenv(name))))
  }
  workers <- availableWorkers(methods = "Slurm")
  cat(sprintf("workers: c(%s)\n", paste(sQuote(workers), collapse = ", ")))
  stopifnot(identical(unique(workers), unique(truth)))
  counts <- table(workers)
  counts <- counts[unique(workers)]
  print(counts)
  counts2 <- table(expanded2)
  counts2 <- counts2[unique(expanded2)]
  print(counts2)
  stopifnot(
    sum(counts) == sum(ncores_per_host),
    sum(counts) == sum(counts2),
    all(counts == counts2)
  )
  
  Sys.unsetenv(c("SLURM_JOB_NODELIST", "SLURM_JOB_CPUS_PER_NODE"))
}

message("*** Slurm w/ SLURM_JOB_NODELIST ... DONE")


message("*** Slurm w/ SLURM_TASKS_PER_NODE ...")

slurm_expand_nodecounts <- parallelly:::slurm_expand_nodecounts

specs <- list(
  "1" = c(1L),
  "1,3" = c(1L,3L),
  "1, 3" = c(1L,3L),
  "2(x3)" = rep(2L, times = 3L),
  "2(x3),3,4(x1)" = c(rep(2L, times = 3L), 3L, 4L)
)

for (kk in seq_along(specs)) {
  message(sprintf("- Specification #%d of %d", kk, length(specs)))
  nodecounts <- names(specs)[kk]
  truth <- specs[[kk]]
  cat(sprintf("nodecounts: %s\n", sQuote(nodecounts)))
  expanded <- slurm_expand_nodecounts(nodecounts)
  cat(sprintf("expanded: c(%s)\n", paste(sQuote(expanded), collapse = ", ")))
  cat(sprintf("truth: c(%s)\n", paste(sQuote(truth), collapse = ", ")))
  stopifnot(
    is.integer(expanded),
    !any(is.na(expanded)),
    length(expanded) == length(truth),
    identical(expanded, truth)
  )
}

message("*** Slurm w/ SLURM_TASKS_PER_NODE ... DONE")



message("*** HPC related ... DONE")


## Any R options and system environment variable
print(availableWorkers(methods = c("width", "FOO_BAR_ENV"),
                     na.rm = FALSE, which = "all"))

## Exception handling
Sys.setenv("FOO_BAR_ENV" = "0")
res <- tryCatch(availableWorkers(methods = "FOO_BAR_ENV"), error = identity)
stopifnot(inherits(res, "error"))

message("*** availableWorkers() ... DONE")
