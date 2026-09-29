# Anonymize hostnames as n1, n2, n3, ...
#
# Used by collect.R, which sources this file. The same file exists in
# both the 'slurm-sweep/' and the 'sge-sweep/' folders, so that each
# folder can be copied to a cluster on its own.
#
# Hostnames are numbered in the order they are first seen, going through
# the rows of the data frames in order, and for each row, the fields in
# the order 'nodelist_fields', 'hostfile_fields', 'host_fields', and
# 'workers_fields'. Both Slurm nodelists and PE_HOSTFILE list the host
# running the job script first, so that host gets the lowest number of
# the hosts not seen in earlier jobs. The same host gets the same alias
# across all jobs.
#
# Hostnames are compared without their domain names, e.g. 'n12' and
# 'n12.cluster.org' are the same host, and 'localhost' is kept as is.
# All other occurrences of a hostname in any field are replaced too,
# e.g. in queue names such as 'long.q@n12' and in pathnames.

## Hosts listed in a Slurm nodelist, e.g. "c4-n[12-13]"
expand_nodelist <- function(nodelist) {
  parallelly:::slurm_expand_nodelist(nodelist)
}

## Compress aliases to a Slurm nodelist, e.g. c("n1", "n2", "n4") ->
## "n[1-2,4]". Slurm lists the hosts of a nodelist in increasing order,
## so aliases in any other order are listed as is, e.g. "n3,n1", in
## order to keep them in the same order as SLURM_JOB_CPUS_PER_NODE
compress_nodelist <- function(aliases) {
  if (length(aliases) <= 1L) return(paste(aliases, collapse = ","))
  k <- as.integer(sub("^n", "", aliases))
  if (any(diff(k) <= 0L)) return(paste(aliases, collapse = ","))
  runs <- split(k, cumsum(c(1L, diff(k) != 1L)))
  runs <- vapply(runs, FUN.VALUE = NA_character_, FUN = function(r) {
    if (length(r) == 1L) as.character(r) else sprintf("%d-%d", r[1], r[length(r)])
  })
  sprintf("n[%s]", paste(runs, collapse = ","))
}

## Hosts in availableWorkers() summaries, e.g. "n12*2, n13*2"
parse_workers <- function(x) {
  x <- unlist(strsplit(x, split = ",", fixed = TRUE), use.names = FALSE)
  sub("[*].*", "", trimws(x))
}

## Hosts in PE_HOSTFILE contents, e.g. "n12 2 all.q@n12 UNDEFINED; ..."
parse_hostfile <- function(x) {
  x <- unlist(strsplit(x, split = ";", fixed = TRUE), use.names = FALSE)
  sub("[[:space:]].*", "", trimws(x))
}

anonymize_hostnames <- function(frames, host_fields = character(0L), nodelist_fields = character(0L), workers_fields = character(0L), hostfile_fields = character(0L)) {
  short <- function(x) sub("[.].*", "", x)

  ## (1) Collect hostnames in the order they are first seen
  hosts <- character(0L)
  add <- function(x) {
    x <- short(x[!is.na(x)])
    x <- x[nzchar(x) & x != "localhost"]
    hosts <<- unique(c(hosts, x))
  }
  for (df in frames) {
    if (is.null(df)) next
    for (ii in seq_len(nrow(df))) {
      for (field in intersect(nodelist_fields, colnames(df))) {
        value <- df[[field]][ii]
        if (!is.na(value)) add(expand_nodelist(value))
      }
      for (field in intersect(hostfile_fields, colnames(df))) {
        value <- df[[field]][ii]
        if (!is.na(value)) add(parse_hostfile(value))
      }
      for (field in intersect(host_fields, colnames(df))) add(df[[field]][ii])
      for (field in intersect(workers_fields, colnames(df))) {
        value <- df[[field]][ii]
        if (!is.na(value)) add(parse_workers(value))
      }
    }
  }
  if (length(hosts) == 0L) return(frames)
  aliases <- structure(sprintf("n%d", seq_along(hosts)), names = hosts)

  ## (2) Replace hostnames, with or without domain names, where not
  ## part of a longer name. Replace via temporary placeholders, so that
  ## an alias is never mistaken for a hostname, e.g. when a real host
  ## is named 'n1'. Longest hostnames first, e.g. 'node10' before 'node1'
  escape <- function(x) gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
  order <- order(nchar(hosts), decreasing = TRUE)
  replace <- function(x) {
    for (kk in order) {
      pattern <- sprintf("(?<![[:alnum:]_.-])%s(?:[.][[:alnum:]-]+)*(?![[:alnum:]_-])", escape(hosts[kk]))
      x <- gsub(pattern, sprintf("\001%d\002", kk), x, perl = TRUE)
    }
    gsub("\001([[:digit:]]+)\002", "n\\1", x)
  }

  lapply(frames, FUN = function(df) {
    if (is.null(df)) return(df)
    for (field in colnames(df)) {
      x <- df[[field]]
      if (!is.character(x)) next
      if (field %in% nodelist_fields) {
        df[[field]] <- vapply(x, FUN.VALUE = NA_character_, USE.NAMES = FALSE, FUN = function(value) {
          if (is.na(value)) return(value)
          compress_nodelist(unname(aliases[short(expand_nodelist(value))]))
        })
      } else {
        df[[field]] <- replace(x)
      }
    }
    df
  })
} ## anonymize_hostnames()
