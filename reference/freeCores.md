# Get the Average Number of Free CPU Cores

Get the Average Number of Free CPU Cores

## Usage

``` r
freeCores(
  memory = c("5min", "15min", "1min"),
  fraction = 0.9,
  logical = getOption2("parallelly.availableCores.logical", TRUE),
  default = parallelly::availableCores()
)
```

## Arguments

- memory:

  (character) The time period used to infer the system load, with
  alternatives being 5 minutes (default), 15 minutes, or 1 minute.

- fraction:

  (non-negative numeric) A scale factor.

- logical:

  Passed as-is to
  [`availableCores()`](https://parallelly.futureverse.org/reference/availableCores.md).

- default:

  (integer) The value to be returned if the system load is unknown, i.e.
  [`cpuLoad()`](https://parallelly.futureverse.org/reference/cpuLoad.md)
  return missing values.

## Value

An positive integer with attributes `loadavg` (named numeric),
`maxCores` (named integer), argument `memory` (character), and argument
`fraction` (numeric).

## Examples

``` r
free <- freeCores()
print(free)
#> [1] 6
#> attr(,"loadavg")
#>  1min  5min 15min 
#>  1.41  1.13  1.14 
#> attr(,"maxCores")
#> system 
#>      8 
#> attr(,"memory")
#> [1] "5min"
#> attr(,"fraction")
#> [1] 0.9

if (FALSE) { # \dontrun{
## Make availableCores() agile to the system load
options(parallelly.availableCores.custom = function() freeCores())
} # }
```
