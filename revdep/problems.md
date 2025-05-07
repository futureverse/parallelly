# adea

<details>

* Version: 1.5.2
* GitHub: NA
* Source code: https://github.com/cran/adea
* Date/Publication: 2024-11-12 18:00:02 UTC
* Number of recursive dependencies: 54

Run `revdepcheck::revdep_details(, "adea")` for more info

</details>

## In both

*   checking package dependencies ... ERROR
    ```
    Package required but not available: ‘ROI.plugin.symphony’
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# apsimx

<details>

* Version: 2.8.235
* GitHub: https://github.com/femiguez/apsimx
* Source code: https://github.com/cran/apsimx
* Date/Publication: 2025-03-10 05:40:02 UTC
* Number of recursive dependencies: 185

Run `revdepcheck::revdep_details(, "apsimx")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  7.7Mb
      sub-directories of 1Mb or more:
        R         1.5Mb
        extdata   5.4Mb
    ```

# bigDM

<details>

* Version: 0.5.6
* GitHub: https://github.com/spatialstatisticsupna/bigDM
* Source code: https://github.com/cran/bigDM
* Date/Publication: 2025-03-25 09:30:06 UTC
* Number of recursive dependencies: 134

Run `revdepcheck::revdep_details(, "bigDM")` for more info

</details>

## Newly broken

*   checking installed package size ... NOTE
    ```
      installed size is  8.9Mb
      sub-directories of 1Mb or more:
        data   8.5Mb
    ```

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘INLA’
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 940 marked Latin-1 strings
    ```

# bootUR

<details>

* Version: 1.0.4
* GitHub: https://github.com/smeekes/bootUR
* Source code: https://github.com/cran/bootUR
* Date/Publication: 2024-05-20 09:30:02 UTC
* Number of recursive dependencies: 66

Run `revdepcheck::revdep_details(, "bootUR")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  6.7Mb
      sub-directories of 1Mb or more:
        libs   6.2Mb
    ```

*   checking for GNU extensions in Makefiles ... NOTE
    ```
    GNU make is a SystemRequirements.
    ```

# breathteststan

<details>

* Version: 0.8.9
* GitHub: https://github.com/dmenne/breathteststan
* Source code: https://github.com/cran/breathteststan
* Date/Publication: 2025-01-08 09:00:07 UTC
* Number of recursive dependencies: 151

Run `revdepcheck::revdep_details(, "breathteststan")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 64.1Mb
      sub-directories of 1Mb or more:
        libs  63.7Mb
    ```

*   checking for GNU extensions in Makefiles ... NOTE
    ```
    GNU make is a SystemRequirements.
    ```

# COTAN

<details>

* Version: 2.6.3
* GitHub: https://github.com/seriph78/COTAN
* Source code: https://github.com/cran/COTAN
* Date/Publication: 2025-02-27
* Number of recursive dependencies: 270

Run `revdepcheck::revdep_details(, "COTAN")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 13.7Mb
      sub-directories of 1Mb or more:
        doc  11.8Mb
    ```

*   checking dependencies in R code ... NOTE
    ```
    'library' or 'require' call to ‘torch’ in package code.
      Please use :: or requireNamespace() instead.
      See section 'Suggested packages' in the 'Writing R Extensions' manual.
    Unexported object imported by a ':::' call: ‘ggplot2:::ggname’
      See the note in ?`:::` about the use of this operator.
    ```

*   checking R code for possible problems ... NOTE
    ```
    mergeUniformCellsClusters : fromMergedName: warning in
      vapply(currentClNames, function(clName, mergedName) {: partial
      argument match of 'FUN.VAL' to 'FUN.VALUE'
    mergeUniformCellsClusters : fromMergedName: warning in
      return(str_detect(mergedName, clName)): partial argument match of
      'FUN.VAL' to 'FUN.VALUE'
    mergeUniformCellsClusters : fromMergedName: warning in }, FUN.VAL =
      logical(1L), mergedClName): partial argument match of 'FUN.VAL' to
      'FUN.VALUE'
    ECDPlot: no visible binding for global variable ‘.’
    ...
      ‘clusterData’
    Undefined global functions or variables:
      . .x CellNumber Cluster Condition ExpGenes GCS GDI PC PC1 PC2 UDEPLot
      Variance a bGroupGenesPlot cl1 cl2 clName1 clName2 clusterData
      clusters coex condName conditions expectedN expectedNN expectedNY
      expectedYN expectedYY g2 group hk keys lambda means mit.percentage n
      nu nuPlot obj objSeurat observedNN observedNY observedY observedYN
      observedYY pcaCellsPlot permMap rankGenes rawNorm secondaryMarkers
      sum.raw.norm type types useTorch usedMaxResolution values violinwidth
      width x xmax xmaxv xminv y zoomedNuPlot
    ```

