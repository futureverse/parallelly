# Get the Recent CPU Load

Get the Recent CPU Load

## Usage

``` r
cpuLoad()
```

## Value

A named numeric vector with three elements `1min`, `5min`, and `15min`
with non-negative values. These values represent estimates of the CPU
load during the last minute, the last five minutes, and the last fifteen
minutes \[1\]. An idle system have values close to zero, and a heavily
loaded system have values near
[`parallel::detectCores()`](https://rdrr.io/r/parallel/detectCores.html).
If they are unknown, missing values are returned.

## Details

This function works only Unix-like system with `/proc/loadavg`.

## References

1.  Linux Load Averages: Solving the Mystery, Brendan Gregg's Blog,
    2017-08-08,
    <https://www.brendangregg.com/blog/2017-08-08/linux-load-averages.html>

## Examples

``` r
loadavg <- cpuLoad()
print(loadavg)
#>  1min  5min 15min 
#>  0.67  0.36  0.28 
```
