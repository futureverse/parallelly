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

bwrap_sandbox <- function(rscript = "*") {
  ro_binds <- function(dirs) {
    dirs <- unique(dirs[file_test("-d", dirs)])
    opts <- rep(dirs, each = 3L)
    opts[seq(from = 1, to = length(opts), by = 3)] <- "--ro-bind"
    opts
  }

  ro_rlibs_remap <- function(dirs = rev(rev(.libPaths())[-1])) {
    dirs <- unique(dirs[file_test("-d", dirs)])
    dirs2 <- sub(sprintf("^%s", Sys.getenv("HOME")), "/home/sandbox-user", dirs)
    opts <- rep(dirs, each = 3L)
    opts[seq(from = 1, to = length(opts), by = 3)] <- "--ro-bind"
    opts[seq(from = 3, to = length(opts), by = 3)] <- dirs2
    opts
  }

  args <- c("bwrap")
  
  ## Unshares
  ## Note, we cannot sandbox the network (--unshare-net), because
  ## PSOCK clusters communicate over socket connections
  unshares <- c(
    "--unshare-user",  # isolate user and group ids
    "--unshare-pid",   # isolate processes
    "--proc", "/proc",
    "--unshare-ipc"    # isolate process communication, e.g. shared memory
  )
  args <- c(args, unshares)
  
  ## Misc options
  opts <- c(
    "--dev", "/dev",   # mount host's /dev
    "--tmpfs", "/tmp"  # mount fresh, private, empty temporary directory
  )
  args <- c(args, opts)
  
  ## Read-only Linux mounts
  dirs <- c("/usr", "/bin", "/usr/bin", "/lib", "/lib64", "/etc/alternatives")

  ## Use host's R and Rscript (by read-only mounting R home folders)
  components <- c("bin", "lib", "doc", "etc", "include", "modules", "share")
  r_dirs <- unname(vapply(components, FUN = R.home, FUN.VALUE = NA_character_))
  r_dirs <- c(r_dirs, dirname(Sys.which("R")), dirname(Sys.which("Rscript")))
  r_dirs <- c(r_dirs, rev(.libPaths())[1])
  dirs <- c(dirs, r_dirs)
  args <- c(args, ro_binds(dirs))

  ## Remap HOME to fresh, private sandboxed HOME
  tmp_home <- tempfile(pattern = "sandbox-home-")
  dir.create(tmp_home)
  opts <- c(
    "--bind", tmp_home, "/home/sandbox-user",
    "--setenv", "HOME", "/home/sandbox-user",
    "--chdir", "/home/sandbox-user"
  )
  args <- c(args, opts)

  ## Read-only remapped non-system R library paths
  args <- c(args, ro_rlibs_remap())

  c(args, rscript)
} ## bwrap_sandbox()


## Launch two parallel workers inside a Bubblewrap sandbox
cl <- makeClusterPSOCK(2L, rscript = bwrap_sandbox("Rscript"))
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