# dataquieR

<details>

* Version: 2.5.1
* GitHub: NA
* Source code: https://github.com/cran/dataquieR
* Date/Publication: 2025-03-05 18:10:02 UTC
* Number of recursive dependencies: 197

Run `revdepcheck::revdep_details(, "dataquieR")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.7Mb
      sub-directories of 1Mb or more:
        R      3.5Mb
        help   1.6Mb
    ```

# decoupleR

<details>

* Version: 2.12.0
* GitHub: https://github.com/saezlab/decoupleR
* Source code: https://github.com/cran/decoupleR
* Date/Publication: 2024-10-29
* Number of recursive dependencies: 266

Run `revdepcheck::revdep_details(, "decoupleR")` for more info

</details>

## Newly broken

*   checking re-building of vignette outputs ...sh: line 1: 1743062 Terminated              '/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/bin/R' --vanilla --no-echo > '/scratch/henrik/revdep/parallelly/checks/decoupleR/new/decoupleR.Rcheck/build_vignettes.log' 2>&1 < '/scratch/henrik/631165/Rtmp3hdHnW/file1a68ac5dd866f8'
    ```
     ERROR
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘decoupleR.Rmd’ using rmarkdown
    --- finished re-building ‘decoupleR.Rmd’
    
    sh: line 1: 1743399 Terminated              '/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/bin/R' --vanilla --no-echo > '/scratch/henrik/631165/RtmpTHlg8Y/file1a98d6360dd9' 2>&1 < '/scratch/henrik/631165/RtmpTHlg8Y/file1a98d6533cf8f9'
    --- re-building ‘pw_bk.Rmd’ using rmarkdown
    [2025-05-05 23:24:00] [WARN]    [OmnipathR] HTTP 504
    [2025-05-05 23:24:00] [WARN]    [OmnipathR] Failed to download `https://www.ensembl.org/info/about/species.html` (attempt 1/3); error: HTTP 504
    --- re-building ‘pw_sc.Rmd’ using rmarkdown
    ```

## Newly fixed

*   checking re-building of vignette outputs ...sh: line 1: 1743038 Terminated              '/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/bin/R' --vanilla --no-echo > '/scratch/henrik/revdep/parallelly/checks/decoupleR/old/decoupleR.Rcheck/build_vignettes.log' 2>&1 < '/scratch/henrik/631165/RtmpQkfoGv/file1a68745894f7d3'
    ```
     ERROR
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘decoupleR.Rmd’ using rmarkdown
    --- finished re-building ‘decoupleR.Rmd’
    
    ```

## In both

*   checking examples ... ERROR
    ```
    Running examples in ‘decoupleR-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: get_collectri
    > ### Title: CollecTRI gene regulatory network. Wrapper to access CollecTRI
    > ###   gene regulatory network. CollecTRI is a comprehensive resource
    > ###   containing a curated collection of transcription factors (TFs) and
    > ###   their target genes. It is an expansion of DoRothEA. Each interaction
    > ###   is weighted by its mode of regulation (either positive or negative).
    > ### Aliases: get_collectri
    ...
    [2025-05-05 22:58:53] [WARN]    [OmnipathR] Failed to download `https://www.ensembl.org/info/about/species.html` (attempt 1/3); error: HTTP 504
    [2025-05-05 22:59:59] [WARN]    [OmnipathR] HTTP 504
    [2025-05-05 22:59:59] [WARN]    [OmnipathR] Failed to download `https://www.ensembl.org/info/about/species.html` (attempt 2/3); error: HTTP 504
    [2025-05-05 23:01:35] [WARN]    [OmnipathR] HTTP 504
    [2025-05-05 23:01:35] [ERROR]   [OmnipathR] Failed to download `https://www.ensembl.org/info/about/species.html` (attempt 3/3); error: HTTP 504
    [2025-05-05 23:01:35] [WARN]    [OmnipathR] Accessing `collectri` as a static table: this is not the recommended way to access OmniPath data; it is only a backup plan for situations when our server or your computer is experiencing issues.
    Error in if (.keep) . else select(., -!!evs_col) : 
      argument is of length zero
    Calls: get_collectri ... tidyselect_data_has_predicates -> unnest_evidences -> %>%
    Execution halted
    ```

*   checking tests ...
    ```
      Running ‘testthat.R’/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/bin/BATCH: line 60: 1742522 Terminated              ${R_HOME}/bin/R -f ${in} ${opts} ${R_BATCH_OPTIONS} > ${out} 2>&1
    
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 50 lines of output:
        |===================================                                   |  50%
        |                                                                            
        |======================================================================| 100%
      
      
    ...
      [2025-05-05 23:16:28] [WARN]    [OmnipathR] HTTP 504
      [2025-05-05 23:16:28] [WARN]    [OmnipathR] Failed to download `https://www.ensembl.org/info/about/species.html` (attempt 2/3); error: HTTP 504
      [2025-05-05 23:18:29] [WARN]    [OmnipathR] HTTP 504
      [2025-05-05 23:18:29] [ERROR]   [OmnipathR] Failed to download `https://www.ensembl.org/info/about/species.html` (attempt 3/3); error: HTTP 504
      [2025-05-05 23:18:29] [WARN]    [OmnipathR] Accessing `PROGENy` as a static table: this is not the recommended way to access OmniPath data; it is only a backup plan for situations when our server or your computer is experiencing issues.
      [2025-05-05 23:18:31] [SUCCESS] [OmnipathR] Loaded 700239 annotation records from cache.
      [2025-05-05 23:19:37] [WARN]    [OmnipathR] HTTP 504
      [2025-05-05 23:19:37] [WARN]    [OmnipathR] Failed to download `https://www.ensembl.org/info/about/species.html` (attempt 1/3); error: HTTP 504
      [2025-05-05 23:21:12] [WARN]    [OmnipathR] HTTP 504
      [2025-05-05 23:21:12] [WARN]    [OmnipathR] Failed to download `https://www.ensembl.org/info/about/species.html` (attempt 2/3); error: HTTP 504
    ```

*   checking Rd cross-references ... WARNING
    ```
    Missing link or links in Rd file 'run_gsva.Rd':
      ‘GSVA::gsva’ ‘GeneSetCollection’
    
    See section 'Cross-references' in the 'Writing R Extensions' manual.
    ```

*   checking installed package size ... NOTE
    ```
      installed size is  9.1Mb
      sub-directories of 1Mb or more:
        doc       6.9Mb
        extdata   1.4Mb
    ```

# desla

<details>

* Version: 0.3.0
* GitHub: https://github.com/RobertAdamek/desla
* Source code: https://github.com/cran/desla
* Date/Publication: 2023-06-29 11:50:06 UTC
* Number of recursive dependencies: 33

Run `revdepcheck::revdep_details(, "desla")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  7.5Mb
      sub-directories of 1Mb or more:
        libs   7.3Mb
    ```

# gastempt

<details>

* Version: 0.7.0
* GitHub: https://github.com/dmenne/gastempt
* Source code: https://github.com/cran/gastempt
* Date/Publication: 2024-12-20 07:50:02 UTC
* Number of recursive dependencies: 107

Run `revdepcheck::revdep_details(, "gastempt")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 176.3Mb
      sub-directories of 1Mb or more:
        libs  175.8Mb
    ```

*   checking for GNU extensions in Makefiles ... NOTE
    ```
    GNU make is a SystemRequirements.
    ```

# greta

<details>

* Version: 0.5.0
* GitHub: https://github.com/greta-dev/greta
* Source code: https://github.com/cran/greta
* Date/Publication: 2024-11-12 06:40:02 UTC
* Number of recursive dependencies: 144

Run `revdepcheck::revdep_details(, "greta")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.1Mb
      sub-directories of 1Mb or more:
        R   3.5Mb
    ```

# gtfstools

<details>

* Version: 1.4.0
* GitHub: https://github.com/ipeaGIT/gtfstools
* Source code: https://github.com/cran/gtfstools
* Date/Publication: 2025-01-09 00:40:02 UTC
* Number of recursive dependencies: 88

Run `revdepcheck::revdep_details(, "gtfstools")` for more info

</details>

## In both

*   checking Rd cross-references ... NOTE
    ```
    Package unavailable to check Rd xrefs: ‘tidytransit’
    ```

# InPAS

<details>

* Version: 2.14.1
* GitHub: NA
* Source code: https://github.com/cran/InPAS
* Date/Publication: 2024-12-23
* Number of recursive dependencies: 164

Run `revdepcheck::revdep_details(, "InPAS")` for more info

</details>

## In both

*   checking Rd cross-references ... WARNING
    ```
    Missing link or links in Rd file 'get_ssRleCov.Rd':
      ‘[BSgenome:BSgenomeForge]{BSgenome::forgeBSgenomeDataPkg()}’
    
    Missing link or links in Rd file 'set_globals.Rd':
      ‘[BSgenome:BSgenomeForge]{BSgenome::forgeBSgenomeDataPkg()}’
    
    See section 'Cross-references' in the 'Writing R Extensions' manual.
    ```

*   checking installed package size ... NOTE
    ```
      installed size is  5.5Mb
      sub-directories of 1Mb or more:
        R      1.5Mb
        data   2.1Mb
    ```

*   checking dependencies in R code ... NOTE
    ```
    There are ::: calls to the package's namespace in its code. A package
      almost never needs to use ::: for its own objects:
      ‘adjust_distalCPs’ ‘adjust_proximalCPs’ ‘adjust_proximalCPsByNBC’
      ‘adjust_proximalCPsByPWM’ ‘calculate_mse’ ‘find_valleyBySpline’
      ‘get_PAscore’ ‘get_PAscore2’ ‘remove_convergentUTR3s’
      ‘search_distalCPs’ ‘search_proximalCPs’
    ```

*   checking Rd \usage sections ... NOTE
    ```
    Documented arguments not in \usage in Rd file 'get_UTR3TotalCov.Rd':
      ‘gcCompensationensation’
    
    Functions with \usage entries need to have the appropriate \alias
    entries, and all their arguments documented.
    The \usage entries must correspond to syntactically valid R code.
    See chapter ‘Writing R documentation files’ in the ‘Writing R
    Extensions’ manual.
    ```

# JMbayes2

<details>

* Version: 0.5-2
* GitHub: https://github.com/drizopoulos/JMbayes2
* Source code: https://github.com/cran/JMbayes2
* Date/Publication: 2025-02-28 06:10:01 UTC
* Number of recursive dependencies: 75

Run `revdepcheck::revdep_details(, "JMbayes2")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 13.0Mb
      sub-directories of 1Mb or more:
        libs  12.2Mb
    ```

# mappp

<details>

* Version: 1.0.0
* GitHub: https://github.com/cole-brokamp/mappp
* Source code: https://github.com/cran/mappp
* Date/Publication: 2022-01-25 09:22:42 UTC
* Number of recursive dependencies: 35

Run `revdepcheck::revdep_details(, "mappp")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘pbmcapply’
      All declared Imports should be used.
    ```

# mice

<details>

* Version: 3.17.0
* GitHub: https://github.com/amices/mice
* Source code: https://github.com/cran/mice
* Date/Publication: 2024-11-27 18:00:02 UTC
* Number of recursive dependencies: 133

Run `revdepcheck::revdep_details(, "mice")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.3Mb
      sub-directories of 1Mb or more:
        help   1.5Mb
        libs   2.9Mb
    ```

# mlr3

<details>

* Version: 0.23.0
* GitHub: https://github.com/mlr-org/mlr3
* Source code: https://github.com/cran/mlr3
* Date/Publication: 2025-03-12 12:30:02 UTC
* Number of recursive dependencies: 49

Run `revdepcheck::revdep_details(, "mlr3")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  6.0Mb
      sub-directories of 1Mb or more:
        R      3.5Mb
        help   1.7Mb
    ```

*   checking Rd cross-references ... NOTE
    ```
    Package unavailable to check Rd xrefs: ‘mlr3oml’
    ```

# mmrm

<details>

* Version: 0.3.14
* GitHub: https://github.com/openpharma/mmrm
* Source code: https://github.com/cran/mmrm
* Date/Publication: 2024-09-27 23:30:01 UTC
* Number of recursive dependencies: 175

Run `revdepcheck::revdep_details(, "mmrm")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 188.6Mb
      sub-directories of 1Mb or more:
        libs  186.8Mb
    ```

# NCC

<details>

* Version: 1.0
* GitHub: https://github.com/pavlakrotka/NCC
* Source code: https://github.com/cran/NCC
* Date/Publication: 2023-03-03 09:10:10 UTC
* Number of recursive dependencies: 117

Run `revdepcheck::revdep_details(, "NCC")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘magick’
      All declared Imports should be used.
    ```

# nebula

<details>

* Version: 1.5.3
* GitHub: https://github.com/lhe17/nebula
* Source code: https://github.com/cran/nebula
* Date/Publication: 2024-02-15 23:00:02 UTC
* Number of recursive dependencies: 170

Run `revdepcheck::revdep_details(, "nebula")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 35.4Mb
      sub-directories of 1Mb or more:
        libs  33.7Mb
    ```

# outliers.ts.oga

<details>

* Version: 1.0.1
* GitHub: NA
* Source code: https://github.com/cran/outliers.ts.oga
* Date/Publication: 2025-02-27 09:50:02 UTC
* Number of recursive dependencies: 156

Run `revdepcheck::revdep_details(, "outliers.ts.oga")` for more info

</details>

## In both

*   checking whether package ‘outliers.ts.oga’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      Warning: no DISPLAY variable so Tk is not available
    See ‘/scratch/henrik/revdep/parallelly/checks/outliers.ts.oga/new/outliers.ts.oga.Rcheck/00install.out’ for details.
    ```

