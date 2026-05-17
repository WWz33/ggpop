# Full extdata gallery

This gallery uses the full example data shipped in `inst/extdata`. It is
the closest match to the package’s real-world supported examples.

## GWAS

``` r
gwas <- import_gwas(ggpop_extdata("gwas", "gcta.mlma"), type = "gcta")
plot_manha(gwas, title = "GCTA Manhattan", use_fastman = TRUE)
#> 载入需要的程序包：ggplot2
#> 
#> 载入程序包：'ggplot2'
#> The following object is masked from 'package:ggpop':
#> 
#>     geom_qq
#> Scale for y is already present.
#> Adding another scale for y, which will replace the existing scale.
```

![Full-data GWAS examples showing a Manhattan plot and a Q-Q plot from
the bundled GCTA result
file.](full-extdata_files/figure-html/unnamed-chunk-1-1.png)

``` r
plot_qq(gwas, title = "GCTA Q-Q", use_fastman = TRUE)
```

![Full-data GWAS examples showing a Manhattan plot and a Q-Q plot from
the bundled GCTA result
file.](full-extdata_files/figure-html/unnamed-chunk-1-2.png)

## PCA

``` r
pca <- import_pca(
  ggpop_extdata("pca", "gcta.eigenvec"),
  type = "gcta",
  eigenval = ggpop_extdata("pca", "gcta.eigenval"),
  pop_group = ggpop_extdata("pop_group.txt")
)
plot_pca(pca, title = "GCTA PCA")
```

![PCA scatter plot from the bundled GCTA eigenvector file, with point
colour encoding imported population
groups.](full-extdata_files/figure-html/unnamed-chunk-2-1.png)

## Admixture

``` r
admix <- import_admix(
  ggpop_extdata("admixture"),
  type = "admixture",
  ind = ggpop_extdata("snp", "finalsnp_ld.fam"),
  pop_group = ggpop_extdata("pop_group.txt")
)
plot_admix(admix, k = "all", title = "ADMIXTURE", order_group = TRUE)
```

![Joined admixture stacked bar chart from full bundled ADMIXTURE
results, grouped by population
labels.](full-extdata_files/figure-html/unnamed-chunk-3-1.png)

The same data also works with the layered path:

``` r
ggpop(admix) + geom_admix(k = 3, order_group = TRUE)
```

![Layered admixture stacked bar chart for K equals 3 using the same
imported full ADMIXTURE
data.](full-extdata_files/figure-html/unnamed-chunk-4-1.png)
