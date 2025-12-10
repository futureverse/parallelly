# Checks whether or not a Cluster Node Runs in a Forked Process

Checks whether or not a Cluster Node Runs in a Forked Process

## Usage

``` r
isForkedNode(node, ...)
```

## Arguments

- node:

  A cluster node of class `SOCKnode` or `SOCK0node`.

- ...:

  Not used.

## Value

(logical) Returns TRUE if the cluster node is running in a forked child
process and FALSE if it does not. If it cannot be inferred, NA is
returned.
