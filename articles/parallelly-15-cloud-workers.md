# Parallel Workers in the Cloud

## Introduction

This vignette illustrates how to launch parallel workers on cloud
services such as Amazon AWS (<https://aws.amazon.com/>) and Google
Compute Engine (<https://cloud.google.com/products/compute>).

## Examples

### Example: Remote worker running on GCE

This example launches a parallel worker on Google Compute Engine (GCE)
running a container based VM (with a \#cloud-config specification).

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`parallelly`](https://parallelly.futureverse.org)`)`\
\
`public_ip`` ``<-`` ``"1.2.3.4"`\
`user`` ``<-`` ``"johnny"`\
`ssh_private_key_file`` ``<-`` ``"~/.ssh/google_compute_engine"`\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(`\
`  ``## Public IP number of GCE instance`\
`  ``public_ip``,`\
`  ``## User name (== SSH key label (sic!))`\
`  user ``=`` ``user``,`\
`  ``## Use private SSH key registered with GCE`\
`  rshopts ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"-o"``, ``"StrictHostKeyChecking=no"``,`\
`    ``"-o"``, ``"IdentitiesOnly=yes"``,`\
`    ``"-i"``, ``ssh_private_key_file`\
`  ``)``,`\
`  ``## Launch Rscript inside Docker container`\
`  rscript ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"docker"``, ``"run"``, ``"--net=host"``, ``"rocker/r-parallel"``,`\
`    ``"Rscript"`\
`  ``)`\
`)`

### Example: Remote worker running on AWS

This example, which is a bit dated, launches a parallel worker on Amazon
AWS EC2 running one of the Amazon Machine Images (AMI) provided by Posit
(<https://www.louisaslett.com/RStudio_AMI/>).

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`parallelly`](https://parallelly.futureverse.org)`)`\
\
`public_ip`` ``<-`` ``"1.2.3.4"`\
`ssh_private_key_file`` ``<-`` ``"~/.ssh/my-private-aws-key.pem"`\
\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(`\
`  ``## Public IP number of EC2 instance`\
`  ``public_ip``,`\
`  ``## User name (always 'ubuntu')`\
`  user ``=`` ``"ubuntu"``,`\
`  ``## Use private SSH key registered with AWS`\
`  rshopts ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"-o"``, ``"StrictHostKeyChecking=no"``,`\
`    ``"-o"``, ``"IdentitiesOnly=yes"``,`\
`    ``"-i"``, ``ssh_private_key_file`\
`  ``)``,`\
`  ``## Set up .libPaths() for the 'ubuntu' user`\
`  ``## and then install the future package`\
`  rscript_startup ``=`` `[`quote`](https://rdrr.io/r/base/substitute.html)`(`[`local`](https://rdrr.io/r/base/eval.html)`(``{`\
`    ``p`` ``<-`` `[`Sys.getenv`](https://rdrr.io/r/base/Sys.getenv.html)`(``"R_LIBS_USER"``)`\
`    `[`dir.create`](https://rdrr.io/r/base/files2.html)`(``p``, recursive ``=`` ``TRUE``, showWarnings ``=`` ``FALSE``)`\
`    `[`.libPaths`](https://rdrr.io/r/base/libPaths.html)`(``p``)`\
`    `[`install.packages`](https://rdrr.io/r/utils/install.packages.html)`(``"future"``)`\
`  ``}``)``)`\
`)`