# pmartR

<details>

* Version: 2.5.0
* GitHub: https://github.com/pmartR/pmartR
* Source code: https://github.com/cran/pmartR
* Date/Publication: 2025-04-23 18:00:02 UTC
* Number of recursive dependencies: 145

Run `revdepcheck::revdep_details(, "pmartR")` for more info

</details>

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘pmartRdata’
    ```

*   checking installed package size ... NOTE
    ```
      installed size is 12.0Mb
      sub-directories of 1Mb or more:
        R      1.5Mb
        help   1.5Mb
        libs   7.9Mb
    ```

# QDNAseq

<details>

* Version: 1.42.0
* GitHub: https://github.com/ccagc/QDNAseq
* Source code: https://github.com/cran/QDNAseq
* Date/Publication: 2024-10-29
* Number of recursive dependencies: 94

Run `revdepcheck::revdep_details(, "QDNAseq")` for more info

</details>

## In both

*   checking re-building of vignette outputs ... WARNING
    ```
    Error(s) in re-building vignettes:
    --- re-building ‘QDNAseq.Rnw’ using Sweave
    EM algorithm started ... 
    
    Warning in allprior/tot :
      Recycling array of length 1 in vector-array arithmetic is deprecated.
      Use c() or as.vector() instead.
    Warning in allprior/tot :
      Recycling array of length 1 in vector-array arithmetic is deprecated.
      Use c() or as.vector() instead.
    ...
    l.197 \RequirePackage
                         {parnotes}^^M
    !  ==> Fatal error occurred, no output PDF file produced!
    --- failed re-building ‘QDNAseq.Rnw’
    
    SUMMARY: processing the following file failed:
      ‘QDNAseq.Rnw’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

