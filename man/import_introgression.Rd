\name{import_introgression}
\alias{import_introgression}
\title{Import introgression results}
\usage{
import_introgression(
  dir = NULL,
  ...,
  type = c("auto", "dsuite_dtrios", "dsuite_dinvestigate", "genomics_general",
    "treemix", "qpgraph")
)
}
\arguments{
\item{dir}{Directory containing introgression result files, or a single file path.}
\item{...}{Optional named file paths. Relative paths are resolved inside \code{dir}.}
\item{type}{Input type. Supports Dsuite \code{Dtrios}, Dsuite \code{Dinvestigate}/localFstats, genomics_general ABBA-BABA window outputs, TreeMix edge lists, and ADMIXTOOLS2 qpGraph edge tables.}
}
\value{
A \code{ggpop_introgression} tidy S3 data frame with standardized columns including \code{analysis}, \code{stat}, \code{value}, and format-specific columns such as \code{chr}, \code{start}, \code{end}, \code{pop1}, \code{pop2}, \code{pop3}, \code{from}, and \code{to}.
}
\description{
Import introgression summaries into a typed tidy object for use with \code{plot_introgression()} or \code{ggpop() + geom_introgression()}.
}
\details{
Windowed Dsuite \code{Dinvestigate}/localFstats and genomics_general ABBA-BABA outputs are normalized to one row per statistic per window. Dsuite \code{Dtrios} is imported as trio-level D statistic summaries. Graph imports expect a user-facing edge table with \code{from} and \code{to} columns; this is suitable for TreeMix migration-edge summaries or ADMIXTOOLS2 qpGraph edge data frames.
}
\examples{
gg_dir <- system.file("extdata", "introgression", "genomics_general", package = "ggpop")
intro <- import_introgression(gg_dir, type = "genomics_general")
intro |> plot_introgression(stat = c("D", "fdM"))

trios <- import_introgression(
  system.file("extdata", "introgression", "Dsuite", "Dtrios.tsv", package = "ggpop"),
  type = "dsuite_dtrios"
)
trios |> plot_introgression()
}
