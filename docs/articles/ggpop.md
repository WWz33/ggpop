# Getting Started with ggpop

`ggpop` is a ggplot2 extension package for population genetics
workflows. The package keeps each module in the same tidy shape:

- `import_*()` functions create typed S3 objects.
- `plot_*()` functions return full `ggplot` objects.
- [`ggpop()`](https://wwz33.github.io/ggpop/reference/ggpop.md) +
  `geom_*()` build layered ggplot extensions.
- Advanced compatibility helpers remain exported for users who need
  original-package behavior.

## Module API map

| Module | Import | Direct plot | ggplot extension path | Advanced / compatibility |
|----|----|----|----|----|
| GWAS Manhattan | [`import_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md) | [`plot_manha()`](https://wwz33.github.io/ggpop/reference/plot_manha.md) | `ggpop() + geom_manha()` | internal fastman-style layout |
| GWAS Q-Q | [`import_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md) | [`plot_qq()`](https://wwz33.github.io/ggpop/reference/plot_qq.md) | `ggpop() + ggpop::geom_qq()` | internal fastqq-style layout |
| PCA | [`import_pca()`](https://wwz33.github.io/ggpop/reference/import_pca.md) / [`compute_pca()`](https://wwz33.github.io/ggpop/reference/import_pca.md) | [`plot_pca()`](https://wwz33.github.io/ggpop/reference/plot_pca.md) | `ggpop() + geom_pca()` | `compute_pca(method = "flashpca")` |
| Admixture | [`import_admix()`](https://wwz33.github.io/ggpop/reference/import_admixture.md) / [`import_admixture()`](https://wwz33.github.io/ggpop/reference/import_admixture.md) | [`plot_admix()`](https://wwz33.github.io/ggpop/reference/plot_admix.md) | `ggpop() + geom_admix()` | see compatibility article |
| Population statistics | [`import_stats()`](https://wwz33.github.io/ggpop/reference/import_stats.md) | [`plot_stats()`](https://wwz33.github.io/ggpop/reference/geom_stats.md) | `ggpop() + geom_stats()` | pixy and vcftools summaries |

## Core pattern

``` r
gwas <- import_gwas(ggpop_extdata("gwas", "gcta.mlma"), type = "gcta")
pca <- import_pca(
  ggpop_extdata("pca", "gcta.eigenvec"),
  type = "gcta",
  eigenval = ggpop_extdata("pca", "gcta.eigenval"),
  pop_group = ggpop_extdata("pop_group.txt")
)
admix <- import_admix(
  ggpop_extdata("admixture"),
  type = "admixture",
  ind = ggpop_extdata("snp", "finalsnp_ld.fam"),
  pop_group = ggpop_extdata("pop_group.txt")
)
stats <- import_stats(
  ggpop_extdata("Population_genomics_statistics", "pixy"),
  type = "pixy"
)
```

Each importer returns a typed object:

``` r
class(gwas)
#> [1] "ggpop_gwas" "data.frame"
class(pca)
#> [1] "ggpop_pca"  "data.frame"
class(admix)
#> [1] "ggpop_admix" "data.frame"
class(stats)
#> [1] "ggpop_stats" "data.frame"
```

## Tidy plotting style

Every module has two user-facing plotting paths. Use the direct
`plot_*()` function when you want the reference plot immediately, or use
[`ggpop()`](https://wwz33.github.io/ggpop/reference/ggpop.md) plus the
module `geom_*()` when you want to compose with other ggplot layers.

The direct path:

``` r
gwas |>
  plot_manha(title = "GCTA Manhattan")
```

![Manhattan plot. Chromosomes are arranged along the x-axis and minus
log10 p-values are on the y-axis. Points form chromosome-specific bands
with horizontal reference lines marking suggestive and genome-wide
significance thresholds.](ggpop_files/figure-html/unnamed-chunk-3-1.png)

The ggplot extension path:

``` r
gwas |>
  ggpop() +
  geom_manha()
```

![Manhattan plot from the layered ggplot extension path. Chromosomes are
arranged along the x-axis and minus log10 p-values are on the y-axis,
matching the direct plot_manha visual
style.](ggpop_files/figure-html/unnamed-chunk-4-1.png)

The same pattern applies across modules:

``` r
gwas |> ggpop() + ggpop::geom_qq()
```

![Q-Q scatter plot. Expected minus log10 p-values are on the x-axis and
observed minus log10 p-values are on the y-axis, with points compared
against a diagonal reference
line.](ggpop_files/figure-html/unnamed-chunk-5-1.png)

``` r
pca |> ggpop() + geom_pca()
```

![Scatter chart. Principal component 1 is on the x-axis and principal
component 2 is on the y-axis, with point colour encoding population
groups.](ggpop_files/figure-html/unnamed-chunk-5-2.png)

``` r
admix |> ggpop() + geom_admix(k = 3, order_group = TRUE)
```

![Stacked bar chart. Individuals are arranged along the x-axis and
ancestry proportions are stacked within each bar for K equals
3.](ggpop_files/figure-html/unnamed-chunk-5-3.png)

## Population groups and discrete colours

Population grouping uses a simple two-column file:

``` r
head(import_pop_group(ggpop_extdata("pop_group.txt")))
#>   sample_id  pop
#> 1      P001 PopC
#> 2      P004 PopB
#> 3      P006 PopC
#> 4      P009 PopA
#> 5      P010 PopB
#> 6      P012 PopB
```

The same file drives PCA colours and admixture group labels:

``` r
pca |> plot_pca(title = "GCTA PCA by population")
```

![Scatter chart. Principal component 1 is on the x-axis and principal
component 2 is on the y-axis, with point colour encoding imported
population groups.](ggpop_files/figure-html/unnamed-chunk-7-1.png)

``` r
admix |> plot_admix(k = 3, order_group = TRUE, show_group_labels = TRUE)
```

![Stacked bar chart. Individuals are arranged along the x-axis and
ancestry proportions are stacked within each bar, with population group
labels used for
ordering.](ggpop_files/figure-html/unnamed-chunk-7-2.png)

All categorical colours use a unified discrete palette entry:

``` r
ggpop_palette(4, "population")
#> [1] "#0072B2" "#009E73" "#E69F00" "#CC79A7"
ggpop_palette(8, "admixture")
#> [1] "#4E79A7" "#F28E2B" "#E15759" "#76B7B2" "#EDC948" "#9C755F"
#> [7] "#2F4B7C" "#FF7C43"
```

## What to use

- Use
  [`plot_manha()`](https://wwz33.github.io/ggpop/reference/plot_manha.md)
  and `ggpop() + geom_manha()` for Manhattan plots.
- Use [`plot_qq()`](https://wwz33.github.io/ggpop/reference/plot_qq.md)
  and `ggpop() + ggpop::geom_qq()` for Q-Q plots.
- Use
  [`plot_pca()`](https://wwz33.github.io/ggpop/reference/plot_pca.md)
  and `ggpop() + geom_pca()` for PCA plots.
- Use
  [`plot_admix()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
  and `ggpop() + geom_admix()` for admixture plots.
- Use
  [`plot_stats()`](https://wwz33.github.io/ggpop/reference/geom_stats.md)
  and `ggpop() + geom_stats()` for windowed population statistics.
- Treat the direct `plot_*()` functions as the reference style;
  `geom_*()` is the same look inside a ggplot composition.
- Use the compatibility article only when you need original `pophelper`
  workflows.
