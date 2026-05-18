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
  bin_size = 200
)
}
\arguments{
\item{dir}{Directory containing LD decay result files.}
\item{...}{Optional named file paths. Relative paths are resolved inside \code{dir}.}
\item{type}{Input type. Supports \code{"poplddecay"} and \code{"plink"}.}
\item{pop}{Optional sample or group labels for input files. A scalar is recycled across files; a vector is matched to file order.}
\item{pop_group}{Optional population group table or path to the standard two-column \code{sample pop} file. File labels are matched through \code{sample}.}
\item{bin_size}{Distance bin width in base pairs for PLINK pairwise LD files.}
}
\value{
A \code{ggpop_ld_decay} tidy S3 data frame with standardized columns including \code{dist}, \code{dist_kb}, \code{r2}, \code{pop}, and \code{n_pairs}.
}
\description{
Import LD decay summaries into a typed tidy object for use with \code{plot_ld_decay()} or \code{ggpop() + geom_ld_decay()}. PopLDdecay \code{*.stat.gz} files are read directly. PLINK pairwise \code{*.ld} files are summarized into distance bins.
}
\details{
Population grouping follows the package-wide convention: \code{pop_group} is the standard two-column \code{sample pop} table used by PCA and admixture workflows. LD decay file labels are stored as \code{sample_id}; when \code{pop_group} is supplied, matching labels are mapped to \code{pop}.
}
\examples{
ld_dir <- system.file("extdata", "ld_decay", "PopLDdecay", package = "ggpop")
ld <- import_ld_decay(ld_dir, type = "poplddecay")
ld |> plot_ld_decay(style = "point")
ld |> plot_ld_decay(style = "line")
}
