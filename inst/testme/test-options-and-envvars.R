library(parallelly)

getOption2 <- parallelly:::getOption2
getEnvVar2 <- parallelly:::getEnvVar2

options(parallelly.some.option = NULL)
options(parallelly.some.option = NULL)
Sys.unsetenv("R_FUTURE_SOME_ENVVAR")
Sys.unsetenv("R_PARALLELLY_SOME_ENVVAR")


message("*** Options and environment variables ...")

showall <- function() {
  utils::str(list(
    future.some.setting       = getOption("future.some.setting", NULL),
    parallelly.some.setting   = getOption("parallelly.some.setting", NULL),
    R_FUTURE_SOME_SETTING     = Sys.getenv("R_FUTURE_SOME_SETTING", ""),
    R_PARALLELLY_SOME_SETTING = Sys.getenv("R_PARALLELLY_SOME_SETTING", "")
  ))
}

for (what in c("option", "envvar")) {
  if (what == "option") {
    setvalue <- function(name, value) {
      name <- sprintf("%s.some.setting", tolower(name))
      if (is.null(value)) {
        args <- list(NULL)
      } else {
        args <- as.list(value)
      }
      names(args) <- name
      do.call(options, args = args)
      class(args) <- "option"
      args
    }
  } else if (what == "envvar") {
    setvalue <- function(name, value) {
      name <- sprintf("R_%s_SOME_SETTING", toupper(name))
      if (is.null(value)) {
        Sys.unsetenv(name)
        args <- list(NULL)
        names(args) <- name
      } else {
        args <- as.list(value)
        names(args) <- name
        do.call(Sys.setenv, args = args)
      }
      class(args) <- "envvar"
      args
    }
  }
  
  for (name in c("future", "parallelly")) {
    for (value0 in list(NULL, TRUE)) {
      args <- setvalue(name, value0)
      stopifnot(inherits(args, what))
      showall()
      
      if (is.null(value0)) {
        message("- getOption2()")
        value <- getOption2("future.some.setting", NA)
        stopifnot(is.na(value))
        value <- getOption2("parallelly.some.setting", NA)
        stopifnot(is.na(value))
        
        message("- getEnvVar2()")
        value <- getEnvVar2("R_FUTURE_SOME_ENVVAR", NA)
        stopifnot(is.na(value))
        value <- getEnvVar2("R_PARALLELLY_SOME_ENVVAR", NA)
        stopifnot(is.na(value))
      } else if (isTRUE(value0)) {
        if (what == "option") {
          message("- getOption2()")
          value1 <- getOption2("future.some.setting", NA)
          stopifnot(isTRUE(value1))
          value2 <- getOption2("parallelly.some.setting", NA)
          stopifnot(isTRUE(value2))
        } else if (what == "envvar") {
          message("- getEnvVar2()")
          value1 <- getEnvVar2("R_FUTURE_SOME_SETTING", NA)
          stopifnot(value1 == "TRUE")
          value2 <- getEnvVar2("R_PARALLELLY_SOME_SETTING", NA)
          stopifnot(value2 == "TRUE")
        }
        stopifnot(identical(value1, value2))
      }

      args <- setvalue(name, NULL)
      stopifnot(inherits(args, what), is.null(args[[1]]))
    } ## for (value ...)
  } ## for (name ...)
} ## for (what ...)


message("*** Options and environment variables ... DONE")
