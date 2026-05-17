\name{import_gwas}
\alias{import_gwas}
\title{Import GWAS result files}
\usage{
import_gwas(file, type = c("auto", "gcta", "gemma", "emmax"), ...)
}
\arguments{
\item{file}{Path to a GWAS result file.}
\item{type}{Input format: `gcta`, `gemma`, `emmax`, or `auto`.}
\item{...}{Additional arguments passed to `read.table()`.}
}
\description{
Imports supported GWAS results into a `ggpop_gwas` data frame with normalized `chr`, `pos`, `p`, and `snp` columns.
}