# qtl2pleio

<details>

* Version: 1.4.3
* GitHub: https://github.com/fboehm/qtl2pleio
* Source code: https://github.com/cran/qtl2pleio
* Date/Publication: 2020-12-02 22:50:02 UTC
* Number of recursive dependencies: 127

Run `revdepcheck::revdep_details(, "qtl2pleio")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 36.9Mb
      sub-directories of 1Mb or more:
        libs  36.6Mb
    ```

*   checking LazyData ... NOTE
    ```
      'LazyData' is specified without a 'data' directory
    ```

# ResIN

<details>

* Version: 2.0.0
* GitHub: https://github.com/pwarncke77/ResIN
* Source code: https://github.com/cran/ResIN
* Date/Publication: 2024-10-04 10:40:03 UTC
* Number of recursive dependencies: 110

Run `revdepcheck::revdep_details(, "ResIN")` for more info

</details>

## In both

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 1 marked UTF-8 string
    ```

# rivnet

<details>

* Version: 0.6.0
* GitHub: https://github.com/lucarraro/rivnet
* Source code: https://github.com/cran/rivnet
* Date/Publication: 2025-02-12 13:20:02 UTC
* Number of recursive dependencies: 134

Run `revdepcheck::revdep_details(, "rivnet")` for more info

</details>

## In both

*   checking whether package ‘rivnet’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/scratch/henrik/revdep/parallelly/checks/rivnet/new/rivnet.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘rivnet’ ...
** package ‘rivnet’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘g++ (GCC) 13.3.1 20240611 (Red Hat 13.3.1-2)’
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c RcppExports.cpp -o RcppExports.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c init_perm_rev.cpp -o init_perm_rev.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c path_vel.cpp -o path_vel.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c riverweight_src.cpp -o riverweight_src.o
g++ -std=gnu++17 -shared -L/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/lib -L/usr/local/lib64 -o rivnet.so RcppExports.o init_perm_rev.o path_vel.o riverweight_src.o -L/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/lib -lR
...
** R
** data
** inst
** byte-compile and prepare package for lazy loading
Error in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]) : 
  there is no package called ‘adespatial’
Calls: <Anonymous> ... loadNamespace -> withRestarts -> withOneRestart -> doWithOneRestart
Execution halted
ERROR: lazy loading failed for package ‘rivnet’
* removing ‘/scratch/henrik/revdep/parallelly/checks/rivnet/new/rivnet.Rcheck/rivnet’


```
### CRAN

