#' Get Set of Available Workers
#'
#' @param constraints An optional character specifying under what
#' constraints ("purposes") we are requesting the values.
#' Using `constraints = "connections"`, will append `"connections"` to
#' the `methods` argument.
#'
#' @param methods A character vector specifying how to infer the number
#' of available cores.
#'
#' @param na.rm If TRUE, only non-missing settings are considered/returned.
#'
#' @param logical Passed as-is to [availableCores()].
#'
#' @param default The default set of workers.
#'
#' @param which A character specifying which set / sets to return.
#' If `"auto"` (default), the first non-empty set found.
#' If `"min"`, the minimum value is returned.
#' If `"max"`, the maximum value is returned (be careful!)
#' If `"all"`, all values are returned.
#'
#' @return Return a character vector of workers, which typically consists
#' of names of machines / compute nodes, but may also be IP numbers.
#'
#' @details
#' The default set of workers for each method is
#' `rep("localhost", times = availableCores(methods = method, logical = logical))`,
#' which means that each will at least use as many parallel workers on the
#' current machine that [availableCores()] allows for that method.
#'
#' In addition, the following settings ("methods") are also acknowledged:
#' \itemize{
#'  \item `"LSF"` -
#'    Query Platform Load Sharing Facility (LSF)/OpenLava environment variable
#'    \env{LSB_HOSTS}.
#'
#'  \item `"PJM"` - 
#'    Query Fujitsu Technical Computing Suite (that we choose to shorten
#'    as "PJM") the hostname file given by environment variable
#'    \env{PJM_O_NODEINF}.
#'    The \env{PJM_O_NODEINF} file lists the hostnames of the nodes allotted.
#'    This function returns those hostnames each repeated `availableCores()`
#'    times, where `availableCores()` reflects \env{PJM_VNODE_CORE}.
#'    For example, for `pjsub -L vnode=2 -L vnode-core=8 hello.sh`, the
#'    \env{PJM_O_NODEINF} file gives two hostnames, and \env{PJM_VNODE_CORE}
#'    gives eight cores per host, resulting in a character vector of 16
#'    hostnames (for two unique hostnames).
#'
#'  \item `"PBS"` -
#'    Query TORQUE/PBS environment variable \env{PBS_NODEFILE}.
#'    If this is set and specifies an existing file, then the set
#'    of workers is read from that file, where one worker (node)
#'    is given per line.
#'    An example of a job submission that results in this is
#'    `qsub -l nodes=4:ppn=2`, which requests four nodes each
#'    with two cores.
#'
#'  \item `"SGE"` -
#'    Query Sun Grid Engine/Oracle Grid Engine/Son of Grid Engine (SGE)
#'    and Univa Grid Engine (UGE)/Altair Grid Engine (AGE) environment
#'    variable \env{PE_HOSTFILE}.
#'    An example of a job submission that results in this is
#'    `qsub -pe mpi 8` (or `qsub -pe ompi 8`), which
#'    requests eight cores on a any number of machines.
#'
#'  \item `"Slurm"` -
#'    Query Slurm environment variable \env{SLURM_JOB_NODELIST} (fallback
#'    to legacy \env{SLURM_NODELIST}) and parse set of nodes.
#'    Then query Slurm environment variable \env{SLURM_JOB_CPUS_PER_NODE}
#'    (fallback \env{SLURM_TASKS_PER_NODE}) to infer how many CPU cores
#'    Slurm have allotted to each of the nodes.  If \env{SLURM_CPUS_PER_TASK}
#'    is set, which is always a scalar, then that is respected too, i.e.
#'    if it is smaller, then that is used for all nodes.
#'    For example, if `SLURM_NODELIST="n1,n[03-05]"` (expands to
#'    `c("n1", "n03", "n04", "n05")`) and `SLURM_JOB_CPUS_PER_NODE="2(x2),3,2"`
#'    (expands to `c(2, 2, 3, 2)`), then
#'    `c("n1", "n1", "n03", "n03", "n04", "n04", "n04", "n05", "n05")` is
#'    returned.  If in addition, `SLURM_CPUS_PER_TASK=1`, which can happen
#'    depending on hyperthreading configurations on the Slurm cluster, then 
#'    `c("n1", "n03", "n04", "n05")` is returned.
#'
#'  \item `"custom"` -
#'    If option
#'    \code{\link[=parallelly.options]{parallelly.availableWorkers.custom}}
#'    is set and a function,
#'    then this function will be called (without arguments) and it's value
#'    will be coerced to a character vector, which will be interpreted as
#'    hostnames of available workers.
#'    It is safe for this custom function to call `availableWorkers()`; if
#'    done, the custom function will _not_ be recursively called.
#' }
#'
#' @section Known limitations:
#' `availableWorkers(methods = "Slurm")` will expand \env{SLURM_JOB_NODELIST}
#' using \command{scontrol show hostnames "$SLURM_JOB_NODELIST"}, if available.
#' If not available, then it attempts to parse the compressed nodelist based
#' on a best-guess understanding on what the possible syntax may be.
#' One known limitation is that "multi-dimensional" ranges are not supported,
#' e.g. `"a[1-2]b[3-4]"` is expanded by \command{scontrol} to
#' `c("a1b3", "a1b4", "a2b3", "a2b4")`.  If \command{scontrol} is not
#' available, then any components that failed to be parsed are dropped with
#' an informative warning message.  If no components could be parsed, then
#' the result of `methods = "Slurm"` will be empty.
#'
#' @examples
#' message(paste("Available workers:",
#'         paste(sQuote(availableWorkers()), collapse = ", ")))
#'
#' \dontrun{
#' options(mc.cores = 2L)
#' message(paste("Available workers:",
#'         paste(sQuote(availableWorkers()), collapse = ", ")))
#' }
#'
#' \dontrun{
#' ## Always use two workers on host 'n1' and one on host 'n2'
#' options(parallelly.availableWorkers.custom = function() {
#'   c("n1", "n1", "n2")
#' })
#' message(paste("Available workers:",
#'         paste(sQuote(availableWorkers()), collapse = ", ")))
#' }
#'
#' \dontrun{
#' ## A 50% random subset of the available workers.
#' ## Note that it is safe to call availableWorkers() here.
#' options(parallelly.availableWorkers.custom = function() {
#'   workers <- parallelly::availableWorkers()
#'   sample(workers, size = 0.50 * length(workers))
#' })
#' message(paste("Available workers:",
#'         paste(sQuote(availableWorkers()), collapse = ", ")))
#' }
#'
#' @seealso
#' To get the number of available workers on the current machine,
#' see [availableCores()].
#'
#' @importFrom utils file_test
#' @export
availableWorkers <- function(constraints = NULL, methods = getOption2("parallelly.availableWorkers.methods", c("mc.cores", "BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "LSF", "PJM", "PBS", "SGE", "Slurm", "custom", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc", "system", "fallback")), na.rm = TRUE, logical = getOption2("parallelly.availableCores.logical", TRUE), default = getOption2("parallelly.localhost.hostname", "localhost"), which = c("auto", "min", "max", "all")) {
  stop_if_not(
    is.null(constraints) || is.character(constraints), !anyNA(constraints)
  )

  which <- match.arg(which, choices = c("auto", "min", "max", "all"))
  stop_if_not(is.character(default), length(default) >= 1, !anyNA(default))

  methods_localhost <- c("BiocParallel", "_R_CHECK_LIMIT_CORES_", "Bioconductor", "mc.cores", "mc.cores+1", "cgroups.cpuset", "cgroups.cpuquota", "cgroups2.cpu.max", "nproc", "system")

  if ("connections" %in% constraints) {
    methods <- unique(c(methods, "connections"))
    methods_localhost <- unique(c(methods_localhost, "connections"))
    constraints <- setdiff(constraints, "connections")
  }

  ## Default is to use the current machine
  ncores <- availableCores(constraints = constraints, methods = methods, na.rm = FALSE, logical = logical, which = "all")

  localhost_hostname <- getOption2("parallelly.localhost.hostname", "localhost")
  workers <- lapply(ncores, FUN = function(n) {
    if (length(n) == 0 || is.na(n)) n <- 0L
    rep(localhost_hostname, times = n)
  })
  
  ## Acknowledge known HPC settings (skip others)
  methodsT <- setdiff(methods, methods_localhost)
  for (method in methodsT) {
    if (method == "PBS") {
      w <- availableWorkersPBS()
      if (anyNA(w)) next
    } else if (method == "SGE") {
      w <- availableWorkersSGE()
      if (anyNA(w)) next
    } else if (method == "Slurm") {
      w <- availableWorkersSlurm()
      if (anyNA(w)) next
    } else if (method == "LSF") {
      w <- availableWorkersLSF()
      if (anyNA(w)) next
    } else if (method == "PJM") {
      w <- availableWorkersPJM()
      if (anyNA(w)) next
    } else if (method == "custom") {
      fcn <- getOption2("parallelly.availableWorkers.custom", NULL)
      if (!is.function(fcn)) next
      w <- local({
        ## Avoid calling the custom function recursively
        oopts <- options(parallelly.availableWorkers.custom = NULL)
        on.exit(options(oopts))
        fcn()
      })
      w <- as.character(w)
    } else {
      ## Fall back to querying option and system environment variable
      ## with the given name
      w <- getopt_chr(method)
      if (is.na(w)) w <- getenv_chr(method)
      if (is.na(w)) next
      w <- split_trim(w)
    }

    ## Drop missing values?
    if (na.rm) w <- w[!is.na(w)]

    workers[[method]] <- w
  }

  
  nnodes <- unlist(lapply(workers, FUN = length), use.names = TRUE)
  
  if (which == "auto") {
    ## For default localhost sets, use the minimum allowed number of
    ## workers **according to availableCores()**.
    methodsT <- intersect(names(workers), methods_localhost)
    methodsT <- methodsT[is.finite(ncores[methodsT]) & ncores[methodsT] > 0]
    if (length(methodsT) > 1L) {
      min <- min(ncores[methodsT], na.rm = TRUE)
      if (is.finite(min)) {
        nnodes[methodsT] <- min
        workers[methodsT] <- list(rep(localhost_hostname, times = min))
      }
    }

    workers <- apply_fallback(workers)
    nnodes <- unlist(lapply(workers, FUN = length), use.names = TRUE)
    
    ## Now, pick the first positive and finite value
    idx <- which(nnodes > 0L, useNames = FALSE)[1]
    workers <- if (is.na(idx)) character(0L) else workers[[idx]]
  } else if (which == "min") {
    workers <- apply_fallback(workers)
    nnodes <- unlist(lapply(workers, FUN = length), use.names = TRUE)
    idx <- which.min(nnodes)
    workers <- workers[[idx]]
  } else if (which == "max") {
    workers <- apply_fallback(workers)
    nnodes <- unlist(lapply(workers, FUN = length), use.names = TRUE)
    idx <- which.max(nnodes)
    workers <- workers[[idx]]
  }

  ## Fall back to default?
  if (is.character(workers) && length(workers) == 0) workers <- default

  ## Sanity checks
  min_count <- as.integer(na.rm)
  if (is.list(workers)) {
    lapply(workers, FUN = function(w) {
      stop_if_not(is.character(w), length(w) >= 0L, all(nchar(w) > 0))
    })
  } else {
    stop_if_not(is.character(workers), length(workers) >= min_count, all(nchar(workers) > 0))
  }

  workers
} # availableWorkers()



