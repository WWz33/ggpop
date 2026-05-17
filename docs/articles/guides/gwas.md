# GWAS plots

`ggpop` supports Manhattan and Q-Q plots from common GWAS outputs. The
intended flow is:

1.  import a typed object;
2.  plot with
    [`plot_manha()`](https://wwz33.github.io/ggpop/reference/plot_manha.md)
    / [`plot_qq()`](https://wwz33.github.io/ggpop/reference/plot_qq.md)
    or `ggpop() + geom_*()`;
3.  keep [`fastman`](https://github.com/adhikari-statgen-lab/fastman) as
    the optional fast path when installed.

## API summary

| Task | Direct API | Layer API | Notes |
|----|----|----|----|
| Import GCTA/GEMMA/EMMAX | `import_gwas(file, type = ...)` | \- | Returns `ggpop_gwas` |
| Manhattan | [`plot_manha()`](https://wwz33.github.io/ggpop/reference/plot_manha.md) | `ggpop(data) + geom_manha()` | Defaults are aligned |
| Q-Q | [`plot_qq()`](https://wwz33.github.io/ggpop/reference/plot_qq.md) | `ggpop(data) + ggpop::geom_qq()` | Use explicit namespace to avoid [`ggplot2::geom_qq()`](https://ggplot2.tidyverse.org/reference/geom_qq.html) |
| Backend | `use_fastman = TRUE` | native ggpop stat | Direct wrappers use fastman when available |

## GCTA example

``` r
gwas <- import_gwas(ggpop_extdata("gwas", "gcta.mlma"), type = "gcta")
```

``` r
plot_manha(gwas, title = "GCTA Manhattan", use_fastman = TRUE)
#> Loading required package: ggplot2
#> 
#> Attaching package: 'ggplot2'
#> The following object is masked from 'package:ggpop':
#> 
#>     geom_qq
#> Scale for y is already present.
#> Adding another scale for y, which will replace the existing scale.
```

![Manhattan plot. Chromosomes are arranged along the x-axis and minus
log10 p-values are on the y-axis, with threshold lines marking
suggestive and genome-wide
significance.](gwas_files/figure-html/unnamed-chunk-2-1.png)

``` r
plot_qq(gwas, title = "GCTA Q-Q", use_fastman = TRUE)
```

![Q-Q scatter plot. Expected minus log10 p-values are on the x-axis and
observed minus log10 p-values are on the y-axis, with a diagonal
reference line and genomic inflation
label.](gwas_files/figure-html/unnamed-chunk-3-1.png)

## Layered workflow

``` r
gwas |>
  ggpop() +
  geom_manha()
```

![Layered GWAS examples showing a Manhattan plot followed by a Q-Q
scatter plot using the same imported GWAS
object.](gwas_files/figure-html/unnamed-chunk-4-1.png)

``` r

gwas |>
  ggpop() +
  ggpop::geom_qq()
```

![Layered GWAS examples showing a Manhattan plot followed by a Q-Q
scatter plot using the same imported GWAS
object.](gwas_files/figure-html/unnamed-chunk-4-2.png)

`plot_manha(gwas, use_fastman = FALSE)` and `ggpop(gwas) + geom_manha()`
share the same default threshold and suggestive reference lines.

## GWAS colour palettes

The GWAS module uses the same unified discrete palette entry as the rest
of `ggpop`. Manhattan plots default to one discrete colour per
chromosome:

``` r
plot_manha(gwas, use_fastman = FALSE, palette = "manhattan")
```

![Manhattan plot using the default ggpop manhattan palette with one
discrete colour assigned per
chromosome.](gwas_files/figure-html/unnamed-chunk-5-1.png)

For a two-colour alternating Manhattan plot, set `binary = TRUE` and
pass either a ggpop palette name or two explicit colours:

``` r
plot_manha(
  gwas,
  use_fastman = FALSE,
  palette = c("#123456", "#654321"),
  binary = TRUE
)
```

![Manhattan plot using a two-colour alternating palette repeated across
chromosomes.](gwas_files/figure-html/unnamed-chunk-6-1.png)

## Alternative GWAS formats

[`import_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md)
accepts `type = "gcta"`, `type = "gemma"`, and `type = "emmax"`. The
package also keeps typo-compatible aliases for old prompts and
notebooks. They are compatibility helpers, not recommended in new code:

``` r
improt_gwas("assoc.mlma", type = "gcta")
prot_gwas("assoc.mlma", type = "gcta")
```

If `fastman` is installed, the direct GWAS wrappers use it by default.
If it is not installed, the ggplot-native path still works.