```
* installing *source* package ‘rivnet’ ...
** package ‘rivnet’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘g++ (GCC) 13.3.1 20240611 (Red Hat 13.3.1-2)’
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c RcppExports.cpp -o RcppExports.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c init_perm_rev.cpp -o init_perm_rev.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c path_vel.cpp -o path_vel.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c riverweight_src.cpp -o riverweight_src.o
g++ -std=gnu++17 -shared -L/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/lib -L/usr/local/lib64 -o rivnet.so RcppExports.o init_perm_rev.o path_vel.o riverweight_src.o -L/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/lib -lR
...
** R
** data
** inst
** byte-compile and prepare package for lazy loading
Error in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]) : 
  there is no package called ‘adespatial’
Calls: <Anonymous> ... loadNamespace -> withRestarts -> withOneRestart -> doWithOneRestart
Execution halted
ERROR: lazy loading failed for package ‘rivnet’
* removing ‘/scratch/henrik/revdep/parallelly/checks/rivnet/old/rivnet.Rcheck/rivnet’


```
# SCDB

<details>

* Version: 0.5.1
* GitHub: https://github.com/ssi-dk/SCDB
* Source code: https://github.com/cran/SCDB
* Date/Publication: 2025-02-27 12:50:02 UTC
* Number of recursive dependencies: 162

