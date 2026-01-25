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

*   checking whether package ‘adea’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/c4/home/henrik/futureverse/parallelly/revdep/checks/adea/new/adea.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘adea’ ...
** this is package ‘adea’ version ‘1.5.2’
** package ‘adea’ successfully unpacked and MD5 sums checked
** using staged installation
** R
** data
** demo
** inst
** byte-compile and prepare package for lazy loading
Error: package or namespace load failed for ‘ROI.plugin.symphony’ in loadNamespace(i, c(lib.loc, .libPaths()), versionCheck = vI[[i]]):
 there is no package called ‘Rsymphony’
Execution halted
ERROR: lazy loading failed for package ‘adea’
* removing ‘/c4/home/henrik/futureverse/parallelly/revdep/checks/adea/new/adea.Rcheck/adea’


```
### CRAN

```
* installing *source* package ‘adea’ ...
** this is package ‘adea’ version ‘1.5.2’
** package ‘adea’ successfully unpacked and MD5 sums checked
** using staged installation
** R
** data
** demo
** inst
** byte-compile and prepare package for lazy loading
Error: package or namespace load failed for ‘ROI.plugin.symphony’ in loadNamespace(i, c(lib.loc, .libPaths()), versionCheck = vI[[i]]):
 there is no package called ‘Rsymphony’
Execution halted
ERROR: lazy loading failed for package ‘adea’
* removing ‘/c4/home/henrik/futureverse/parallelly/revdep/checks/adea/old/adea.Rcheck/adea’


```
# ctsem

<details>

* Version: 3.10.5
* GitHub: https://github.com/cdriveraus/ctsem
* Source code: https://github.com/cran/ctsem
* Date/Publication: 2026-01-20 06:10:27 UTC
* Number of recursive dependencies: 170

Run `revdepcheck::revdep_details(, "ctsem")` for more info

</details>

## In both

*   checking whether package ‘ctsem’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      Warning: namespace ‘colorspace’ is not available and has been replaced
    See ‘/c4/home/henrik/futureverse/parallelly/revdep/checks/ctsem/new/ctsem.Rcheck/00install.out’ for details.
    ```

*   checking re-building of vignette outputs ... WARNING
    ```
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘hierarchicalmanual.rnw’ using knitr_notangle
    Warning in texi2dvi(file = file, pdf = TRUE, clean = clean, quiet = quiet,  :
      texi2dvi script/program not available, using emulation
    Error: processing vignette 'hierarchicalmanual.rnw' failed with diagnostics:
    unable to run pdflatex on 'hierarchicalmanual.tex'
    LaTeX errors:
    ! LaTeX Error: File `apacite.sty' not found.
    
    ...
    l.62 \bibliographystyle
                           {apacite}     % Set bibliography style^^M
    !  ==> Fatal error occurred, no output PDF file produced!
    --- failed re-building ‘hierarchicalmanual.rnw’
    
    SUMMARY: processing the following file failed:
      ‘hierarchicalmanual.rnw’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

# decoupleR

<details>

* Version: 2.16.0
* GitHub: https://github.com/saezlab/decoupleR
* Source code: https://github.com/cran/decoupleR
* Date/Publication: 2025-10-29
* Number of recursive dependencies: 265

Run `revdepcheck::revdep_details(, "decoupleR")` for more info

</details>

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
    > 
    > ### ** Examples
    > 
    > collectri <- get_collectri(organism='human', split_complexes=FALSE)
    [2026-01-25 14:20:16] [WARN]    [OmnipathR] Accessing `collectri` as a static table: this is not the recommended way to access OmniPath data; it is only a backup plan for situations when our server or your computer is experiencing issues.
    Error in if (.keep) . else select(., -!!evs_col) : 
      argument is of length zero
    Calls: get_collectri ... tidyselect_data_has_predicates -> unnest_evidences -> %>%
    Execution halted
    ```

*   checking tests ...
    ```
      Running ‘testthat.R’
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 50 lines of output:
       26. │ ├─col %in% colnames(data)
       27. │ └─base::colnames(data)
       28. │   └─base::is.data.frame(x)
       29. ├─OmnipathR::filter_evidences(...)
       30. │ └─expr(...) %>% eval_select(data) %>% names %>% ...
       31. ├─OmnipathR:::if_null_len0(...)
    ...
       26. │ └─value %>% ...
       27. ├─tidyselect::eval_select(., data)
       28. │ └─tidyselect::tidyselect_data_has_predicates(data)
       29. └─OmnipathR::unnest_evidences(., .keep = .keep)
       30.   └─... %>% ...
      
      [ FAIL 5 | WARN 11 | SKIP 0 | PASS 29 ]
      Error:
      ! Test failures.
      Execution halted
    ```

*   checking re-building of vignette outputs ... ERROR
    ```
    Error(s) in re-building vignettes:
    --- re-building ‘decoupleR.Rmd’ using rmarkdown
    --- finished re-building ‘decoupleR.Rmd’
    
    --- re-building ‘pw_bk.Rmd’ using rmarkdown
    [2026-01-25 14:28:09] [WARN]    [OmnipathR] Accessing `PROGENy` as a static table: this is not the recommended way to access OmniPath data; it is only a backup plan for situations when our server or your computer is experiencing issues.
    [2026-01-25 14:28:14] [SUCCESS] [OmnipathR] Loaded 700239 annotation records from cache.
    Warning: ggrepel: 445 unlabeled data points (too many overlaps). Consider increasing max.overlaps
    [WARNING] Could not fetch resource https://decoupler-py.readthedocs.io/en/1.4.0/_images/mlm.png: HttpExceptionRequest Request {
        host                 = "decoupler-py.readthedocs.io"
    ...
    
    Error: processing vignette 'tf_sc.Rmd' failed with diagnostics:
    argument is of length zero
    --- failed re-building ‘tf_sc.Rmd’
    
    SUMMARY: processing the following files failed:
      ‘tf_bk.Rmd’ ‘tf_sc.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

