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
      if (is.null(os) || os == .Platform[["OS.type"]]) {
        truth <- base::shQuote(cmd)
      } else if (os == "unix") {
        truth <- base::shQuote(cmd, type = "sh")
      } else if (os == "windows") {
        truth <- base::shQuote(cmd, type = "cmd")
      }
    } else if (is.na(type)) {
      value <- shQuote(cmd)
      if (is.null(os) || os == .Platform[["OS.type"]]) {
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


message("- is_localhost()")

is_localhost <- parallelly:::is_localhost
## Reset cache
is_localhost(worker = NULL, hostname = NULL)

## Known localhost names
stopifnot(
  is_localhost("localhost"),
  is_localhost("127.0.0.1")
)

## Current hostname is localhost
hostname <- Sys.info()[["nodename"]]
stopifnot(is_localhost(hostname))

## After being identified, hostname should be cached
stopifnot(is_localhost(hostname))

## A clearly non-local host
stopifnot(!is_localhost("this-host-does-not-exist-12345.example.org"))

## Reset cache for clean state
is_localhost(worker = NULL, hostname = NULL)


message("- is_ip_number()")

is_ip_number <- parallelly:::is_ip_number
stopifnot(
  is_ip_number("192.168.1.1"),
  is_ip_number("0.0.0.0"),
  is_ip_number("255.255.255.255"),
  !is_ip_number("256.0.0.0"),
  !is_ip_number("not-an-ip"),
  !is_ip_number("192.168.1"),
  !is_ip_number("192.168.1.1.1")
)


message("- is_fqdn()")

is_fqdn <- parallelly:::is_fqdn
stopifnot(
  is_fqdn("host.example.com"),
  is_fqdn("a.b"),
  !is_fqdn("localhost"),
  !is_fqdn("singlename")
)

message("*** utils,cluster ... DONE")
