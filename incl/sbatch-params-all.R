library(future.batchtools)
library(future.apply)
library(tibble)
library(readr)
library(progressr)
handlers(global = TRUE)
handlers("cli")

task_specs_list <- list(
  list(ntasks = NA, nodes = NA, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  
  list(ntasks = NA, nodes = NA, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = NA, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = NA, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = NA, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = 1L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = 2L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = 4L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  
  list(ntasks = 1L, nodes = NA, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = NA, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = NA, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = NA, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = NA, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = 1L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = 1L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = 1L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = 1L, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 1L, nodes = 1L, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  
  list(ntasks = 2L, nodes = NA, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = NA, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = NA, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = NA, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = NA, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 1L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 1L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 1L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 1L, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 1L, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 2L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 2L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 2L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 2L, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 2L, nodes = 2L, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),

  list(ntasks = 4L, nodes = NA, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = NA, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = NA, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = NA, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = NA, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 2L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 2L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 2L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 2L, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 2L, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 4L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 4L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 4L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 4L, cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 4L, cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),

  list(ntasks = NA, nodes = "1-2", cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = "1-2", cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = "1-2", cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = "1-2", cpus_per_task = 3L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = NA, nodes = "1-2", cpus_per_task = 4L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA)
)


## --threads-per-core=n: n must be <= 2
task_specs_list <- list(
  list(ntasks = 4L, nodes = 1L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = 1),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = 1),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = 1),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = 2),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 1L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = 2),
  list(ntasks = 4L, nodes = 1L, cpus_per_task = 2L, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = 2),

  list(ntasks = 4L, nodes = 2L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = NA),
  list(ntasks = 4L, nodes = 2L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = 1),
  list(ntasks = 4L, nodes = 2L, cpus_per_task = NA, ntasks_per_core = NA, ntasks_per_node = NA, ntasks_per_socket = NA, threads_per_core = 2)
)


vs <- local({
  p <- progressr::progressor(along = task_specs_list)
  
  fs <- lapply(task_specs_list, FUN = function(task_specs) {
    on.exit(p("Submit job", amount = 0.5))
    resources <- list()
    resources[["cli_options"]] <- c(list(time = "00:01:00"), task_specs)
##    message("resources:"); R.utils::mstr(resources)

    oplan <- plan(batchtools_slurm, resources = resources)
    on.exit(plan(oplan), add = TRUE)
    
    future({
      on.exit(p("Resolved", amount = 0.5))
      res <- task_specs
      envvars <- c(
        "SLURM_JOB_ID",
        "HOSTNAME",
        "SLURM_NTASKS",
        "SLURM_JOB_NUM_NODES",
        "SLURM_JOB_NODELIST",
        "SLURM_JOB_NUM_NODES",
        "SLURM_JOB_CPUS_ON_NODE",
        "SLURM_JOB_CPUS_PER_NODE",
        "SLURM_TASKS_PER_NODE",
        "SLURM_CPUS_PER_TASK",
        "SLURM_CPUS_ON_NODE",
        "SLURM_NTASKS_PER_CORE",
        "SLURM_NTASKS_PER_NODE",
        "SLURM_NTASKS_PER_SOCKET",
        "SLURM_TASKS_PER_NODE",
        "SLURM_THREADS_PER_CORE"
      )
      for (name in envvars) {
        value <- Sys.getenv(name, NA_character_)
        res[[name]] <- value
      }
      res$availableCores   <- parallelly::availableCores()
      res$availableWorkers <- list(parallelly::availableWorkers())
      res$nproc            <- parallelly::availableCores(methods = "nproc")
      res$cgroups          <- parallelly::availableCores(methods = c("cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max"))
      res$proc_status      <- parallelly::availableCores(methods = c("/proc/self/status"))
      res
    })
  })

  message("Number of jobs: ", length(fs))
  vs <- value(fs)
})
vs <- lapply(vs, FUN = as_tibble)

