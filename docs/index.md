# ggpop [![Scatter chart of PCA results with samples grouped by population colour.](reference/figures/readme-pca.png)](https://wwz33.github.io/ggpop/)

The goal of `ggpop` is to streamline publication-ready
population-genomics visualization in R. It combines typed import
helpers, direct plotting functions, and composable `ggplot2` extension
layers for GWAS, PCA, and admixture results.

`ggpop` focuses on a tidy workflow:

``` r
import_gwas("assoc.mlma", type = "gcta") |>
  plot_manha()

import_gwas("assoc.mlma", type = "gcta") |>
  ggpop() +
  geom_manha()
```

Both paths return `ggplot` objects. The direct `plot_*()` functions
define the publication-style visual contract, and the matching
`geom_*()` layers follow the same defaults inside a
[`ggpop()`](https://wwz33.github.io/ggpop/reference/ggpop.md) pipeline.

GWAS Manhattan plots support explicit palette control:

``` r
plot_manha(gwas, palette = "publication")
plot_manha(gwas, palette = c("#123456", "#654321"), binary = TRUE)
```

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("WWz33/ggpop")
```

The core package uses CRAN-available dependencies for native plotting.
Optional compatibility backends are installed from GitHub-aware
`Remotes` when requested:

- [`fastman`](https://github.com/adhikari-statgen-lab/fastman) for
  original Manhattan and Q-Q backends;
- [`flashpcaR`](https://github.com/WWz33/flashpca/tree/master/flashpcaR)
  for `compute_pca(method = "flashpca")`;
- [`pophelper`](https://github.com/royfrancis/pophelper) for direct
  `plotQ()` compatibility helpers.

Dependency repository policy:

- `fastman` is unmodified and points to the original upstream
  repository.
- `pophelper` is unmodified and points to the original upstream
  repository.
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
  plot_manha(title = "GCTA Manhattan", use_fastman = FALSE)
```

![Manhattan plot. Chromosomes are arranged along the x-axis and minus
log10 p-values are on the y-axis, with alternating chromosome colours
and horizontal genome-wide threshold
lines.](reference/figures/readme-manhattan.png)

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
  plot_pca(title = "PCA by population")
```

![Scatter chart. Principal component 1 is on the x-axis and principal
component 2 is on the y-axis, with point colour encoding population
group.](reference/figures/readme-pca.png)

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

![Stacked bar chart. Individuals are arranged along the x-axis and
ancestry proportions fill each bar, with group labels separating
population groups.](reference/figures/readme-admixture.png)

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

## Interface

The recommended user-facing API is intentionally small.

| Module | Import | Direct plot | ggplot extension |
|----|----|----|----|
| GWAS Manhattan | [`import_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md) | [`plot_manha()`](https://wwz33.github.io/ggpop/reference/plot_manha.md) | `ggpop() + geom_manha()` |
| GWAS Q-Q | [`import_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md) | [`plot_qq()`](https://wwz33.github.io/ggpop/reference/plot_qq.md) | `ggpop() + geom_qq()` |
| PCA | [`import_pca()`](https://wwz33.github.io/ggpop/reference/import_pca.md) / [`compute_pca()`](https://wwz33.github.io/ggpop/reference/import_pca.md) | [`plot_pca()`](https://wwz33.github.io/ggpop/reference/plot_pca.md) | `ggpop() + geom_pca()` |
| Admixture | [`import_admix()`](https://wwz33.github.io/ggpop/reference/import_admixture.md) | [`plot_admix()`](https://wwz33.github.io/ggpop/reference/plot_admix.md) | `ggpop() + geom_admix()` |
| Population groups | [`import_pop_group()`](https://wwz33.github.io/ggpop/reference/import_pop_group.md) | used by plot functions | used by geom layers |

Advanced compatibility helpers remain available for users who need
direct backend behavior, but ordinary workflows should prefer the
`import_*() |> plot_*()` and `import_*() |> ggpop() + geom_*()`
interfaces.

## Color Schemes

`ggpop` provides a unified discrete palette entry for
population-genomics categorical variables. PCA population colours and
admixture cluster fills use the same publication-oriented palette system
by default.

``` r
ggpop_palette(5, "population")
ggpop_palette(5, "admixture")
scale_colour_ggpop("population")
scale_fill_ggpop("admixture")
```

## Fixed Installation Issues

This version includes dependency fixes needed for reliable source
installation:

- added `Remotes` for GitHub-only optional dependencies;
- kept unmodified `fastman` and `pophelper` pointed at upstream
  repositories;
- forked `flashpcaR` to `WWz33/flashpca` for Windows source
  installation;
- replaced `flashpcaR/flashpcaR/src/*.cpp` and `src/*.h` path stubs with
  real source files;
- changed `flashpcaR/flashpcaR/src/Makevars` and `Makevars.win` from
  `CXX11` to `CXX14`;
- fixed optional backend argument forwarding for calls such as
  `plot_manha(use_fastman = TRUE)`.

## Documentation

- [Package index](https://wwz33.github.io/ggpop/reference/) Overview of
  all ggpop functions

- [Get started](https://wwz33.github.io/ggpop/articles/ggpop.html)
  Getting started guide

- [GWAS guide](https://wwz33.github.io/ggpop/articles/guides/gwas.html)
  Manhattan and Q-Q plotting workflows

- [PCA guide](https://wwz33.github.io/ggpop/articles/guides/pca.html)
  PCA imports, population colours, and plotting

- [Admixture
  guide](https://wwz33.github.io/ggpop/articles/guides/admixture.html)
  ADMIXTURE/STRUCTURE imports, group labels, and sorting

- [Color
  schemes](https://wwz33.github.io/ggpop/articles/guides/color-schemes.html)
  Unified discrete palettes for population-genomics plots

## Acknowledgements

`ggpop` builds on `ggplot2` and follows tidy plotting conventions
inspired by packages such as `tidyplots`. Optional compatibility paths
reference `fastman`, `flashpcaR`, and `pophelper` while keeping the
native ggplot implementation usable without those packages.
