# Parallel Workers Running in a Sandbox

## Introduction

This vignette shows how to set up “sandboxed” parallel workers with
limited access to the host system.

## Examples

### Example: Bubblewrap on Linux

This example sets up two parallel workers on Linux sandboxed using
[Bubblewrap](https://github.com/containers/bubblewrap).

\
[`library`](https://rdrr.io/r/base/library.html)`(`[`parallelly`](https://parallelly.futureverse.org)`)`\
\
`bwrap_sandbox`` ``<-`` ``function``(``rscript`` ``=`` ``"*"``)`` ``{`\
`  ``ro_binds`` ``<-`` ``function``(``dirs``)`` ``{`\
`    ``dirs`` ``<-`` `[`unique`](https://rdrr.io/r/base/unique.html)`(``dirs``[`[`file_test`](https://rdrr.io/r/utils/filetest.html)`(``"-d"``, ``dirs``)``]``)`\
`    ``opts`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``dirs``, each ``=`` ``3L``)`\
`    ``opts``[`[`seq`](https://rdrr.io/r/base/seq.html)`(``from ``=`` ``1``, to ``=`` `[`length`](https://rdrr.io/r/base/length.html)`(``opts``)``, by ``=`` ``3``)``]`` ``<-`` ``"--ro-bind"`\
`    ``opts`\
`  ``}`\
\
`  ``ro_rlibs_remap`` ``<-`` ``function``(``dirs`` ``=`` `[`rev`](https://rdrr.io/r/base/rev.html)`(`[`rev`](https://rdrr.io/r/base/rev.html)`(`[`.libPaths`](https://rdrr.io/r/base/libPaths.html)`(``)``)``[``-``1``]``)``)`` ``{`\
`    ``dirs`` ``<-`` `[`unique`](https://rdrr.io/r/base/unique.html)`(``dirs``[`[`file_test`](https://rdrr.io/r/utils/filetest.html)`(``"-d"``, ``dirs``)``]``)`\
`    ``dirs2`` ``<-`` `[`sub`](https://rdrr.io/r/base/grep.html)`(`[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"^%s"``, `[`Sys.getenv`](https://rdrr.io/r/base/Sys.getenv.html)`(``"HOME"``)``)``, ``"/home/sandbox-user"``, ``dirs``)`\
`    ``opts`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``dirs``, each ``=`` ``3L``)`\
`    ``opts``[`[`seq`](https://rdrr.io/r/base/seq.html)`(``from ``=`` ``1``, to ``=`` `[`length`](https://rdrr.io/r/base/length.html)`(``opts``)``, by ``=`` ``3``)``]`` ``<-`` ``"--ro-bind"`\
`    ``opts``[`[`seq`](https://rdrr.io/r/base/seq.html)`(``from ``=`` ``3``, to ``=`` `[`length`](https://rdrr.io/r/base/length.html)`(``opts``)``, by ``=`` ``3``)``]`` ``<-`` ``dirs2`\
`    ``opts`\
`  ``}`\
\
`  ``args`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"bwrap"``)`\
`  `\
`  ``## Unshares`\
`  ``## Note, we cannot sandbox the network (--unshare-net), because`\
`  ``## PSOCK clusters communicate over socket connections`\
`  ``unshares`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"--unshare-user"``,  ``# isolate user and group ids`\
`    ``"--unshare-pid"``,   ``# isolate processes`\
`    ``"--proc"``, ``"/proc"``,`\
`    ``"--unshare-ipc"``    ``# isolate process communication, e.g. shared memory`\
`  ``)`\
`  ``args`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``args``, ``unshares``)`\
`  `\
`  ``## Misc options`\
`  ``opts`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"--dev"``, ``"/dev"``,   ``# mount host's /dev`\
`    ``"--tmpfs"``, ``"/tmp"``  ``# mount fresh, private, empty temporary directory`\
`  ``)`\
`  ``args`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``args``, ``opts``)`\
`  `\
`  ``## Read-only Linux mounts`\
`  ``dirs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"/usr"``, ``"/bin"``, ``"/usr/bin"``, ``"/lib"``, ``"/lib64"``, ``"/etc/alternatives"``)`\
\
`  ``## Use host's R and Rscript (by read-only mounting R home folders)`\
`  ``components`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"bin"``, ``"lib"``, ``"doc"``, ``"etc"``, ``"include"``, ``"modules"``, ``"share"``)`\
`  ``r_dirs`` ``<-`` `[`unname`](https://rdrr.io/r/base/unname.html)`(`[`vapply`](https://rdrr.io/r/base/lapply.html)`(``components``, FUN ``=`` ``R.home``, FUN.VALUE ``=`` ``NA_character_``)``)`\
`  ``r_dirs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``r_dirs``, `[`dirname`](https://rdrr.io/r/base/basename.html)`(`[`Sys.which`](https://rdrr.io/r/base/Sys.which.html)`(``"R"``)``)``, `[`dirname`](https://rdrr.io/r/base/basename.html)`(`[`Sys.which`](https://rdrr.io/r/base/Sys.which.html)`(``"Rscript"``)``)``)`\
`  ``r_dirs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``r_dirs``, `[`rev`](https://rdrr.io/r/base/rev.html)`(`[`.libPaths`](https://rdrr.io/r/base/libPaths.html)`(``)``)``[``1``]``)`\
`  ``dirs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``dirs``, ``r_dirs``)`\
`  ``args`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``args``, ``ro_binds``(``dirs``)``)`\
\
`  ``## Remap HOME to fresh, private sandboxed HOME`\
`  ``tmp_home`` ``<-`` `[`tempfile`](https://rdrr.io/r/base/tempfile.html)`(``pattern ``=`` ``"sandbox-home-"``)`\
`  `[`dir.create`](https://rdrr.io/r/base/files2.html)`(``tmp_home``)`\
`  ``opts`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`\
`    ``"--bind"``, ``tmp_home``, ``"/home/sandbox-user"``,`\
`    ``"--setenv"``, ``"HOME"``, ``"/home/sandbox-user"``,`\
`    ``"--chdir"``, ``"/home/sandbox-user"`\
`  ``)`\
`  ``args`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``args``, ``opts``)`\
\
`  ``## Read-only remapped non-system R library paths`\
`  ``args`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``args``, ``ro_rlibs_remap``(``)``)`\
\
`  `[`c`](https://rdrr.io/r/base/c.html)`(``args``, ``rscript``)`\
`}`` ``## bwrap_sandbox()`\
\
\
`## Launch two parallel workers inside a Bubblewrap sandbox`\
`cl`` ``<-`` `[`makeClusterPSOCK`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)`(``2L``, rscript ``=`` ``bwrap_sandbox``(``"*"``)``)`\
[`print`](https://rdrr.io/r/base/print.html)`(``cl``)`\
`#> Socket cluster with 2 nodes on host 'localhost' (R version 4.6.1`\
`#> (2026-06-24), platform x86_64-pc-linux-gnu)`\
\
`host_user`` ``<-`` `[`Sys.info`](https://rdrr.io/r/base/Sys.info.html)`(``)``[[``"user"``]``]`\
`host_user`\
`#> "alice"`\
\
`worker_user`` ``<-`` `[`unlist`](https://rdrr.io/r/base/unlist.html)`(``parallel``::`[`clusterEvalQ`](https://rdrr.io/r/parallel/clusterApply.html)`(``cl``, `[`Sys.info`](https://rdrr.io/r/base/Sys.info.html)`(``)``[[``"user"``]``]``)``)`\
`worker_user`\
`#> [1] "unknown" "unknown"`
