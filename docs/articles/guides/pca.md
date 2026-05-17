# PCA plots

`ggpop` reads PLINK and GCTA PCA output into a typed `ggpop_pca` object.
The same object supports
[`plot_pca()`](https://wwz33.github.io/ggpop/reference/plot_pca.md) and
the layered `ggpop() + geom_pca()` style.

## API summary

| Task | API | Notes |
|----|----|----|
| Import PLINK/GCTA PCA | `import_pca(file, type = ..., eigenval = NULL, pop_group = NULL)` | Returns `ggpop_pca` |
| Direct plot | `plot_pca(data, pc_x = 1, pc_y = 2)` | Returns `ggplot` |
| Layered plot | `ggpop(data) + geom_pca(pc_x = 1, pc_y = 2)` | Tidy ggplot extension path |
| Compute PCA | `compute_pca(genotype, method = "flashpca")` | Requires `flashpcaR` |

## GCTA PCA

``` r
pca <- import_pca(
  ggpop_extdata("pca", "gcta.eigenvec"),
  type = "gcta",
  eigenval = ggpop_extdata("pca", "gcta.eigenval"),
  pop_group = ggpop_extdata("pop_group.txt")
)
```

``` r
plot_pca(pca, title = "GCTA PCA")
```

![Scatter chart. Principal component 1 is on the x-axis and principal
component 2 is on the y-axis, with point colour encoding imported
population groups. Samples cluster by their PCA coordinates while
preserving the same population colour mapping used elsewhere in
ggpop.](pca_files/figure-html/unnamed-chunk-2-1.png)

``` r
ggpop(pca) + geom_pca(pc_x = 1, pc_y = 3)
```

![Scatter chart. Principal component 1 is on the x-axis and principal
component 3 is on the y-axis, showing that geom_pca can switch component
axes while keeping the same sample-level PCA
data.](pca_files/figure-html/unnamed-chunk-3-1.png)

When the imported object has a `pop` column, both plotting routes map
population groups to the unified ggpop discrete colour scale.

``` r
ggpop(pca) +
  geom_pca(pc_x = 1, pc_y = 2, palette = "population")
```

![Scatter chart. Principal component 1 and principal component 2 are
plotted with point colour mapped to population group through the unified
ggpop population palette.](pca_files/figure-html/unnamed-chunk-4-1.png)

## PC labels

The axis labels can carry variance explained when eigenvalues are
available.

``` r
plot_pca(pca, pc_x = 1, pc_y = 2)
```

![Scatter chart. Principal component axes include variance explained
percentages in their labels when eigenvalues are available, making the
relative contribution of each PC
explicit.](pca_files/figure-html/unnamed-chunk-5-1.png)

## Optional flashpcaR computation

`compute_pca(method = "flashpca")` is available when `flashpcaR` is
installed. It is intentionally not forced during vignette build because
it depends on a genotype object.

``` r
compute_pca(genotype, method = "flashpca")
```
