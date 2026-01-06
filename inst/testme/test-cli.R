message("*** CLI ...")

cmdargs <- character(0L)
print(cmdargs)
args <- parallelly:::parse_cmd_args(cmdargs = cmdargs)
utils::str(args)

cmdargs <- c("--int=0", "--int=42", "--num=3.14", "--logical=TRUE", "--name=abc", "--expr=1+2")
print(cmdargs)
patterns <- list("--(int)=([[:digit:]]+)", "--(num)=([[:digit:].]+)", "--(logical)=(TRUE|FALSE)", "--(name)=(.*)", "--(expr)=(.*)")
str(patterns)
args <- tryCatch(parallelly:::parse_cmd_args(patterns = patterns, cmdargs = cmdargs), error = identity)
utils::str(args)
stopifnot(
  args[["int"]] == "42",
  args[["num"]]  == "3.14",
  args[["logical"]] == "TRUE",
  args[["name"]] == "abc",
  args[["expr"]] == "1+2"
)

cmdargs <- c("--int=0", "--int=42", "--num=3.14", "--logical=TRUE", "--name=abc", "--expr=1+2")
print(cmdargs)
patterns <- list(parallelly:::cli_arg_integer("int"), parallelly:::cli_arg_numeric("num"), parallelly:::cli_arg_logical("logical"), parallelly:::cli_arg_character("name"), parallelly:::cli_arg_expr("expr"))
str(patterns)
args <- tryCatch(parallelly:::parse_cmd_args(patterns = patterns, cmdargs = cmdargs), error = identity)
utils::str(args)
stopifnot(
  is.integer(args[["int"]]), args[["int"]] == 42L,
  is.numeric(args[["num"]]), args[["num"]]  == 3.14,
  is.logical(args[["logical"]]), args[["logical"]] == TRUE,
  is.character(args[["name"]]), args[["name"]] == "abc",
  is.numeric(args[["num"]]), args[["expr"]] == "3"
)

cmdargs <- c("--int=42", "--num=3.14", "--logical=TRUE", "--name=abc")
print(cmdargs)
args <- tryCatch(parallelly:::parse_cmd_args(cmdargs = cmdargs), error = identity)
stopifnot(inherits(args, "error"))

print(parallelly::availableCores, call = FALSE)

options(future.p2p.tests.cmdargs = character(0L))
print(parallelly::availableCores, call = TRUE)

options(future.p2p.tests.cmdargs = c("--max=4"))
print(parallelly::availableCores, call = TRUE)


fcn <- function(abc = 0L, def = 0.0) {
  abc <- as.integer(abc)
  def <- as.numeric(def)
  if (abc == 0) {
    data.frame(abc = abc, def = def)
  } else if (abc < 0) {
    list(abc = abc, def = def)
  } else if (abc > 0) {
    list(abc, def)
  }
}
parallelly:::cli_fcn(fcn) <- list(parallelly:::cli_arg_integer("abc"), parallelly:::cli_arg_numeric("def"))
output <- parallelly:::cli_fcn_output(fcn)
print(output)

output(42)
output(list(42))
output(list(abc = 42))
output(c(abc = 42))


options(future.p2p.tests.cmdargs = character(0L))
void <- print(fcn)

options(future.p2p.tests.cmdargs = c("--abc=0", "--def=3.14"))
void <- print(fcn)

options(future.p2p.tests.cmdargs = c("--abc=-1", "--def=3.14"))
void <- print(fcn)

options(future.p2p.tests.cmdargs = c("--abc=+1", "--def=3.14"))
void <- print(fcn)

parallelly:::cli_fcn_output(fcn) <- utils::str
options(future.p2p.tests.cmdargs = c("--abc=+1", "--def=3.14"))
void <- print(fcn)

parallelly:::cli_fcn(fcn) <- list(structure(parallelly:::cli_arg_integer("abc"), type = "unknown"))
void <- tryCatch(print(fcn), error = identity)
print(void)
stopifnot(inherits(void, "error"))

options(future.p2p.tests.cmdargs = NULL)


res <- tryCatch(parallelly:::cli_prune(), error = identity)
print(res)
stopifnot(inherits(res, "error"))


message("*** CLI ... DONE")
