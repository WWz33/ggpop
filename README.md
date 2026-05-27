<!-- README.md is maintained directly for now. -->

# ggPopi <a href="https://wwz33.github.io/ggPopi/"><img src="man/figures/logo.png" align="right" height="170" alt="ggPopi hexagon sticker with population-genomics plot marks." /></a>

<!-- badges: start -->

[![R](https://img.shields.io/badge/R-%3E%3D%204.1-blue.svg)](https://www.r-project.org/)
[![ggplot2](https://img.shields.io/badge/ggplot2-extension-2C3E50.svg)](https://ggplot2.tidyverse.org/)
[![pkgdown](https://img.shields.io/badge/docs-pkgdown-75AADB.svg)](https://wwz33.github.io/ggPopi/)
<!-- badges: end -->

`ggPopi` provides tidy, publication-oriented `ggplot2` workflows for common
population-genomics plots. It combines typed import helpers, direct `plot_*()`
functions, and composable `ggpop() + geom_*()` layers.

Supported modules include GWAS Manhattan and Q-Q plots, PCA, admixture,
population statistics, LD decay, selective sweep scans, introgression summaries,
and demographic / effective population size histories.

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("WWz33/ggPopi")
```

Core plotting uses CRAN-available dependencies. Optional integrations use:

- [`flashpcaR`](https://github.com/WWz33/flashpca/tree/master/flashpcaR) for
  `compute_pca(method = "flashpca")`;
- [`pophelper`](https://github.com/royfrancis/pophelper) for direct `plotQ()`
  compatibility helpers.

## Quick Start

``` r
library(ggPopi)

gwas <- import_gwas(
  system.file("extdata", "gwas", "gcta.mlma", package = "ggPopi"),
  type = "gcta"
)

plot_manha(gwas)
```

<p align="center"><img src="man/figures/readme-manhattan.png" width="75%" alt="Manhattan plot with chromosomes on the x-axis and minus log10 p-values on the y-axis." /></p>

The same imported object can be used through the layered ggplot extension path:

``` r
gwas |>
  ggpop() +
  geom_manha()
```

## Interface

Every module follows the same shape:

1. `import_*()` reads tool output into a typed data frame.
2. `plot_*()` returns a complete `ggplot` object with module defaults.
3. `ggpop() + geom_*()` provides the same visual grammar inside a ggplot pipeline.

| Module | Import | Direct plot | ggplot extension | Guide |
|---|---|---|---|---|
| GWAS | `import_gwas()` | `plot_manha()`, `plot_qq()` | `geom_manha()`, `geom_qq()` | [GWAS](https://wwz33.github.io/ggPopi/articles/guides/gwas.html) |
| PCA | `import_pca()`, `compute_pca()` | `plot_pca()` | `geom_pca()` | [PCA](https://wwz33.github.io/ggPopi/articles/guides/pca.html) |
| Admixture | `import_admix()` | `plot_admix()`, `plot_admix2()` | `geom_admix()`, `geom_admix2()` | [Admixture](https://wwz33.github.io/ggPopi/articles/guides/admixture.html) |
| Population statistics | `import_stats()` | `plot_stats()` | `geom_stats()` | [Stats](https://wwz33.github.io/ggPopi/articles/guides/stats.html) |
| LD decay | `import_ld_decay()` | `plot_ld_decay()` | `geom_ld_decay()` | [LD decay](https://wwz33.github.io/ggPopi/articles/guides/ld-decay.html) |
| Selective sweeps | `import_selection()` | `plot_selection()` | `geom_selection()` | [Selection](https://wwz33.github.io/ggPopi/articles/guides/selection.html) |
| Introgression | `import_introgression()` | `plot_introgression()` | `geom_introgression()` | [Introgression](https://wwz33.github.io/ggPopi/articles/guides/introgression.html) |
| Demographic / Ne history | `import_ne_history()`, `import_demographic_history()` | `plot_ne_history()`, `plot_demographic_history()` | `geom_ne_history()`, `geom_demographic_history()` | [Ne history](https://wwz33.github.io/ggPopi/articles/guides/ne-history.html) |

## Documentation

- Getting started: <https://wwz33.github.io/ggPopi/articles/ggPopi.html>
- Function reference: <https://wwz33.github.io/ggPopi/reference/>
- Compatibility helpers: <https://wwz33.github.io/ggPopi/articles/guides/compatibility.html>

## Design

`ggPopi` keeps the user-facing API small while preserving module-specific visual
defaults. Direct `plot_*()` functions are the reference style, and matching
`geom_*()` layers make those defaults available in ggplot compositions.

Palette and theme helpers such as `ggpop_palette()`, `scale_colour_ggpop()`,
`scale_fill_ggpop()`, and `theme_tidyplot()` provide shared styling across
modules.
