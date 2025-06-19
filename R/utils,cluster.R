## Checks if a given worker is the same as the localhost.  It is, iff:
##
## * worker == "localhost"
## * worker == "127.0.0.1"
## * worker == hostname
## * worker and hostname appears on the same line in /etc/hosts
##
## This should cover cases such as:
## * Calling is_localhost("n3") from machine n3
## * Calling is_localhost("n3.myserver.org") from machine n3[.myserver.org]
##
## References:
## * https://en.wikipedia.org/wiki/Hostname
#' @importFrom utils file_test
is_localhost <- local({
  localhosts <- c("localhost", "127.0.0.1")
  non_localhosts <- character(0L)
  
  function(worker, hostname = Sys.info()[["nodename"]], pathnames = "/etc/hosts") {
    ## INTERNAL: Clear list of known local hosts?
    if (is.null(worker) && is.null(hostname)) {
      localhosts <<- c("localhost", "127.0.0.1")
      non_localhosts <<- character(0L)
      return(NA)
    }
    
    stop_if_not(length(worker) == 1, length(hostname) == 1)
  
    ## Already known to a localhost or not to one?
    if (worker %in% localhosts) return(TRUE)
    if (worker %in% non_localhosts) return(FALSE)
    
    if (worker == hostname) {
      ## Add worker to the list of known local hosts.
      localhosts <<- unique(c(localhosts, worker))
      return(TRUE)
    }

    alias <- getOption2("parallelly.localhost.hostname")
    if (is.character(alias) && worker == alias) {
      ## Add worker to the list of known local hosts.
      localhosts <<- unique(c(localhosts, worker))
      return(TRUE)
    }

    ## Scan known "hosts" files
    pathnames <- pathnames[file_test("-f", pathnames)]
    if (length(pathnames) == 0L) return(FALSE)
  
    ## Search for (hostname, worker) and (worker, hostname)
    ## occuring on the same line and are separates by one or
    ## more whitespace symbols (but nothing else).
    pattern <- sprintf("^((|.*[[:space:]])%s[[:space:]]+%s([[:space:]]+|)|(|.*[[:space:]])%s[[:space:]]+%s([[:space:]]+|))$", hostname, worker, worker, hostname)
    
    for (pathname in pathnames) {
      bfr <- readLines(pathname, warn = FALSE)
      if (any(grepl(pattern, bfr, ignore.case = TRUE))) {
        ## Add worker to the list of known local hosts.
        localhosts <<- unique(c(localhosts, worker))
        return(TRUE)
      }
    }
    
    ## Add worker to the list of known non-local hosts.
    non_localhosts <<- unique(c(non_localhosts, worker))
    
    FALSE
  }
}) ## is_localhost()


## Checks if a worker is specified by its IP number.
is_ip_number <- function(worker) {
  if (!grepl("^([[:digit:]]+[.]){3}[[:digit:]]+$", worker)) return(FALSE)
  ip <- strsplit(worker, split = ".", fixed = TRUE)[[1]]
  ip <- as.integer(ip)
  all(0 <= ip & ip <= 255)
}

## Checks if a worker is specified as a fully qualified domain name (FQDN)
is_fqdn <- function(worker) {
  grepl(".", worker, fixed = TRUE)
}