## Used by availableWorkers()
apply_fallback <- function(workers) {
  ## No 'fallback'?
  idx_fallback <- which(names(workers) == "fallback")
  if (length(idx_fallback) == 0) return(workers)

  ## Number of workers per set
  nnodes <- unlist(lapply(workers, FUN = length), use.names = TRUE)

  ## No 'fallback' workers?
  if (nnodes[idx_fallback] == 0) return(workers)
  
  ## Only consider non-empty sets
  nonempty <- which(nnodes > 0)
  workers_nonempty <- workers[nonempty]

  ## Nothing to do?
  n_nonempty <- length(workers_nonempty)
  if (n_nonempty <= 1) return(workers)
  
  ## Drop 'fallback'?
  if (n_nonempty > 2) {
    workers <- workers[-idx_fallback]
    return(workers)
  }
  
  ## No 'system' to override?
  idx_system <- which(names(workers) == "system")
  if (length(idx_system) == 0) return(workers)

  ## Drop 'system' in favor or 'fallback'
  workers <- workers[-idx_system]

  workers
} ## apply_fallback()



# --------------------------------------------------------------------------
# Utility functions
# --------------------------------------------------------------------------
## Local functions
getenv_chr <- function(name) {
  as.character(trim(getEnvVar2(name, default = NA_character_)))
}