*   checking Rd cross-references ... WARNING
    ```
    Missing link(s) in Rd file 'run_gsva.Rd':
      ‘GSVA::gsva’ ‘GeneSetCollection’
    
    See section 'Cross-references' in the 'Writing R Extensions' manual.
    ```

# fmeffects

<details>

* Version: 0.1.4
* GitHub: https://github.com/holgstr/fmeffects
* Source code: https://github.com/cran/fmeffects
* Date/Publication: 2024-11-05 18:50:02 UTC
* Number of recursive dependencies: 182

Run `revdepcheck::revdep_details(, "fmeffects")` for more info

</details>

## In both

*   checking re-building of vignette outputs ... ERROR
    ```
    Error(s) in re-building vignettes:
    --- re-building ‘fme_theory.Rmd’ using rmarkdown
    [WARNING] Deprecated: --highlight-style. Use --syntax-highlighting instead.
    --- finished re-building ‘fme_theory.Rmd’
    
    --- re-building ‘fmeffects.Rmd’ using rmarkdown
    
    Quitting from fmeffects.Rmd:121-127 [unnamed-chunk-11]
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    <error/purrr_error_indexed>
    ...
    ℹ In index: 1.
    Caused by error in `.__Task__col_roles()`:
    ! Assertion on 'names(rhs)' failed: Names must be a permutation of set {'feature','target','name','order','stratum','group','offset','weights_learner','weights_measure'}, but has extra elements {'always_included'}.
    --- failed re-building ‘fmeffects.Rmd’
    
    SUMMARY: processing the following file failed:
      ‘fmeffects.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

# geocodebr

<details>

* Version: 0.6.0
* GitHub: https://github.com/ipeaGIT/geocodebr
* Source code: https://github.com/cran/geocodebr
* Date/Publication: 2026-01-23 19:10:02 UTC
* Number of recursive dependencies: 102

Run `revdepcheck::revdep_details(, "geocodebr")` for more info

</details>

## In both

*   checking package dependencies ... ERROR
    ```
    Package required but not available: ‘enderecobr’
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# InPAS

<details>

* Version: 2.18.1
* GitHub: NA
* Source code: https://github.com/cran/InPAS
* Date/Publication: 2025-11-25
* Number of recursive dependencies: 164

Run `revdepcheck::revdep_details(, "InPAS")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    There are ::: calls to the package's namespace in its code. A package
      almost never needs to use ::: for its own objects:
      ‘adjust_distalCPs’ ‘adjust_proximalCPs’ ‘adjust_proximalCPsByNBC’
      ‘adjust_proximalCPsByPWM’ ‘calculate_mse’ ‘find_valleyBySpline’
      ‘get_PAscore’ ‘get_PAscore2’ ‘remove_convergentUTR3s’
      ‘search_distalCPs’ ‘search_proximalCPs’
    ```

