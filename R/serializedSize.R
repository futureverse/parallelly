#' Calculate the size of an R object when it is serialized
#'
#' This function goes through all the motions of serializing an object, but
#' does nothing with the bytes other than to tally the total length.
#'
#' @param obj An R object.
#'
#' @return (double) Number of bytes needed to serialize this object.
#'
#' @examples
#' object.size(mtcars)
#' serializedSize(mtcars)
#'
#' @author Mike FC
#' 
#' @export
serializedSize <- function(obj) {
  .Call(C_R_calc_serialized_size, obj)
}