getopt_chr <- function(name) {
  as.character(getOption2(name, default = NA_character_))
}


split_trim <- function(s) {
  x <- unlist(strsplit(s, split = "[, ]", fixed = FALSE), use.names = FALSE)
  x <- trim(x)
  x <- x[nzchar(x)]
  x
}


# --------------------------------------------------------------------------
# High-Performance Compute (HPC) Schedulers
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
# LSF
# --------------------------------------------------------------------------
availableWorkersLSF <- function() {      
  data <- getenv_chr("LSB_HOSTS")
  if (is.na(data)) return(NA_character_)
  w <- split_trim(data)
  w
} ## availableWorkersLSF()



# --------------------------------------------------------------------------
# PBS
# --------------------------------------------------------------------------
#' @importFrom utils read.table
read_pbs_nodefile <- function(pathname, sort = TRUE) {
  ## One (node) per line
  lines <- readLines(pathname, warn = FALSE)
  lines <- trim(lines)

  ## Sanity checks
  stop_if_not(
    all(nzchar(lines)),
    !anyNA(lines),
    !any(grepl("[[:space:]]", lines))
  )

  data <- data.frame(node = lines, stringsAsFactors = FALSE)

  if (sort) {
    data <- data[order(data$node), , drop = FALSE]
  }

  data
}

