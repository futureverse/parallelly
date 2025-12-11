library(parallelly)

message("isConnectionValid() ...")

## Test connectionId()

## Test with stdin, stdout, stderr
stopifnot(connectionId(stdin()) == 0L)
stopifnot(connectionId(stdout()) == 1L)
stopifnot(connectionId(stderr()) == 2L)

## Test with a connection that has no conn_id attribute
con_no_id <- file(tempfile(), open = "w+")
class(con_no_id) <- c("test_connection", class(con_no_id)) ## Inherit from connection
attr(con_no_id, "conn_id") <- NULL ## Ensure no conn_id
res <- connectionId(con_no_id)
stopifnot(is.na(res))
close(con_no_id)

## Test with a serialized connection (should return -1L)
con_ser <- file(tempfile(), open = "w")
x_ser <- list(con = con_ser)
y_ser <- unserialize(serialize(x_ser, connection = NULL))
stopifnot(connectionId(y_ser$con) == -1L)
close(con_ser)

## Test with a valid file connection
con_valid <- file(tempfile(), open = "w+")
id_valid <- connectionId(con_valid)
stopifnot(is.integer(id_valid), id_valid >= 3L)
close(con_valid)


## Test isConnectionValid()

## Test with stdin, stdout, stderr
stopifnot(isConnectionValid(stdin()))
stopifnot(isConnectionValid(stdout()))
stopifnot(isConnectionValid(stderr()))

## Test with a serialized connection (should be FALSE)
con_ser_valid <- file(tempfile(), open = "w")
x_ser_valid <- list(con = con_ser_valid)
y_ser_valid <- unserialize(serialize(x_ser_valid, connection = NULL))
res_ser_valid <- isConnectionValid(y_ser_valid$con)
stopifnot(!res_ser_valid, inherits(attr(res_ser_valid, "reason"), "character"))
close(con_ser_valid)

## Test with a valid connection
con_real_valid <- file(tempfile(), open = "w+")
stopifnot(isConnectionValid(con_real_valid))
close(con_real_valid)


## Test with a connection where index is not found in getAllConnections()
# 1. Create a connection
con_temp_file <- file(tempfile(), open = "w+")

# 2. Close it, so its index is no longer in getAllConnections()
close(con_temp_file)

# 3. Now `con_temp_file` is a "zombie" object - its index is preserved
#    but `is.element(as.integer(con_temp_file), getAllConnections())` is FALSE.
res_non_existent <- isConnectionValid(con_temp_file)
stopifnot(!res_non_existent, inherits(attr(res_non_existent, "reason"), "character"))


message("isConnectionValid() ... done")