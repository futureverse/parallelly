fullTest <- (Sys.getenv("_R_CHECK_FULL_") != "")


on_windows <- (.Platform[["OS.type"]] == "windows")
on_windows_32 <- (on_windows && .Platform[["r_arch"]] == "i386")
on_macos <- grepl("^darwin", R.version[["os"]])
on_solaris <- grepl("^solaris", R.version[["os"]])

covr_testing <- ("covr" %in% loadedNamespaces())
on_githubactions <- isTRUE(as.logical(Sys.getenv("GITHUB_ACTIONS")))

useXDR <- isTRUE(parallelly:::getOption2("parallelly.makeNodePSOCK.useXDR"))
