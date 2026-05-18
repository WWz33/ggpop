\name{import_selection}
\alias{import_selection}
\title{Import selective sweep scan results}
\usage{
import_selection(dir = NULL, ..., type = c("selscan", "xpclr", "auto"))
}
\arguments{
\item{dir}{Directory containing selective sweep scan result files.}
\item{...}{Optional named file paths. Relative paths are resolved inside \code{dir}.}
\item{type}{Input type. Supports \code{"selscan"} and \code{"xpclr"}.}
}
\value{
A \code{ggpop_selection} tidy S3 data frame with standardized columns including \code{stat}, \code{chr}, \code{pos}, \code{value}, and \code{score_type}.
}
\description{
Import selective sweep scan results into a typed tidy object for use with \code{plot_selection()} or \code{ggpop() + geom_selection()}.
}
\examples{
selscan_dir <- system.file("extdata", "selective_sweep", "selscan", package = "ggpop")
selection <- import_selection(selscan_dir, type = "selscan")
selection |> plot_selection(stat = "ihs", chr = "1")
xpclr_dir <- system.file("extdata", "selective_sweep", "xpclr", package = "ggpop")
xpclr <- import_selection(xpclr_dir, type = "xpclr")
xpclr |> plot_selection(stat = "xpclr", chr = "1", start = 1, end = 1600000)
}
