% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/availableConnections.R
\name{availableConnections}
\alias{availableConnections}
\alias{freeConnections}
\title{Number of Available and Free Connections}
\usage{
availableConnections()

freeConnections()
}
\value{
A non-negative integer, or \code{+Inf} if the available number of connections
is greater than 16384, which is a limit be set via option
\code{\link[=parallelly.options]{parallelly.availableConnections.tries}}.
}
\description{
The number of \link{connections} that can be open at the same time in \R is
\emph{typically} 128, where the first three are occupied by the always open
\code{\link[=stdin]{stdin()}}, \code{\link[=stdout]{stdout()}}, and \code{\link[=stderr]{stderr()}} connections, which leaves 125 slots
available for other types of connections.  Connections are used in many
places, e.g. reading and writing to file, downloading URLs, communicating
with parallel \R processes over a socket connections (e.g.
\code{\link[parallel:makeCluster]{parallel::makeCluster()}} and \code{\link[=makeClusterPSOCK]{makeClusterPSOCK()}}), and capturing
standard output via text connections (e.g. \code{\link[utils:capture.output]{utils::capture.output()}}).
}
\section{How to increase the limit}{

In R (>= 4.4.0), it is possible to \emph{increase} the limit of 128 connections
to a greater number via command-line option \code{--max-connections=N}, e.g.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{$ Rscript -e "parallelly::availableConnections()"
[1] 128

$ Rscript --max-connections=512 -e "parallelly::availableConnections()"
[1] 512
}\if{html}{\out{</div>}}

For R (< 4.4.0), the limit can only be changed by rebuilding \R from
source, because the limited is hardcoded as a

\if{html}{\out{<div class="sourceCode c">}}\preformatted{#define NCONNECTIONS 128
}\if{html}{\out{</div>}}

in \file{src/main/connections.c}.
}

\section{How the limit is identified}{

Since the limit \emph{might} changed, for instance in custom \R builds or in
future releases of \R, we do not want to assume that the limit is 128 for
all \R installation.  Unfortunately, it is not possible to query \R for what
the limit is.
Instead, \code{availableConnections()} infers it from trial-and-error.
Specifically, it attempts to open as many concurrent connections as possible
until it fails.  For efficiency, the result is memoized throughout the
current \R session.
}

\examples{
total <- availableConnections()
message("You can have ", total, " connections open in this R installation")
free <- freeConnections()
message("There are ", free, " connections remaining")

}
\references{
\enumerate{
\item 'WISH: Increase limit of maximum number of open connections (currently 125+3)', 2016-07-09,
\url{https://github.com/HenrikBengtsson/Wishlist-for-R/issues/28}
}
}
\seealso{
\code{\link[base:showConnections]{base::showConnections()}}.
}
