message("parallelly:::stealth_sample() ...")

# 1. Basic usage
set.seed(42)
oseed <- .GlobalEnv$.Random.seed
s1 <- stealth_sample(1:10, size = 5)
stopifnot(length(s1) == 5, identical(.GlobalEnv$.Random.seed, oseed))

set.seed(42)
oseed <- .GlobalEnv$.Random.seed
s2 <- sample(1:10, size = 5)
stopifnot(length(s2) == 5, !identical(.GlobalEnv$.Random.seed, oseed))
stopifnot(!identical(s1, s2)) # stealth_sample should produce different sequence for same seed due to internal set.seed

# 2. size = 0L case
x <- 1:10
s_empty <- stealth_sample(x, size = 0L)
stopifnot(length(s_empty) == 0L, identical(s_empty, x[integer(0)]))

# 3. length(x) == 1L case without error
# 3.1. size = 1L
x_single <- 5
s_single_1 <- stealth_sample(x_single, size = 1L)
stopifnot(length(s_single_1) == 1L, identical(s_single_1, x_single))

# 3.2. replace = TRUE, size > 1L
s_single_rep <- stealth_sample(x_single, size = 3L, replace = TRUE)
stopifnot(length(s_single_rep) == 3L, all(s_single_rep == x_single))

# 4. Error case: length(x) == 1L, replace = FALSE, size > 1L
res <- tryCatch({
  stealth_sample(5, size = 2L, replace = FALSE)
}, error = function(e) e)
stopifnot(inherits(res, "simpleError"), grepl("Cannot take a sample", res$message))

# 5. Verify that .Random.seed is preserved
set.seed(123)
oseed_before <- .GlobalEnv$.Random.seed
stealth_sample(1:10, size = 5)
oseed_after <- .GlobalEnv$.Random.seed
stopifnot(identical(oseed_before, oseed_after))

message("parallelly:::stealth_sample() ... done")
