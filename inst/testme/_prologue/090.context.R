fullTest <- (Sys.getenv("_R_CHECK_FULL_") != "")

covr_testing <- ("covr" %in% loadedNamespaces())
on_solaris <- grepl("^solaris", R.version$os)
on_macos <- grepl("^darwin", R.version$os)
on_githubactions <- as.logical(Sys.getenv("GITHUB_ACTIONS", "FALSE"))

isWin32 <- (.Platform$OS.type == "windows" && .Platform$r_arch == "i386")
useXDR <- parallelly:::getOption2("parallelly.makeNodePSOCK.useXDR", FALSE)