#' Search for SSH clients on the current system
#'
#' @param which A character vector specifying which types of SSH clients
#' to search for.  If NULL, a default set of clients supported by the
#' current platform is searched for.
#'
#' @param first If TRUE, the first client found is returned, otherwise
#' all located clients are returned.
#'
#' @param must_work If TRUE and no clients was found, then an error
#' is produced, otherwise only a warning.
#'
#' @return A named list of pathnames to all located SSH clients.
#' The pathnames may be followed by zero or more command-line options,
#' i.e. the elements of the returned list are character vectors of length
#' one or more.
#' If `first = TRUE`, only the first one is returned.
#' Attribute `version` contains the output from querying the
#' executable for its version (via command-line option `-V`).
#'
#' @keywords internal
find_rshcmd <- function(which = NULL, first = FALSE, must_work = TRUE) {
  query_version <- function(bin, args = "-V") {
    v <- suppressWarnings(system2(bin, args = args, stdout = TRUE, stderr = TRUE))
    v <- paste(v, collapse = "; ")
    stop_if_not(length(v) == 1L)
    v
  }

  ## Soon, RStudio will no longer come with a built-in 'ssh' client
  ## for MS Windows. It's old and Windows (>= 10) comes with a
  ## built-in 'ssh' client.
  ## Source: https://github.com/futureverse/parallelly/issues/116
  find_rstudio_ssh <- function() {
    path <- Sys.getenv("RSTUDIO_MSYS_SSH", NA_character_)
    if (is.na(path)) return(NULL)
    if (!file_test("-d", path)) return(NULL)   
    path <- normalizePath(path)
    path_org <- Sys.getenv("PATH")
    on.exit(Sys.setenv(PATH = path_org))
    
    ## Set PATH to only look in RSTUDIO_MSYS_SSH to avoid
    ## picking up other clients with the same name
    ## Comment: In RStudio, RSTUDIO_MSYS_SSH is appended
    ## to the PATH, see PATH in 'Tools -> Shell ...'.
    Sys.setenv(PATH = path)
    bin <- Sys.which("ssh")
    if (!nzchar(bin)) return(NULL)
    attr(bin, "type") <- "rstudio-ssh"
    attr(bin, "version") <- query_version(bin, args = "-V")
    bin
  }

  find_putty_plink <- function() {
    bin <- Sys.which("plink")
    if (!nzchar(bin)) return(NULL)
    res <- c(bin, "-ssh")
    attr(res, "type") <- "putty-plink"
    attr(res, "version") <- query_version(bin, args = "-V")
    res
  }

  find_ssh <- function() {
    bin <- Sys.which("ssh")
    if (!nzchar(bin)) return(NULL)
    attr(bin, "type") <- "ssh"
    v <- query_version(bin, args = "-V")
    attr(bin, "version") <- v
    if (any(grepl("OpenSSH_for_Windows", v)))
      attr(bin, "OpenSSH_for_Windows") <- TRUE
    bin
  }

  if (!is.null(which)) stop_if_not(is.character(which), length(which) >= 1L, !anyNA(which))
  stop_if_not(is.logical(first), length(first) == 1L, !is.na(first))
  stop_if_not(is.logical(must_work), length(must_work) == 1L, !is.na(must_work))

  if (is.null(which)) {
    if (.Platform[["OS.type"]] == "windows") {
      which <- c("ssh", "putty-plink", "rstudio-ssh")
    } else {
      which <- c("ssh")
    }
  }
  
  res <- list()
  for (name in which) {
    pathname <- switch(name,
      "ssh"         = find_ssh(),
      "putty-plink" = find_putty_plink(),
      "rstudio-ssh" = find_rstudio_ssh(),
      stopf("Unknown 'rshcmd' type: %s", sQuote(name))
    )
    
    if (!is.null(pathname)) {
      if (first) return(pathname)
      res[[name]] <- pathname
    }
  }    

  if (length(res) > 0) return(res)
  
  msg <- sprintf("Failed to locate a default SSH client (checked: %s). Please specify one via argument 'rshcmd'.", paste(sQuote(which), collapse = ", ")) #nolint
  if (must_work) stop(msg)

  pathname <- "ssh"
  msg <- sprintf("%s Will still try with %s.", msg, sQuote(paste(pathname, collapse = " ")))
  warning(msg)
  pathname
}


#' @importFrom utils installed.packages
session_info <- function(pkgs = getOption2("parallelly.makeNodePSOCK.sessionInfo.pkgs", FALSE)) {
  libs <- .libPaths()
  info <- list(
    ## Process ID
    process = list(pid = Sys.getpid()),

    ## R version and operating system
    r = c(R.version, os.type = .Platform[["OS.type"]]),

    ## System information
    system = as.list(Sys.info()),

    ## Folders
    pwd = getwd(),
    tempdir = tempdir(),

    ## R package libraries
    libs = libs,
    
    ## Installed packages
    pkgs = if (isTRUE(pkgs)) {
      structure(lapply(libs, FUN = function(lib.loc) {
        pkgs <- installed.packages(lib.loc = lib.loc)
        if (length(pkgs) == 0) return(NULL)
        paste0(pkgs[, "Package"], "_", pkgs[, "Version"])
      }), names = libs)
    }
  )
  info
}


#' @importFrom utils capture.output
#' @importFrom parallel clusterCall
add_cluster_session_info <- local({
  get_session_info <- session_info
  formals(get_session_info)$pkgs <- FALSE
  environment(get_session_info) <- getNamespace("utils")
  
  function(cl) {
    is_node <- inherits(cl, c("SOCKnode", "SOCK0node"))
    if (is_node) cl <- as.cluster(cl)
    stop_if_not(inherits(cl, "cluster"))
    
    for (ii in seq_along(cl)) {
      node <- cl[[ii]]
      if (is.null(node)) next  ## Happens with dryrun = TRUE
  
      ## Session information already collected?
      if (!is.null(node$session_info)) next
  
      pkgs <- getOption2("parallelly.makeNodePSOCK.sessionInfo.pkgs", FALSE)
      node$session_info <- clusterCall(cl[ii], fun = get_session_info, pkgs = pkgs)[[1]]
      
      cl[[ii]] <- node
    }

    if (is_node) cl <- cl[[1]]

    cl
  }
}) ## add_cluster_session_info()


## Gets the Windows build version, e.g. '10.0.17134.523' (Windows 10 v1803)
## and '10.0.17763.253' (Windows 10 v1809).
windows_build_version <- local({
  if (.Platform[["OS.type"]] != "windows") return(function() NULL)
  function() {
    res <- shell("ver", intern = TRUE)
    if (length(res) == 0) return(NULL)
    res <- grep("Microsoft", res, value = TRUE)
    if (length(res) == 0) return(NULL)
    res <- gsub(".*Version ([0-9.]+).*", "\\1", res)
    tryCatch({
      numeric_version(res)
    }, error = function(ex) NULL)
  }
})


