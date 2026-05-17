\name{import_stats}
\alias{import_stats}
\title{Import population genomics summary statistics}
\usage{
import_stats(dir = NULL, ..., type = c("pixy", "vcftools", "auto"))
}
\arguments{
\item{dir}{Directory containing pixy or vcftools result files. Files are auto-discovered by suffix.}
\item{...}{Optional named files such as \code{pi = "pixy_pi.txt"} or \code{fst = "pixy_fst.txt"}. Relative paths are resolved inside \code{dir}.}
\item{type}{Input format. Supports \code{"pixy"}, \code{"vcftools"}, and \code{"auto"}.}
}
\value{
A \code{ggpop_stats} data frame with normalized columns: \code{stat}, \code{chr}, \code{start}, \code{end}, \code{pos}, and \code{value}.
}
\description{
Import windowed population genomics statistics such as FST, pi, Dxy, Watterson's theta, and Tajima's D for tidy ggpop plotting.
}
\examples{
pixy_dir <- system.file("extdata", "Population_genomics_statistics", "pixy", package = "ggpop")
stats <- import_stats(pixy_dir, type = "pixy")
stats |> plot_stats(stat = c("fst", "pi"), chr = "chr2L")
}
