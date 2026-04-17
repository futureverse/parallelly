<!--
%\VignetteIndexEntry{Parallel Workers Running MS Windows via Wine}
%\VignetteAuthor{Henrik Bengtsson}
%\VignetteKeyword{R}
%\VignetteKeyword{package}
%\VignetteKeyword{vignette}
%\VignetteEngine{parallelly::selfonly}
-->


# Introduction

This vignette shows how to set up parallel workers running R for MS
Windows via Wine (https://www.winehq.org/) on Linux and macOS. This
can be useful when we need to run R code or call R packages that work
only on MS Windows.

The below instructions assume that you already have Wine installed.


## Install R for MS Windows 11

To install R for MS Windows in Wine, first configure Wine to use
Windows 11;

```sh
$ winecfg /v win11
$ winecfg /v
win11
```

Then, install [R for Windows] in Wine, by:

```sh
$ wget https://cran.r-project.org/bin/windows/base/R-4.5.2-win.exe
$ wine R-4.5.2-win.exe /SILENT
```

Finally, verify that R is available in Wine;

```sh
$ wine "C:/Program Files/R/R-4.5.2/bin/x64/Rscript.exe" --version
...
Rscript (R) version 4.5.2 (2025-10-31)
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
    "LC_ALL=en_US.UTF-8",
    ## Don't pass LC_* and R_LIBS* environments from host to Wine
    sprintf("%s=", grep("^(LC_|R_LIBS)", names(Sys.getenv()), value = TRUE)),
    "wine",
    "C:/Program Files/R/R-4.5.2/bin/x64/Rscript.exe"
  )
)
print(cl)
#> Socket cluster with 1 node on host 'localhost'
#> (R version 4.5.2 (2025-10-31 ucrt), platform x86_64-w64-mingw32)
```


## Example: Installing packages in Wine

We can install R packages as usual, e.g.

```r
void <- parallel::clusterEvalQ(cl[1], { 
  chooseCRANmirror(ind = 1L) 
  install.packages("future")
})
```


# Appendix

## Using a personal package library in Wine

When using Wine, the system package library - the last one reported by
`.libPaths()` - is owned by the users that installed R in Wine. This
means that is _not_ write protected for most users and any package can
be installed there.

Sometimes its preferred to install packages to a personal package
library. To do this, all we have to do is pre-create the personal
package library in Wine. This can be done as:

```r
void <- parallel::clusterEvalQ(cl[1], { 
  dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE) 
})
```

To validate that the personal package library exists, _restart the
cluster_. Then call:

```r
parallel::clusterEvalQ(cl[1], { .libPaths() })[[1]]
[1] "C:/users/alice/AppData/Local/R/win-library/4.5"
[2] "C:/PROG~FBU/R/R-45~RZJ.2/library"
```

The first directory is the personal package library.


## Wine and R warnings

It might be that Wine produces warnings like:

```plain
0128:fixme:font:find_matching_face Untranslated charset 255
```

and R for Windows produces a warning on:

```plain
During startup - Warning message:
Using locale code page other than 65001 ("UTF-8") may cause problems.
```

These are typically harmless. Environment variable setting
`WINEDEBUG=fixme-all` should take care of the first one, and
`LC_ALL=en_US.UTF-8` the second one.


## Windows-only CRAN packages 

A small number of the CRAN packages install only on MS Windows. Here
is how to see which they are:

```r
db <- read.dcf(url("https://cran.r-project.org/src/contrib/PACKAGES"))
db <- as.data.frame(db)
win_only <- subset(db, OS_type == "windows")
print(win_only$Package)
```

As of 2026-03-03, this outputs:

```r
 [1] "BiplotGUI"         "blatr"             "excel.link"
 [4] "KeyboardSimulator" "MDSGUI"            "MediaNews"
 [7] "R2PPT"             "R2wd"              "rFUSION"
[10] "RWinEdt"           "spectrino"         "taskscheduleR"
```

[R for Windows]: https://cran.r-project.org/bin/windows/base/
[Winetricks]: https://github.com/Winetricks/winetricks
