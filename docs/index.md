# ggPopi

`ggPopi` provides tidy, publication-oriented `ggplot2` workflows for
common population-genomics plots. It combines typed import helpers,
direct `plot_*()` functions, and composable `ggpop() + geom_*()` layers.

Supported modules include GWAS Manhattan and Q-Q plots, PCA, admixture,
population statistics, LD decay, selective sweep scans, introgression
summaries, and demographic / effective population size histories.

## Installation

Install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("WWz33/ggPopi")
```

Core plotting uses CRAN-available dependencies. Optional integrations
use:

- [`flashpcaR`](https://github.com/WWz33/flashpca/tree/master/flashpcaR)
  for `compute_pca(method = "flashpca")`;
- [`pophelper`](https://github.com/royfrancis/pophelper) for direct
  `plotQ()` compatibility helpers.

## Quick Start

``` r
library(ggPopi)

gwas <- import_gwas(
  system.file("extdata", "gwas", "gcta.mlma", package = "ggPopi"),
  type = "gcta"
)

plot_manha(gwas)
```

![Manhattan plot with chromosomes on the x-axis and minus log10 p-values
on the y-axis.](reference/figures/readme-manhattan.png)

The same imported object can be used through the layered ggplot
extension path:

``` r
gwas |>
  ggpop() +
  geom_manha()
```

## Interface

Every module follows the same shape:

1.  `import_*()` reads tool output into a typed data frame.
2.  `plot_*()` returns a complete `ggplot` object with module defaults.
3.  `ggpop() + geom_*()` provides the same visual grammar inside a
    ggplot pipeline.

| Module | Import | Direct plot | ggplot extension | Guide |
|----|----|----|----|----|
| GWAS | [`import_gwas()`](https://wwz33.github.io/ggPopi/reference/import_gwas.md) | [`plot_manha()`](https://wwz33.github.io/ggPopi/reference/plot_manha.md), [`plot_qq()`](https://wwz33.github.io/ggPopi/reference/plot_qq.md) | [`geom_manha()`](https://wwz33.github.io/ggPopi/reference/geom_manha.md), [`geom_qq()`](https://wwz33.github.io/ggPopi/reference/geom_qq.md) | [GWAS](https://wwz33.github.io/ggPopi/articles/guides/gwas.html) |
| PCA | [`import_pca()`](https://wwz33.github.io/ggPopi/reference/import_pca.md), [`compute_pca()`](https://wwz33.github.io/ggPopi/reference/import_pca.md) | [`plot_pca()`](https://wwz33.github.io/ggPopi/reference/plot_pca.md) | [`geom_pca()`](https://wwz33.github.io/ggPopi/reference/geom_pca.md) | [PCA](https://wwz33.github.io/ggPopi/articles/guides/pca.html) |
| Admixture | [`import_admix()`](https://wwz33.github.io/ggPopi/reference/import_admix.md) | [`plot_admix()`](https://wwz33.github.io/ggPopi/reference/plot_admix.md), [`plot_admix2()`](https://wwz33.github.io/ggPopi/reference/plot_admix2.md) | [`geom_admix()`](https://wwz33.github.io/ggPopi/reference/geom_admix.md), [`geom_admix2()`](https://wwz33.github.io/ggPopi/reference/plot_admix2.md) | [Admixture](https://wwz33.github.io/ggPopi/articles/guides/admixture.html) |
| Population statistics | [`import_stats()`](https://wwz33.github.io/ggPopi/reference/import_stats.md) | [`plot_stats()`](https://wwz33.github.io/ggPopi/reference/geom_stats.md) | [`geom_stats()`](https://wwz33.github.io/ggPopi/reference/geom_stats.md) | [Stats](https://wwz33.github.io/ggPopi/articles/guides/stats.html) |
| LD decay | [`import_ld_decay()`](https://wwz33.github.io/ggPopi/reference/import_ld_decay.md) | [`plot_ld_decay()`](https://wwz33.github.io/ggPopi/reference/geom_ld_decay.md) | [`geom_ld_decay()`](https://wwz33.github.io/ggPopi/reference/geom_ld_decay.md) | [LD decay](https://wwz33.github.io/ggPopi/articles/guides/ld-decay.html) |
| Selective sweeps | [`import_selection()`](https://wwz33.github.io/ggPopi/reference/import_selection.md) | [`plot_selection()`](https://wwz33.github.io/ggPopi/reference/geom_selection.md) | [`geom_selection()`](https://wwz33.github.io/ggPopi/reference/geom_selection.md) | [Selection](https://wwz33.github.io/ggPopi/articles/guides/selection.html) |
| Introgression | [`import_introgression()`](https://wwz33.github.io/ggPopi/reference/import_introgression.md) | [`plot_introgression()`](https://wwz33.github.io/ggPopi/reference/geom_introgression.md) | [`geom_introgression()`](https://wwz33.github.io/ggPopi/reference/geom_introgression.md) | [Introgression](https://wwz33.github.io/ggPopi/articles/guides/introgression.html) |
| Demographic / Ne history | [`import_ne_history()`](https://wwz33.github.io/ggPopi/reference/import_ne_history.md), [`import_demographic_history()`](https://wwz33.github.io/ggPopi/reference/import_ne_history.md) | [`plot_ne_history()`](https://wwz33.github.io/ggPopi/reference/geom_ne_history.md), [`plot_demographic_history()`](https://wwz33.github.io/ggPopi/reference/geom_ne_history.md) | [`geom_ne_history()`](https://wwz33.github.io/ggPopi/reference/geom_ne_history.md), [`geom_demographic_history()`](https://wwz33.github.io/ggPopi/reference/geom_ne_history.md) | [Ne history](https://wwz33.github.io/ggPopi/articles/guides/ne-history.html) |

## Documentation

- Getting started: <https://wwz33.github.io/ggPopi/articles/ggPopi.html>
- Function reference: <https://wwz33.github.io/ggPopi/reference/>
- Compatibility helpers:
  <https://wwz33.github.io/ggPopi/articles/guides/compatibility.html>

## Design

`ggPopi` keeps the user-facing API small while preserving
module-specific visual defaults. Direct `plot_*()` functions are the
reference style, and matching `geom_*()` layers make those defaults
available in ggplot compositions.

Palette and theme helpers such as
[`ggpop_palette()`](https://rdrr.io/pkg/ggPopi/man/pop_palettes.html),
[`scale_colour_ggpop()`](https://rdrr.io/pkg/ggPopi/man/pop_palettes.html),
[`scale_fill_ggpop()`](https://rdrr.io/pkg/ggPopi/man/pop_palettes.html),
and
[`theme_tidyplot()`](https://wwz33.github.io/ggPopi/reference/themes.md)
provide shared styling across modules.