*   checking Rd metadata ... NOTE
    ```
    Invalid package aliases in Rd file 'InPAS.Rd':
      ‘-package’
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

# iscream

<details>

* Version: 1.0.0
* GitHub: https://github.com/huishenlab/iscream
* Source code: https://github.com/cran/iscream
* Date/Publication: 2025-10-29
* Number of recursive dependencies: 147

Run `revdepcheck::revdep_details(, "iscream")` for more info

</details>

## In both

*   checking tests ...
    ```
      Running ‘testthat.R’
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 50 lines of output:
      0%   10   20   30   40   50   60   70   80   90   100%
      [----|----|----|----|----|----|----|----|----|----|
      **************************************************|
      0%   10   20   30   40   50   60   70   80   90   100%
      [----|----|----|----|----|----|----|----|----|----|
      **************************************************|
    ...
       12. │       └─parallelly:::call_slurm_show_hostname(nodelist)
       13. │         └─parallelly:::stop_if_not(file_test("-x", bin))
       14. │           └─parallelly:::stopf(...)
       15. │             └─base::stop(cond)
       16. └─base (local) `<fn>`(`<smplErrr>`)
      
      [ FAIL 1 | WARN 0 | SKIP 2 | PASS 352 ]
      Error:
      ! Test failures.
      Execution halted
    ```

# lidR

<details>

* Version: 4.2.3
* GitHub: https://github.com/r-lidar/lidR
* Source code: https://github.com/cran/lidR
* Date/Publication: 2026-01-08 09:10:02 UTC
* Number of recursive dependencies: 153

Run `revdepcheck::revdep_details(, "lidR")` for more info

</details>

## In both

*   checking tests ...
    ```
      Running ‘testthat.R’/software/c4/cbi/software/_rocky8/R-4.5.2-gcc13/lib64/R/bin/BATCH: line 60: 3183535 Aborted                 (core dumped) ${R_HOME}/bin/R -f ${in} ${opts} ${R_BATCH_OPTIONS} > ${out} 2>&1
    
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 50 lines of output:
                                                                                      
      
                                                                                      
      
                                                                                      
    ...
      
                                                                                      
      
                                                                                      
      
                                                                                      
      
                                                                                      
      terminate called after throwing an instance of 'std::length_error'
        what():  basic_string::_M_create
    ```

# mappp

<details>

* Version: 1.0.0
* GitHub: https://github.com/cole-brokamp/mappp
* Source code: https://github.com/cran/mappp
* Date/Publication: 2022-01-25 09:22:42 UTC
* Number of recursive dependencies: 34

Run `revdepcheck::revdep_details(, "mappp")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘pbmcapply’
      All declared Imports should be used.
    ```

# NCC

<details>

* Version: 1.0
* GitHub: https://github.com/pavlakrotka/NCC
* Source code: https://github.com/cran/NCC
* Date/Publication: 2023-03-03 09:10:10 UTC
* Number of recursive dependencies: 116

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

* Version: 1.1.1
* GitHub: NA
* Source code: https://github.com/cran/outliers.ts.oga
* Date/Publication: 2025-09-03 14:50:02 UTC
* Number of recursive dependencies: 155

Run `revdepcheck::revdep_details(, "outliers.ts.oga")` for more info

</details>

## In both

*   checking whether package ‘outliers.ts.oga’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      Warning: no DISPLAY variable so Tk is not available
    See ‘/c4/home/henrik/futureverse/parallelly/revdep/checks/outliers.ts.oga/new/outliers.ts.oga.Rcheck/00install.out’ for details.
    ```

# proffer

<details>

* Version: 0.2.2
* GitHub: https://github.com/r-prof/proffer
* Source code: https://github.com/cran/proffer
* Date/Publication: 2024-11-15 16:00:02 UTC
* Number of recursive dependencies: 36

Run `revdepcheck::revdep_details(, "proffer")` for more info

</details>

## In both

*   checking package dependencies ... ERROR
    ```
    Package required but not available: ‘RProtoBuf’
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# QDNAseq

<details>

* Version: 1.46.0
* GitHub: https://github.com/ccagc/QDNAseq
* Source code: https://github.com/cran/QDNAseq
* Date/Publication: 2025-10-29
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

* Version: 1.28.0
* GitHub: https://github.com/campbio/scruff
* Source code: https://github.com/cran/scruff
* Date/Publication: 2025-10-29
* Number of recursive dependencies: 173

Run `revdepcheck::revdep_details(, "scruff")` for more info

</details>

## In both

*   checking DESCRIPTION meta-information ... NOTE
    ```
    License stub is invalid DCF.
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: 'patchwork'
      All declared Imports should be used.
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
* Number of recursive dependencies: 131

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

# targets

<details>

* Version: 1.11.4
* GitHub: https://github.com/ropensci/targets
* Source code: https://github.com/cran/targets
* Date/Publication: 2025-09-13 05:10:02 UTC
* Number of recursive dependencies: 156

Run `revdepcheck::revdep_details(, "targets")` for more info

</details>

## In both

*   checking Rd cross-references ... NOTE
    ```
    Unknown package ‘qs’ in Rd xrefs
    ```

