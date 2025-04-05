#' @export
all.equal.connection <- function(target, current, ...) {
  if (!identical(target, current)) {
    return("Connections differ")
  }
  TRUE
}
