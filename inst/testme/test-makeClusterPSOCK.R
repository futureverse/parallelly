library(parallelly)

is_fqdn <- parallelly:::is_fqdn
is_ip_number <- parallelly:::is_ip_number
is_localhost <- parallelly:::is_localhost
find_rshcmd <- parallelly:::find_rshcmd

message("*** makeClusterPSOCK() ...")

message("- makeClusterPSOCK() - internal utility functions")

stopifnot(
   is_fqdn("a.b"),
   is_fqdn("a.b.c"),
  !is_fqdn("a")
)

stopifnot(
   is_ip_number("1.2.3.4"),
  !is_ip_number("a"),
  !is_ip_number("1.2.3"),
  !is_ip_number("1.2.3.256"),
  !is_ip_number("1.2.3.-1"),
  !is_ip_number("1.2.3.a")
)

## Reset internal cache
stopifnot(is.na(is_localhost(worker = NULL, hostname = NULL)))
stopifnot(
   is_localhost("localhost"),
   is_localhost("127.0.0.1"),
   is_localhost(Sys.info()[["nodename"]]),
   is_localhost(Sys.info()[["nodename"]]), ## cache hit
  !is_localhost("not.a.localhost.hostname")
)

cmd <- find_rshcmd(must_work = FALSE)
print(cmd)


message("- makeClusterPSOCK()")

cl <- makeClusterPSOCK("<a-non-existing-hostname>", user = "johndoe", master = NULL, revtunnel = FALSE, rshcmd = "my_ssh", renice = TRUE, manual = TRUE, dryrun = TRUE)
print(cl)

cl <- makeClusterPSOCK(1L, port = "random", dryrun = TRUE)
print(cl)

cl <- makeClusterPSOCK(1L)
print(cl)
node <- cl[[1]]
utils::str(node)
stopifnot(isTRUE(attr(node[["host"]], "localhost")))
parallel::stopCluster(cl)


message("- makeClusterPSOCK() - useXDR = TRUE/FALSE")

for (xdr in c(TRUE, FALSE)) {
  cl <- makeClusterPSOCK(1L, useXDR = xdr)
  node <- cl[[1]]
  stopifnot(
    is.list(node),
    inherits(node, if (xdr) "SOCKnode" else "SOCK0node"),
    "session_info" %in% names(node)
  )
  si <- node[["session_info"]]
  stopifnot(is.list(si))
  parallel::stopCluster(cl)
}

message("- makeClusterPSOCK() - argument 'socketOptions'")

for (value in list(NULL, "NULL", "no-delay")) {
  cl <- makeClusterPSOCK(1L, socketOptions = value)
  y <- parallel::clusterEvalQ(cl, 42L)[[1]]
  stopifnot(identical(y, 42L))
  parallel::stopCluster(cl)
}


message("- makeClusterPSOCK() - argument 'rscript_startup'")

for (value in list(NULL, "options(abc = 42L)", quote(options(abc = 42L)))) {
  cl <- makeClusterPSOCK(1L, rscript_startup = value)
  y <- parallel::clusterEvalQ(cl, getOption("abc", NA_integer_))[[1]]
  stopifnot(is.integer(y), length(y) == 1L)
  if (!is.null(value)) stopifnot(identical(y, 42L))
  parallel::stopCluster(cl)
}


message("- makeClusterPSOCK() - setup_strategy = TRUE/FALSE")

for (setup_strategy in c("sequential", "parallel")) {
  dt <- system.time({
    cl <- makeClusterPSOCK(2L, setup_strategy = setup_strategy)
  })
  print(dt)
  print(cl)
  parallel::stopCluster(cl)
}


message("- makeClusterPSOCK() - with and w/out validation")

cl <- makeClusterPSOCK(1L, validate = TRUE) ## default
node <- cl[[1]]
stopifnot(
  is.list(node),
  inherits(node, if (useXDR) "SOCKnode" else "SOCK0node"),
  "session_info" %in% names(node)
)
si <- node[["session_info"]]
stopifnot(is.list(si))
parallel::stopCluster(cl)

cl <- makeClusterPSOCK(1L, validate = FALSE)
node <- cl[[1]]
stopifnot(
  is.list(node),
  inherits(node, if (useXDR) "SOCKnode" else "SOCK0node"),
  ! "session_info" %in% names(node)
)
parallel::stopCluster(cl)


message("- makeClusterPSOCK() - w/out 'parallelly' on worker")

ovalue <- Sys.getenv("R_LIBS_USER")
Sys.setenv(R_LIBS_USER = tempdir())
cl <- makeClusterPSOCK(1L, outfile = "")
print(cl)
parallel::stopCluster(cl)
Sys.setenv(R_LIBS_USER = ovalue)


message("- makeClusterPSOCK() - assert 'parallelly' is not loaded")

cl <- makeClusterPSOCK(1L)
ns <- parallel::clusterCall(cl, function() { loadedNamespaces() })
print(ns)
stopifnot(!is.element("parallelly", ns))
parallel::stopCluster(cl)


message("- makeClusterPSOCK() - launch via the R executable")

