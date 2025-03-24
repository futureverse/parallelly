#' @param worker The hostname or IP number of the machine where the worker
#' should run.
#' Attribute `localhost` can be set to TRUE or FALSE to manually indicate
#' whether `worker` is the same as the local host.
#' 
#' @param master The hostname or IP number of the master / calling machine, as
#' known to the workers.  If NULL (default), then the default is
#' `Sys.info()[["nodename"]]` unless `worker` is _localhost_ or
#' `revtunnel = TRUE` in case it is `"localhost"`.
#' 
#' @param connectTimeout The maximum time (in seconds) allowed for each socket
#' connection between the master and a worker to be established (defaults to
#' 2 minutes). _See note below on current lack of support on Linux and
#' macOS systems._
#' 
#' @param timeout The maximum time (in seconds) allowed to pass without the
#' master and a worker communicate with each other (defaults to 30 days).
#' 
#' @param rscript,homogeneous The system command for launching \command{Rscript}
#' on the worker and whether it is installed in the same path as the calling
#' machine or not.  For more details, see below.
#' 
#' @param rscript_args Additional arguments to \command{Rscript} (as a character
#' vector).  This argument can be used to customize the \R environment of the
#' workers before they launches.
#' For instance, use `rscript_args = c("-e", shQuote('setwd("/path/to")'))`
#' to set the working directory to \file{/path/to} on _all_ workers.
#'
#' @param rscript_envs A named character vector environment variables to
#' set or unset on worker at startup, e.g.
#' `rscript_envs = c(FOO = "3.14", "HOME", "UNKNOWN", UNSETME = NA_character_)`.
#' If an element is not named, then the value of that variable will be used as
#' the name and the value will be the value of `Sys.getenv()` for that
#' variable.  Non-existing environment variables will be dropped.
#' These variables are set using `Sys.setenv()`.
#' An named element with value `NA_character_` will cause that variable to be
#' unset, which is done via `Sys.unsetenv()`.
#' 
#' @param rscript_libs A character vector of \R library paths that will be
#' used for the library search path of the \R workers.  An asterisk
#' (`"*"`) will be resolved to the default `.libPaths()` _on the
#' worker_. That is, to `prepend` a folder, instead of replacing the
#' existing ones, use `rscript_libs = c("new_folder", "*")`.
#' To pass down a non-default library path currently set _on the main \R
#' session_ to the workers, use `rscript_libs = .libPaths()`.
#' 
#' @param rscript_startup An \R expression or a character vector of \R code,
#' or a list with a mix of these, that will be evaluated on the \R worker
#' prior to launching the worker's event loop.
#' For instance, use `rscript_startup = 'setwd("/path/to")'`
#' to set the working directory to \file{/path/to} on _all_ workers.
#' 
#' @param rscript_sh The type of shell used where `rscript` is launched,
#' which should be `"sh"` is launched via a POSIX shell and `"cmd"` if 
#' launched via an MS Windows shell.  This controls how shell command-line
#' options are quoted, but also how R string expression are quoted when
#' passed to `Rscript`.
#' If `"none"`, then no quoting is done.
#' If `"auto"` (default), and the cluster node is launched locally, then it
#' is set to `"sh"` or `"cmd"` according to the current platform.
#' _If launched remotely_, then it is set to `"sh"` based on the assumption
#' remote machines typically launch commands via SSH in a POSIX shell.
#' If the remote machines run MS Windows, use `rscript_sh = "cmd"`.
#' If `length(rscript_sh)` is two, then `rscript_sh[1]` is for the inner and
#' `rscript_sh[2]` is for the outer shell quoting of the Rscript call.
#' More precisely, `rscript_sh[1]` is for Rscript arguments that need shell
#' quoting (e.g. `Rscript -e "<expr>"`), and `rscript_sh[2]` is for the whole
#' `Rscript ...` call.
#' If `length(rscript_sh)` is one, then it is used for both the inner and the
#' outer shell quoting.
#'
#' @param default_packages A character vector or NULL that controls which R
#' packages are attached on each cluster node during startup.  An asterisk
#' (`"*"`) resolves to `getOption("defaultPackages")` _on the current machine_.
#' If NULL, then the default set of packages R are attached.
#'
#' @param methods If TRUE (default), then the \pkg{methods} package is also 
#' loaded. This is argument exists for legacy reasons due to how 
#' \command{Rscript} worked in R (< 3.5.0).
#' 
#' @param useXDR If FALSE (default), the communication between master and workers, which is binary, will use small-endian (faster), otherwise big-endian ("XDR"; slower).
#' 
#' @param socketOptions A character string that sets \R option 
#' \code{socketOptions} on the worker.
#' 
#' @param outfile Where to direct the \link[base:showConnections]{stdout} and
#' \link[base:showConnections]{stderr} connection output from the workers.
#' If NULL, then no redirection of output is done, which means that the
#' output is relayed in the terminal on the local computer.  On Windows, the
#' output is only relayed when running \R from a terminal but not from a GUI.
#' 
#' @param renice A numerical 'niceness' (priority) to set for the worker
#' processes.
#' 
#' @param rank A unique one-based index for each worker (automatically set).
#' 
#' @param rshcmd,rshopts The command (character vector) to be run on the master
#' to launch a process on another host and any additional arguments (character
#' vector).  These arguments are only applied if `machine` is not
#' _localhost_.  For more details, see below.
#' 
#' @param rshlogfile (optional) If a filename, the output produced by the
#' `rshcmd` call is logged to this file, of if TRUE, then it is logged
#' to a temporary file.  The log file name is available as an attribute
#' as part of the return node object.
#' _Warning: This only works with SSH clients that support command-line
#' option \option{-E out.log`}_.  For example, PuTTY's \command{plink} does
#' _not_ support this option, and any attempts to specify `rshlogfile` will
#' cause the SSH connection to fail.
#'
#' @param user (optional) The user name to be used when communicating with
#' another host.
#' 
#' @param revtunnel If TRUE, a reverse SSH tunnel is set up for each worker such
#' that the worker \R process sets up a socket connection to its local port
#' `(port + rank - 1)` which then reaches the master on port `port`.
#' If FALSE, then the worker will try to connect directly to port `port` on
#' `master`.
#' If NA, then TRUE or FALSE is inferred from inspection of `rshcmd[1]`.
#' For more details, see below.
#' 
#' @param manual If TRUE the workers will need to be run manually. The command
#' to run will be displayed.
#' 
#' @param dryrun If TRUE, nothing is set up, but a message suggesting how to
#' launch the worker from the terminal is outputted.  This is useful for
#' troubleshooting.
#'
#' @param quiet If TRUE, then no output will be produced other than that from
#' using `verbose = TRUE`.
#'
#' @param setup_strategy If `"parallel"` (default), the workers are set up
#' concurrently, one after the other.  If `"sequential"`, they are set up
#' sequentially.
#'
#' @param action This is an internal argument.
#'
#' @return `makeNodePSOCK()` returns a `"SOCKnode"` or
#' `"SOCK0node"` object representing an established connection to a worker.
#'
#' @section Definition of _localhost_:
#' A hostname is considered to be _localhost_ if it equals:
#' \itemize{
#'   \item `"localhost"`,
#'   \item `"127.0.0.1"`, or
#'   \item `Sys.info()[["nodename"]]`.
#' }
#' It is also considered _localhost_ if it appears on the same line
#' as the value of `Sys.info()[["nodename"]]` in file \file{/etc/hosts}.
#' 
#' @section Default SSH client and options (arguments `rshcmd` and `rshopts`):
#' Arguments `rshcmd` and `rshopts` are only used when connecting
#' to an external host.
#' 
#' The default method for connecting to an external host is via SSH and the
#' system executable for this is given by argument `rshcmd`.  The default
#' is given by option
#' \code{\link[=parallelly.options]{parallelly.makeNodePSOCK.rshcmd}}.
#' If that is not
#' set, then the default is to use \command{ssh} on Unix-like systems,
#' including macOS as well as Windows 10.  On older MS Windows versions, which
#' does not have a built-in \command{ssh} client, the default is to use
#' (i) \command{plink} from the \href{https://www.putty.org/}{\command{PuTTY}}
#' project, and then (ii) the \command{ssh} client that is distributed with
#' RStudio.
#'
#' PuTTY puts itself on Windows' system \env{PATH} when installed, meaning this
#' function will find PuTTY automatically if installed.  If not, to manually
#' set specify PuTTY as the SSH client, specify the absolute pathname of
#' \file{plink.exe} in the first element and option \command{-ssh} in the
#' second as in `rshcmd = c("C:/Path/PuTTY/plink.exe", "-ssh")`.
#' This is because all elements of `rshcmd` are individually "shell"
#' quoted and element `rshcmd[1]` must be on the system \env{PATH}.
#'
#' Furthermore, when running \R from RStudio on Windows, the \command{ssh}
#' client that is distributed with RStudio will also be considered.
#' This client, which is from \href{https://en.wikipedia.org/wiki/MinGW}{MinGW}
#' MSYS, is searched for in the folder given by the \env{RSTUDIO_MSYS_SSH}
#' environment variable---a variable that is (only) set when running RStudio.
#' To use this SSH client outside of RStudio, set \env{RSTUDIO_MSYS_SSH}
#' accordingly.
#'
#' You can override the default set of SSH clients that are searched for
#' by specifying them in argument `rshcmd` or via option
#' \code{\link[=parallelly.options]{parallelly.makeNodePSOCK.rshcmd}}
#' using the format `<...>`, e.g.
#' `rshcmd = c("<rstudio-ssh>", "<putty-plink>", "<ssh>")`.  See
#' below for examples.
#'
#' If no SSH-client is found, an informative error message is produced.
#'
#' Additional SSH command-line options may be specified via argument `rshopts`,
#' which defaults to option \code{parallelly.makeNodePSOCK.rshopts}. For
#' instance, a private SSH key can be provided as
#' `rshopts = c("-i", "~/.ssh/my_private_key")`.  PuTTY users should
#' specify a PuTTY PPK file, e.g.
#' `rshopts = c("-i", "C:/Users/joe/.ssh/my_keys.ppk")`.
#' Contrary to `rshcmd`, elements of `rshopts` are not quoted.
#' 
#' @section Accessing external machines that prompts for a password:
#' _IMPORTANT: With one exception, it is not possible to for these
#' functions to log in and launch \R workers on external machines that requires
#' a password to be entered manually for authentication._
#' The only known exception is the PuTTY client on Windows for which one can
#' pass the password via command-line option \option{-pw}, e.g. 
#' `rshopts = c("-pw", "MySecretPassword")`.
#'
#' Note, depending on whether you run \R in a terminal or via a GUI, you might
#' not even see the password prompt.  It is also likely that you cannot enter
#' a password, because the connection is set up via a background system call.
#'
#' The poor man's workaround for setup that requires a password is to manually
#' log into the each of the external machines and launch the \R workers by hand.
#' For this approach, use `manual = TRUE` and follow the instructions
#' which include cut'n'pasteable commands on how to launch the worker from the
#' external machine.
#'
#' However, a much more convenient and less tedious method is to set up
#' key-based SSH authentication between your local machine and the external
#' machine(s), as explain below.
#'
#' @section Accessing external machines via key-based SSH authentication:
#' The best approach to automatically launch \R workers on external machines
#' over SSH is to set up key-based SSH authentication.  This will allow you
#' to log into the external machine without have to enter a password.
#'
#' Key-based SSH authentication is taken care of by the SSH client and not \R.
#' To configure this, see the manuals of your SSH client or search the web
#' for "ssh key authentication".
#'
#' @section Reverse SSH tunneling:
#' If SSH is used, which is inferred from `rshcmd[1]`, then the default is
#' to use reverse SSH tunneling (`revtunnel = TRUE`), otherwise not
#' (`revtunnel = FALSE`). Using reverse SSH tunneling, avoids complications
#' from otherwise having to configure port forwarding in firewalls, which
#' often requires static IP address as well as privileges to edit the
#' firewall on your outgoing router, something most users don't have.
#' It also has the advantage of not having to know the internal and / or the
#' public IP address / hostname of the master.
#' Yet another advantage is that there will be no need for a DNS lookup by the
#' worker machines to the master, which may not be configured or is disabled
#' on some systems, e.g. compute clusters.
#'
#' @section Argument `rscript`:
#' If `homogeneous` is FALSE, the `rscript` defaults to `"Rscript"`, i.e. it
#' is assumed that the \command{Rscript} executable is available on the
#' \env{PATH} of the worker.
#' If `homogeneous` is TRUE, the `rscript` defaults to
#' `file.path(R.home("bin"), "Rscript")`, i.e. it is basically assumed that
#' the worker and the caller share the same file system and \R installation.
#'
#' When specified, argument `rscript` should be a character vector with one or
#' more elements.  Any asterisk (`"*"`) will be resolved to the above default
#' `homogeneous`-dependent `Rscript` path.
#' All elements are automatically shell quoted using [base::shQuote()], except
#' those that are of format `<ENVVAR>=<VALUE>`, that is, the ones matching the
#' regular expression '\samp{^[[:alpha:]_][[:alnum:]_]*=.*}'.
#' Another exception is when `rscript` inherits from 'AsIs'.
#' 
#' @section Default value of argument `homogeneous`:
#' The default value of `homogeneous` is TRUE if and only if either
#' of the following is fulfilled:
#' \itemize{
#'  \item `worker` is _localhost_
#'  \item `revtunnel` is FALSE and `master` is _localhost_
#'  \item `worker` is neither an IP number nor a fully qualified domain
#'        name (FQDN).  A hostname is considered to be a FQDN if it contains
#'        one or more periods
#' }
#' In all other cases, `homogeneous` defaults to FALSE.
#' 
#' @section Connection timeout:
#' Argument `connectTimeout` does _not_ work properly on Unix and
#' macOS due to limitation in \R itself.  For more details on this, please see
#' R-devel thread 'BUG?: On Linux setTimeLimit() fails to propagate timeout
#' error when it occurs (works on Windows)' on 2016-10-26
#' (\url{https://stat.ethz.ch/pipermail/r-devel/2016-October/073309.html}).
#' When used, the timeout will eventually trigger an error, but it won't happen
#' until the socket connection timeout `timeout` itself happens.
#'
#' @section Communication timeout:
#' If there is no communication between the master and a worker within the
#' `timeout` limit, then the corresponding socket connection will be
#' closed automatically.  This will eventually result in an error in code
#' trying to access the connection.
#' This timeout is also what terminates a stray-running parallel cluster-node
#' process.
#'
#' @section Failing to set up local workers:
#' When setting up a cluster of localhost workers, that is, workers running
#' on the same machine as the master \R process, occasionally a connection
#' to a worker ("cluster node") may fail to be set up.
#' When this occurs, an informative error message with troubleshooting
#' suggestions will be produced.
#' The most common reason for such localhost failures is due to port
#' clashes.  Retrying will often resolve the problem.
#'
#' If R stalls when setting up a cluster of local workers, then it might
#' be that you have a virtual private network (VPN) enabled that is
#' configured to prevent you from connecting to `localhost`.  To verify that
#' this is the case, call the following from the terminal:
#'
#' ```sh
#' {local}$ ssh localhost "date"
#' ```
#'
#' This also freezed if the VPN intercepts connections to `localhost`.
#' If this happens, try also:
#'
#' ```sh
#' {local}$ ssh 127.0.0.1 "date"
#' ```
#'
#' In rare cases, `127.0.0.1` might work when `localhost` does not.
#' If the latter works, setting R option:
#'
#' ```r
#' options(parallelly.localhost.hostname = "127.0.0.1")
#' ```
#'
#' should solve it (the default is `"localhost"`).  You can set this
#' automatically when R starts by adding it to your `~/.Rprofile` startup
#' file. Alternatively, set environment variable
#' `R_PARALLELLY_LOCALHOST_HOSTNAME=127.0.0.1` in your `~/.Renviron` file.
#'
#' If using `127.0.0.1` did not work around the problem, check your VPN
#' settings and make sure it allows connections to `localhost` or `127.0.0.1`.
#'
#'
#' @section Failing to set up remote workers:
#' A cluster of remote workers runs \R processes on external machines. These
#' external \R processes are launched over, typically, SSH to the remote
#' machine.  For this to work, each of the remote machines needs to have
#' \R installed, which preferably is of the same version as what is on the
#' main machine.  For this to work, it is required that one can SSH to the
#' remote machines.  Ideally, the SSH connections use authentication based
#' on public-private SSH keys such that the set up of the remote workers can
#' be fully automated (see above).  If `makeClusterPSOCK()` fails to set
#' up one or more remote \R workers, then an informative error message is
#' produced.
#' There are a few reasons for failing to set up remote workers.  If this
#' happens, start by asserting that you can SSH to the remote machine and
#' launch \file{Rscript} by calling something like:
#' \preformatted{
#' {local}$ ssh -l alice remote.server.org
#' {remote}$ Rscript --version
#' R scripting front-end version 4.2.2 (2022-10-31)
#' {remote}$ logout
#' {local}$
#' }
#' When you have confirmed the above to work, then confirm that you can achieve
#' the same in a single command-line call;
#' \preformatted{
#' {local}$ ssh -l alice remote.server.org Rscript --version
#' R scripting front-end version 4.2.2 (2022-10-31)
#' {local}$
#' }
#' The latter will assert that you have proper startup configuration also for
#' _non-interactive_ shell sessions on the remote machine.
#'
#' If the remote machines are running on MS Windows, make sure to add argument
#' `rscript_sh = "cmd"` when calling `makeClusterPSOCK()`, because the default
#' is `rscript_sh = "sh"`, which assumes that that the remote machines are
#' Unix-like machines.
#' 
#' Another reason for failing to setup remote workers could be that they are
#' running an \R version that is not compatible with the version that your main
#' \R session is running.  For instance, if we run R (>= 3.6.0) locally and the
#' workers run R (< 3.5.0), we will get:
#' `Error in unserialize(node$con) : error reading from connection`.
#' This is because R (>= 3.6.0) uses serialization format version 3 by default
#' whereas R (< 3.5.0) only supports version 2.  We can see the version of the
#' \R workers by adding `rscript_args = c("-e", shQuote("getRversion()"))` when
#' calling `makeClusterPSOCK()`.
#'
#' @rdname makeClusterPSOCK
#' @importFrom tools pskill
#' @importFrom utils flush.console
#' @export
makeNodePSOCK <- function(worker = getOption2("parallelly.localhost.hostname", "localhost"), master = NULL, port, connectTimeout = getOption2("parallelly.makeNodePSOCK.connectTimeout", 2 * 60), timeout = getOption2("parallelly.makeNodePSOCK.timeout", 30 * 24 * 60 * 60), rscript = NULL, homogeneous = NULL, rscript_args = NULL, rscript_envs = NULL, rscript_libs = NULL, rscript_startup = NULL, rscript_sh = c("auto", "cmd", "sh", "none"), default_packages = c("datasets", "utils", "grDevices", "graphics", "stats", if (methods) "methods"), methods = TRUE, socketOptions = getOption2("parallelly.makeNodePSOCK.socketOptions", "no-delay"), useXDR = getOption2("parallelly.makeNodePSOCK.useXDR", FALSE), outfile = "/dev/null", renice = NA_integer_, rshcmd = getOption2("parallelly.makeNodePSOCK.rshcmd", NULL), user = NULL, revtunnel = NA, rshlogfile = NULL, rshopts = getOption2("parallelly.makeNodePSOCK.rshopts", NULL), rank = 1L, manual = FALSE, dryrun = FALSE, quiet = FALSE, setup_strategy = getOption2("parallelly.makeNodePSOCK.setup_strategy", "parallel"), action = c("launch", "options"), verbose = FALSE) {
  verbose <- as.logical(verbose)
  stop_if_not(length(verbose) == 1L, !is.na(verbose))
  verbose_prefix <- "[local output] "

  if (inherits(worker, "makeNodePSOCKOptions")) {
    return(launchNodePSOCK(options = worker, verbose = verbose))
  }

  if (missing(rscript_sh)) rscript_sh <- rscript_sh[1]
  rscript_sh <- match.arg(rscript_sh, several.ok = TRUE)
  
  ## Record all the original arguments
  args_org <- list(
    worker = worker,
    master = master,
    port = port,
    connectTimeout = connectTimeout,
    timeout = timeout,
    rscript = rscript,
    homogeneous = homogeneous,
    rscript_args = rscript_args,
    rscript_envs = rscript_envs,
    rscript_libs = rscript_libs,
    rscript_startup = rscript_startup,
    rscript_sh = rscript_sh,
    default_packages = default_packages,
    methods = methods,
    socketOptions = socketOptions,
    useXDR = useXDR,
    outfile = outfile,
    renice = renice,
    rshcmd = rshcmd,
    user = user,
    revtunnel = revtunnel,
    rshlogfile = rshlogfile,
    rshopts = rshopts,
    rank = rank,
    manual = manual,
    dryrun = dryrun,
    quiet = quiet,
    setup_strategy = setup_strategy
  )

  localhostHostname <- getOption2("parallelly.localhost.hostname", "localhost")
  
  localMachine <- attr(worker, "localhost")
  if (is.logical(localMachine)) {
    stop_if_not(length(localMachine) == 1L, !is.na(localMachine))
  } else {
    localMachine <- is.element(worker, c(localhostHostname, "localhost", "127.0.0.1"))
    ## Could it be that the worker specifies the name of the localhost?
    ## Note, this approach preserves worker == "127.0.0.1" if that is given.
    if (!localMachine) {
      localMachine <- is_localhost(worker)
      if (localMachine) worker <- getOption2("parallelly.localhost.hostname", "localhost")
    }
    attr(worker, "localhost") <- localMachine
  }

  stop_if_not(is.character(rscript_sh), length(rscript_sh) >= 1L,
              length(rscript_sh) <= 2L, !anyNA(rscript_sh))
  is_auto <- (rscript_sh == "auto")
  if (any(is_auto)) {
    if (localMachine) {
      rscript_sh[is_auto] <- if (.Platform[["OS.type"]] == "windows") "cmd" else "sh"
    } else {
      ## Assume remote machine uses as POSIX shell
     rscript_sh[is_auto] <- "sh"
    }
  }

  ## rscript_sh[1] is for inner and rscript_sh[2] is for the outer shell
  ## quoting of the Rscript call.  Precisely, rscript_sh[1] is for Rscript
  ## arguments that need shell quoting (e.g. Rscript -e "<expr>"), and
  ## rscript_sh[2] is for the the whole 'Rscript ...' call
  rscript_sh <- rep(rscript_sh, length.out = 2L)
  
  manual <- as.logical(manual)
  stop_if_not(length(manual) == 1L, !is.na(manual))

  dryrun <- as.logical(dryrun)
  stop_if_not(length(dryrun) == 1L, !is.na(dryrun))

  setup_strategy <- match.arg(setup_strategy, choices = c("sequential", "parallel"))

  quiet <- as.logical(quiet)
  stop_if_not(length(quiet) == 1L, !is.na(quiet))
  
  ## Locate a default SSH client?
  if (identical(rshcmd, "")) rshcmd <- NULL
  
  if (!is.null(rshcmd)) {
    if (is.function(rshcmd)) {
       args <- formals(rshcmd)
       names <- names(args)
       stop_if_not(length(args) >= 2)
       if (!"rshopts" %in% names) {
         stop("Argument 'rshcmd' specifies a function that does not have an `rshopts` argument: ", paste(sQuote(names), collapse = ", "))
       } else if (!"worker" %in% names) {
         stop("Argument 'rshcmd' specifies a function that does not have an `worker` argument: ", paste(sQuote(names), collapse = ", "))
       }
       type <- attr(rshcmd, "type")
       if (is.null(type)) {
         attr(rshcmd, "type") <- "function"
       }
    } else {
       rshcmd <- as.character(rshcmd)
       stop_if_not(length(rshcmd) >= 1L)
    }
  }

  if (identical(rshopts, "")) rshopts <- NULL
  rshopts <- as.character(rshopts)
  
  user <- as.character(user)
  stop_if_not(length(user) <= 1L)
  
  port <- as.integer(port)
  assertPort(port)

  ## Find default SSH client?
  if (!is.function(rshcmd) && !localMachine && (is.null(rshcmd) || all(grepl("^<[a-zA-Z-]+>$", rshcmd)))) {
    if (is.null(rshcmd)) {
      which <- NULL
      if (verbose) {
        mdebugf("%sWill search for all 'rshcmd' available\n",
                verbose_prefix)
      }
    } else if (all(grepl("^<[a-zA-Z-]+>$", rshcmd))) {
      if (verbose) {
        mdebugf("%sWill search for specified 'rshcmd' types: %s\n",
                verbose_prefix, paste(sQuote(rshcmd), collapse = ", "))
      }
      which <- gsub("^<([a-zA-Z-]+)>$", "\\1", rshcmd)
    }

    rshcmd <- find_rshcmd(which = which,
                          must_work = !localMachine && !manual && !dryrun)
    if (verbose) {
      s <- unlist(lapply(rshcmd, FUN = function(r) {
        sprintf("%s [type=%s, version=%s]", paste(sQuote(r), collapse = ", "), sQuote(attr(r, "type")), sQuote(attr(r, "version")))
      }))
      s <- paste(sprintf("%s %d. %s", verbose_prefix, seq_along(s), s), collapse = "\n")
      mdebugf("%sFound the following available 'rshcmd':\n%s", verbose_prefix, s)
    }
    rshcmd <- rshcmd[[1]]
    
    ## Holds a pathname with an optional set of command-line options
    stop_if_not(is.character(rshcmd), length(rshcmd) >= 1L)
  } else if (!is.function(rshcmd) && !is.null(rshcmd)) {
    ## Try to guess "type" of 'rshcmd' from it's basename
    basename <- tolower(basename(rshcmd[1]))
    if (basename %in% c("ssh", "plink")) {
      type <- "ssh"
    } else if (basename %in% c("rsh")) {
      type <- "rsh"
    } else {
      type <- "<unknown>"
    }
    if (is.null(attr(rshcmd, "type"))) attr(rshcmd, "type") <- type
    if (is.null(attr(rshcmd, "version"))) attr(rshcmd, "version") <- "<unknown>"
  }

  revtunnel <- as.logical(revtunnel)
  stop_if_not(length(revtunnel) == 1L)
  
  ## Should reverse tunneling be used or not?
  if (is.na(revtunnel)) {
    if (localMachine) {
      mdebugf("%slocalMachine=TRUE => revtunnel=FALSE\n", verbose_prefix)
      revtunnel <- FALSE
    } else if (identical(attr(rshcmd, "type"), "ssh")) {
      mdebugf("%slocalMachine=FALSE && 'rshcmd' type is \"%s\" => revtunnel=TRUE\n", verbose_prefix, attr(rshcmd, "type"))
      revtunnel <- TRUE
    } else {
      mdebugf("%slocalMachine=FALSE && 'rshcmd' type is \"%s\" => revtunnel=FALSE\n", verbose_prefix, attr(rshcmd, "type"))
      revtunnel <- FALSE
    }
  }

  if (!is.null(rshlogfile)) {
    if (is.logical(rshlogfile)) {
      stop_if_not(!is.na(rshlogfile))
      if (rshlogfile) {
        rshlogfile <- tempfile(pattern = "parallelly_makeClusterPSOCK_", fileext = ".log")
      } else {
        rshlogfile <- NULL
      }
    } else {
      rshlogfile <- as.character(rshlogfile)
      rshlogfile <- normalizePath(rshlogfile, mustWork = FALSE)
    }
  }

  if (is.null(master)) {
    if (localMachine || revtunnel) {
      master <- localhostHostname
    } else {
      master <- Sys.info()[["nodename"]]
    }
  }
  stop_if_not(!is.null(master))

  timeout <- as.numeric(timeout)
  stop_if_not(length(timeout) == 1L, !is.na(timeout), is.finite(timeout), timeout >= 0)

  ## FIXME: This is really legacy code there. It stems from R (< 3.5.0), where
  ## 'Rscript' did *not* attach the 'methods' package by default, whereas 'R'
  ## did.  Since R 3.5.0, 'R' and 'Rscript' attach the same set of packages.
  methods <- as.logical(methods)
  stop_if_not(length(methods) == 1L, !is.na(methods))

  if (!is.null(default_packages)) {
    default_packages <- as.character(default_packages)
    stop_if_not(!anyNA(default_packages))
    is_asterisk <- (default_packages == "*")
    if (any(is_asterisk)) {
      pkgs <- getOption("defaultPackages")
      if (length(pkgs) == 0) {
        default_packages[!is_asterisk]
      } else {
        pkgs <- paste(pkgs, collapse=",")
        default_packages[is_asterisk] <- pkgs
        default_packages <- unlist(strsplit(default_packages, split = ",", fixed = TRUE))
      }
    }
    default_packages <- unique(default_packages)
    pattern <- sprintf("^%s$", .standard_regexps()$valid_package_name)
    invalid <- grep(pattern, default_packages, invert = TRUE, value = TRUE)
    if (length(invalid) > 0) {
      stop(sprintf("Argument %s specifies invalid package names: %s", sQuote("default_packages"), paste(sQuote(invalid), collapse = ", ")))
    }
  }
 
  if (is.null(homogeneous)) {
    homogeneous <- {
      localMachine ||
      (!revtunnel && is_localhost(master)) ||
      (!is_ip_number(worker) && !is_fqdn(worker))
    }
  }
  homogeneous <- as.logical(homogeneous)
  stop_if_not(length(homogeneous) == 1L, !is.na(homogeneous))

  ## Is a parallel setup strategy possible?
  if (setup_strategy == "parallel") {
    if (getRversion() < "4.0.0" ||
        manual || dryrun || !homogeneous || !localMachine) {
      setup_strategy <- "sequential"
    }
  }

  bin <- "Rscript"
  if (homogeneous) bin <- file.path(R.home("bin"), bin)
  if (is.null(rscript)) {
    rscript <- bin
  } else {
    if (!is.character(rscript)) rscript <- as.character(rscript)
    stop_if_not(length(rscript) >= 1L)
    rscript[rscript == "*"] <- bin
    bin <- rscript[1]
    if (homogeneous && !inherits(bin, "AsIs")) {
      bin <- Sys.which(bin)
      if (bin == "") bin <- normalizePath(rscript[1], mustWork = FALSE)
      rscript[1] <- bin
    }
  }

  ## Is rscript[1] referring to Rscript, or R/Rterm?
  name <- sub("[.]exe$", "", basename(bin))
  is_Rscript <- (tolower(name) == "rscript")
  name <- bin <- NULL  ## not needed anymore
  
  rscript_args <- as.character(rscript_args)

  if (length(rscript_startup) > 0L) {
    if (!is.list(rscript_startup)) rscript_startup <- list(rscript_startup)
    rscript_startup <- lapply(rscript_startup, FUN = function(init) {
      if (is.language(init)) {
        init <- deparse(init, width.cutoff = 500L)
        ## We cannot use newline between statements because
        ## it needs to be passed as a one line string via -e <code>
        init <- paste(init, collapse = ";")
      }
      init <- as.character(init)
      if (length(init) == 0L) return(NULL)
      tryCatch({
        parse(text = init)
      }, error = function(ex) {
        stopf("Syntax error in argument 'rscript_startup': %s", conditionMessage(ex))
      })
      init
    })
    rscript_startup <- unlist(rscript_startup, use.names = FALSE)
  }

  if (!is.null(rscript_libs)) {
    rscript_libs <- as.character(rscript_libs)
    stop_if_not(!anyNA(rscript_libs))
  }

  useXDR <- as.logical(useXDR)
  stop_if_not(length(useXDR) == 1L, !is.na(useXDR))

  if (!is.null(socketOptions)) {
    stop_if_not(is.character(socketOptions),length(socketOptions) == 1L,
                !is.na(socketOptions), nzchar(socketOptions))
    if (socketOptions == "NULL") socketOptions <- NULL
  }

  stop_if_not(is.null(outfile) || is.character(outfile))

  renice <- as.integer(renice)
  stop_if_not(length(renice) == 1L)

  rank <- as.integer(rank)
  stop_if_not(length(rank) == 1L, !is.na(rank))

  action <- match.arg(action, choices = c("launch", "options"))

  ## Shell quote the Rscript executable?
  if (!inherits(rscript, "AsIs")) {
    idxs <- grep("^[[:alpha:]_][[:alnum:]_]*=.*", rscript, invert = TRUE)
    rscript[idxs] <- shQuote(rscript[idxs], type = rscript_sh[1])
  }

  rscript_args_internal <- character(0L)

  ## Can we get the worker's PID during launch?
  if (localMachine && !dryrun) {
    res <- useWorkerPID(rscript, rank = rank, rscript_sh = rscript_sh[1], verbose = verbose)
    pidfile <- res$pidfile
    rscript_args_internal <- c(res$rscript_pid_args, rscript_args_internal)
  } else {
    pidfile <- NULL
  }

  ## Add Rscript "label"?
  rscript_label <- getOption2("parallelly.makeNodePSOCK.rscript_label", NULL)
  if (!is.null(rscript_label) && nzchar(rscript_label) && !isFALSE(as.logical(rscript_label))) {
    if (isTRUE(as.logical(rscript_label))) {
      script <- grep("[.]R$", commandArgs(), value = TRUE)[1]
      if (is.na(script)) script <- "UNKNOWN"
      rscript_label <- sprintf("%s:%s:%s:%s", script, Sys.getpid(), Sys.info()[["nodename"]], Sys.info()[["user"]])
    }
    rscript_args_internal <- c("-e", shQuote(paste0("#label=", rscript_label), type = rscript_sh[1]), rscript_args_internal)
  }

  ## In contrast to default_packages=character(0), default_packages = NULL
  ## skips --default-packages/R_DEFAULT_PACKAGES completely.
  if (!is.null(default_packages)) {
    pkgs <- paste(unique(default_packages), collapse = ",")
    if (is_Rscript) {
      arg <- sprintf("--default-packages=%s", pkgs)
      rscript_args_internal <- c(arg, rscript_args_internal)
    } else {
      ## FIXME: Make 'rscript_envs' work this way so they are applied sooner
      ## in the R startup process, instead via -e 'Sys.setenv(FOO="1")'.
      arg <- sprintf("R_DEFAULT_PACKAGES=%s", pkgs)

      ## Is the cluster node launched in a MS Windows machine?
      on_MSWindows <- (rscript_sh[1] %in% c("cmd", "cmd2"))
      if (on_MSWindows) {
        ## On MS Windows, we have to use special '/path/to/R FOO=1 ...'
        rscript_args <- c(arg, rscript_args)
      } else {
        ## Everywhere else, we can use 'FOO=1 /path/to/R ...'
        rscript <- c(arg, rscript)
      }
    }
  }

  ## Port that the Rscript should use to connect back to the master
  if (!localMachine && revtunnel && getOption2("parallelly.makeNodePSOCK.port.increment", TRUE)) {
    rscript_port <- assertPort(port + rank - 1L)
    if (verbose) {
      mdebugf("%sRscript port: %d + %d = %d\n", verbose_prefix, port, rank - 1L, rscript_port)
    }
  } else {
    rscript_port <- port
    if (verbose) {
      mdebugf("%sRscript port: %d\n", verbose_prefix, rscript_port)
    }
  }

  if (length(socketOptions) == 1L) {
    code <- sprintf("options(socketOptions=\"%s\")", socketOptions)
    rscript_expr <- c("-e", shQuote(code, type = rscript_sh[1]))
    rscript_args_internal <- c(rscript_args_internal, rscript_expr)
  }

  if (length(rscript_startup) > 0L) {
    rscript_startup <- paste("invisible({", rscript_startup, "})", sep = "")
    rscript_startup <- shQuote(rscript_startup, type = rscript_sh[1])
    rscript_startup <- lapply(rscript_startup, FUN = function(value) c("-e", value))
    rscript_startup <- unlist(rscript_startup, use.names = FALSE)
    rscript_args_internal <- c(rscript_args_internal, rscript_startup)
  }

  if (length(rscript_envs) > 0L) {
    names <- names(rscript_envs)
    if (is.null(names)) {
      copy <- seq_along(rscript_envs)
    } else {
      copy <- which(nchar(names) == 0L)
    }
    if (length(copy) > 0L) {
      missing <- NULL
      for (idx in copy) {
        name <- rscript_envs[idx]
        if (!nzchar(name)) {
          stop("Argument 'rscript_envs' contains an empty non-named environment variable")
        }
        value <- Sys.getenv(name, NA_character_)
        if (!is.na(value)) {
          rscript_envs[idx] <- value
          names(rscript_envs)[idx] <- name
        } else {
          missing <- c(missing, name)
        }
      }
      if (length(missing) > 0L) {
        warnf("Did not pass down missing environment variables to cluster node: %s", paste(sQuote(missing), collapse = ", "))
      }
      names <- names(rscript_envs)
      rscript_envs <- rscript_envs[nzchar(names)]
      names <- names(rscript_envs)
    }
    ## Any environment variables to unset?
    if (length(unset <- which(is.na(rscript_envs))) > 0L) {
      names <- names(rscript_envs[unset])
      code <- sprintf("\"%s\"", names)
      code <- paste(code, collapse = ", ")
      code <- paste0("Sys.unsetenv(c(", code, "))")
      tryCatch({
        parse(text = code)
      }, error = function(ex) {
        stopf("Argument 'rscript_envs' appears to contain invalid values: %s", paste(sprintf("%s", sQuote(names)), collapse = ", "))
      })
      rscript_args_internal <- c(rscript_args_internal, "-e", shQuote(code, type = rscript_sh[1]))
      rscript_envs <- rscript_envs[-unset]
      names <- names(rscript_envs)
    }

    ## Any environment variables to set?
    if (length(names) > 0L) {
      code <- sprintf('"%s"="%s"', names, rscript_envs)
      code <- paste(code, collapse = ", ")
      code <- paste0("Sys.setenv(", code, ")")
      tryCatch({
        parse(text = code)
      }, error = function(ex) {
        stopf("Argument 'rscript_envs' appears to contain invalid values: %s", paste(sprintf("%s=%s", sQuote(names), sQuote(rscript_envs)), collapse = ","))
      })
      rscript_args_internal <- c(rscript_args_internal, "-e", shQuote(code, type = rscript_sh[1]))
    }
  }

  if (length(rscript_libs) > 0L) {
    ## Make sure to preserve backslashes, e.g. in Windows network drives
    rscript_libs <- gsub("\\\\", "\\\\\\\\", rscript_libs, fixed = TRUE)
    code <- paste0('"', rscript_libs, '"')
    code[rscript_libs == "*"] <- ".libPaths()"
    code <- paste(code, collapse = ",")
    code <- paste0('.libPaths(c(', code, '))')
    tryCatch({
      parse(text = code)
    }, error = function(ex) {
      stopf("Argument 'rscript_libs' appears to contain invalid values: %s", paste(sQuote(rscript_libs), collapse = ", "))
    })
    rscript_args_internal <- c(rscript_args_internal, "-e", shQuote(code, type = rscript_sh[1]))
  }
  
  ## .{slave,work}RSOCK() command already specified?
  if (!any(grepl("parallel:::[.](slave|work)RSOCK[(][)]", rscript_args))) {
    ## In R (>= 4.1.0), parallel:::.slaveRSOCK() was renamed to .workRSOCK()
    cmd <- "workRSOCK<-tryCatch(parallel:::.workRSOCK,error=function(e)parallel:::.slaveRSOCK);workRSOCK()"
    rscript_args_internal <- c(rscript_args_internal, "-e", shQuote(cmd, type = rscript_sh[1]))
  }

  ## Append or inject rscript_args_internal?
  rscript_args_org <- rscript_args
  idx <- which(rscript_args == "*")
  if (length(idx) == 0L) {
    rscript_args <- c(rscript_args, rscript_args_internal)
  } else if (length(idx) == 1L) {
    n <- length(rscript_args)
    if (idx == 1L) {
      rscript_args <- c(rscript_args_internal, rscript_args[-1])
    } else if (idx == n) {
      rscript_args <- c(rscript_args[-n], rscript_args_internal)
    } else {
      rscript_args <- c(rscript_args[1:(idx-1)], rscript_args_internal, 
                        rscript_args[(idx+1):n])
    }
  } else {
    stop(sprintf("Argument 'rscript_args' may contain at most one asterisk ('*'): %s", paste(sQuote(rscript_args), collapse = " ")))
  }

  rscript <- paste(rscript, collapse = " ")
  rscript_args <- paste(rscript_args, collapse = " ")
  envvars <- paste0("MASTER=", master, " PORT=", rscript_port, " OUT=", outfile, " TIMEOUT=", timeout, " XDR=", useXDR,
                    " SETUPTIMEOUT=", connectTimeout, " SETUPSTRATEGY=", setup_strategy)
  
  cmd <- paste(rscript, rscript_args, envvars)

  ## Renice?
  if (!is.na(renice) && renice > 0L) {
    cmd <- sprintf("nice --adjustment=%d %s", renice, cmd)
  }

  if (!localMachine) {
    ## Must hold a pathname with an optional set of command-line options
    stop_if_not(is.function(rshcmd) || is.character(rshcmd), length(rshcmd) >= 1L)

    ## Create label
    s <- sprintf("type=%s, version=%s", sQuote(attr(rshcmd, "type")), sQuote(attr(rshcmd, "version")))
    if (is.function(rshcmd)) {
      rshcmd_label <- sprintf("%s [%s]", paste(sQuote("rshcmd-function"), collapse = ", "), s)
    } else {
      rshcmd_label <- sprintf("%s [%s]", paste(sQuote(rshcmd), collapse = ", "), s)
    }
    if (verbose) mdebugf("%sUsing 'rshcmd': %s", verbose_prefix, rshcmd_label)
    
    ## User?
    if (length(user) == 1L) rshopts <- c("-l", user, rshopts)

    ## Reverse tunneling?
    if (revtunnel) {
      ## WORKAROUND: The Windows 10 loopback resolution uses IPv6 by default
      ## and the server is not listening for "localhost".  The solution is
      ## to use "127.0.0.1" instead, or force IPv4 by using ssh option '-4'.
      ## For more details, see 
      ## https://github.com/PowerShell/Win32-OpenSSH/issues/1265#issuecomment-855234326 for 
      if (is_localhost(master) && .Platform[["OS.type"]] == "windows" && (
           isTRUE(attr(rshcmd, "OpenSSH_for_Windows")) ||
           basename(rshcmd[1]) == "ssh"
         )) {
        master <- "127.0.0.1"
      }
      rshopts <- c(sprintf("-R %d:%s:%d", rscript_port, master, port), rshopts)
    }
    
    ## SSH log file?
    if (is.character(rshlogfile)) {
      rshopts <- c(sprintf("-E %s", shQuote(rshlogfile)), rshopts)
    }
    
    rshopts <- paste(rshopts, collapse = " ")

    ## Local commands
    if (is.function(rshcmd)) {
      rsh_call <- rshcmd(rshopts = rshopts, worker = worker)
    } else {
      rsh_call <- paste(paste(shQuote(rshcmd), collapse = " "), rshopts, worker)
    }
    local_cmd <- paste(rsh_call, shQuote(cmd, type = rscript_sh[2]))
  } else {
    rshcmd_label <- NULL
    rsh_call <- NULL
    local_cmd <- cmd
  }
  stop_if_not(length(local_cmd) == 1L)

  options <- structure(list(
    worker = worker,
    master = master,
    port = port,
    connectTimeout = connectTimeout,
    timeout = timeout,
    rscript = rscript,
    homogeneous = homogeneous,
    rscript_args = rscript_args,
    rscript_envs = rscript_envs,
    rscript_libs = rscript_libs,
    rscript_startup = rscript_startup,
    rscript_sh = rscript_sh,
    default_packages = default_packages,
    methods = methods,
    socketOptions = socketOptions,
    useXDR = useXDR,
    outfile = outfile,
    renice = renice,
    rshcmd = rshcmd,
    user = user,
    revtunnel = revtunnel,
    rshlogfile = rshlogfile,
    rshopts = rshopts,
    rank = rank,
    manual = manual,
    dryrun = dryrun,
    quiet = quiet,
    setup_strategy = setup_strategy,
    
    local_cmd = local_cmd,
    pidfile = pidfile,
    ## For messages, warnings, and errors:
    rshcmd_label = rshcmd_label,
    rsh_call = rsh_call,
    cmd = cmd,
    localMachine = localMachine,

    ## Function and original arguments used here
    make_fcn = makeNodePSOCK,
    arguments = args_org
  ), class = c("makeNodePSOCKOptions", "makeNodeOptions"))

  ## Return options?
  if (action == "options") return(options)

  launchNodePSOCK(options, verbose = verbose)
} ## makeNodePSOCK()