availableWorkersPBS <- function() {    
  pathname <- getenv_chr("PBS_NODEFILE")
  if (is.na(pathname)) return(NA_character_)
  
  if (!file_test("-f", pathname)) {
    warnf("Environment variable %s was set but no such file %s exists", sQuote("PBS_NODEFILE"), sQuote(pathname))
    return(NA_character_)
  }
  
  data <- read_pbs_nodefile(pathname)
  w <- data$node

  ## Sanity checks
  pbs_np <- getenv_int("PBS_NP")
  if (!identical(pbs_np, length(w))) {
    warnf("Identified %d workers from the %s file (%s), which does not match environment variable %s = %d", length(w), sQuote("PBS_NODEFILE"), sQuote(pathname), sQuote("PBS_NP"), pbs_np)
  }

  pbs_nodes <- getenv_int("PBS_NUM_NODES")
  pbs_ppn <- getenv_int("PBS_NUM_PPN")
  pbs_np <- pbs_nodes * pbs_ppn
  if (!identical(pbs_np, length(w))) {
    warnf("Identified %d workers from the %s file (%s), which does not match environment variables %s * %s = %d * %d = %d", length(w), sQuote("PBS_NODEFILE"), sQuote(pathname), sQuote("PBS_NUM_NODES"), sQuote("PBS_NUM_PPN"), pbs_nodes, pbs_ppn, pbs_np)
  }

  ## TO DO: Add validation of 'w' (from PBS_HOSTFILE) toward
  ## counts in PBS_NP and / or PBS_NUM_NODES * PBS_NUM_PPN.
  
  w
} ## availableWorkersPBS()      




# --------------------------------------------------------------------------
# PJM
# --------------------------------------------------------------------------
#' @importFrom utils read.table
read_pjm_nodefile <- function(pathname, sort = TRUE) {
  read_pbs_nodefile(pathname, sort = sort)
}

availableWorkersPJM <- function() {      
  pathname <- getenv_chr("PJM_O_NODEINF")
  if (is.na(pathname)) return(NA_character_)
  
  if (!file_test("-f", pathname)) {
    warnf("Environment variable %s was set but no such file %s exists", sQuote("PJM_O_NODEINF"), sQuote(pathname))
    return(NA_character_)
  }
  
  data <- read_pjm_nodefile(pathname, sort = FALSE)

  ## Sanity check against PJM_VNODE
  n <- suppressWarnings(getenv_int("PJM_VNODE"))
  if (!is.na(n) && n != nrow(data)) {
    warnf("Environment variable %s does not agree with the number of hosts in file %s: %s != %s", sQuote("PJM_VNODE"), sQuote("PJM_O_NODEINF"), getenv_chr("PJM_VNODE"), nrow(data))
  }

  ## This will query PJM for the number of cores per worker, which we
  ## assume is the same for all workers, because I don't think it can
  ## be different across workers, but not 100% sure.  If for some 
  ## reason availableCores() don't find a PJM environment variable of
  ## interest, it'll fall back to the default (=1).  If so, we give
  ## an informative warning with troubleshooting info. /HB 2022-05-28
  cores_per_worker <- availableCores(methods = "PJM")
  if (!grepl("PJM", names(cores_per_worker))) {
    warnf("Inferred parallel workers from the hostname file given by environment variable %s, but could not find a corresponding 'PJM_*' environment variable for inferring the number of cores per worker: %s", sQuote("PJM_O_NODEINF"), paste(sQuote(grep("^PJM_", names(Sys.getenv()), value = TRUE)), collapse = ", "))
  }
  w <- rep(data$node, each = cores_per_worker)
  w
} ## availableWorkersPJM()