useWorkerPID <- local({
  parent_pid <- NULL
  .cache <- list()

  makeResult <- function(rank, rscript_sh) {
    if (is.null(parent_pid)) parent_pid <<- Sys.getpid()
    pidfile <- tempfile(pattern = sprintf("worker.rank=%d.parallelly.parent=%d.",
                   rank, parent_pid), fileext = ".pid")
    pidfile <- normalizePath(pidfile, winslash = "/", mustWork = FALSE)
    pidcode <- sprintf('try(suppressWarnings(cat(Sys.getpid(),file="%s")),silent=TRUE)', pidfile)
    rscript_pid_args <- c("-e", shQuote(pidcode, type = rscript_sh))
    list(pidfile = pidfile, rscript_pid_args = rscript_pid_args)
  }
  
  function(rscript, rank, rscript_sh, force = FALSE, verbose = FALSE) {
    autoKill <- getOption2("parallelly.makeNodePSOCK.autoKill", TRUE)
    if (!isTRUE(as.logical(autoKill))) return(list())

    result <- makeResult(rank, rscript_sh = rscript_sh)
    
    ## Already cached?
    key <- paste(rscript, collapse = "\t")
    if (!force && isTRUE(.cache[[key]])) return(result)

    test_cmd <- paste(c(
      rscript,
      result$rscript_pid_args,
      "-e", shQuote(sprintf('file.exists("%s")', result$pidfile), type = rscript_sh)
    ), collapse = " ")
    if (verbose) {
      mdebugf("Testing if worker's PID can be inferred: %s", sQuote(test_cmd))
    }
    
    input <- NULL
    
    ## AD HOC: 'singularity exec ... Rscript' requires input="".  If not,
    ## they will be terminated because they try to read from non-existing
    ## standard input. /HB 2019-02-14
    ##
    ## I cannot reproduce this with Singularity 3.7.1 or Apptainer 1.1.3-1.
    ## Note sure when it was fixed and for what version the issue was
    ## confirmed; Singularity 3.0.3 was released on 2019-01-21, and
    ## Singularity 3.0.2 on 2019-01-04, and Singularity 2.6.1 on 2018-12-08,
    ## so probably somewhere around those versions.
    ##
    ## It's not related to the "closed stdin" bug in R (<= 4.2.1), cf.
    ## https://github.com/HenrikBengtsson/Wishlist-for-R/issues/140.
    ## The problem does not appear with Singularity 3.7.1, host R 4.2.1,
    ## and R 3.6.1 in the container.
    ##
    ## Thus, I'll assume this is not a problem for Apptainer, so I will
    ## not check for 'apptainer' here. /HB 2022-12-03
    if (any(grepl("singularity", rscript, ignore.case = TRUE))) input <- ""
    
    assert_system_is_supported()
    res <- system(test_cmd, intern = TRUE, input = input)
    status <- attr(res, "status")
    suppressWarnings(file.remove(result$pidfile))
    
    .cache[[key]] <<- (is.null(status) || status == 0L) && any(grepl("TRUE", res))
    if (verbose) mdebugf("- Possible to infer worker's PID: %s", .cache[[key]])
    
    result
  }  
})


readWorkerPID <- function(pidfile, wait = 0.5, maxTries = 8L, verbose = FALSE) {
  if (is.null(pidfile)) return(NULL)
  
  if (verbose) mdebug("Attempting to infer PID for worker process ...")
  pid <- NULL
  
  ## Wait for PID file
  tries <- 0L
  while (!file.exists(pidfile) && tries <= maxTries) {
    Sys.sleep(wait)
    tries <- tries + 1L
  }
  
  if (file.exists(pidfile)) {
    pid0 <- NULL
    for (tries in 1:maxTries) {
      pid0 <- tryCatch(readLines(pidfile, warn = FALSE), error = identity)
      if (!inherits(pid0, "error")) break
      pid0 <- NULL
      Sys.sleep(wait)
    }
    file.remove(pidfile)
    
    if (length(pid0) > 0L) {
      ## Use last one, if more than one ("should not happend")
      pid <- as.integer(pid0[length(pid0)])
      if (verbose) mdebugf(" - pid: %s", pid)
      if (is.na(pid)) {
        warnf("Worker PID is a non-integer: %s", pid0)
        pid <- NULL
      } else if (pid == Sys.getpid()) {
        warnf("Hmm... worker PID and parent PID are the same: %s", pid)
        pid <- NULL
      }
    }
  }
 
  if (verbose) mdebug("Attempting to infer PID for worker process ... done")
  
  pid
} ## readWorkerPID()


# shQuote() that also accepts type = "none"
shQuote <- local({
  known_types <- eval(formals(base::shQuote)[["type"]])
  known_types <- c(known_types, "none")
  
  function(string, type = NULL) {
    if (is.null(type) || missing(type)) {
      if (.Platform[["OS.type"]] == "windows") {
        type <- "cmd"
      } else {
        type <- known_types[1]
      }
    }
    type <- match.arg(type, choices = known_types, several.ok = FALSE)
    if (type == "none") return(string)
    base::shQuote(string, type = type)
  }
})

