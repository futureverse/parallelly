# Checks if a Connection is Valid

Get a unique identifier for an R
[connection](https://rdrr.io/r/base/connections.html) and check whether
or not the connection is still valid.

## Usage

``` r
isConnectionValid(con)

connectionId(con)
```

## Arguments

- con:

  A [connection](https://rdrr.io/r/base/connections.html).

## Value

`isConnectionValid()` returns TRUE if the connection is still valid,
otherwise FALSE. If FALSE, then character attribute `reason` provides an
explanation why the connection is not valid.

`connectionId()` returns an non-negative integer, -1, or `NA_integer_`.
For connections stdin, stdout, and stderr, 0, 1, and 2, are returned,
respectively. For all other connections, an integer greater or equal to
3 based on the connection's internal pointer is returned. A connection
that has been serialized, which is no longer valid, has identifier -1.
Attribute `raw_id` returns the pointer string from which the above is
inferred.

## Connection Index versus Connection Identifier

R represents [connections](https://rdrr.io/r/base/connections.html) as
indices using plain integers, e.g. `idx <- as.integer(con)`. The three
connections standard input ("stdin"), standard output ("stdout"), and
standard error ("stderr") always exists and have indices 0, 1, and 2.
Any connection opened beyond these will get index three or greater,
depending on availability as given by
[`base::showConnections()`](https://rdrr.io/r/base/showConnections.html).
To get the connection with a given index, use
[`base::getConnection()`](https://rdrr.io/r/base/showConnections.html).
**Unfortunately, this index representation of connections is
non-robust**, e.g. there are cases where two or more 'connection'
objects can end up with the same index and if used, the written output
may end up at the wrong destination and files and database might get
corrupted. This can for instance happen if
[`base::closeAllConnections()`](https://rdrr.io/r/base/showConnections.html)
is used (\*). **In contrast, `id <- connectionId(con)` gives an
identifier that is unique to that 'connection' object.** This identifier
is based on the internal pointer address of the object. The risk for two
connections in the same R session to end up with the same pointer
address is very small. Thus, in case we ended up in a situation where
two connections `con1` and `con2` share the same
index—`as.integer(con1) == as.integer(con2)`— they will never share the
same identifier— `connectionId(con1) != connectionId(con2)`. Here,
`isConnectionValid()` can be used to check which one of these
connections, if any, are valid.

(\*) Note that there is no good reason for calling
[`closeAllConnections()`](https://rdrr.io/r/base/showConnections.html)
If called, there is a great risk that the files get corrupted etc. See
(1) for examples and details on this problem. If you think there is a
need to use it, it is much safer to restart R because that is guaranteed
to give you a working R session with non-clashing connections. It might
also be that
[`closeAllConnections()`](https://rdrr.io/r/base/showConnections.html)
is used because
[`base::sys.save.image()`](https://rdrr.io/r/base/base-internal.html) is
called, which might happen if R is being forced to terminate.

## Connections Cannot be Serialized Or Saved

A 'connection' cannot be serialized, e.g. it cannot be saved to file to
be read and used in another R session. If attempted, the connection will
not be valid. This is a problem that may occur in parallel processing
when passing an R object to parallel worker for further processing, e.g.
the exported object may hold an internal database connection which will
no longer be valid on the worker. When a connection is serialized, its
internal pointer address will be invalidated (set to nil). In such
cases, `connectionId(con)` returns -1 and `isConnectionValid(con)`
returns FALSE.

## References

1.  ['BUG: A `connection` object may become corrupt and re-referenced to
    another connection
    (PATCH)'](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/81),
    2018-10-30.

2.  R-devel thread [PATCH: Asserting that 'connection' used has not
    changed +
    R_GetConnection2()](https://stat.ethz.ch/pipermail/r-devel/2018-October/077004.html),
    2018-10-31.

## See also

See
[`base::showConnections()`](https://rdrr.io/r/base/showConnections.html)
for currently open connections and their indices. To get a connection by
its index, use
[`base::getConnection()`](https://rdrr.io/r/base/showConnections.html).

## Examples

``` r
## R represents connections as plain indices
as.integer(stdin())          ## int 0
#> [1] 0
as.integer(stdout())         ## int 1
#> [1] 3
as.integer(stderr())         ## int 2
#> [1] 2

## The first three connections always exist and are always valid
isConnectionValid(stdin())   ## TRUE
#> [1] TRUE
connectionId(stdin())        ## 0L
#> [1] 0
isConnectionValid(stdout())  ## TRUE
#> [1] FALSE
#> attr(,"reason")
#> [1] "Connection (connection: index=3, description=\"\", class=\"file\", mode=\"w+b\", text=\"binary\", opened=\"opened\", can read=\"yes\", can write=\"yes\", id=NA) is no longer valid. It differ from the currently registered R connection with the same index 3 (connection: index=3, description=\"\", class=\"file\", mode=\"w+b\", text=\"binary\", opened=\"opened\", can read=\"yes\", can write=\"yes\", id=1477, raw_id=\"<pointer: 0x5c5>\")"
connectionId(stdout())       ## 1L
#> [1] NA
isConnectionValid(stderr())  ## TRUE
#> [1] TRUE
connectionId(stderr())       ## 2L
#> [1] 2

## Connections cannot be serialized
con <- file(tempfile(), open = "w")
x <- list(value = 42, stderr = stderr(), con = con)
y <- unserialize(serialize(x, connection = NULL))
isConnectionValid(y$stderr)  ## TRUE
#> [1] TRUE
connectionId(y$stderr)       ##  2L
#> [1] 2
isConnectionValid(y$con)     ## FALSE with attribute 'reason'
#> [1] FALSE
#> attr(,"reason")
#> [1] "Connection (connection: index=6, description=\"/tmp/hb/Rtmp9FS7yv/file251c5f7dd7b572\", class=\"file\", mode=\"w\", text=\"text\", opened=\"opened\", can read=\"no\", can write=\"yes\", id=-1) is no longer valid. It differ from the currently registered R connection with the same index 6 (connection: index=6, description=\"/tmp/hb/Rtmp9FS7yv/file251c5f7dd7b572\", class=\"file\", mode=\"w\", text=\"text\", opened=\"opened\", can read=\"no\", can write=\"yes\", id=1479, raw_id=\"<pointer: 0x5c7>\")"
connectionId(y$con)          ## -1L
#> [1] -1
close(con)
```