# --------------------------------------------------------------------------
# SGE
# --------------------------------------------------------------------------
#' @importFrom utils read.table
read_pe_hostfile <- function(pathname, sort = TRUE, expand = FALSE) {
  ## One (node, ncores, queue, comment) per line, e.g.
  ## opt88 3 short.q@opt88 UNDEFINED
  ## iq242 2 short.q@iq242 UNDEFINED
  ## opt116 1 short.q@opt116 UNDEFINED
  data <- read.table(pathname, header = FALSE, sep = " ", stringsAsFactors = FALSE)
  
  ## Sanity checks
  stop_if_not(ncol(data) >= 2)
  
  colnames(data)[1:2] <- c("node", "count")
  if (ncol(data) >= 3) colnames(data)[3] <- "via"
  if (ncol(data) >= 4) colnames(data)[4] <- "notes"

  stop_if_not(
    is.character(data$node),
    !anyNA(data$node),
    !any(grepl("[[:space:]]", data$node)),
    is.integer(data$count),
    !anyNA(data$count),
    all(is.finite(data$count)),
    all(data$count > 0)
  )

  if (sort) {
    data <- data[order(data$node, data$count), , drop = FALSE]
  }

  if (expand) {
    data <- sge_expand_node_count_pairs(data)
  }
  
  data
}


## Used after read_pe_hostfile()
sge_expand_node_count_pairs <- function(data) {
  nodes <- mapply(data$node, data$count, FUN = function(node, count) {
    rep(node, times = count)
  }, SIMPLIFY = FALSE, USE.NAMES = FALSE)
  unlist(nodes, recursive = FALSE, use.names = FALSE)
}

availableWorkersSGE <- function() {      
  pathname <- getenv_chr("PE_HOSTFILE")
  if (is.na(pathname)) return(NA_character_)
  
  if (!file_test("-f", pathname)) {
    warnf("Environment variable %s was set but no such file %s exists", sQuote("PE_HOSTFILE"), sQuote(pathname))
    return(NA_character_)
  }
  
  w <- read_pe_hostfile(pathname, expand = TRUE)

  ## Sanity checks: It is not always true that length(w) == $NSLOTS, e.g.
  ## on the UCSF Wynton SGE cluster, 'qsub -pe mpi-8 16 ...' will produce
  ## a job with w=2 workers and NSLOTS=16. /HB 2023-02-01
  nslots <- getenv_int("NSLOTS")
  if (length(w) < nslots) {
    warnf("Identified %d workers from the %s file (%s), which is less than environment variable %s = %d", length(w), sQuote("PE_HOSTFILE"), sQuote(pathname), sQuote("NSLOTS"), nslots)
  }

  w
} ## availableWorkersSGE()      



# --------------------------------------------------------------------------
# Slurm
# --------------------------------------------------------------------------
#' @importFrom utils file_test
call_slurm_show_hostname <- function(nodelist, bin = Sys.which("scontrol")) {
  stop_if_not(file_test("-x", bin))
  
  args <- c("show", "hostname", shQuote(nodelist))
  res <- system2(bin, args = args, stdout = TRUE)
  status <- attr(res, "status")
  if (!is.null(status)) {
    call <- sprintf("%s %s", shQuote(bin), paste(args, collapse = " "))
    msg <- sprintf("%s failed with exit code %s", call, status)
    stop(msg)
  }
  
  res
}

supports_scontrol_show_hostname <- local({
  res <- NA
  function() {
    if (!is.na(res)) return(res)

    ## Look for 'scontrol'
    bin <- Sys.which("scontrol")
    if (!nzchar(bin)) {
      res <<- FALSE
      return(res)
    }

    ## Try a conversion
    truth <- c("a1", "b02", "b03", "b04", "b6", "b7")
    nodelist <- "a1,b[02-04,6-7]"
    
    hosts <- tryCatch({
      call_slurm_show_hostname(nodelist, bin = bin)
    }, error = identity)
    
    if (inherits(hosts, "error")) {
      res <<- FALSE
      return(res)
    }

    ## Sanity check
    if (!isTRUE(all.equal(sort(hosts), sort(truth)))) {
      warnf("Internal availableWorkers() validation failed: 'scontrol show hostnames %s' did not return the expected results.  Expected c(%s) but got c(%s).  Will still use it this methods but please report this to the maintainer of the 'parallelly' package", shQuote(nodelist), commaq(truth), commaq(hosts), immediate. = TRUE)
    }
    
    value <- TRUE
    attr(value, "scontrol") <- bin
    res <<- value
    
    res
  }
})


