message("*** utils ...")

message("*** hpaste() ...")

# Some vectors
x <- 1:6
y <- 10:1
z <- LETTERS[x]

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Abbreviation of output vector
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
printf("x = %s.\n", hpaste(x))
## x = 1, 2, 3, ..., 6.

printf("x = %s.\n", hpaste(x, maxHead = 2))
## x = 1, 2, ..., 6.

printf("x = %s.\n", hpaste(x, maxHead = 3)) # Default
## x = 1, 2, 3, ..., 6.

# It will never output 1, 2, 3, 4, ..., 6
printf("x = %s.\n", hpaste(x, maxHead = 4))
## x = 1, 2, 3, 4, 5 and 6.

# Showing the tail
printf("x = %s.\n", hpaste(x, maxHead = 1, maxTail = 2))
## x = 1, ..., 5, 6.

# Turning off abbreviation
printf("y = %s.\n", hpaste(y, maxHead = Inf))
## y = 10, 9, 8, 7, 6, 5, 4, 3, 2, 1

## ...or simply
printf("y = %s.\n", paste(y, collapse = ", "))
## y = 10, 9, 8, 7, 6, 5, 4, 3, 2, 1

# Change last separator
printf("x = %s.\n", hpaste(x, lastCollapse = " and "))
## x = 1, 2, 3, 4, 5 and 6.

# No collapse
stopifnot(all(hpaste(x, collapse = NULL) == x))

# Empty input
stopifnot(identical(hpaste(character(0)), character(0)))

message("*** hpaste() ... DONE")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# debug()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
message("*** mdebug() ...")

mdebug("Hello #", 1)
mdebugf("Hello #%d", 1)
options(parallelly.debug = TRUE)

mdebug("Hello #", 2)
mdebugf("Hello #%d", 2)
options(parallelly.debug = FALSE)

mdebug("Hello #", 3)
mdebugf("Hello #%d", 3)

message("*** mdebug() ... DONE")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# pid_exists()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
message("*** pid_exists() ...")
options(parallelly.debug = TRUE)

pid <- Sys.getpid()
printf("Current PID: %d\n", pid)

exists <- pid_exists(pid)
printf("Does it exist: %s\n", exists)

## Either pid_exists() works and return TRUE here, or it fails
## to query the process information at all in case it returns NA
## However, it should never return FALSE.
stopifnot(is.logical(exists), length(exists) == 1L,
          isTRUE(exists) || is.na(exists))

message("*** pid_exists() ... DONE")

message("*** inRCmdCheck() ...")
cat(sprintf("R CMD check is running: %s\n", inRCmdCheck()))
message("*** inRCmdCheck() ... DONE")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# trim()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
message("*** trim() ...")

trim <- parallelly:::trim

stopifnot(
  identical(trim("  hello  "), "hello"),
  identical(trim("hello"), "hello"),
  identical(trim("\t hello \n"), "hello"),
  identical(trim(""), ""),
  identical(trim("  "), "")
)

message("*** trim() ... DONE")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# commaq()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
message("*** commaq() ...")

commaq <- parallelly:::commaq

res <- commaq("a")
stopifnot(identical(res, sQuote("a")))

res <- commaq(c("a", "b"))
stopifnot(identical(res, paste(sQuote(c("a", "b")), collapse = ", ")))

res <- commaq(character(0))
stopifnot(identical(res, ""))

message("*** commaq() ... DONE")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# hpaste() - lastCollapse
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
message("*** hpaste() - lastCollapse ...")

## Two-element vector with lastCollapse
res <- hpaste(c("a", "b"), lastCollapse = " and ")
stopifnot(identical(res, "a and b"))

## Single-element vector
res <- hpaste("a", lastCollapse = " and ")
stopifnot(identical(res, "a"))

message("*** hpaste() - lastCollapse ... DONE")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# pid_exists() - argument validation
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
message("*** pid_exists() - argument validation ...")

## Non-existent PID
result <- pid_exists(2^31 - 1L)
message("pid_exists(non-existent PID): ", result)
stopifnot(is.logical(result), length(result) == 1L,
          isFALSE(result) || is.na(result))

## Invalid arguments
res <- tryCatch(pid_exists(-1L), error = identity)
stopifnot(inherits(res, "error"))

res <- tryCatch(pid_exists(NA_real_), error = identity)
stopifnot(inherits(res, "error"))

message("*** pid_exists() - argument validation ... DONE")

options(parallelly.debug = FALSE)

message("*** utils ... DONE")
