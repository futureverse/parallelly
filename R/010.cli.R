parse_cmd_args <- function(patterns = list(), cmdargs = getOption("future.p2p.tests.cmdargs", commandArgs(trailingOnly = TRUE))) {
  args <- list()
  for (pattern in patterns) {
    type <- attr(pattern, "type")
    pattern <- sprintf("^%s$", pattern)
    idx <- grep(pattern, cmdargs)
    if (length(idx) > 0) {
      cmdarg <- cmdargs[idx]
      cmdargs <- cmdargs[-idx]
      ## Use only last, iff multiple are given
      if (length(cmdarg) > 1) cmdarg <- cmdarg[length(cmdarg)]
      name <- gsub(pattern, "\\1", cmdarg)
      value <- gsub(pattern, "\\2", cmdarg)
      if (!is.null(type)) {
        if (type == "expr") {
          value <- local(eval(parse(text = value)))
        } else {
          value <- strsplit(value, split = ",", fixed = TRUE)[[1]]
          if (type == "character") {
            value <- as.character(value)
          } else if (type == "logical") {
            value <- as.logical(value)
          } else if (type == "integer") {
            value <- as.integer(value)
          } else if (type == "numeric") {
            value <- as.numeric(value)
          } else {
            stop("Unknown cli_arg type: ", sQuote(type))
          }
        }
      }
      class(value) <- "cmd_arg"
      args[[name]] <- value
    }
  }

  if (length(cmdargs) > 0) {
    stop(sprintf("Unknown %s command-line arguments: %s", .packageName, paste(cmdargs, collapse = " ")), call. = FALSE)
  }

  args
} # parse_cmd_args()


`cli_fcn<-` <- function(x, value = character(0L)) {
  fcn <- x
  patterns <- value
  stopifnot(
    is.function(fcn),
    is.list(patterns)
  )
  class(fcn) <- c("cli_fcn", class(fcn))
  attr(fcn, "cli_fcn_patterns") <- patterns
  
  attr(fcn, "cli_fcn_output") <- function(x) {
    if (is.list(x) || is.data.frame(x)) {
      print(x)
    } else if (is.null(names(x))) {
      x <- paste(x, collapse = " ")
      cat(x, "\n", sep = "")
    } else {
      x <- as.list(x)
      x <- as.data.frame(x, check.names = FALSE)
      print(x, row.names = FALSE)
    }
  }
  
  invisible(fcn)
}

cli_fcn_args <- function(fcn) {
  attr(fcn, "cli_fcn_patterns", exact = TRUE)
}

`cli_fcn_output<-` <- function(x, value = cat) {
  stopifnot(is.function(value))
  attr(x, "cli_fcn_output") <- value
  invisible(x)
}

cli_fcn_output <- function(fcn) {
  attr(fcn, "cli_fcn_output", exact = TRUE)
}

#' @export
print.cli_fcn <- function(x, ..., call = !interactive(), envir = parent.frame()) {
  if (!call) return(NextMethod())
  
  # Call function...
  patterns <- cli_fcn_args(x)
  res <- withVisible(do.call(x, args = parse_cmd_args(patterns = patterns), envir = envir))

  # Should the result be printed?
  if (res$visible) {
    output <- cli_fcn_output(x)
    output(res$value)
  }

  # Return nothing
  invisible(return())
}


cli_arg_character <- function(name) {
  value <- sprintf("--(%s)=(.*)", name)
  attr(value, "type") <- "character"
  value
}

cli_arg_logical <- function(name) {
  value <- sprintf("--(%s)=(TRUE|FALSE|NA)", name)
  attr(value, "type") <- "logical"
  value
}

cli_arg_integer <- function(name) {
  value <- sprintf("--(%s)=((|[+]|[-])([[:digit:]]+))", name)
  attr(value, "type") <- "integer"
  value
}

cli_arg_numeric <- function(name) {
  value <- sprintf("--(%s)=((|[+]|[-])([[:digit:].]+|Inf))", name)
  attr(value, "type") <- "numeric"
  value
}

cli_arg_expr <- function(name) {
  value <- sprintf("--(%s)=(.*)", name)
  attr(value, "type") <- "expr"
  value
}

cli_prune <- function() {
  ns <- getNamespace(.packageName)
  for (name in names(ns)) {
    if (!exists(name, mode = "function", envir = ns, inherits = FALSE)) next
    fcn <- get(name, mode = "function", envir = ns, inherits = FALSE)
    if (!inherits(fcn, "cli_fcn")) next
    attrs <- attributes(fcn)
    attrs[["cli_fcn_patterns"]] <- NULL
    attributes(fcn) <- attrs
    class(fcn) <- setdiff(class(fcn), "cli_fcn")
    assign(name, fcn, envir = ns, inherits = FALSE)
  }
}
