library(parallel)
cl <- makeCluster(1L)

res <- clusterEvalQ(cl, tryCatch(capabilities(), error = identity))
print(res)

res <- clusterEvalQ(cl, tryCatch(l10n_info(), error = identity))
print(res)

res <- clusterEvalQ(cl, tryCatch(La_version(), error = identity))
print(res)

res <- clusterEvalQ(cl, tryCatch(La_library(), error = identity))
print(res)

res <- clusterEvalQ(cl, tryCatch(extSoftVersion(), error = identity))
print(res)

stopCluster(cl)


## NOTE: Drop 'dryrun = TRUE' below in order to actually connect.  Add
## 'verbose = TRUE' if you run into problems and need to troubleshoot.

## ---------------------------------------------------------------
## Section 1. Setting up parallel workers on the local machine
## ---------------------------------------------------------------
## EXAMPLE: Two workers on the local machine
workers <- c("localhost", "localhost")
cl <- makeClusterPSOCK(workers, dryrun = TRUE, quiet = TRUE)


## EXAMPLE: Launch 124 workers on MS Windows 10, where half are
## running on CPU Group #0 and half on CPU Group #1.  
## (https://lovickconsulting.com/2021/11/18/
##  running-r-clusters-on-an-amd-threadripper-3990x-in-windows-10-2/)
## The parallel workers are launched as:
## "%COMSPEC%" /c start /B /NODE 1 /AFFINITY 0xFFFFFFFFFFFFFFFE ...
## ...
## "%COMSPEC%" /c start /B /NODE 1 /AFFINITY 0xFFFFFFFFFFFFFFFE ...

## Temporarily disable CPU load protection for this example
oopts <- options(parallelly.maxWorkers.localhost = Inf)

ncores <- 124
cpu_groups <- c(0, 1)
cl <- lapply(cpu_groups, FUN = function(cpu_group) {
    parallelly::makeClusterPSOCK(ncores %/% length(cpu_groups),
      rscript = I(c(
        Sys.getenv("COMSPEC"), "/c", "start", "/B",
        "/NODE", cpu_group, "/AFFINITY", "0xFFFFFFFFFFFFFFFE",
        "*"
      )),
      dryrun = TRUE, quiet = TRUE
    )
})
## merge the two 62-node clusters into one with 124 nodes
cl <- do.call(c, cl)

## Re-enable CPU load protection
options(oopts)


## ---------------------------------------------------------------
## Section 2. Setting up parallel workers on remote machines
## ---------------------------------------------------------------
## EXAMPLE: Three remote workers
## Setup of three R workers on two remote machines are set up
## The parallel workers are launched as:
## '/usr/bin/ssh' -R 11058:localhost:11058 n1.remote.org ...
## '/usr/bin/ssh' -R 11059:localhost:11058 n2.remote.org ...
## '/usr/bin/ssh' -R 11060:localhost:11058 n1.remote.org ...
workers <- c("n1.remote.org", "n2.remote.org", "n1.remote.org")
cl <- makeClusterPSOCK(workers, dryrun = TRUE, quiet = TRUE)


## EXAMPLE: Two remote workers running on MS Windows.  Because the
## remote workers are MS Windows machines, we need to use
## rscript_sh = "cmd".
## The parallel workers are launched as:
## '/usr/bin/ssh' -R 11912:localhost:11912 mswin1.remote.org ...
## '/usr/bin/ssh' -R 11913:localhost:11912 mswin2.remote.org ...
workers <- c("mswin1.remote.org", "mswin2.remote.org")
cl <- makeClusterPSOCK(workers, rscript_sh = "cmd", dryrun = TRUE, quiet = TRUE)


