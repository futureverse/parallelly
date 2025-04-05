## This test asserts that two R connections are identified as different,
## although they share the same connection index. This helps to work
## around a bug in R [1]
## [1] https://github.com/HenrikBengtsson/Wishlist-for-R/issues/81

message("all.equal() for connection ...")
con1 <- rawConnection(raw())
close(con1)

con2 <- rawConnection(raw())
close(con2)

stopifnot(!isTRUE(all.equal(con1, con2)))
message("all.equal() for connection ... done")
