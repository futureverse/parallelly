library(parallelly)

message("serializedSize() ...")

# Test with a simple integer vector
obj_int_vec <- 1:100
str(obj_int_vec)
size_int_vec <- serializedSize(obj_int_vec)
message("size_int_vec: ", size_int_vec)
stopifnot(is.double(size_int_vec), size_int_vec > 0)

# Test with a character vector
obj_char_vec <- letters
str(obj_char_vec)
size_char_vec <- serializedSize(obj_char_vec)
message("size_char_vec: ", size_char_vec)
stopifnot(is.double(size_char_vec), size_char_vec > 0)

# Test with a list of mixed types
obj_list_mixed <- list(a = 1:10, b = "hello", c = TRUE)
str(obj_list_mixed)
size_list_mixed <- serializedSize(obj_list_mixed)
message("size_list_mixed: ", size_list_mixed)
stopifnot(is.double(size_list_mixed), size_list_mixed > 0)

# Test with an empty object (e.g., NULL)
obj_null <- NULL
str(obj_null)
size_null <- serializedSize(obj_null)
message("size_null: ", size_null)
stopifnot(is.double(size_null), size_null >= 0) # Can be 0 or small positive for NULL

# Test with a data frame created on the fly
obj_df_custom <- data.frame(id = 1:5, name = c("A", "B", "C", "D", "E"), value = c(10.1, 12.3, 15.0, 11.8, 13.5))
str(obj_df_custom)
size_df_custom <- serializedSize(obj_df_custom)
message("size_df_custom: ", size_df_custom)
stopifnot(is.double(size_df_custom), size_df_custom > 0)

# Should be the same as the length of serialize() using the default version
objs <- list(obj_int_vec, obj_char_vec, obj_list_mixed, obj_null, obj_df_custom)
for (obj in objs) {
  size <- serializedSize(obj)
  truth <- length(serialize(obj, connection = NULL))
  stopifnot(size == truth)
}


message("serializedSize() ... done")
