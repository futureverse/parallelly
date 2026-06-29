# caretSDM (1.8.3)

* GitHub: <https://github.com/luizesser/caretSDM>
* Email: <mailto:luizesser@gmail.com>
* GitHub mirror: <https://github.com/cran/caretSDM>

Run `revdepcheck::revdep_details(, "caretSDM")` for more info

## In both

*   checking examples ... ERROR
     ```
     ...
     Warning in CPL_write_gdal(mat, file, driver, options, type, dims, from,  :
       GDAL Error 1: PROJ: proj_as_wkt: DatumEnsemble can only be exported to WKT2:2019
     Warning in CPL_write_gdal(mat, file, driver, options, type, dims, from,  :
       GDAL Error 1: PROJ: proj_as_wkt: DatumEnsemble can only be exported to WKT2:2019
     Warning in CPL_gdalwarp(source, destination, options, oo, doo, config_options,  :
       GDAL Error 1: Cannot compute bounding box of cutline. Cannot find source SRS
     Error in `value[[3L]]()`:
     ✖ GDAL warp failed.
     In index: 1.
     Backtrace:
          ▆
       1. ├─caretSDM::add_predictors(sa, bioc)
       2. └─caretSDM:::add_predictors.stars(sa, bioc) at caretSDM/R/add_predictors.R:83:3
       3.   └─caretSDM:::.add_predictors(...) at caretSDM/R/add_predictors.R:109:3
       4.     ├─caretSDM::sdm_area(...) at caretSDM/R/add_predictors.R:123:3
       5.     └─caretSDM:::sdm_area.stars(...) at caretSDM/R/sdm_area.R:126:3
       6.       ├─dplyr::select(...) at caretSDM/R/sdm_area.R:288:5
       7.       └─caretSDM:::.sdm_area_from_stars_using_gdal(...) at caretSDM/R/sdm_area.R:288:5
       8.         └─base::tryCatch(...) at caretSDM/R/sdm_area.R:530:3
       9.           └─base (local) tryCatchList(expr, classes, parentenv, handlers)
      10.             └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
      11.               └─value[[3L]](cond)
      12.                 └─cli::cli_abort(c(x = "GDAL warp failed.", i = e$message)) at caretSDM/R/sdm_area.R:579:7
      13.                   └─rlang::abort(...)
     Execution halted
     ```

*   checking tests ...
     ```
     ...
         9.             └─cli::cli_abort(c(x = "GDAL warp failed.", i = e$message)) at caretSDM/R/sdm_area.R:579:7
        10.               └─rlang::abort(...)
       ── Error ('test-train_sdm.R:4:3'): (code run outside of `test_that()`) ─────────
       Error in `value[[3L]](cond)`: x GDAL warp failed.
       In index: 1.
       Backtrace:
            ▆
         1. ├─caretSDM::add_predictors(sa, bioc) at test-train_sdm.R:4:3
         2. └─caretSDM:::add_predictors.stars(sa, bioc) at caretSDM/R/add_predictors.R:83:3
         3.   └─caretSDM:::.add_predictors(...) at caretSDM/R/add_predictors.R:109:3
         4.     ├─caretSDM::sdm_area(...) at caretSDM/R/add_predictors.R:123:3
         5.     └─caretSDM:::sdm_area.stars(...) at caretSDM/R/sdm_area.R:126:3
         6.       ├─dplyr::select(...) at caretSDM/R/sdm_area.R:288:5
         7.       └─caretSDM:::.sdm_area_from_stars_using_gdal(...) at caretSDM/R/sdm_area.R:288:5
         8.         └─base::tryCatch(...) at caretSDM/R/sdm_area.R:530:3
         9.           └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        10.             └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        11.               └─value[[3L]](cond)
        12.                 └─cli::cli_abort(c(x = "GDAL warp failed.", i = e$message)) at caretSDM/R/sdm_area.R:579:7
        13.                   └─rlang::abort(...)
       
       [ FAIL 18 | WARN 68 | SKIP 74 | PASS 305 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# COTAN (2.12.1)

* GitHub: <https://github.com/seriph78/COTAN>
* Email: <mailto:silvia.galfre@di.unipi.it>

Run `revdepcheck::revdep_details(, "COTAN")` for more info

## In both

*   checking dependencies in R code ... NOTE
     ```
     Namespaces in Imports field not imported from:
       ‘BiocStyle’ ‘GEOquery’ ‘R.utils’ ‘conflicted’
       All declared Imports should be used.
     ```

# decoupleR (2.17.0)

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
     [2026-06-29 02:50:15] [WARN]    [OmnipathR] Accessing `collectri` as a static table: this is not the recommended way to access OmniPath data; it is only a backup plan for situations when our server or your computer is experiencing issues.
     Error in if (.keep) . else select(., -!!evs_col) : 
       argument is of length zero
     Calls: get_collectri ... tidyselect_data_has_predicates -> unnest_evidences -> %>%
     Execution halted
     ```

