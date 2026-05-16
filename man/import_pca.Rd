\name{import_pca}
\alias{import_pca}
\alias{compute_pca}
\title{Import or compute PCA results}
\usage{
import_pca(file, type = c("auto", "plink", "gcta"), eigenval = NULL,
  pop_group = NULL, ...)
compute_pca(genotype, method = c("flashpca"), pop_group = NULL, ...)
}
\arguments{
\item{file}{Path to a PLINK or GCTA eigenvector file.}
\item{type}{Input format: `plink`, `gcta`, or `auto`.}
\item{eigenval}{Optional eigenvalue file.}
\item{pop_group}{Optional path or data frame with two columns, `sample` and `pop`, used for population colors.}
\item{genotype}{Genotype matrix or flashpcaR-supported input.}
\item{method}{PCA method. Currently `flashpca`, backed by `flashpcaR`.}
\item{...}{Additional arguments.}
}
\description{
Imports PCA coordinates into `ggpop_pca`, or computes PCA using the optional `flashpcaR` backend. When `pop_group` is supplied, PCA plots map population groups to ggpop's unified discrete colour scale by default.
}
