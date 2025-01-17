<!--
%\VignetteIndexEntry{Parallel Workers in the Cloud}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

This vignettes illustrates how to launch parallel workers on cloud
services such as Amazon AWS (<https://aws.amazon.com/>) and Google
Compute Engine (<https://cloud.google.com/products/compute>).


# Examples

## Example: Remote worker running on GCE

This example launches a parallel worker on Google Compute Engine (GCE)
running a container based VM (with a #cloud-config specification).

```r
library(parallelly)

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
  )
)
```


## Example: Remote worker running on AWS

This example, which is a bit dated, launches a parallel worker on
Amazon AWS EC2 running one of the Amazon Machine Images (AMI) provided
by Posit (<https://www.louisaslett.com/RStudio_AMI/>).

```r
library(parallelly)

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
  }))
)
```
