# Checks whether or not we are running in a forked child process

Checks whether or not we are running in a forked child process

## Usage

``` r
isForkedChild()
```

## Value

(logical) Returns TRUE if the running in a forked child process,
otherwise FALSE.

## Details

Examples of setups and functions that rely on *forked* parallelization
are `parallel::makeCluster(n, type = "FORK")`,
[`parallel::mclapply()`](https://rdrr.io/r/parallel/mclapply.html), and
`future::plan("multicore")`.
