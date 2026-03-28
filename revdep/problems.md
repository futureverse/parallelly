# adea (1.5.2)

* Email: <mailto:manuel.munoz@uca.es>
* GitHub mirror: <https://github.com/cran/adea>

Run `revdepcheck::revdep_details(, "adea")` for more info

## In both

*   checking whether package ‘adea’ can be installed ... ERROR
     ```
     Installation failed.
     See ‘/scratch/henrik/revdep/parallelly/checks/adea/new/adea.Rcheck/00install.out’ for details.
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
* removing ‘/scratch/henrik/revdep/parallelly/checks/adea/new/adea.Rcheck/adea’


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
* removing ‘/scratch/henrik/revdep/parallelly/checks/adea/old/adea.Rcheck/adea’


```
# ctsem (3.10.6)

* GitHub: <https://github.com/cdriveraus/ctsem>
* Email: <mailto:charles.driver2@uzh.ch>
* GitHub mirror: <https://github.com/cran/ctsem>

Run `revdepcheck::revdep_details(, "ctsem")` for more info

## In both

*   checking whether package ‘ctsem’ can be installed ... WARNING
     ```
     Found the following significant warnings:
       Warning: namespace ‘colorspace’ is not available and has been replaced
     See ‘/scratch/henrik/revdep/parallelly/checks/ctsem/new/ctsem.Rcheck/00install.out’ for details.
     ```

*   checking re-building of vignette outputs ... WARNING
     ```
     ...
       ...
     --- re-building ‘hierarchicalmanual.rnw’ using knitr_notangle
     Warning in texi2dvi(file = file, pdf = TRUE, clean = clean, quiet = quiet,  :
       texi2dvi script/program not available, using emulation
     Error: processing vignette 'hierarchicalmanual.rnw' failed with diagnostics:
     unable to run pdflatex on 'hierarchicalmanual.tex'
     LaTeX errors:
     ! LaTeX Error: File `apacite.sty' not found.
     
     Type X to quit or <RETURN> to proceed,
     or enter new name. (Default extension: sty)
     
     ! Emergency stop.
     <read *> 
              
     l.62 \bibliographystyle
                            {apacite}     % Set bibliography style^^M
     !  ==> Fatal error occurred, no output PDF file produced!
     --- failed re-building ‘hierarchicalmanual.rnw’
     
     SUMMARY: processing the following file failed:
       ‘hierarchicalmanual.rnw’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# decoupleR (2.16.0)

* GitHub: <https://github.com/saezlab/decoupleR>
* Email: <mailto:pau.badia@uni-heidelberg.de>