Run `revdepcheck::revdep_details(, "SCDB")` for more info

</details>

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘RPostgres’
    ```

*   checking Rd cross-references ... NOTE
    ```
    Package unavailable to check Rd xrefs: ‘RPostgres’
    ```

# scruff

<details>

* Version: 1.24.0
* GitHub: https://github.com/campbio/scruff
* Source code: https://github.com/cran/scruff
* Date/Publication: 2024-10-29
* Number of recursive dependencies: 179

Run `revdepcheck::revdep_details(, "scruff")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.2Mb
      sub-directories of 1Mb or more:
        data   2.4Mb
        doc    1.7Mb
    ```

*   checking DESCRIPTION meta-information ... NOTE
    ```
    License stub is invalid DCF.
    ```

*   checking dependencies in R code ... NOTE
    ```
    Unexported object imported by a ':::' call: 'ShortRead:::.set_omp_threads'
      See the note in ?`:::` about the use of this operator.
    ```

*   checking foreign function calls ... NOTE
    ```
    Foreign function call to a different package:
      .Call(ShortRead:::.set_omp_threads, ...)
    See chapter ‘System and foreign language interfaces’ in the ‘Writing R
    Extensions’ manual.
    ```

*   checking R code for possible problems ... NOTE
    ```
    .plotFracProteinCodingGenes: no visible binding for global variable
      'genes'
    .plotGenes: no visible binding for global variable 'genes'
    .plotGenesPerMillionReads: no visible binding for global variable
      'genes'
    Undefined global functions or variables:
      genes
    ```

# SimDesign

<details>

* Version: 2.19.2
* GitHub: https://github.com/philchalmers/SimDesign
* Source code: https://github.com/cran/SimDesign
* Date/Publication: 2025-03-28 15:30:02 UTC
* Number of recursive dependencies: 136

Run `revdepcheck::revdep_details(, "SimDesign")` for more info

</details>

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘FrF2’
    ```