*   checking tests ...
     ```
     ...
       + expected[8, ]   0.076411558
       - actual[9, ]     1.000000000
       + expected[9, ]   0.976649086
       - actual[10, ]    1.000000000
       + expected[10, ]  0.976649086
       and 134 more ...
       
            actual$p_value | expected$p_value                 
        [1] 0.105          - 0.075            [1]             
        [2] 0.105          - 0.075            [2]             
        [3] 0.519          - 0.548            [3]             
        [4] 0.519          - 0.548            [4]             
        [5] 0.010          | 0.010            [5]             
        [6] 0.010          | 0.010            [6]             
        [7] 0.087          - 0.076            [7]             
        [8] 0.087          - 0.076            [8]             
        [9] 1.000          - 0.977            [9]             
       [10] 1.000          - 0.977            [10]            
        ... ...              ...              and 134 more ...
       
       
       [ FAIL 7 | WARN 7 | SKIP 0 | PASS 27 ]
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

*   checking for non-standard things in the check directory ... NOTE
     ```
     Found the following files/directories:
       ‘omnipathr-log’
     ```

# future.batchtools (0.22.0)

* GitHub: <https://github.com/futureverse/future.batchtools>
* Email: <mailto:henrikb@braju.com>
* GitHub mirror: <https://github.com/cran/future.batchtools>

Run `revdepcheck::revdep_details(, "future.batchtools")` for more info

## In both

*   checking for non-standard things in the check directory ... NOTE
     ```
     Found the following files/directories:
       ‘.future-set-during-startup’
     ```

# gtfs2gps (2.1-4)

* GitHub: <https://github.com/ipeaGIT/gtfs2gps>
* Email: <mailto:pedro.andrade@inpe.br>
* GitHub mirror: <https://github.com/cran/gtfs2gps>

Run `revdepcheck::revdep_details(, "gtfs2gps")` for more info

## In both

*   checking tests ...
     ```
     ...
       
       > 
       > test_check("gtfs2gps")
       Saving _problems/test_simplify_shapes-7.R
       [ FAIL 1 | WARN 0 | SKIP 0 | PASS 119 ]
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Error ('test_simplify_shapes.R:7:5'): simplify_shapes ───────────────────────
       Error: [] make_valid is not available for GEOS < 3.8
       Backtrace:
           ▆
        1. └─gtfs2gps:::simplify_shapes(poa, 1e-05) at test_simplify_shapes.R:7:5
        2.   ├─terra::simplifyGeom(x = gtfs_st_simpl, tolerance = tol) at gtfs2gps/R/simplify_shapes.R:20:3
        3.   └─terra::simplifyGeom(x = gtfs_st_simpl, tolerance = tol)
        4.     └─terra (local) .local(x, ...)
        5.       ├─terra::makeValid(x)
        6.       └─terra::makeValid(x)
        7.         └─terra (local) .local(x, ...)
        8.           └─terra:::messages(x)
        9.             └─terra:::error(f, x@pntr$getError())
       
       [ FAIL 1 | WARN 0 | SKIP 0 | PASS 119 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# IFAA (1.14.0)

* GitHub: <https://github.com/quranwu/IFAA>
* Email: <mailto:lzg2151@gmail.com>

Run `revdepcheck::revdep_details(, "IFAA")` for more info

## In both

*   checking package dependencies ... ERROR
     ```
     Package required but not available: ‘HDCI’
     
     See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
     manual.
     ```

# InPAS (2.20.0)

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

# reproducible (3.1.1)

* GitHub: <https://github.com/PredictiveEcology/reproducible>
* Email: <mailto:eliot.mcintire@canada.ca>
* GitHub mirror: <https://github.com/cran/reproducible>

Run `revdepcheck::revdep_details(, "reproducible")` for more info

## In both

*   checking tests ...
     ```
     ...
        2. └─sf:::st_make_valid.sfc(p1)
       ── Failure ('test-postProcessTerra.R:85:3'): testing terra ─────────────────────
       Expected `sum(is.na(t1[]) != is.na(y[])) == 0` to be TRUE.
       Differences:
       `actual`:   FALSE
       `expected`: TRUE 
       
       ── Error ('test-postProcessTerra.R:132:3'): testing terra ──────────────────────
       Error: [] make_valid is not available for GEOS < 3.8
       Backtrace:
           ▆
        1. └─reproducible::postProcessTo(xVect, v) at test-postProcessTerra.R:132:3
        2.   └─reproducible::projectTo(...) at reproducible/R/postProcessTo.R:296:7
        3.     └─reproducible::fixErrorsIn(from) at reproducible/R/postProcessTo.R:798:9
        4.       └─reproducible:::makeVal(x) at reproducible/R/postProcessTo.R:440:9
        5.         ├─terra::makeValid(x) at reproducible/R/postProcessTo.R:455:5
        6.         └─terra::makeValid(x)
        7.           └─terra (local) .local(x, ...)
        8.             └─terra:::messages(x)
        9.               └─terra:::error(f, x@pntr$getError())
       
       [ FAIL 3 | WARN 0 | SKIP 104 | PASS 624 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# scruff (1.30.0)

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
       (/scratch/hb/revdep/parallelly/checks/scruff/new/scruff.Rcheck/00_pkg_src/scruff/R/qcplots.R:333-350)
     .plotGenes: no visible binding for global variable 'genes'
       (/scratch/hb/revdep/parallelly/checks/scruff/new/scruff.Rcheck/00_pkg_src/scruff/R/qcplots.R:303-322)
     .plotGenesPerMillionReads: no visible binding for global variable
       'genes'
       (/scratch/hb/revdep/parallelly/checks/scruff/new/scruff.Rcheck/00_pkg_src/scruff/R/qcplots.R:388-411)
     Undefined global functions or variables:
       genes
     ```

*   checking for non-standard things in the check directory ... NOTE
     ```
     Found the following files/directories:
       ‘20260628_095522_10X_QC_sce.rda’
       ‘20260628_095522__10x_bamqc_filtered.tsv’ ‘Demultiplex’
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

