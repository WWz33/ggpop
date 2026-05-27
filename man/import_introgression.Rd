\name{import_introgression}
\alias{import_introgression}
\title{Import introgression results}
\usage{
import_introgression(
  dir = NULL,
  ...,
  type = c("auto", "dsuite_dtrios", "dsuite_dinvestigate", "fixed_diff",
    "genomics_general", "admixtools", "treemix", "qpgraph")
)
}
\arguments{
\item{dir}{Directory containing introgression result files, or a single file path.}
\item{...}{Optional named file paths. Relative paths are resolved inside \code{dir}.}
\item{type}{Input type. Supports Dsuite \code{Dtrios}/BBAA/Dmin trio summaries, Dsuite \code{Dinvestigate}/localFstats window summaries, fixed-difference trio summaries, genomics_general ABBA-BABA window outputs, ADMIXTOOLS qpdstat/f3/f4ratio tables, TreeMix internal edge/treeout summaries, and legacy qpGraph edge tables. TreeMix \code{*.edges.gz} imports use matching \code{*.vertices.gz} files when present to recover the drift-coordinate layout.}
}
\value{
A \code{ggpop_introgression} tidy S3 data frame with standardized columns including \code{analysis}, \code{stat}, \code{value}, and format-specific columns such as \code{chr}, \code{start}, \code{end}, \code{pop1}, \code{pop2}, \code{pop3}, \code{from}, and \code{to}.
}
\description{
Import introgression summaries into a typed tidy object for use with \code{plot_introgression()} or \code{ggpop() + geom_introgression()}.
}
\details{
Windowed Dsuite \code{Dinvestigate}/localFstats and genomics_general ABBA-BABA outputs are normalized to one row per statistic per window. Dsuite \code{Dtrios}/BBAA/Dmin files are imported as trio-level D statistic summaries. ADMIXTOOLS qpdstat, f3, and f4ratio outputs are imported as trio statistic tables. TreeMix internal \code{*.edges.gz} and \code{*.treeout.gz} files are imported as lightweight graph summaries. For \code{*.edges.gz}, a same-prefix \code{*.vertices.gz} file is used when available to add \code{x}, \code{y}, \code{xend}, and \code{yend} drift coordinates; \code{*.treeout.gz} alone remains a migration-edge summary. Legacy qpGraph edge tables expect user-facing \code{from} and \code{to} columns.
}
\examples{
local_fstats <- system.file(
  "extdata", "introgression", "Dsuite",
  "PopB_PopC_PopA_localFstats_run1_100_50.txt",
  package = "ggPopi"
)
intro <- import_introgression(local_fstats, type = "dsuite_dinvestigate")
intro |> plot_introgression(stat = c("D", "fdM"))

trios <- import_introgression(
  system.file("extdata", "introgression", "Dsuite", "dsuite_results_BBAA.txt", package = "ggPopi"),
  type = "dsuite_dtrios"
)
trios |> plot_introgression(style = "matrix")

qpdstat <- import_introgression(
  system.file("extdata", "introgression", "admixtools", "qpdstat_result.csv", package = "ggPopi"),
  type = "admixtools"
)
qpdstat |> plot_introgression()
}
