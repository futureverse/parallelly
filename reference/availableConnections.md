# Number of Available and Free Connections

The number of [connections](https://rdrr.io/r/base/connections.html)
that can be open at the same time in R is *typically* 128, where the
first three are occupied by the always open
[`stdin()`](https://rdrr.io/r/base/showConnections.html),
[`stdout()`](https://rdrr.io/r/base/showConnections.html), and
[`stderr()`](https://rdrr.io/r/base/showConnections.html) connections,
which leaves 125 slots available for other types of connections.
Connections are used in many places, e.g. reading and writing to file,
downloading URLs, communicating with parallel R processes over a socket
connections (e.g.
[`parallel::makeCluster()`](https://rdrr.io/r/parallel/makeCluster.html)
and
[`makeClusterPSOCK()`](https://parallelly.futureverse.org/reference/makeClusterPSOCK.md)),
and capturing standard output via text connections (e.g.
[`utils::capture.output()`](https://rdrr.io/r/utils/capture.output.html)).

## Usage

``` r
availableConnections()

freeConnections()
```

## Value

A non-negative integer, or `+Inf` if the available number of connections
is greater than 16384, which is a limit be set via option
[`parallelly.availableConnections.tries`](https://parallelly.futureverse.org/reference/zzz-parallelly.options.md).

## How to increase the limit

In R (\>= 4.4.0), it is possible to *increase* the limit of 128
connections to a greater number via command-line option
`--max-connections=N`, e.g.

    $ Rscript -e "parallelly::availableConnections()"
    [1] 128

    $ Rscript --max-connections=512 -e "parallelly::availableConnections()"
    [1] 512

For R (\< 4.4.0), the limit can only be changed by rebuilding R from
source, because the limited is hardcoded as a

    #define NCONNECTIONS 128

in `src/main/connections.c`.

## How the limit is identified

Since the limit *might* changed, for instance in custom R builds or in
future releases of R, we do not want to assume that the limit is 128 for
all R installation. Unfortunately, it is not possible to query R for
what the limit is. Instead, `availableConnections()` infers it from
trial-and-error. Specifically, it attempts to open as many concurrent
connections as possible until it fails. For efficiency, the result is
memoized throughout the current R session.

## References

1.  'WISH: Increase limit of maximum number of open connections
    (currently 125+3)', 2016-07-09,
    <https://github.com/HenrikBengtsson/Wishlist-for-R/issues/28>

## See also

[`base::showConnections()`](https://rdrr.io/r/base/showConnections.html).

## Examples

``` r
total <- availableConnections()
message("You can have ", total, " connections open in this R installation")
#> You can have 128 connections open in this R installation
free <- freeConnections()
message("There are ", free, " connections remaining")
#> There are 124 connections remaining
```
