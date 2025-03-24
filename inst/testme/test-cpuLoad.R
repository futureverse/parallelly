library(parallelly)

message("*** cpuLoad() ...")

loadavg <- cpuLoad()
print(loadavg)

stopifnot(
  is.numeric(loadavg),
  length(loadavg) == 3L,
  !is.null(names(loadavg)),
  identical(names(loadavg), c("1min", "5min", "15min")),
  all(is.na(loadavg) | loadavg >= 0)
)

message("*** cpuLoad() ... DONE")
