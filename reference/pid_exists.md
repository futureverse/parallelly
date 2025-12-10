# Check whether a process PID exists or not

Check whether a process PID exists or not

## Usage

``` r
pid_exists(pid, debug = getOption("parallelly.debug", FALSE))
```

## Arguments

- pid:

  A positive integer.

## Value

Returns `TRUE` if a process with the given PID exists, `FALSE` if a
process with the given PID does not exists, and `NA` if it is not
possible to check PIDs on the current system.

## Details

There is no single go-to function in R for testing whether a PID exists
or not. Instead, this function tries to identify a working one among
multiple possible alternatives. A method is considered working if the
PID of the current process is successfully identified as being existing
such that `pid_exists(Sys.getpid())` is `TRUE`. If no working approach
is found, `pid_exists()` will always return `NA` regardless of PID
tested. On Unix, including macOS, alternatives
`tools::pskill(pid, signal = 0L)` and `system2("ps", args = pid)` are
used. On MS Windows, various alternatives of `system2("tasklist", ...)`
are used. Note, some MS Windows machines are configures to not allow
using `tasklist` on other process IDs than the current one.

## References

1.  The Open Group Base Specifications Issue 7, 2018 edition, IEEE Std
    1003.1-2017 (Revision of IEEE Std 1003.1-2008)
    <https://pubs.opengroup.org/onlinepubs/9699919799/functions/kill.html>

2.  Microsoft, tasklist, 2021-03-03,
    <https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tasklist>

3.  R-devel thread 'Detecting whether a process exists or not by its
    PID?', 2018-08-30.
    <https://stat.ethz.ch/pipermail/r-devel/2018-August/076702.html>

## See also

[`pskill()`](https://rdrr.io/r/tools/pskill.html) and
[`system2()`](https://rdrr.io/r/base/system2.html).
