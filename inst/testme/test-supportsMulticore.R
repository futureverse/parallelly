library(parallelly)

message("*** supportsMulticore() ...")

## Test supportsMulticore()
message("- supportsMulticore() ...")
res <- supportsMulticore()
print(res)
stopifnot(is.logical(res))

options(parallelly.fork.enable = TRUE)
res <- supportsMulticore()
print(res)
stopifnot(
  if (.Platform[["OS.type"]] == "windows") isFALSE(res) else isTRUE(res)
)
options(parallelly.fork.enable = NULL)

options(parallelly.fork.enable = FALSE)
res <- supportsMulticore()
print(res)
stopifnot(isFALSE(res))
options(parallelly.fork.enable = NULL)

Sys.setenv(R_PARALLELLY_FORK_ENABLE = "true")
res <- supportsMulticore()
print(res)
stopifnot(
  if (.Platform[["OS.type"]] == "windows") isFALSE(res) else isTRUE(res)
)

Sys.unsetenv("R_PARALLELLY_FORK_ENABLE")
message("- supportsMulticore() ... DONE")


## Test supportsMulticoreAndRStudio()
message("- supportsMulticoreAndRStudio() ...")

## When not in RStudio
res <- supportsMulticoreAndRStudio()
print(res)
stopifnot(isTRUE(res))


## When in RStudio Console (not supported)
Sys.setenv(RSTUDIO = "1")
res <- supportsMulticoreAndRStudio()
print(res)
stopifnot(isFALSE(res))
Sys.unsetenv("RSTUDIO")

## When in RStudio Terminal (supported)
Sys.setenv(RSTUDIO = "1")
Sys.setenv(RSTUDIO_TERM = "1")
res <- supportsMulticoreAndRStudio()
print(res)
stopifnot(isTRUE(res))

opts <- options(parallelly.supportsMulticore.disableOn = "rstudio_terminal")
res <- supportsMulticoreAndRStudio()
print(res)
stopifnot(isFALSE(res))
options(opts)

Sys.unsetenv("RSTUDIO")
Sys.unsetenv("RSTUDIO_TERM")

## Quiet warning
options(parallelly.supportsMulticore.unstable = "quiet")
Sys.setenv(RSTUDIO = "1")
res <- supportsMulticoreAndRStudio()
print(res)
stopifnot(isFALSE(res))
Sys.unsetenv("RSTUDIO")
options(parallelly.supportsMulticore.unstable = NULL)

message("- supportsMulticoreAndRStudio() ... DONE")


message("*** supportsMulticore() ... DONE")