## SLURM_JOB_NODELIST="a1,b[02-04,6-7]"
slurm_expand_nodelist <- function(nodelist, manual = getOption2("parallelly.slurm_expand_nodelist.manual", FALSE)) {
  ## Alt 1. Is 'scontrol show hostnames' supported?
  if (!manual && supports_scontrol_show_hostname()) {
    hosts <- call_slurm_show_hostname(nodelist)
    return(hosts)
  }

  ## Alt 2. Manually parse the nodelist specification
  data <- nodelist

  ## Replace whitespace *within* square brackets with zeros
  ## Source: scontrol show hostnames treats "n[1,  3-4]" == "n[1,003-4]"
  pattern <- "\\[([[:digit:],-]*)[[:space:]]([[:digit:][:space:],-]*)"
  while (grepl(pattern, data)) {
    data <- gsub(pattern, "[\\10\\2", data)
  }

  ## Replace any commas *within* square brackets with semicolons
  pattern <- "\\[([[:digit:][:space:];-]*),([[:digit:][:space:];-]*)"
  while (grepl(pattern, data)) {
    data <- gsub(pattern, "[\\1;\\2", data)
  }

  data <- strsplit(data, split = "[,[:space:]]", fixed = FALSE)
  data <- as.list(unlist(data, use.names = FALSE))

  ## Keep only non-empty entries, which may happen due to whitespace or
  ## extra commas.  This should not happen but 'scontrol show hostnames'
  ## handles those cases too.
  data <- data[nzchar(data)]

  for (ii in seq_along(data)) {
    spec <- data[[ii]]

    ## Already expanded?
    if (length(spec) > 1L) next
    
    ## 1. Expand square-bracket specifications
    ##    e.g. "a1,b[02-04,6-7]" => c("a1", "b02", "b03", "b04", "b6", "b7")
    pattern <- "^(.*)\\[([[:digit:];-]+)\\]$"
    if (grepl(pattern, spec)) {
      prefix <- gsub(pattern, "\\1", spec)
      set <- gsub(pattern, "\\2", spec)

      sets <- strsplit(set, split = ";", fixed = TRUE)
      sets <- unlist(sets, use.names = FALSE)
      sets <- as.list(sets)
      
      for (jj in seq_along(sets)) {
        set <- sets[[jj]]
        ## Expand by evaluating them as R expressions
        idxs <- tryCatch({
          expr <- parse(text = gsub("-", ":", set, fixed = TRUE))
          eval(expr, envir = baseenv())
        }, error = function(e) NA_integer_)
        idxs <- as.character(idxs)
        
        ## Pad with zeros?
        pattern <- "^([0]*)[[:digit:]]+.*"
        if (grepl(pattern, set)) {
          pad <- gsub(pattern, "\\1", set)
          idxs <- paste(pad, idxs, sep = "")
        }

        set <- paste(prefix, idxs, sep = "")
        sets[[jj]] <- set
      } ## for (jj ...)

      sets <- unlist(sets, use.names = FALSE)
      data[[ii]] <- sets
    }
  } ## for (ii in ...)
  
  hosts <- unlist(data, recursive = FALSE, use.names = FALSE)

  ## Sanity check
  if (any(!nzchar(hosts))) {
    warnf("Unexpected result from parallelly:::slurm_expand_nodelist(..., manual = TRUE), which resulted in %d empty hostname based on nodelist specification %s", sum(!nzchar(hosts)), sQuote(nodelist))
    hosts <- hosts[nzchar(hosts)]
  }

  ## Failed to expand all compressed ranges?  This may happen because 
  ## "multi-dimensional" ranges are given, e.g. "a[1-2]b[3-4]". This is
  ## currently not supported by the above manual parser. /HB 2021-03-05
  invalid <- grep("(\\[|\\]|,|;|[[:space:]])", hosts, value = TRUE)
  if (length(invalid) > 0) {
    warnf("Failed to parse the compressed Slurm nodelist %s. Detected invalid node names, which are dropped: %s", sQuote(nodelist), commaq(invalid))
    hosts <- setdiff(hosts, invalid)
  }

  hosts
}


