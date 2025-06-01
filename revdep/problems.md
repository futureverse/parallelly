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

# bbw

<details>

* Version: 0.3.0
* GitHub: https://github.com/rapidsurveys/bbw
* Source code: https://github.com/cran/bbw
* Date/Publication: 2025-01-16 09:00:06 UTC
* Number of recursive dependencies: 112

Run `revdepcheck::revdep_details(, "bbw")` for more info

</details>

## In both

*   checking DESCRIPTION meta-information ... NOTE
    ```
      Missing dependency on R >= 4.2.0 because package code uses the pipe
      placeholder syntax added in R 4.2.0.
      File(s) using such syntax:
        ‘boot_bw.R’ ‘boot_bw_estimate.R’ ‘post_strat_estimation.R’
    ```

# COTAN

<details>

* Version: 2.8.1
* GitHub: https://github.com/seriph78/COTAN
* Source code: https://github.com/cran/COTAN
* Date/Publication: 2025-04-30
* Number of recursive dependencies: 269

Run `revdepcheck::revdep_details(, "COTAN")` for more info

</details>

## In both

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
    GDIPlot: no visible binding for global variable ‘sum.raw.norm’
    ...
    heatmapPlot: no visible binding for global variable ‘coex’
    mitochondrialPercentagePlot: no visible binding for global variable
      ‘mit.percentage’
    scatterPlot: no visible binding for global variable ‘.x’
    screePlot: no visible binding for global variable ‘PC’
    screePlot: no visible binding for global variable ‘Variance’
    Undefined global functions or variables:
      .x CellNumber Cluster Condition ExpGenes GDI PC PC1 PC2 Variance coex
      g2 group keys means mit.percentage n nu obj sum.raw.norm type types
      values violinwidth width x xmax xmaxv xminv y
    ```

# decoupleR

<details>

* Version: 2.14.0
* GitHub: https://github.com/saezlab/decoupleR
* Source code: https://github.com/cran/decoupleR
* Date/Publication: 2025-04-15
* Number of recursive dependencies: 266

Run `revdepcheck::revdep_details(, "decoupleR")` for more info

</details>

## In both

*   checking tests ...
    ```
      Running ‘testthat.R’
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 50 lines of output:
       17. ├─... %>% ...
       18. ├─OmnipathR::translate_ids(., uniprot, genesymbol, organism = organism)
       19. ├─OmnipathR::orthology_translate_column(...)
       20. │ ├─... %>% ...
       21. │ └─OmnipathR::get_db(db_name, param = orthology_param)
       22. │   └─OmnipathR::load_db(key, param = param)
    ...
       59. │ └─from_cache %<>% if_null(data %>% is_from_cache)
       60. ├─OmnipathR:::if_null(., data %>% is_from_cache)
       61. │ └─value1 %>% is.null %>% if (value2) value1
       62. ├─data %>% is_from_cache
       63. └─OmnipathR:::is_from_cache(.)
       64.   └─obj %>% attr("origin") %>% ...
      
      [ FAIL 1 | WARN 18 | SKIP 0 | PASS 34 ]
      Error: Test failures
      Execution halted
    ```

*   checking Rd cross-references ... WARNING
    ```
    Missing link(s) in Rd file 'run_gsva.Rd':
      ‘GSVA::gsva’ ‘GeneSetCollection’
    
    See section 'Cross-references' in the 'Writing R Extensions' manual.
    ```

# InPAS

<details>

* Version: 2.16.0
* GitHub: NA
* Source code: https://github.com/cran/InPAS
* Date/Publication: 2025-04-15
* Number of recursive dependencies: 163

Run `revdepcheck::revdep_details(, "InPAS")` for more info

</details>

## In both

*   checking Rd cross-references ... WARNING
    ```
    Missing link(s) in Rd file 'get_ssRleCov.Rd':
      ‘[BSgenome:BSgenomeForge]{BSgenome::forgeBSgenomeDataPkg()}’
    
    Missing link(s) in Rd file 'set_globals.Rd':
      ‘[BSgenome:BSgenomeForge]{BSgenome::forgeBSgenomeDataPkg()}’
    
    See section 'Cross-references' in the 'Writing R Extensions' manual.
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

*   checking DESCRIPTION meta-information ... NOTE
    ```
      Missing dependency on R >= 4.1.0 because package code uses the pipe
      |> or function shorthand \(...) syntax added in R 4.1.0.
      File(s) using such syntax:
        ‘interop-car.R’ ‘mmrm_tidiers.Rd’
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

# QDNAseq

<details>

* Version: 1.44.0
* GitHub: https://github.com/ccagc/QDNAseq
* Source code: https://github.com/cran/QDNAseq
* Date/Publication: 2025-04-15
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

# scruff

<details>

* Version: 1.26.0
* GitHub: https://github.com/campbio/scruff
* Source code: https://github.com/cran/scruff
* Date/Publication: 2025-04-15
* Number of recursive dependencies: 178

Run `revdepcheck::revdep_details(, "scruff")` for more info

</details>

## In both

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

# streetscape

<details>

* Version: 1.0.5
* GitHub: NA
* Source code: https://github.com/cran/streetscape
* Date/Publication: 2025-01-21 14:50:03 UTC
* Number of recursive dependencies: 138

Run `revdepcheck::revdep_details(, "streetscape")` for more info

</details>

## In both

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
      code for methods in class “Rcpp_SpatVectorProxy” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpatVectorProxy” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpExtent” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpExtent” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPoly” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPoly” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPolyPart” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPolyPart” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPolygons” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
      code for methods in class “Rcpp_SpPolygons” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
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