## EXAMPLE: Local and remote workers
## Same setup when the two machines are on the local network and
## have identical software setups
cl <- makeClusterPSOCK(
  workers,
  revtunnel = FALSE, homogeneous = TRUE,
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: Three remote workers 'n1', 'n2', and 'n3' that can only be
## accessed via jumphost 'login.remote.org'
## The parallel workers are launched as:
## '/usr/bin/ssh' -R 11226:localhost:11226 -J login.remote.org n1 ...
## '/usr/bin/ssh' -R 11227:localhost:11226 -J login.remote.org n2 ...
## '/usr/bin/ssh' -R 11228:localhost:11226 -J login.remote.org n1 ...
workers <- c("n1", "n2", "n1")
cl <- makeClusterPSOCK(
  workers,
  rshopts = c("-J", "login.remote.org"),
  homogeneous = FALSE,
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: Remote worker running on Linux from MS Windows machine
## Connect to remote Unix machine 'remote.server.org' on port 2200
## as user 'bob' from a MS Windows machine with PuTTY installed.
## Using the explicit special rshcmd = "<putty-plink>", will force
## makeClusterPSOCK() to search for and use the PuTTY plink software,
## preventing it from using other SSH clients on the system search PATH.
## The parallel worker is launched as:
## 'plink' -l bob -P 2200 -i C:/Users/bobby/.ssh/putty.ppk remote.server.org ...
cl <- makeClusterPSOCK(
  "remote.server.org", user = "bob",
  rshcmd = "<putty-plink>",
  rshopts = c("-P", 2200, "-i", "C:/Users/bobby/.ssh/putty.ppk"),
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: Remote workers with specific setup
## Setup of remote worker with more detailed control on
## authentication and reverse SSH tunneling
## The parallel worker is launched as:
## '/usr/bin/ssh' -l johnny -v -R 11000:gateway:11942 remote.server.org ...
## "R_DEFAULT_PACKAGES=... 'nice' '/path/to/Rscript' --no-init-file ...
cl <- makeClusterPSOCK(
  "remote.server.org", user = "johnny",
  ## Manual configuration of reverse SSH tunneling
  revtunnel = FALSE,
  rshopts = c("-v", "-R 11000:gateway:11942"),
  master = "gateway", port = 11942,
  ## Run Rscript nicely and skip any startup scripts
  rscript = c("nice", "/path/to/Rscript"),
  rscript_args = c("--no-init-file"),
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: Remote worker running on Linux from RStudio on MS Windows
## Connect to remote Unix machine 'remote.server.org' on port 2200
## as user 'bob' from a MS Windows machine via RStudio's SSH client.
## Using the explicit special rshcmd = "<rstudio-ssh>", will force
## makeClusterPSOCK() to use the SSH client that comes with RStudio,
## preventing it from using other SSH clients on the system search PATH.
## The parallel worker is launched as:
## 'ssh' -l bob remote.server.org:2200 ...
cl <- makeClusterPSOCK(
  "remote.server.org:2200", user = "bob", rshcmd = "<rstudio-ssh>",
  dryrun = TRUE, quiet = TRUE
)


## ---------------------------------------------------------------
## Section 3. Setting up parallel workers on HPC cluster
## ---------------------------------------------------------------
## EXAMPLE: 'Grid Engine' is a high-performance compute (HPC) job
## scheduler where one can request compute resources on multiple nodes,
## each running multiple cores. Examples of Grid Engine schedulers are
## Oracle Grid Engine (formerly Sun Grid Engine), Univa Grid Engine,
## and Son of Grid Engine - all commonly referred to as SGE schedulers.
## Each SGE cluster may have its own configuration with their own way
## of requesting parallel slots. Here are a few examples:
##
##   ## Request 18 slots on a single host
##   qsub -pe smp 18 script.sh
##
##   ## Request 18 slots on one or more hosts
##   qsub -pe mpi 18 script.sh
##
## This will launch the job script 'script.sh' on one host, while have
## reserved in total 18 slots (CPU cores) on this host and possible
## other hosts.
##
## This example shows how to use the SGE command 'qrsh' to launch
## 18 parallel workers from R, which is assumed to have been launched
## by 'script.sh'.
##
## The parallel workers are launched as:
## 'qrsh' -inherit -nostdin -V comphost01 ...
## 'qrsh' -inherit -nostdin -V comphost01 ...
## ...
## 'qrsh' -inherit -nostdin -V comphost06 ...
cl <- makeClusterPSOCK(
  availableWorkers(),
  rshcmd = "qrsh", rshopts = c("-inherit", "-nostdin", "-V"),
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: The 'Fujitsu Technical Computing Suite' is a high-performance
## compute (HPC) job scheduler where one can request compute resources on
## multiple nodes, each running multiple cores.  For example,
##
##   pjsub -L vnode=3 -L vnode-core=18 script.sh
##
## reserves 18 cores on three nodes. The job script runs on the first
## with enviroment variables set to infer the other nodes, resulting in
## availableWorkers() to return 3 * 18 workers. When the HPC environment
## does not support SSH between compute nodes, one can use the 'pjrsh'
## command to launch the parallel workers.
##
## The parallel workers are launched as:
## 'pjrsh' comphost01 ...
## 'pjrsh' comphost01 ...
## ...
## 'pjrsh' comphost06 ...
cl <- makeClusterPSOCK(
  availableWorkers(),
  rshcmd = "pjrsh",
  dryrun = TRUE, quiet = TRUE
)



## ---------------------------------------------------------------
## Section 4. Setting up remote parallel workers in the cloud
## ---------------------------------------------------------------
## EXAMPLE: Remote worker running on AWS
## Launching worker on Amazon AWS EC2 running one of the
## Amazon Machine Images (AMI) provided by RStudio
## (https://www.louisaslett.com/RStudio_AMI/)
##
## The parallel worker is launched as:
## '/usr/bin/ssh' -R 11153:localhost:11153 -l ubuntu ...
## -o StrictHostKeyChecking=no -o IdentitiesOnly=yes ...
## -i ~/.ssh/my-private-aws-key.pem 1.2.3.4 ...
public_ip <- "1.2.3.4"
ssh_private_key_file <- "~/.ssh/my-private-aws-key.pem"
cl <- makeClusterPSOCK(
  ## Public IP number of EC2 instance
  public_ip,
  ## User name (always 'ubuntu')
  user = "ubuntu",
  ## Use private SSH key registered with AWS
  rshopts = c(
    "-o", "StrictHostKeyChecking=no",
    "-o", "IdentitiesOnly=yes",
    "-i", ssh_private_key_file
  ),
  ## Set up .libPaths() for the 'ubuntu' user
  ## and then install the future package
  rscript_startup = quote(local({
    p <- Sys.getenv("R_LIBS_USER")
    dir.create(p, recursive = TRUE, showWarnings = FALSE)
    .libPaths(p)
    install.packages("future")
  })),
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: Remote worker running on GCE
## Launching worker on Google Cloud Engine (GCE) running a
## container based VM (with a #cloud-config specification)
public_ip <- "1.2.3.4"
user <- "johnny"
ssh_private_key_file <- "~/.ssh/google_compute_engine"
cl <- makeClusterPSOCK(
  ## Public IP number of GCE instance
  public_ip,
  ## User name (== SSH key label (sic!))
  user = user,
  ## Use private SSH key registered with GCE
  rshopts = c(
    "-o", "StrictHostKeyChecking=no",
    "-o", "IdentitiesOnly=yes",
    "-i", ssh_private_key_file
  ),
  ## Launch Rscript inside Docker container
  rscript = c(
    "docker", "run", "--net=host", "rocker/r-parallel",
    "Rscript"
  ),
  dryrun = TRUE, quiet = TRUE
)



## ---------------------------------------------------------------
## Section 5. Parallel workers running locally inside virtual
## machines, Linux containers, etc.
## ---------------------------------------------------------------
## EXAMPLE: Two workers limited to 100% CPU process and 50 MiB of
## memory using Linux CGroups management. The 100% CPU quota limit
## constrain each worker to use at most one CPU worth of
## processing preventing them from overusing the machine, e.g.
## through unintended nested parallelization. The 50 MiB memory
## limit is strict - if a worker use more than this, the operating
## system will terminate the worker instantly.
## See 'man systemd.resource-control' for more details.
cl <- makeClusterPSOCK(2L,
  rscript = c("systemd-run", "--user", "--scope",
    "-p", "CPUQuota=100%",
    "-p", "MemoryMax=50M", "-p", "MemorySwapMax=50M",
    "*"
  ),
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: Two workers running in Docker on the local machine
## Setup of 2 Docker workers running rocker/r-parallel
##
## The parallel workers are launched as:
## R_DEFAULT_PACKAGES=... '/usr/bin/docker' 'run' '--net=host' 'rocker/r-parallel' ...
## R_DEFAULT_PACKAGES=... '/usr/bin/docker' 'run' '--net=host' 'rocker/r-parallel' ...
cl <- makeClusterPSOCK(
  rep("localhost", times = 2L),
  ## Launch Rscript inside Docker container
  rscript = c(
    "docker", "run", "--net=host", "rocker/r-parallel",
    "Rscript"
  ),
  ## IMPORTANT: Because Docker runs inside a virtual machine (VM) on macOS
  ## and MS Windows (not Linux), when the R worker tries to connect back to
  ## the default 'localhost' it will fail, because the main R session is
  ## not running in the VM, but outside on the host.  To reach the host on
  ## macOS and MS Windows, make sure to use master = "host.docker.internal"
  master = if (.Platform$OS.type == "unix") NULL else "host.docker.internal",
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: Two workers running via Linux container 'rocker/r-parallel' from
## DockerHub on the local machine using Apptainer (formerly Singularity)
##
## The parallel workers are launched as:
## R_DEFAULT_PACKAGES=... '/usr/bin/apptainer' 'exec' 'docker://rocker/r-parallel' ...
## R_DEFAULT_PACKAGES=... '/usr/bin/apptainer' 'exec' 'docker://rocker/r-parallel' ...
cl <- makeClusterPSOCK(
  rep("localhost", times = 2L),
  ## Launch Rscript inside Linux container
  rscript = c(
    "apptainer", "exec", "docker://rocker/r-parallel",
    "Rscript"
  ),
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: One worker running in udocker on the local machine
## Setup of a single udocker.py worker running rocker/r-parallel
##
## The parallel worker is launched as:
## R_DEFAULT_PACKAGES=... 'udocker.py' 'run' 'rocker/r-parallel' ...
cl <- makeClusterPSOCK(
  "localhost",
  ## Launch Rscript inside Docker container (using udocker)
  rscript = c(
    "udocker.py", "run", "rocker/r-parallel",
    "Rscript"
  ), 
  ## Manually launch parallel workers
  ## (need double shQuote():s because udocker.py drops one level)
  rscript_args = c(
    "-e", shQuote(shQuote("parallel:::.workRSOCK()"))
  ),
  dryrun = TRUE, quiet = TRUE
)


## EXAMPLE: One worker running in Wine for Linux on the local machine
## To install R for MS Windows in Wine, do something like:
##   winecfg  # In GUI, set 'Windows version' to 'Windows 10'
##   wget https://cran.r-project.org/bin/windows/base/R-4.5.0-win.exe
##   wine R-4.5.0-win.exe /SILENT
## Prevent packages from being installed to R's system library:
##   chmod ugo-w "$HOME/.wine/drive_c/Program Files/R/R-4.5.0/library/"
## Verify it works:
##   wine "C:/Program Files/R/R-4.5.0/bin/x64/Rscript.exe" --version
##
## The parallel worker is launched as:
## R_DEFAULT_PACKAGES=... WINEDEBUG=fixme-all R_LIBS_SITE= R_LIBS_USER= 'wine' ...
cl <- makeClusterPSOCK(1L,
  rscript = c(
    ## Silence Wine warnings
    "WINEDEBUG=fixme-all",
    ## Don't pass LC_* and R_LIBS* environments from host to Wine
    sprintf("%s=", grep("^(LC_|R_LIBS)", names(Sys.getenv()), value = TRUE)),
    "wine",
    "C:/Program Files/R/R-4.5.0/bin/x64/Rscript.exe"
  ),
  dryrun = TRUE, quiet = TRUE
)