*   checking installed package size ... NOTE
    ```
      installed size is  7.5Mb
      sub-directories of 1Mb or more:
        doc   6.6Mb
    ```

# streetscape

<details>

* Version: 1.0.5
* GitHub: NA
* Source code: https://github.com/cran/streetscape
* Date/Publication: 2025-01-21 14:50:03 UTC
* Number of recursive dependencies: 137

Run `revdepcheck::revdep_details(, "streetscape")` for more info

</details>

## In both

*   checking whether package ‘streetscape’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      Warning: namespace ‘colorspace’ is not available and has been replaced
    See ‘/scratch/henrik/revdep/parallelly/checks/streetscape/new/streetscape.Rcheck/00install.out’ for details.
    ```

*   checking data for ASCII and uncompressed saves ... WARNING
    ```
      code for methods in class “Rcpp_SpatCategories” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatCategories” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatDataFrame” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatDataFrame” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatExtent” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatExtent” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatFactor” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatFactor” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatMessages” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatMessages” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    ...
      code for methods in class “Rcpp_SpPoly” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPoly” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPolyPart” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPolyPart” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPolygons” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPolygons” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      Warning: namespace ‘colorspace’ is not available and has been replaced
      by .GlobalEnv when processing object ‘scdataframe’
      Warning: namespace ‘colorspace’ is not available and has been replaced
      by .GlobalEnv when processing object ‘scdataframe’
    ```

*   checking whether startup messages can be suppressed ... NOTE
    ```
    code for methods in class “Rcpp_SpatCategories” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatCategories” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatDataFrame” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatDataFrame” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatExtent” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatExtent” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatFactor” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatFactor” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatMessages” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpatMessages” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    ...
    code for methods in class “Rcpp_SpExtent” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpPoly” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpPoly” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpPolyPart” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpPolyPart” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpPolygons” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    code for methods in class “Rcpp_SpPolygons” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
    
    It looks like this package (or a package it requires) has a startup
    message which cannot be suppressed: see ?packageStartupMessage.
    ```

# targets

<details>

* Version: 1.11.1
* GitHub: https://github.com/ropensci/targets
* Source code: https://github.com/cran/targets
* Date/Publication: 2025-04-10 21:10:02 UTC
* Number of recursive dependencies: 156

Run `revdepcheck::revdep_details(, "targets")` for more info

</details>

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘crew’
    ```

*   checking installed package size ... NOTE
    ```
      installed size is  5.5Mb
      sub-directories of 1Mb or more:
        R      3.5Mb
        help   1.7Mb
    ```

*   checking Rd cross-references ... NOTE
    ```
    Package unavailable to check Rd xrefs: ‘qs’
    ```

# TDApplied

<details>

* Version: 3.0.4
* GitHub: https://github.com/shaelebrown/TDApplied
* Source code: https://github.com/cran/TDApplied
* Date/Publication: 2024-10-29 08:30:02 UTC
* Number of recursive dependencies: 82

Run `revdepcheck::revdep_details(, "TDApplied")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 13.0Mb
      sub-directories of 1Mb or more:
        doc    8.2Mb
        libs   4.4Mb
    ```

