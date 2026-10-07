# Parallel Workers Running in Linux Containers

## Introduction

This vignette shows how to set up parallel workers running in Linux
containers, e.g. Docker (<https://www.docker.com/>), Apptainer
(<https://apptainer.org/>), and udocker
(<https://indigo-dc.github.io/udocker/>).

## Examples

### Example: Two parallel workers running in Docker

This example sets up two parallel workers running Docker image
‘rocker/r-ver:4.6.1’ (<https://hub.docker.com/r/rocker/r-ver>).

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`parallelly`](https://parallelly.futureverse.org)`)`\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(`\
`  `[`rep`](https://rdrr.io/r/base/rep.html)`(``"localhost"``, times ``=`` ``2L``)``,`\
`  ``## Launch Rscript inside Linux container via Docker`\
`  rscript ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"docker"``, ``"run"``, ``"--net=host"``, ``"rocker/r-ver:4.6.1"``,`\
`    ``"Rscript"`\
`  ``)``,`\
`  ``## IMPORTANT: Because Docker runs inside a virtual machine (VM) on macOS`\
`  ``## and MS Windows (not Linux), when the R worker tries to connect back to`\
`  ``## the default 'localhost' it will fail, because the main R session is`\
`  ``## not running in the VM, but outside on the host.  To reach the host on`\
`  ``## macOS and MS Windows, make sure to use master = "host.docker.internal"`\
`  master ``=`` ``if`` ``(``.Platform``$``OS.type`` ``==`` ``"unix"``)`` ``NULL`` ``else`` ``"host.docker.internal"``,`\
`)`\
[`print`](https://rdrr.io/r/base/print.html)`(``cl``)`\
`#> Socket cluster with 2 nodes on host 'localhost' (R version 4.6.1`\
`#> (2026-06-24), platform x86_64-pc-linux-gnu)`

### Example: Two parallel workers running in Apptainer

This example shows how to set up two parallel workers running Docker
image ‘rocker/r-ver:4.6.1’ (<https://hub.docker.com/r/rocker/r-ver>) via
Apptainer (<https://apptainer.org/>).

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`parallelly`](https://parallelly.futureverse.org)`)`\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(`\
`  `[`rep`](https://rdrr.io/r/base/rep.html)`(``"localhost"``, times ``=`` ``2L``)``,`\
`  ``## Launch Rscript inside Linux container via Apptainer`\
`  rscript ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"apptainer"``, ``"exec"``, ``"docker://rocker/r-ver:4.6.1"``,`\
`    ``"Rscript"`\
`  ``)`\
`)`\
[`print`](https://rdrr.io/r/base/print.html)`(``cl``)`\
`#> Socket cluster with 2 nodes on host 'localhost' (R version 4.6.1`\
`#> (2026-06-24), platform x86_64-pc-linux-gnu)`

### Example: Two parallel workers running in udocker

This example shows how to set up two parallel workers running Docker
image ‘rocker/r-ver:4.6.1’ (<https://hub.docker.com/r/rocker/r-ver>) via
udocker (<https://indigo-dc.github.io/udocker/>).

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`parallelly`](https://parallelly.futureverse.org)`)`\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(`\
`  `[`rep`](https://rdrr.io/r/base/rep.html)`(``"localhost"``, times ``=`` ``2L``)``,`\
`  ``## Launch Rscript inside Linux container via Docker`\
`  rscript ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"udocker"``, ``"--quiet"``, ``"run"``, ``"rocker/r-ver:4.6.1"``,`\
`    ``"Rscript"`\
`  ``)`\
`)`\
[`print`](https://rdrr.io/r/base/print.html)`(``cl``)`\
`#> Socket cluster with 2 nodes on host 'localhost' (R version 4.6.1`\
`#> (2026-06-24), platform x86_64-pc-linux-gnu)`
