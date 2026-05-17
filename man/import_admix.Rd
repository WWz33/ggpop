\name{import_admix}
\alias{import_admixture}
\alias{import_admix}
\title{Import admixture proportion files}
\usage{
import_admix(file, type = c("auto", "structure", "admixture"), ind = NULL,
  pattern = "\\\\.Q$", recursive = FALSE, pop_group = NULL, ...)
import_admixture(file, type = c("auto", "structure", "admixture"), ind = NULL,
  pattern = "\\\\.Q$", recursive = FALSE, pop_group = NULL, ...)
}
\arguments{
\item{file}{Path to one or more ADMIXTURE `.Q` files, a directory containing `.Q` files, or a limited STRUCTURE-like numeric matrix.}
\item{type}{Input format: `admixture`, `structure`, or `auto`.}
\item{ind}{Optional sample label file or data frame.}
\item{pattern}{File pattern used when `file` is a directory.}
\item{recursive}{Search directories recursively.}
\item{pop_group}{Optional path or data frame with two columns, `sample` and `pop`, used for population group labels, sorting, and facets.}
\item{...}{Additional arguments passed to `read.table()`.}
}
\description{
Imports admixture proportions into long-format `ggpop_admix` S3 data for `plot_admix()` and `geom_admix()`. Directories are read as full multi-K ADMIXTURE result sets. `import_admix()` is the user-facing interface; `import_admixture()` is kept as a compatibility alias. When `pop_group` is supplied, population labels are joined by `sample_id` and drive pophelper-style group facets and sorting.
}
