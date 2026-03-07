#! /usr/bin/env bash

## Missing or outdated LaTeX packages
false && R --quiet --no-save <<EOF
    tinytex::install_tinytex(force = TRUE)
    message("TeX root: ", tinytex::tinytex_root())
    tinytex::tlmgr_update()
#    tinytex::tlmgr_install("nowidow")  # QDNAseq
#    tinytex::tlmgr_install("wrapfig")  # tramvs
#    tinytex::tlmgr_install("apacite")  # ctsem
#    tinytex::tlmgr_install("textpos")  # WeightedCluster
EOF

## Add packages to check
revdep/run.R --add-children

## Drop packages failing on CRAN (2026-03-07)
revdep/run.R --rm aramappings fmeffects

## Drop packages no longer on CRAN (2026-03-07)
# revdep/run.R --rm ...

## Drop packages failing on Bioconductor (2026-03-07)
# revdep/run.R --rm ...

## Missing tools
revdep/run.R --rm iscream  # requires tool 'tabix' (module load htslib)
revdep/run.R --rm proffer  # requires 'RProtoBuf' -> ProtoBuf library

## Too many cores
revdep/run.R --rm fmeffects gtfs2emis gtfs2gps simIDM WeightedCluster

## Run them separately
# revdep/run.R --add fmeffects gtfs2emis gtfs2gps simIDM
# NSLOTS=112 revdep/run.R
# revdep/run.R --add WeightedCluster
# NSLOTS=8 revdep/run.R