## SLURM_TASKS_PER_NODE="2(x2),1(x3)"  # Source: 'man sbatch'
slurm_expand_nodecounts <- function(nodecounts) {
  counts <- strsplit(nodecounts, split = ",", fixed = TRUE)
  counts <- unlist(counts, use.names = TRUE)
  counts <- counts[nzchar(counts)]
  counts <- as.list(counts)
  counts <- lapply(counts, FUN = function(count) {
    ## Drop whitespace
    count <- gsub("[[:space:]]", "", count)
    pattern <- "^([[:digit:]]+)[(]x([[:digit:]]+)[)]$"
    if (grepl(pattern, count)) {
      times <- gsub(pattern, "\\2", count)
      times <- as.integer(times)
      if (is.na(times)) return(NA_integer_)
      
      count <- gsub(pattern, "\\1", count)
      count <- as.integer(count)
      if (is.na(count)) return(NA_integer_)

      count <- rep(count, times = times)
    } else {
      count <- as.integer(count)
    }
  })
  counts <- unlist(counts, use.names = TRUE)
  
  if (anyNA(counts)) {
    warnf("Failed to parse Slurm node counts specification: %s", nodecounts)
  }
  
  counts
}


availableWorkersSlurm <- function() {
  ## From 'man sbatch':
  ## SLURM_JOB_NODELIST (and SLURM_NODELIST for backwards compatibility)
  ## List of nodes allocated to the job.
  ## Example:
  ## SLURM_JOB_NODELIST=n1,n[3-8],n[23-25]
  nodelist <- getenv_chr("SLURM_JOB_NODELIST")
  if (is.na(nodelist)) data <- getenv_chr("SLURM_NODELIST")
  if (is.na(nodelist)) return(NA_character_)

  ## Parse and expand nodelist
  w <- slurm_expand_nodelist(nodelist)

  ## Failed to parse?
  if (length(w) == 0) return(NA_character_)

  ## SLURM_JOB_CPUS_PER_NODE=64,12,...
  nodecounts <- getenv_chr("SLURM_JOB_CPUS_PER_NODE")
  if (is.na(nodecounts)) nodecounts <- getenv_chr("SLURM_TASKS_PER_NODE")
  if (is.na(nodecounts)) {
    warning("Expected either environment variable 'SLURM_JOB_CPUS_PER_NODE' or 'SLURM_TASKS_PER_NODE' to be set. Will assume one core per node.")
  } else {
    ## Parse counts
    c <- slurm_expand_nodecounts(nodecounts)
    if (anyNA(c)) {
      warnf("Failed to parse 'SLURM_JOB_CPUS_PER_NODE' or 'SLURM_TASKS_PER_NODE': %s", sQuote(nodecounts))
      return(NA_character_)
    }

    if (length(c) != length(w)) {
      warnf("Skipping Slurm settings because the number of elements in 'SLURM_JOB_CPUS_PER_NODE'/'SLURM_TASKS_PER_NODE' (%s) does not match parsed 'SLURM_JOB_NODELIST'/'SLURM_NODELIST' (%s): %d != %d", nodelist, nodecounts, length(c), length(w))
      return(NA_character_)
    }

    ## Always respect 'SLURM_CPUS_PER_TASK' (always a scalar), if that exists
    n <- getenv_chr("SLURM_CPUS_PER_TASK")
    if (!is.na(n)) {
      c0 <- c
      c <- rep(n, times = length(w))
      ## Is our assumption that SLURM_CPUS_PER_TASK <= SLURM_JOB_NODELIST, correct?
      if (any(c < n)) {
        c <- pmin(c, n)
        warnf("Unexpected values of Slurm environment variable. 'SLURM_CPUS_PER_TASK' specifies CPU counts on one or more nodes that is strictly less than what 'SLURM_CPUS_PER_TASK' specifies. Will use the minimum of the two for each node: %s < %s", sQuote(nodecounts), n)
      }
    }

    ## Expand workers list
    w <- as.list(w)
    for (kk in seq_along(w)) {
      w[[kk]] <- rep(w[[kk]], times = c[kk])
    }
    w <- unlist(w, use.names = FALSE)
  }
  
  w
} ## availableWorkersSlurm()
