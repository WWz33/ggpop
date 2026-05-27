# Admixture plots

`ggpop` keeps the user-facing admixture API narrow:

- [`import_admix()`](https://wwz33.github.io/ggPopi/reference/import_admix.md)
  creates typed `ggpop_admix` objects;
- [`plot_admix()`](https://wwz33.github.io/ggPopi/reference/plot_admix.md)
  returns a `ggplot` object;
- `ggpop() + geom_admix()` gives the pophelper-style layered workflow;
- [`plot_admix2()`](https://wwz33.github.io/ggPopi/reference/plot_admix2.md)
  and `ggpop() + geom_admix2()` give a pure ggplot-style layout.

## API summary

| Task | API | Notes |
|----|----|----|
| Import ADMIXTURE directory or `.Q` files | `import_admix(file, type = "admixture", pop_group = NULL)` | Reads full K result sets |
| Import STRUCTURE-style numeric Q matrix | `import_admix(file, type = "structure")` | Limited numeric Q support |
| Direct plot | `plot_admix(data, k = ...)` | `k = "all"`, one K, or a vector |
| Layered plot | `ggpop(data) + geom_admix(k = ...)` | Pophelper-style ggplot extension path |
| Pure ggplot plot | `plot_admix2(data, k = ...)` | Figure 2-like minimal ggplot layout |
| Pure ggplot layer | `ggpop(data) + geom_admix2(k = ...)` | Layered route for the minimal ggplot layout |
| Original pophelper behavior | [`plot_pophelper_q()`](https://wwz33.github.io/ggPopi/reference/pophelper_compat.md) | Advanced compatibility layer |

## Full K results

``` r
admix <- import_admix(
  ggpop_extdata("admixture"),
  type = "admixture",
  ind = ggpop_extdata("snp", "finalsnp_ld.fam"),
  pop_group = ggpop_extdata("pop_group.txt")
)
```

``` r
plot_admix(admix, k = "all")
```

![Faceted stacked bar chart. Each panel represents one K value from the
imported ADMIXTURE directory, individuals are arranged along the x-axis,
and stacked bar segments show ancestry proportions that sum to one for
each individual.](admixture_files/figure-html/unnamed-chunk-2-1.png)

``` r
plot_admix(admix, k = c(2, 4))
```

![Faceted stacked bar chart with two selected K panels. The K equals 2
and K equals 4 panels show how ancestry proportions split into more
clusters when a higher K value is
selected.](admixture_files/figure-html/unnamed-chunk-3-1.png)

``` r
ggpop(admix) + geom_admix(k = 3)
```

![Stacked bar chart. Individuals are on the x-axis and ancestry
proportions are stacked within each bar for K equals 3, demonstrating
that the ggplot layer path produces the same kind of admixture display
as the direct plot.](admixture_files/figure-html/unnamed-chunk-4-1.png)

## Population group labels and sorting

`pop_group.txt` uses two columns, `sample` and `pop`. It is joined
during import:

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

The native ggplot implementation mirrors the supported pophelper
`plotQ()` behavior for:

- individual labels with `show_sample_labels = TRUE`;
- sorting individuals with `sort = "all"`, `sort = "label"`, or a
  cluster name such as `K1`;
- group labels with `show_group_labels = TRUE`;
- sorting with group labels using `order_group = TRUE`.

``` r
plot_admix(
  admix,
  k = 3,
  sort = "all",
  order_group = TRUE,
  show_group_labels = TRUE,
  show_sample_labels = TRUE
)
```

![Grouped stacked bar chart. Individuals are sorted within population
groups for K equals 3, ancestry cluster proportions fill each bar, and
population group strip labels separate the sample
groups.](admixture_files/figure-html/unnamed-chunk-6-1.png)

The layered ggplot path returns the same kind of ggplot object:

``` r
ggpop(admix) +
  geom_admix(k = 3, sort = "all", order_group = TRUE)
```

![Layered grouped stacked bar chart. Individuals are ordered by ancestry
cluster and population group, showing that the geom_admix layer
preserves the same sorting and grouping controls as
plot_admix.](admixture_files/figure-html/unnamed-chunk-7-1.png)

## Direct vs layered use

[`plot_admix()`](https://wwz33.github.io/ggPopi/reference/plot_admix.md)
is the direct plot wrapper.
[`geom_admix()`](https://wwz33.github.io/ggPopi/reference/geom_admix.md)
is the layered interface when you want to build a larger `ggplot` object
yourself. Both routes use the same pophelper-style visual defaults;
[`plot_admix()`](https://wwz33.github.io/ggPopi/reference/plot_admix.md)
is the reference style, and `ggpop(admix) + geom_admix()` reproduces
that look inside a ggplot composition.

``` r
plot_admix(admix, k = 3)
```

![Stacked bar chart from plot_admix. Individuals are arranged along the
x-axis and ancestry proportions are stacked within each bar for K equals
3.](admixture_files/figure-html/unnamed-chunk-8-1.png)

``` r
ggpop(admix) + geom_admix(k = 3)
```

![Stacked bar chart from ggpop plus geom_admix. The same K equals 3
ancestry proportions are displayed through the layered ggplot extension
path.](admixture_files/figure-html/unnamed-chunk-8-2.png)

The `admix2` route mirrors the upstream Figure 2 stacked-bar layout more
closely.

``` r
plot_admix2(admix, k = 3)
```

![ggplot-style stacked bar chart. Individuals are displayed in a cleaner
pure ggplot layout with the same ancestry proportions and faceted K
panels, mirroring the upstream Figure 2 admixture
figure.](admixture_files/figure-html/unnamed-chunk-9-1.png)

``` r
ggpop(admix) + geom_admix2(k = 3)
```

![ggplot-style stacked bar chart. Individuals are displayed in a cleaner
pure ggplot layout with the same ancestry proportions and faceted K
panels, mirroring the upstream Figure 2 admixture
figure.](admixture_files/figure-html/unnamed-chunk-9-2.png)

## STRUCTURE-style input

[`import_admix()`](https://wwz33.github.io/ggPopi/reference/import_admix.md)
also accepts limited STRUCTURE-style inputs. The importer always returns
the same typed long-format object.

``` r
structure <- import_admix("structure_results.out", type = "structure")
plot_admix(structure, k = "all")
```