data <- do.call(rbind, vs)
data$availableWorkers <- vapply(data$availableWorkers, FUN.VALUE = NA_character_, FUN = function(x) {
  t <- table(x)
  paste(sprintf("%d*%s", t, names(t)), collapse = ", ")
})

## Drop uninformative columns
keep <- apply(data, MARGIN=2L, FUN = function(x) !all(is.na(x)))
data <- data[, keep]

## Assert redundancy assumptions
##   (i) SLURM_NTASKS == ntasks
stopifnot(with(data, identical(as.integer(SLURM_NTASKS), ntasks)))

##  (ii) SLURM_CPUS_PER_TASK == cpus_per_task
if ("SLURM_CPUS_PER_TASK" %in% colnames(data)) {
  stopifnot(with(data, identical(as.integer(SLURM_CPUS_PER_TASK), cpus_per_task)))
}

## (iii) HOSTNAME == availableWorkers()[1]
void <- lapply(vs, FUN = function(job) with(job, stopifnot(availableWorkers[[1]][1] == HOSTNAME)))

##  (iv) nproc = cgroups = proc.status
stopifnot(with(data, identical(unname(nproc), as.integer(cgroups)), identical(unname(proc), proc_status)))

## NOT TRUE: (v) availableCores() == sum(availableWorkers() == availableWorkers()[1])
# ns_first <- vapply(vs, FUN.VALUE = NA_integer_, FUN = function(job) with(job, { sum(availableWorkers[[1]] == availableWorkers[[1]][1]) }))
# void <- lapply(vs, FUN = function(job) with(job, { stopifnot(availableCores == sum(availableWorkers[[1]] == availableWorkers[[1]][1]) }))

## Drop redundant data
keep <- !(colnames(data) %in% c("HOSTNAME"))
data <- data[, keep]

if (FALSE) {
keep <- !(colnames(data) %in% c("SLURM_NTASKS", "SLURM_CPUS_PER_TASK", "HOSTNAME"))
data <- data[, keep]
}

## Order by SLURM_CPUS_PER_TASK (== cpus_per_task)
if ("SLURM_CPUS_PER_TASK" %in% colnames(data)) {
  data <- data[with(data, order(cpus_per_task, na.last = FALSE)), ]
}  

## Drop other less-useful columns
keep <- !(colnames(data) %in% c("SLURM_JOB_ID"))
data <- data[, keep]
data0 <- data

## Reorder columns
cols <- c(
  ## Input
  "ntasks", "nodes", "cpus_per_task", "threads_per_core",

  ## parallelly output
  "availableCores", "availableWorkers",

  ## Slurm
  "SLURM_NTASKS",             # input
  "SLURM_JOB_NUM_NODES",      # allocations
  "SLURM_CPUS_PER_TASK",      # input
  "SLURM_JOB_NODELIST",       # allocations
  "SLURM_TASKS_PER_NODE",     # allocations
  "SLURM_JOB_CPUS_PER_NODE",  # allocations
  "SLURM_CPUS_ON_NODE",       # "current-machine" view

  ## system tools output
  "nproc", "cgroups", "proc_status"
)

cols <- intersect(cols, colnames(data))
data <- data[, cols]

## Reorder rows
if ("cpus_per_task" %in% colnames(data)) {
  data <- data[with(data, order(ntasks, cpus_per_task, nodes, na.last = FALSE)), ]
} else {
  data <- data[with(data, order(ntasks, nodes, na.last = FALSE)), ]
}

## Write to file
readr::write_csv(data, "sbatch-params-all-02.csv")

## Print without SLURM_ prefix
data2 <- data
## Add asterisk to env vars reflecting the Slurm input parameters
cols <- c("SLURM_NTASKS", "SLURM_CPUS_PER_TASK")
names <- colnames(data2)
names[names %in% cols] <- paste0(names[names %in% cols], ".")
colnames(data2) <- names
colnames(data2) <- gsub("^SLURM_", "", colnames(data2))
options(width = 200)
print(data2, n = 100L)
