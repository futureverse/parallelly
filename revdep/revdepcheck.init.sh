#! /usr/bin/env bash

## Missing or outdated LaTeX packages
false && R --quiet --no-save <<EOF
    tinytex::install_tinytex(force = TRUE)
    message("TeX root: ", tinytex::tinytex_root())
    tinytex::tlmgr_update()
    tinytex::tlmgr_install("apacite")  # ctsem
    tinytex::tlmgr_install("textpos")  # WeightedCluster
EOF

## Non-default system dependencies
if command -v module &> /dev/null; then
    module try-load CBI htslib  ## iscream
fi    


## ---------------------------------------------------------------------
## Phase 1
## ---------------------------------------------------------------------

## Add packages to check
revdep/run.R --add-children

## Drop packages failing on CRAN (2026-03-12)
revdep/run.R --rm aramappings fmeffects

## Drop packages no longer on CRAN (2026-03-07)
# revdep/run.R --rm ...

## Drop packages failing on Bioconductor (2026-03-07)
# revdep/run.R --rm ...

## Missing tools
revdep/run.R --rm proffer  # requires 'RProtoBuf' -> ProtoBuf library

## Errors for unknown reason
## 'iscream' fails with "error in evaluating the argument 'obj' in selecting a method
## for function 'unname': 'file_test("-x", bin)' is not TRUE" despite having 'tabix'
## on the PATH /2026-03-13 
revdep/run.R --rm iscream


## Too many cores
pkgs=(fmeffects gtfs2emis gtfs2gps rBiasCorrection simIDM WeightedCluster)
revdep/run.R --rm "${pkgs[@]}"

## Run revdep check
revdep/run.R


## ---------------------------------------------------------------------
## Phase 2
## ---------------------------------------------------------------------
## Run them separately
revdep/run.R --add "${pkgs[@]}"
OMP_NUM_THREADS=4 NSLOTS=4 revdep/run.R

