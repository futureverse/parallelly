## Local functions for test scripts
printf <- function(...) cat(sprintf(...))
if (!exists("anyNA", mode = "function")) anyNA <- function(x) any(is.na(x))
