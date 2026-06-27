# Worker Event-Loop Function for PSOCK Workers

This is a version of `parallel:::.workRSOCK()` with an option to
override the default `parallel:::workerCommand()`.

## Usage

``` r
workRPSOCK(workCommand = NULL)
```

## Arguments

- workCommand:

  A function taking a single argument `master` (the socket node
  connection) that processes one incoming command from the parent
  process. It should return `TRUE` to continue the work loop, `FALSE` to
  shut down, or `NULL` if the connection was not established. If `NULL`
  (default), `parallel:::workCommand()` is used.

## Value

Nothing. The function enters an event loop and does not return until the
worker receives a `"DONE"` message.
