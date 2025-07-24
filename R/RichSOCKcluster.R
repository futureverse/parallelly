#' @export
summary.RichSOCKnode <- function(object, ...) {
  res <- list(
    host             = NA_character_,
    r_version        = NA_character_,
    platform         = NA_character_,
    pwd              = NA_character_,
    pid              = NA_integer_,
    connection_index = NA_integer_,
    connection       = NA_character_
  )
  host <- object[["host"]]
  if (!is.null(host)) res$host <- host
  con <- object[["con"]]
  if (!is.null(con)) {
    res$connection_index <- as.integer(con)
    res$connection <- tryCatch({
      summary(con)$description
    }, error = function(ex) {
      sprintf("ERROR: %s", conditionMessage(ex))
    })
  }
  if (!is.null(host)) res$host <- host
  session_info <- object[["session_info"]]
  if (!is.null(session_info)) {
    res$r_version <- session_info[["r"]][["version.string"]]
    res$platform <- session_info[["r"]][["platform"]]
    res$pwd <- session_info[["pwd"]]
    res$pid <- session_info[["process"]][["pid"]]
  }
  as.data.frame(res, stringsAsFactors = FALSE)
}

#' @export
summary.RichSOCKcluster <- function(object, ...) {
  res <- lapply(object, FUN = function(node) {
    if (is.null(node)) return(summary.RichSOCKnode(node))
    summary(node)
  })
  res <- do.call(rbind, res)
  rownames(res) <- NULL
  res
}

#' @importFrom utils capture.output
#' @export
print.RichSOCKnode <- function(x, ...) {
  info <- summary(x)
  host <- info$host
  localhost <- isTRUE(attr(host, "localhost"))
  txt <- sprintf("%s of a socket cluster on %s host '%s' with pid %s (%s, %s) using socket connection #%d ('%s')\n", class(x)[1], if (localhost) "local" else "remote", host, info$pid, info$r_version, info$platform, info$connection_index, info$connection)
  cat(txt)
  invisible(x)
}


#' @export
print.RichSOCKcluster <- function(x, ...) {
  info <- summary(x)
  txt <- sprintf("host %s", sQuote(info[["host"]]))
  
  ## Add R version info
  specs <- sprintf("(%s, platform %s)", info[["r_version"]], info[["platform"]])
  specs[is.na(info[["r_version"]])] <- "(R version and platform not queried)"
  txt <- paste(txt, specs, sep = " ")

  t <- table(txt)
  if (length(t) == 1L) {
    if (length(x) == 1L) {
      txt <- sprintf("Socket cluster with 1 node on %s", names(t))
    } else {
      txt <- sprintf("Socket cluster with %d nodes on %s", length(x), names(t))
    }
  } else {
    t <- t[order(t, decreasing = TRUE)]
    w <- ifelse(t == 1L, "node is", "nodes are")
    txt <- sprintf("%d %s on %s", t, w, names(t))
    txt <- paste(txt, collapse = ", ")
    txt <- sprintf("Socket cluster with %d nodes where %s", length(x), txt)
  }

  ## Check for invalid connections
  broken <- grep("ERROR:", info[["connection"]])
  nbroken <- length(broken)
  if (nbroken > 0) {
    w <- ifelse(nbroken == 1L, "node (%s) has a broken connection", "nodes (%s) have broken connections")
    w <- sprintf(w, paste(sprintf("#%d", broken), collapse = ", "))
    reason <- unique(info[["connection"]][broken])
    specs <- sprintf("%d %s (%s)", nbroken, w, paste(reason, collapse = "; "))
    txt <- paste(txt, ". ", specs, sep = "")
  }

  ## Report on autoStop?
  if (!is.null(attr(x, "gcMe"))) {
    txt <- sprintf("%s. This cluster is registered to be automatically stopped by the garbage collector", txt)
  }
  
  cat(txt, "\n", sep = "")
  invisible(x)
}
