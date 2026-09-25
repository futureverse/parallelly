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
       ‘20260925_011717_10X_QC_sce.rda’
       ‘20260925_011717__10x_bamqc_filtered.tsv’ ‘Demultiplex’
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

