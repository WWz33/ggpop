\name{import_ld_decay}
\alias{import_ld_decay}
\title{Import LD decay results}
\usage{
import_ld_decay(
  dir = NULL,
  ...,
  type = c("poplddecay", "plink", "auto"),
  pop = NULL,
  pop_group = NULL,
  method = c("MeanBin", "none", "MedianBin", "PercentileBin"),
  bin1 = 10,
  bin2 = 100,
  breakpoint = 100,
  percent = 0.5,
  bin_size = NULL
)
}
\arguments{
\item{dir}{Directory containing LD decay result files.}
\item{...}{Optional named file paths. Relative paths are resolved inside \code{dir}.}
\item{type}{Input type. Supports \code{"poplddecay"} and \code{"plink"}.}
\item{pop}{Optional sample or group labels for input files. A scalar is recycled across files; a vector is matched to file order.}
\item{pop_group}{Optional population group table or path to the standard two-column \code{sample pop} file. File labels are matched through \code{sample}.}
\item{method}{Binning method for PopLDdecay summaries and PLINK pairwise LD tables. \code{"MeanBin"} matches the common PopLDdecay summary plot; \code{"MedianBin"} and \code{"PercentileBin"} use pair-count weighted quantiles.}
\item{bin1}{Short-distance bin width in base pairs.}
\item{bin2}{Long-distance bin width in base pairs.}
\item{breakpoint}{Distance threshold that switches from \code{bin1} to \code{bin2}.}
\item{percent}{Percentile used by \code{"PercentileBin"}.}
\item{bin_size}{Legacy alias for a single bin width. When supplied, \code{method} is treated as \code{"MeanBin"} and both bin widths use the same size.}
}
\value{
A \code{ggpop_ld_decay} tidy S3 data frame with standardized columns including \code{dist}, \code{dist_kb}, \code{r2}, \code{pop}, and \code{n_pairs}.
}
\description{
Import LD decay summaries into a typed tidy object for use with \code{plot_ld_decay()} or \code{ggpop() + geom_ld_decay()}. PopLDdecay \code{*.stat.gz} and \code{*.bin.gz} files are read directly. PLINK pairwise \code{*.ld} files are summarized into distance bins.
}
\details{
Population grouping follows the package-wide convention: \code{pop_group} is the standard two-column \code{sample pop} table used by PCA and admixture workflows. LD decay file labels are stored as \code{sample_id}; when \code{pop_group} is supplied, matching labels are mapped to \code{pop}.
The plotting helpers use the mapped population label for colour. Point and line styles keep the imported summaries; the fitted style summarizes mapped rows by population before drawing fitted curves.
}
\examples{
ld_dir <- system.file("extdata", "ld_decay", "PopLDdecay_grouped", package = "ggPopi")
groups <- system.file("extdata", "pop_group.txt", package = "ggPopi")
ld <- import_ld_decay(ld_dir, type = "poplddecay", pop_group = groups)
ld |> plot_ld_decay(style = "point")
ld |> plot_ld_decay(style = "line")
ld |> plot_ld_decay(style = "fit")
}