Run `revdepcheck::revdep_details(, "decoupleR")` for more info

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
     [2026-03-27 17:38:45] [WARN]    [OmnipathR] Accessing `collectri` as a static table: this is not the recommended way to access OmniPath data; it is only a backup plan for situations when our server or your computer is experiencing issues.
     Error in if (.keep) . else select(., -!!evs_col) : 
       argument is of length zero
     Calls: get_collectri ... tidyselect_data_has_predicates -> unnest_evidences -> %>%
     Execution halted
     ```

*   checking tests ...
     ```
     ...
        11. │ └─... %>% ...
        12. ├─dplyr::filter(., if_any(EVIDENCES_KEYS, ~not(map_lgl(.x, is.null))))
        13. ├─OmnipathR::from_evidences(., .keep = .keep)
        14. │ └─OmnipathR:::must_have_evidences(data, wide_ok = TRUE)
        15. │   └─OmnipathR:::has_evidences(data, wide_ok = wide_ok)
        16. │     └─data %>% has_column("evidences") %>% ...
        17. ├─OmnipathR:::has_column(., "evidences")
        18. │ ├─col %in% colnames(data)
        19. │ └─base::colnames(data)
        20. │   └─base::is.data.frame(x)
        21. ├─OmnipathR::filter_evidences(...)
        22. │ └─expr(...) %>% eval_select(data) %>% names %>% ...
        23. ├─OmnipathR:::if_null_len0(...)
        24. │ └─value1 %>% is_empty_2 %>% if (value2) value1
        25. ├─OmnipathR:::is_empty_2(.)
        26. │ └─value %>% ...
        27. ├─tidyselect::eval_select(., data)
        28. │ └─tidyselect::tidyselect_data_has_predicates(data)
        29. └─OmnipathR::unnest_evidences(., .keep = .keep)
        30.   └─... %>% ...
       
       [ FAIL 5 | WARN 7 | SKIP 0 | PASS 29 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
      17. ├─OmnipathR:::has_column(., "evidences")
      18. │ ├─col %in% colnames(data)
      19. │ └─base::colnames(data)
      20. │   └─base::is.data.frame(x)
      21. ├─OmnipathR::filter_evidences(...)
      22. │ └─expr(...) %>% eval_select(data) %>% names %>% ...
      23. ├─OmnipathR:::if_null_len0(...)
      24. │ └─value1 %>% is_empty_2 %>% if (value2) value1
      25. ├─OmnipathR:::is_empty_2(.)
      26. │ └─value %>% ...
      27. ├─tidyselect::eval_select(., data)
      28. │ └─tidyselect::tidyselect_data_has_predicates(data)
      29. └─OmnipathR::unnest_evidences(., .keep = .keep)
      30.   └─... %>% ...
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
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

# fmeffects (0.1.4)

* GitHub: <https://github.com/holgstr/fmeffects>
* Email: <mailto:hbj.loewe@gmail.com>
* GitHub mirror: <https://github.com/cran/fmeffects>

Run `revdepcheck::revdep_details(, "fmeffects")` for more info

## In both

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
      50. │                   └─fmeffects (local) simpson(prediction.s, subintervals)
      51. │                     └─fmeffects (local) f(0/s + m)
      52. │                       └─predictor$predict(observation.t)
      53. │                         ├─data.table::as.data.table(self$model$predict_newdata(newdata))
      54. │                         └─self$model$predict_newdata(newdata)
      55. │                           └─mlr3:::.__Learner__predict_newdata(...)
      56. └─mlr3 (local) `<fn>`(base::quote(`<named list>`))
      57.   └─mlr3:::.__Task__col_roles(...)
      58.     └─checkmate::assert_names(names(rhs), "unique", permutation.of = mlr_reflections$task_col_roles[[self$task_type]])
      59.       └─checkmate::makeAssertion(x, res, .var.name, add)
      60.         └─checkmate:::mstop(...)
      61.           └─base::stop(simpleError(sprintf(msg, ...), call.))
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'fmeffects.Rmd' failed with diagnostics:
     ℹ In index: 1.
     Caused by error in `.__Task__col_roles()`:
     ! Assertion on 'names(rhs)' failed: Names must be a permutation of set {'feature','target','name','order','stratum','group','offset','weights_learner','weights_measure'}, but has extra elements {'always_included'}.
     --- failed re-building ‘fmeffects.Rmd’
     
     SUMMARY: processing the following file failed:
       ‘fmeffects.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# InPAS (2.18.1)

* Email: <mailto:jou@morgridge.org>

Run `revdepcheck::revdep_details(, "InPAS")` for more info

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

# ldaPrototype (0.3.2)

* GitHub: <https://github.com/JonasRieger/ldaPrototype>
* Email: <mailto:jonas.rieger@tu-dortmund.de>
* GitHub mirror: <https://github.com/cran/ldaPrototype>

Run `revdepcheck::revdep_details(, "ldaPrototype")` for more info

## In both

*   checking tests ...
     ```
     ...
        1. └─ldaPrototype::LDARep(...) at test_mergeTopics.R:6:1
        2.   ├─base::suppressWarnings(parallelMap::parallelExport("docs", "vocab"))
        3.   │ └─base::withCallingHandlers(...)
        4.   └─parallelMap::parallelExport("docs", "vocab")
        5.     └─parallelMap:::exportToSlavePkgParallel(n, get(n, envir = sys.parent()))
        6.       └─parallel::clusterCall(...)
        7.         └─parallel:::defaultCluster(cl)
       ── Error ('test_rboTopics.R:6:1'): (code run outside of `test_that()`) ─────────
       Error in `defaultCluster(cl)`: no cluster 'cl' supplied and none is registered
       Backtrace:
           ▆
        1. ├─ldaPrototype::mergeTopics(...) at test_rboTopics.R:6:1
        2. └─ldaPrototype::LDARep(...)
        3.   ├─base::suppressWarnings(parallelMap::parallelExport("docs", "vocab"))
        4.   │ └─base::withCallingHandlers(...)
        5.   └─parallelMap::parallelExport("docs", "vocab")
        6.     └─parallelMap:::exportToSlavePkgParallel(n, get(n, envir = sys.parent()))
        7.       └─parallel::clusterCall(...)
        8.         └─parallel:::defaultCluster(cl)
       
       [ FAIL 8 | WARN 0 | SKIP 0 | PASS 132 ]
       Error:
       ! Test failures.
       There were 50 or more warnings (use warnings() to see the first 50)
       Execution halted
     ```

# lidR (4.2.3)

* GitHub: <https://github.com/r-lidar/lidR>
* Email: <mailto:info@r-lidar.com>
* GitHub mirror: <https://github.com/cran/lidR>

Run `revdepcheck::revdep_details(, "lidR")` for more info

## In both

*   checking tests ...
     ```
     ...
       
                                                                                       
       
                                                                                       
       
                                                                                       
       
                                                                                       
       
                                                                                       
       
                                                                                       
       Chunk 1 of 1 (100%): state ✓
       
                                                                                       
       
                                                                                       
       
                                                                                       
       
                                                                                       
       
                                                                                       
       terminate called after throwing an instance of 'std::length_error'
         what():  basic_string::_M_create
     ```

# mappp (1.0.0)

* GitHub: <https://github.com/cole-brokamp/mappp>
* Email: <mailto:cole.brokamp@gmail.com>
* GitHub mirror: <https://github.com/cran/mappp>

Run `revdepcheck::revdep_details(, "mappp")` for more info

## In both

*   checking dependencies in R code ... NOTE
     ```
     Namespace in Imports field not imported from: ‘pbmcapply’
       All declared Imports should be used.
     ```

# NCC (1.0)

* GitHub: <https://github.com/pavlakrotka/NCC>
* Email: <mailto:pavla.krotka@meduniwien.ac.at>
* GitHub mirror: <https://github.com/cran/NCC>

Run `revdepcheck::revdep_details(, "NCC")` for more info

## In both

*   checking dependencies in R code ... NOTE
     ```
     Namespace in Imports field not imported from: ‘magick’
       All declared Imports should be used.
     ```

# QDNAseq (1.46.0)

* GitHub: <https://github.com/ccagc/QDNAseq>
* Email: <mailto:d.sie@vumc.nl>

Run `revdepcheck::revdep_details(, "QDNAseq")` for more info

## In both

*   checking re-building of vignette outputs ... WARNING
     ```
     ...
     Total time:0minutes
     
     Warning in texi2dvi(file = file, pdf = TRUE, clean = clean, quiet = quiet,  :
       texi2dvi script/program not available, using emulation
     Error: processing vignette 'QDNAseq.Rnw' failed with diagnostics:
     unable to run pdflatex on 'QDNAseq.tex'
     LaTeX errors:
     ! LaTeX Error: File `nowidow.sty' not found.
     
     Type X to quit or <RETURN> to proceed,
     or enter new name. (Default extension: sty)
     
     ! Emergency stop.
     <read *> 
              
     l.197 \RequirePackage
                          {parnotes}^^M
     !  ==> Fatal error occurred, no output PDF file produced!
     --- failed re-building ‘QDNAseq.Rnw’
     
     SUMMARY: processing the following file failed:
       ‘QDNAseq.Rnw’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# scruff (1.28.0)

* GitHub: <https://github.com/campbio/scruff>
* Email: <mailto:zhe@bu.edu>

Run `revdepcheck::revdep_details(, "scruff")` for more info

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

# streetscape (1.0.5)

* Email: <mailto:xiaohaoy@umich.edu>
* GitHub mirror: <https://github.com/cran/streetscape>

Run `revdepcheck::revdep_details(, "streetscape")` for more info

## In both

*   checking data for ASCII and uncompressed saves ... WARNING
     ```
     ...
       code for methods in class “Rcpp_SpatOptions” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatRaster” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatRaster” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatRasterCollection” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatRasterCollection” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatRasterStack” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatRasterStack” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatSRS” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatSRS” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatTime_v” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatTime_v” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatVector” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatVector” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatVectorCollection” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
       code for methods in class “Rcpp_SpatVectorCollection” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
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
     ...
     code for methods in class “Rcpp_SpatRasterCollection” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatRasterCollection” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatRasterStack” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatRasterStack” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatSRS” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatSRS” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatTime_v” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatTime_v” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatVector” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatVector” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatVectorCollection” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_SpatVectorCollection” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
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
     
     It looks like this package (or a package it requires) has a startup
     message which cannot be suppressed: see ?packageStartupMessage.
     ```

# targets (1.12.0)

* GitHub: <https://github.com/ropensci/targets>
* Email: <mailto:will.landau.oss@gmail.com>
* GitHub mirror: <https://github.com/cran/targets>

Run `revdepcheck::revdep_details(, "targets")` for more info

## In both

*   checking examples ... ERROR
     ```
     Running examples in ‘targets-Ex.R’ failed
     The error most likely occurred in:
     
     > ### Name: tar_renv
     > ### Title: Set up package dependencies for compatibility with 'renv'
     > ### Aliases: tar_renv
     > 
     > ### ** Examples
     > 
     > tar_dir({ # tar_dir() runs code from a temp dir for CRAN.
     +   tar_script({
     +     library(targets)
     +     library(tarchetypes)
     +     tar_option_set(packages = c("tibble", "qs"))
     +     list()
     +   }, ask = FALSE)
     +   tar_renv()
     +   writeLines(readLines("_targets_packages.R"))
     + })
     Error:
     ! Error in tar_renv():
       there is no package called ‘tarchetypes’
       See https://books.ropensci.org/targets/debugging.html
     Execution halted
     ```

# WeightedCluster (2.0)

* Email: <mailto:matthias.studer@unige.ch>
* GitHub mirror: <https://github.com/cran/WeightedCluster>

Run `revdepcheck::revdep_details(, "WeightedCluster")` for more info

## In both

*   checking re-building of vignette outputs ... WARNING
     ```
     ...
     
     --- re-building ‘WeightedClusterPreview.Rnw’ using knitr
     Warning in texi2dvi(file = file, pdf = TRUE, clean = clean, quiet = quiet,  :
       texi2dvi script/program not available, using emulation
     Error: processing vignette 'WeightedClusterPreview.Rnw' failed with diagnostics:
     unable to run pdflatex on 'WeightedClusterPreview.tex'
     LaTeX errors:
     ! LaTeX Error: File `textpos.sty' not found.
     
     Type X to quit or <RETURN> to proceed,
     or enter new name. (Default extension: sty)
     
     ! Emergency stop.
     <read *> 
              
     l.85 \usepackage
                     {tikz}^^M
     !  ==> Fatal error occurred, no output PDF file produced!
     --- failed re-building ‘WeightedClusterPreview.Rnw’
     
     SUMMARY: processing the following files failed:
       ‘WeightedClusterFR.Rnw’ ‘WeightedClusterPreview.Rnw’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

