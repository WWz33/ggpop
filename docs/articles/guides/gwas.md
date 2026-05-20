# GWAS plots

`ggpop` supports Manhattan and Q-Q plots from common GWAS outputs. The
intended flow is:

1.  import a typed object;
2.  plot with
    [`plot_manha()`](https://wwz33.github.io/ggpop/reference/plot_manha.md)
    / [`plot_qq()`](https://wwz33.github.io/ggpop/reference/plot_qq.md)
    or `ggpop() + geom_*()`;
3.  use internal fastman-style Manhattan and Q-Q plotting behavior
    without an external `fastman` dependency.

## API summary

| Task | Direct API | Layer API | Notes |
|----|----|----|----|
| Import GCTA/GEMMA/EMMAX | `import_gwas(file, type = ...)` | \- | Returns `ggpop_gwas` |
| Manhattan | [`plot_manha()`](https://wwz33.github.io/ggpop/reference/plot_manha.md) | `ggpop(data) + geom_manha()` | Defaults are aligned |
| Q-Q | [`plot_qq()`](https://wwz33.github.io/ggpop/reference/plot_qq.md) | `ggpop(data) + ggpop::geom_qq()` | Use explicit namespace to avoid [`ggplot2::geom_qq()`](https://ggplot2.tidyverse.org/reference/geom_qq.html) |
| Backend | internal fastman-style layout | native ggpop stat | Direct wrappers and geoms share one implementation |

## GCTA example

``` r
gwas <- import_gwas(ggpop_extdata("gwas", "gcta.mlma"), type = "gcta")
```

``` r
plot_manha(gwas)
```

![Manhattan plot. Chromosomes are arranged along the x-axis and minus
log10 p-values are on the y-axis. Most points sit below the reference
lines, while the horizontal suggestive and genome-wide threshold lines
show where stronger GWAS signals would stand
out.](gwas_files/figure-html/unnamed-chunk-2-1.png)

``` r
plot_qq(gwas)
```

![Q-Q scatter plot. Expected minus log10 p-values are on the x-axis and
observed minus log10 p-values are on the y-axis. Points follow the red
diagonal reference line closely, and a lambda annotation summarizes
genomic inflation.](gwas_files/figure-html/unnamed-chunk-3-1.png)

## Layered workflow

``` r
gwas |>
  ggpop() +
  geom_manha()
```

![Manhattan plot from the layered ggplot workflow. Chromosomes are
arranged along the x-axis and minus log10 p-values are on the y-axis,
with horizontal suggestive and genome-wide threshold
lines.](gwas_files/figure-html/unnamed-chunk-4-1.png)

``` r

gwas |>
  ggpop() +
  ggpop::geom_qq()
#> Registered S3 method overwritten by 'ggpop':
#>   method                     from
#>   print.ggpop_palette_scheme ggPopi
```

![Q-Q scatter plot from the layered ggplot workflow. Expected minus
log10 p-values are on the x-axis and observed minus log10 p-values are
on the y-axis, with points compared against a diagonal reference
line.](gwas_files/figure-html/unnamed-chunk-4-2.png)

`plot_manha(gwas)` and `ggpop(gwas) + geom_manha()` share the same
default threshold and suggestive reference lines.

## GWAS colour palettes

The GWAS module uses the same unified discrete palette entry as the rest
of `ggpop`. Manhattan plots default to a two-colour alternating
chromosome palette:

``` r
plot_manha(gwas, palette = "manhattan")
```

![Manhattan plot with a two-colour alternating palette. Adjacent
chromosomes alternate between blue and pale blue, preserving the same
p-value threshold lines.](gwas_files/figure-html/unnamed-chunk-5-1.png)

To override the Manhattan colours, pass two explicit colours.
`binary = TRUE` keeps the two-colour alternation even when a longer
palette is supplied:

``` r
plot_manha(
  gwas,
  palette = c("#4E79A7", "#C4E2F3"),
  binary = TRUE
)
```

![Manhattan plot with a two-colour alternating palette. Adjacent
chromosomes alternate between the two supplied colours, emphasizing
chromosome separation without changing the p-value scale or
thresholds.](gwas_files/figure-html/unnamed-chunk-6-1.png)

Reference-line colours continue to use the publication palette by
default. Override them with `threshold_color` and `suggestive_color`
when needed.

## Alternative GWAS formats

[`import_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md)
accepts `type = "gcta"`, `type = "gemma"`, and `type = "emmax"`. GWAS
plotting uses ggpop’s internal ggplot implementation in both direct and
layered workflows.
