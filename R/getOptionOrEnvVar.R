getOption2 <- local({
  re <- sprintf("^(future|%s)[.]", .packageName)
  prefixes <- paste(c(.packageName, "future"), ".", sep = "")
  
  function(name, default = NULL) {
    value <- getOption(name)
    if (!is.null(value)) return(value)

    ## Backward compatibility with the 'future' package
    basename <- sub(re, "", name)
    names <- unique(c(name, paste(prefixes, basename, sep="")))
  
    ## Is there an R option set?
    for (name in names) {
      value <- getOption(name)
      if (!is.null(value)) return(value)
    }
  
    default
  }
})


getEnvVar2 <- local({
  re <- sprintf("^R_(FUTURE|%s)_", toupper(.packageName))
  prefixes <- paste("R_", toupper(c(.packageName, "future")), "_", sep = "")
  
  function(name, default = NA_character_) {
    value <- Sys.getenv(name, "")
    if (nzchar(value)) return(value)
    
    ## Backward compatibility with the 'future' package
    basename <- sub(re, "", name)
    names <- unique(c(name, paste(prefixes, basename, sep="")))
  
    ## Is there an environment variable set?
    for (name in names) {
      value <- Sys.getenv(name, "")
      if (nzchar(value)) return(value)
    }

    default
  }
})


if (getRversion() < "4.0.0") {
  ## When 'default' is specified, this is 30x faster than
  ## base::getOption().  The difference is that here we use
  ## use names(.Options) whereas in 'base' names(options())
  ## is used.
  getOption <- local({
    go <- base::getOption
    function(x, default = NULL) {
      if (missing(default) || match(x, table = names(.Options), nomatch = 0L) > 0L) go(x) else default
    }
  })
}
