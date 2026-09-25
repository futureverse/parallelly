mounts <- parallelly:::getCGroupsMounts()
print(mounts)

stopifnot(
  is.data.frame(mounts),
  nrow(mounts) > 0L,
  ncol(mounts) == 6L,
  "cgroup" %in% mounts[["type"]],
  "cgroup2" %in% mounts[["type"]]
)