if (on_windows) {
  ## R and R.exe fails on MS Windows, cf. R-devel thread "MS Windows: R does
  ## not escape quotes in CLI options the same way as Rterm and Rscript"
  ## on 2021-12-15.
  rscripts <- file.path(R.home("bin"), c("Rterm", "Rterm.exe"))
} else {
  rscripts <- file.path(R.home("bin"), "R")
}

for (rscript in rscripts) {
  message("  Launcher: ", sQuote(rscript))
  rscript_args <- c("--no-echo", "--no-restore", "*", "--args")
  cl <- tryCatch({
    makeClusterPSOCK(1L, rscript = rscript, rscript_args = rscript_args)
  }, warning = identity)
  stopifnot(inherits(cl, "cluster"))
  parallel::stopCluster(cl)
}


message("- makeClusterPSOCK() - default packages")

if (on_windows) {
  ## R and R.exe fails on MS Windows, cf. R-devel thread "MS Windows: R does
  ## not escape quotes in CLI options the same way as Rterm and Rscript"
  ## on 2021-12-15.
  rscripts <- file.path(R.home("bin"), c("Rscript", "Rterm", "Rterm.exe"))
} else {
  rscripts <- file.path(R.home("bin"), c("Rscript", "R"))
}
default_packages <- c("utils", "tools")
for (rscript in rscripts) {
  message("  Launcher: ", sQuote(rscript))
  if (tools::file_path_sans_ext(basename(rscript)) %in% c("R", "Rterm")) {
    rscript_args <- c("--no-echo", "--no-restore", "*", "--args")
  } else {
    rscript_args <- NULL
  }
  cl <- tryCatch({
    makeClusterPSOCK(1L, rscript = rscript, rscript_args = rscript_args, default_packages = default_packages)
  }, warning = identity)
  stopifnot(inherits(cl, "cluster"))
  pkgs <- parallel::clusterEvalQ(cl, { getOption("defaultPackages") })[[1]]
  stopifnot(identical(pkgs, default_packages))
  parallel::stopCluster(cl)
}

if (on_windows) {
  ## R and R.exe fails on MS Windows, cf. R-devel thread "MS Windows: R does
  ## not escape quotes in CLI options the same way as Rterm and Rscript"
  ## on 2021-12-15.
  rscripts <- file.path(R.home("bin"), c("Rscript", "Rterm", "Rterm.exe"))
} else {
  rscripts <- file.path(R.home("bin"), c("Rscript", "R"))
}
default_packages <- c("parallelly", "*")
truth <- unique(c("parallelly", getOption("defaultPackages")))
for (rscript in rscripts) {
  message("  Launcher: ", sQuote(rscript))
  if (tools::file_path_sans_ext(basename(rscript)) %in% c("R", "Rterm")) {
    rscript_args <- c("--no-echo", "--no-restore", "*", "--args")
  } else {
    rscript_args <- NULL
  }
  cl <- tryCatch({
    makeClusterPSOCK(1L, rscript = rscript, rscript_args = rscript_args, default_packages = default_packages)
  }, warning = identity)
  stopifnot(inherits(cl, "cluster"))
  pkgs <- parallel::clusterEvalQ(cl, { getOption("defaultPackages") })[[1]]
  stopifnot(identical(pkgs, truth))
  parallel::stopCluster(cl)
}


message("- makeClusterPSOCK() - exceptions")

res <- tryCatch({
  cl <- makeClusterPSOCK(1:2)
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  cl <- makeClusterPSOCK(0L)
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  cl <- makeClusterPSOCK(1L, rshcmd = character(0L))
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  cl <- makeClusterPSOCK(1L, port = integer(0L))
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

res <- tryCatch({
  cl <- makeClusterPSOCK(1L, port = NA_integer_)
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))


message("- makeClusterPSOCK() - exceptions")

## Non-existing hostname
res <- tryCatch({
  cl <- makeNodePSOCK("not.a.localhost.hostname", revtunnel = TRUE)
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Invalid port
res <- tryCatch({
  cl <- makeNodePSOCK("localhost", port = NA_integer_)
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

## Don't test on CRAN
if (fullTest || covr_testing) {
  ## Occupied/blocked port
  res <- tryCatch(
    cl <- parallelly::makeClusterPSOCK("localhost", port = 80L, tries = 1L),
  error = identity)
  print(res)
  ## Skip error assertion in case this actually works on some machine.
  ## But where it fails, we are testing the port-failure exception code.
}


## https://github.com/futureverse/parallelly/issues/95
if (getRversion() >= "4.0.0") {
  res <- tryCatch({
    parallelly::makeClusterPSOCK(1L, rscript_startup = quote(Sys.sleep(6.0)),
                                 connectTimeout = 0.1, timeout = 7.0)
  }, error = identity)
  print(res)
  stopifnot(
    inherits(res, "error"),
    grepl("^Cluster setup failed", conditionMessage(res))
  )

  ## Make sure to wait for background process to timeout before continuing,
  ## when on MS Windows
  if (on_windows) Sys.sleep(5.0)
}

message("*** makeClusterPSOCK() ... DONE")
