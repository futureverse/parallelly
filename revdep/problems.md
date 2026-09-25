# chms (7.1)

* GitHub: <https://github.com/statcan/chms>
* Email: <mailto:joel.barnes@statcan.gc.ca>
* GitHub mirror: <https://github.com/cran/chms>

Run `revdepcheck::revdep_details(, "chms")` for more info

## In both

*   checking dependencies in R code ... NOTE
     ```
     Namespaces in Imports field not imported from:
       ‘R6’ ‘dbplyr’ ‘knitr’ ‘mirai’ ‘mori’ ‘parallelly’ ‘readr’ ‘utils’
       All declared Imports should be used.
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
     [2026-09-24 16:14:34] [WARN]    [OmnipathR] Accessing `collectri` as a static table: this is not the recommended way to access OmniPath data; it is only a backup plan for situations when our server or your computer is experiencing issues.
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

# flexstanr (0.2.0)

* GitHub: <https://github.com/ACCIDDA/flexstanr>
* Email: <mailto:carl.ab.pearson@gmail.com>
* GitHub mirror: <https://github.com/cran/flexstanr>

Run `revdepcheck::revdep_details(, "flexstanr")` for more info

## In both

*   checking whether startup messages can be suppressed ... NOTE
     ```
     code for methods in class “Rcpp_model_base” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_model_base” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_stan_fit” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     code for methods in class “Rcpp_stan_fit” was not checked for suspicious field assignments (recommended package ‘codetools’ not available?)
     
     It looks like this package (or a package it requires) has a startup
     message which cannot be suppressed: see ?packageStartupMessage.
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
       ‘20260924_171317_10X_QC_sce.rda’
       ‘20260924_171317__10x_bamqc_filtered.tsv’ ‘Demultiplex’
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

