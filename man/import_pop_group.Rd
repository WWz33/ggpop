\name{import_pop_group}
\alias{import_pop_group}
\title{Import population group labels}
\usage{
import_pop_group(file, sample_col = "sample", pop_col = "pop", ...)
}
\arguments{
\item{file}{Path to a delimited text file.}
\item{sample_col}{Sample ID column name. Defaults to `sample`.}
\item{pop_col}{Population group column name. Defaults to `pop`.}
\item{...}{Additional arguments passed to `read.table()`.}
}
\description{
Imports a two-column population group file for PCA colours and admixture group labels. The default format is `sample pop`.
}
\examples{
groups <- import_pop_group(system.file("extdata", "pop_group.txt", package = "ggpop"))
}
