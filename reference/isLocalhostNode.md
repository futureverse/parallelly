# Checks whether or not a Cluster Node Runs on Localhost

Checks whether or not a Cluster Node Runs on Localhost

## Usage

``` r
isLocalhostNode(node, ...)
```

## Arguments

- node:

  A cluster node of class `SOCKnode` or `SOCK0node`.

- ...:

  Not used.

## Value

(logical) Returns TRUE if the cluster node is running on the current
machine and FALSE if it runs on another machine. If it cannot be
inferred, NA is returned.
