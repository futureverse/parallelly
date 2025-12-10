# Search for SSH clients on the current system

Search for SSH clients on the current system

## Usage

``` r
find_rshcmd(which = NULL, first = FALSE, must_work = TRUE)
```

## Arguments

- which:

  A character vector specifying which types of SSH clients to search
  for. If NULL, a default set of clients supported by the current
  platform is searched for.

- first:

  If TRUE, the first client found is returned, otherwise all located
  clients are returned.

- must_work:

  If TRUE and no clients was found, then an error is produced, otherwise
  only a warning.

## Value

A named list of pathnames to all located SSH clients. The pathnames may
be followed by zero or more command-line options, i.e. the elements of
the returned list are character vectors of length one or more. If
`first = TRUE`, only the first one is returned. Attribute `version`
contains the output from querying the executable for its version (via
command-line option `-V`).
