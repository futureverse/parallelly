message("*** utils,cluster ...")

shQuote <- parallelly:::shQuote

check_types <- function(cmd = "foo bar", os = NULL) {
  if (is.null(os)) {
    info <- ""
  } else {
    environment(shQuote)[[".Platform"]] <- list(OS.type = os)
    on.exit(rm(list = ".Platform", envir = environment(shQuote)))
    info <- sprintf(" with os = '%s'", os)
  }

  for (type in list("sh", "cmd", "none", NULL, NA)) {
    type_str <- if (is.null(type)) "NULL" else sprintf('"%s"', type)
    message(sprintf("- sQuote(... type = %s)%s", type_str, info))
    if (is.null(type)) {
      value <- shQuote(cmd, type = type)
      if (is.null(os) || os == .Platform$OS.type) {
        truth <- base::shQuote(cmd)
      } else if (os == "unix") {
        truth <- base::shQuote(cmd, type = "sh")
      } else if (os == "windows") {
        truth <- base::shQuote(cmd, type = "cmd")
      }
    } else if (is.na(type)) {
      value <- shQuote(cmd)
      if (is.null(os) || os == .Platform$OS.type) {
        truth <- base::shQuote(cmd)
      } else if (os == "unix") {
        truth <- base::shQuote(cmd, type = "sh")
      } else if (os == "windows") {
        truth <- base::shQuote(cmd, type = "cmd")
      }
    } else if (type == "none") {
      value <- shQuote(cmd, type = type)
      truth <- cmd
    } else {
      value <- shQuote(cmd, type = type)
      truth <- base::shQuote(cmd, type = type)
    }
    str(list(value = value, truth = truth))
    stopifnot(value == truth)
  }
}


message("- sQuote()")

cmd <- "foo bar"
stopifnot(shQuote(cmd) == base::shQuote(cmd))


for (os in list(NULL, "unix", "windows")) {
  check_types(cmd = cmd, os = os)
}


message("*** utils,cluster ... DONE")
