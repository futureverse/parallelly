<!--
%\VignetteIndexEntry{Parallel Workers Running MS Windows via Wine}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

This vignette shows how to set up parallel workers running on MS
Windows via Wine (<https://www.winehq.org/>) on Linux and macOS.

## Install R for MS Windows 10

To install R for MS Windows in Wine, first configure Wine to use
Windows 10;

```sh
$ winecfg
```

In the GUI, set 'Windows version' to 'Windows 10'. Then, install R for
Windows in Wine, by:

```sh
$ wget https://cran.r-project.org/bin/windows/base/R-4.4.2-win.exe
$ wine R-4.4.2-win.exe /SILENT
```

Finally, verify that R is available in Wine;

```sh
$ wine "C:/Program Files/R/R-4.4.2/bin/x64/Rscript.exe" --version
...
Rscript (R) version 4.4.2 (2024-10-31)
```


# Examples

## Example: Parallel workers running MS Windows via Wine

This example shows how to launch one worker running in Wine for Linux
on the local machine.

```r
cl <- makeClusterPSOCK(
  1L,
  rscript = c(
    ## Silence Wine warnings
    "WINEDEBUG=fixme-all",
    ## Don't pass LC_* and R_LIBS* environments from host to Wine
    sprintf("%s=", grep("^(LC_|R_LIBS)", names(Sys.getenv()), value = TRUE)),
    "wine",
    "C:/Program Files/R/R-4.4.2/bin/x64/Rscript.exe"
  )
)
print(cl)
#> Socket cluster with 1 nodes where 1 node is on host 'localhost'
#> (R version 4.4.2 (2024-10-31 ucrt), platform x86_64-w64-mingw32)
```
