<!-- README.md is maintained directly for now. -->

# ggpop <a href="https://wwz33.github.io/ggpop/"><img src="man/figures/readme-pca.png" align="right" height="139" alt="Scatter chart of PCA results with samples grouped by population colour." /></a>

<!-- badges: start -->

[![R](https://img.shields.io/badge/R-%3E%3D%204.1-blue.svg)](https://www.r-project.org/)
[![ggplot2](https://img.shields.io/badge/ggplot2-extension-2C3E50.svg)](https://ggplot2.tidyverse.org/)
[![pkgdown](https://img.shields.io/badge/docs-pkgdown-75AADB.svg)](https://wwz33.github.io/ggpop/)
<!-- badges: end -->

The goal of `ggpop` is to streamline publication-ready population-genomics
visualization in R. It combines typed import helpers, direct plotting functions,
and composable `ggplot2` extension layers for GWAS, PCA, and admixture results.
It also includes a population genomics statistics module for windowed FST, pi,
Tajima's D, Dxy, and Watterson's theta summaries, LD decay curves, plus
selective sweep scan plots for selscan and XPCLR outputs, and introgression
summaries from Dsuite, genomics_general, TreeMix-style edge tables, and
ADMIXTOOLS2 qpGraph outputs. It also includes effective population size history
curves from PSMC, MSMC2, SMC++, and Stairway Plot 2 outputs.

`ggpop` focuses on a tidy workflow:

``` r
import_gwas("assoc.mlma", type = "gcta") |>
  plot_manha()

import_gwas("assoc.mlma", type = "gcta") |>
  ggpop() +
  geom_manha()
```

Both paths return `ggplot` objects. The direct `plot_*()` functions define the
publication-style visual contract, and the matching `geom_*()` layers follow the
same defaults inside a `ggpop()` pipeline.

GWAS Manhattan plots support explicit palette control:

``` r
plot_manha(gwas, palette = "publication")
plot_manha(gwas, palette = c("#4E79A7", "#F28E2B"), binary = TRUE)
plot_manha(gwas, threshold_color = "#E15759", suggestive_color = "#4E79A7")
```

## Installation

You can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("WWz33/ggpop")
```

The core package uses CRAN-available dependencies for native plotting. The GWAS
module includes internal fastman-style Manhattan and Q-Q plotting logic, so
ordinary GWAS plots do not require installing `fastman`.

- [`flashpcaR`](https://github.com/WWz33/flashpca/tree/master/flashpcaR) for `compute_pca(method = "flashpca")`;
- [`pophelper`](https://github.com/royfrancis/pophelper) for direct `plotQ()` compatibility helpers.

Dependency repository policy:

- `pophelper` is unmodified and points to the original upstream repository.
- `flashpcaR` required Windows source-install fixes and points to
  <https://github.com/WWz33/flashpca>.

## Usage

Here are the main workflows.

Also have a look at the [getting started
guide](https://wwz33.github.io/ggpop/articles/ggpop.html) and the [full
documentation](https://wwz33.github.io/ggpop/reference/).

``` r
library(ggpop)

import_gwas("assoc.mlma", type = "gcta") |>
  plot_manha()
```

<p align="center"><img src="man/figures/readme-manhattan.png" width="75%" alt="Manhattan plot. Chromosomes are arranged along the x-axis and minus log10 p-values are on the y-axis, with alternating chromosome colours and horizontal genome-wide threshold lines." /></p>

``` r
import_gwas("assoc.mlma", type = "gcta") |>
  ggpop() +
  geom_manha()
```

``` r
import_pca(
  "plink.eigenvec",
  type = "plink",
  pop_group = "pop_group.txt"
) |>
  plot_pca()
```

<p align="center"><img src="man/figures/readme-pca.png" width="60%" alt="Scatter chart. Principal component 1 is on the x-axis and principal component 2 is on the y-axis, with point colour encoding population group." /></p>

`pop_group` is optional at plot time:

``` r
plot_pca(pca, pop_group = FALSE)
```

``` r
import_admix(
  "admixture_results/",
  type = "admixture",
  ind = "samples.fam",
  pop_group = "pop_group.txt"
) |>
  plot_admix(k = 3, sort = "all", order_group = TRUE)
```

<p align="center"><img src="man/figures/readme-admixture.png" width="60%" alt="Stacked bar chart. Individuals are arranged along the x-axis and ancestry proportions fill each bar, with group labels separating population groups." /></p>

`pop_group` is optional at plot time:

``` r
plot_admix(admix, k = 3, pop_group = FALSE)
```

``` r
import_admix(
  "admixture_results/",
  type = "admixture",
  ind = "samples.fam",
  pop_group = "pop_group.txt"
) |>
  ggpop() +
  geom_admix(k = 3, sort = "all", order_group = TRUE)
```

Population groups use a simple two-column `sample pop` file:

``` text
sample  pop
P001    PopA
P002    PopB
```

``` r
import_stats("pixy_results/", type = "pixy") |>
  plot_stats(stat = "all", chr = "chr2L")
```

<p align="center"><img src="man/figures/readme-stats.png" width="60%" alt="Faceted line plot. Population genomics statistics are stacked vertically for chromosome chr2L, genomic position in megabases is on the shared x-axis, and each panel has its own statistic value scale." /></p>

``` r
import_stats("vcftools_results/", type = "vcftools") |>
  plot_stats(stat = "all", chr = "chr2L")
```

``` r
ld_decay <- import_ld_decay("PopLDdecay_results/", type = "poplddecay")

plot_ld_decay(ld_decay, style = "point")
plot_ld_decay(ld_decay, style = "line")
```

<p align="center"><img src="man/figures/readme-ld-decay.png" width="60%" alt="LD decay point plot. Pairwise distance in kilobases is on the x-axis and mean LD r squared is on the y-axis, with points coloured by population label." /></p>

``` r
selscan_chr1 <- import_selection(
  "selscan_results/",
  ihs = "chr1.ihs.out.100bins.norm",
  nsl = "chr1.nsl.out.100bins.norm",
  xpehh = "chr1.xpehh.out.norm",
  xpnsl = "chr1.xpnsl.out.norm",
  type = "selscan"
)

plot_selection(
  selscan_chr1,
  stat = c("ihs", "nsl", "xpehh", "xpnsl"),
  chr = "1"
)
```

<p align="center"><img src="man/figures/readme-selection.png" width="60%" alt="Faceted selection scan on chromosome 1. iHS, nSL, XP-EHH, and XP-nSL are stacked vertically with genomic position in megabases on the x-axis." /></p>

Selection plots support signed or absolute score views. Fixed thresholds such
as `threshold = 2` draw score cutoffs directly, while
`threshold = 0.95, threshold_type = "quantile"` derives a cutoff from the
filtered scan values. Genome-wide calls default to a Manhattan-like chromosome
axis; calls with `chr`, `start`, or `end` default to a single-region view.

``` r
intro <- import_introgression(
  "introgression/genomics_general/",
  type = "genomics_general"
)

plot_introgression(intro, stat = c("D", "fdM"))
```

<p align="center"><img src="man/figures/readme-introgression.png" width="60%" alt="Manhattan-like introgression plot. D and fdM window statistics are shown in stacked panels over chromosomes, with points coloured by chromosome." /></p>

Trio-level D-statistics and graph edge tables use the same import and direct
plot shape:

``` r
import_introgression("Dtrios.tsv", type = "dsuite_dtrios") |>
  plot_introgression()

import_introgression("qpgraph_edges.tsv", type = "qpgraph") |>
  plot_introgression()
```

``` r
ne_history <- import_ne_history("smcpp_model.csv", type = "smcpp")

plot_ne_history(ne_history)
```

<p align="center"><img src="man/figures/readme-ne-history.png" width="60%" alt="Effective population size history line plot. Time before present is on the x-axis and effective population size is on the y-axis, with separate curves for two populations." /></p>

## Interface

The recommended user-facing API is intentionally small.

| Module | Import | Direct plot | ggplot extension |
|---|---|---|---|
| GWAS Manhattan | `import_gwas()` | `plot_manha()` | `ggpop() + geom_manha()` |
| GWAS Q-Q | `import_gwas()` | `plot_qq()` | `ggpop() + geom_qq()` |
| PCA | `import_pca()` / `compute_pca()` | `plot_pca()` | `ggpop() + geom_pca()` |
| Admixture | `import_admix()` | `plot_admix()` | `ggpop() + geom_admix()` |
| Population statistics | `import_stats()` | `plot_stats()` | `ggpop() + geom_stats()` |
| LD decay | `import_ld_decay(method = ...)` | `plot_ld_decay(measure = ...)` | `ggpop() + geom_ld_decay(measure = ...)` |
| Selective sweeps | `import_selection()` | `plot_selection()` | `ggpop() + geom_selection()` |
| Introgression | `import_introgression()` | `plot_introgression()` | `ggpop() + geom_introgression()` |
| Ne history | `import_ne_history()` | `plot_ne_history()` | `ggpop() + geom_ne_history()` |
| Population groups | `import_pop_group()` | used by plot functions | used by geom layers |

Advanced compatibility helpers remain available for users who need direct
backend behavior, but ordinary workflows should prefer the `import_*() |>
plot_*()` and `import_*() |> ggpop() + geom_*()` interfaces.

## Color Schemes

`ggpop` provides a unified discrete palette entry for population-genomics
categorical variables. PCA population colours and admixture cluster fills use the
same publication-oriented palette system by default.

``` r
ggpop_palette(5, "population")
ggpop_palette(5, "admixture")
scale_colour_ggpop("population")
scale_fill_ggpop("admixture")
```

## Fixed Installation Issues

This version includes dependency fixes needed for reliable source installation:

- replaced `flashpcaR/flashpcaR/src/*.cpp` and `src/*.h` path stubs with real source files;
- changed `flashpcaR/flashpcaR/src/Makevars` and `Makevars.win` from `CXX11` to `CXX14`;
- embedded fastman-style Manhattan and Q-Q plotting behavior in native ggplot layers.

## Documentation

- [GWAS guide](https://wwz33.github.io/ggpop/articles/guides/gwas.html)
  Manhattan and Q-Q plotting workflows
- [PCA guide](https://wwz33.github.io/ggpop/articles/guides/pca.html)
  PCA imports, population colours, and plotting
- [Admixture guide](https://wwz33.github.io/ggpop/articles/guides/admixture.html)
  ADMIXTURE/STRUCTURE imports, group labels, and sorting
- [Population statistics guide](https://wwz33.github.io/ggpop/articles/guides/stats.html)
  Windowed FST, pi, Tajima's D, Dxy, and Watterson's theta plotting
- [LD decay guide](https://wwz33.github.io/ggpop/articles/guides/ld-decay.html)
  PopLDdecay imports with point and line plot styles
- [Selective sweep guide](https://wwz33.github.io/ggpop/articles/guides/selection.html)
  selscan and XPCLR imports, signed or absolute score plots, and quantile thresholds
- [Introgression guide](https://wwz33.github.io/ggpop/articles/guides/introgression.html)
  Dsuite, genomics_general, TreeMix-style, and qpGraph introgression plotting
- [Ne history guide](https://wwz33.github.io/ggpop/articles/guides/ne-history.html)
  PSMC, MSMC2, SMC++, and Stairway Plot 2 effective population size histories

## Acknowledgements

`ggpop` builds on `ggplot2` and follows tidy plotting conventions inspired by
packages such as `tidyplots`. Optional compatibility paths reference
`flashpcaR` and `pophelper`, while GWAS Manhattan and Q-Q plots use native
ggplot layers with `fastman`-style data transformation and layout.
