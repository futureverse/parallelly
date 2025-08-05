<!--
%\VignetteIndexEntry{Parallel Workers Running in a Sandbox}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteKeyword{Docker}
%\VignetteKeyword{Apptainer}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

This vignette shows how to set up "sandboxed" parallel workers with
limited access to the host system.

# Examples

## Example: Bubblewrap on Linux

This example sets up two parallel workers on Linux sandboxed using
[Bubblewrap].

```r
library(parallelly)

## Helper functions to configure Bubblewrap
ro_binds <- function(dirs) {
  dirs <- unique(dirs)
  dirs <- dirs[file_test("-d", dirs)]
  opts <- rep(dirs, each = 3L)
  opts[seq(from = 1, to = length(opts), by = 3)] <- "--ro-bind"
  opts
} ## ro_binds()

ro_rlibs <- function(dirs, home, sandbox_home) {
  dirs <- unique(dirs)
  dirs <- dirs[file_test("-d", dirs)]

  pattern <- sprintf("^%s", home)
  to_dirs <- sub(pattern, sandbox_home, dirs) 
  opts <- rep(dirs, each = 3L)
  opts[seq(from = 1, to = length(opts), by = 3)] <- "--ro-bind"
  opts[seq(from = 3, to = length(opts), by = 3)] <- to_dirs
  opts
} ## ro_rlibs()

bwrap_args <- function() {
  ## Unshares
  ## Note, we cannot sandbox the network (--unshare-net), because
  ## PSOCK clusters communicate over socket connections
  bwrap_unshares <- c(
    "--unshare-user",
    "--unshare-pid",
    "--unshare-ipc"
  )
  bwrap_opts <- bwrap_unshares
  
  ## Misc options
  opts <- c("--proc", "/proc", "--dev", "/dev", "--tmpfs", "/tmp")
  bwrap_opts <- c(bwrap_opts, opts)
  
  ## Read-only Linux mounts
  dirs <- c("/usr", "/bin", "/usr/bin", "/lib", "/lib64", "/etc/alternatives")

  ## Read-only mount R home folders
  components <- c("bin", "lib", "doc", "etc", "include", "modules", "share")
  r_dirs <- unname(vapply(components, FUN = R.home, FUN.VALUE = NA_character_))
  r_dirs <- c(r_dirs, dirname(Sys.which("R")), dirname(Sys.which("Rscript")))
  r_dirs <- c(r_dirs, rev(.libPaths())[1])
  dirs <- c(dirs, r_dirs)

  bwrap_opts <- c(bwrap_opts, ro_binds(dirs))

  ## Remap HOME
  home <- Sys.getenv("HOME")
  sandbox_home <- "/home/sandbox-user"
  stopifnot(file_test("-d", home))
  tmp_home <- tempfile(pattern = "sandbox-home-")
  dir.create(tmp_home)
  stopifnot(file_test("-d", tmp_home))
  opts <- c("--bind", tmp_home, sandbox_home)
  opts <- c(opts, "--setenv", "HOME", sandbox_home)
  opts <- c(opts, "--chdir", sandbox_home)
  bwrap_opts <- c(bwrap_opts, opts)

  ## Read-only remapped R library paths
  libs <- .libPaths()
  libs <- rev(rev(libs)[-1])
  bwrap_opts <- c(bwrap_opts, ro_rlibs(libs, home = home, sandbox_home = sandbox_home))

  bwrap_opts
} ## bwrap_args()

bwrap_sandbox <- function() {
  c("bwrap", bwrap_args())
}

cl <- makeClusterPSOCK(2L
  ## Launch Rscript inside a Bubblewrap sandbox
  rscript = c(bwrap_sandbox(), "Rscript")
)
print(cl)
#> Socket cluster with 2 nodes on host 'localhost' (R version 4.5.1
#> (2025-06-13), platform x86_64-pc-linux-gnu)

host_user <- Sys.info()[["user"]]
host_user
#> "alice"

worker_user <- unlist(parallel::clusterEvalQ(cl, Sys.info()[["user"]]))
worker_user
#> [1] "unknown" "unknown"
```

[Bubblewrap]: https://github.com/containers/bubblewrap
