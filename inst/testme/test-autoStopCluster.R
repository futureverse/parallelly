library(parallelly)

message("*** autoStopCluster() ...")

## Test with debug = FALSE
cl <- makeClusterPSOCK(1L)
print(cl)
cl <- autoStopCluster(cl)
print(cl)
stopifnot(!is.null(attr(cl, "gcMe")))

## Test that it doesn't add a second finalizer
cl <- autoStopCluster(cl)
print(cl)
stopifnot(!is.null(attr(cl, "gcMe")))

rm(list = "cl")
gc()


## Test with debug = TRUE
## Capture output from finalizer
f <- tempfile()
con <- file(f, open = "w")
sink(con, type = "message")
cl <- makeClusterPSOCK(1L)
cl <- autoStopCluster(cl, debug = TRUE)
rm(list = "cl")
gc()
sink(type = "message")
close(con)
output <- readLines(f, warn = FALSE)
unlink(f)

print(output)
stopifnot(any(grepl("Finalizing cluster", output)))


message("*** autoStopCluster() ... DONE")
