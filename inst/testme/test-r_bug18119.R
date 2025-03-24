library(parallelly)

r_version_has_bug18119 <- function() {
  parallelly:::r_version_has_bug18119(force = TRUE)
}

affected_by_bug18119 <- function() {
  parallelly:::affected_by_bug18119(force = TRUE)
}


message("*** R bug #18119 ...")

has <- r_version_has_bug18119()
message("r_version_has_bug18119(<current>): ", has)

Sys.setenv(R_PARALLELLY_R_VERSION="3.5.3")
has <- r_version_has_bug18119()
message("r_version_has_bug18119(<R 3.5.3>): ", has)
stopifnot(!has)

Sys.setenv(R_PARALLELLY_R_VERSION="4.0.0")
has <- r_version_has_bug18119()
message("r_version_has_bug18119(<R 4.0.0>): ", has)
stopifnot(has)

Sys.setenv(R_PARALLELLY_R_VERSION="4.0.5")
has <- r_version_has_bug18119()
message("r_version_has_bug18119(<R 4.0.5>): ", has)
stopifnot(has)

Sys.setenv(R_PARALLELLY_R_VERSION="4.1.0")
has <- r_version_has_bug18119()
message("r_version_has_bug18119(<R 4.1.0>): ", has)
stopifnot(has)

Sys.setenv(R_PARALLELLY_R_VERSION="4.1.1")
has <- r_version_has_bug18119()
message("r_version_has_bug18119(<R 4.1.1>): ", has)
stopifnot(!has)

Sys.setenv(R_PARALLELLY_R_VERSION="4.2.0")
has <- r_version_has_bug18119()
message("r_version_has_bug18119(<R 4.2.0>): ", has)
stopifnot(!has)

message("*** R bug #18119 ... DONE")
