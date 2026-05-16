\name{ggpop}
\alias{ggpop}
\alias{ggpop.ggpop_gwas}
\alias{ggpop.ggpop_pca}
\alias{ggpop.ggpop_admix}
\title{Create a ggplot object from ggpop data}
\usage{
ggpop(data, mapping = ggplot2::aes(), ..., module = NULL)
}
\arguments{
\item{data}{A `ggpop_gwas`, `ggpop_pca`, or `ggpop_admix` object.}
\item{mapping}{Default ggplot2 aesthetic mapping.}
\item{...}{Reserved for future module-specific options.}
\item{module}{Optional module override.}
}
\description{
Creates a ggplot2 object from typed ggpop data so users can add ggpop geoms with the standard `+` syntax.
}
