# Admixture plots

`ggpop` keeps the user-facing admixture API narrow:

- [`import_admix()`](https://wwz33.github.io/ggpop/reference/import_admixture.md)
  /
  [`import_admixture()`](https://wwz33.github.io/ggpop/reference/import_admixture.md)
  create typed `ggpop_admix` objects;
- [`plot_admix()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
  returns a `ggplot` object;
- `ggpop() + geom_admix()` gives the extension-style layered workflow.

## API summary

| Task | API | Notes |
|----|----|----|
| Import ADMIXTURE directory or `.Q` files | `import_admix(file, type = "admixture", pop_group = NULL)` | Reads full K result sets |
| Import STRUCTURE-style numeric Q matrix | `import_admixture(file, type = "structure")` | Limited numeric Q support |
| Direct plot | `plot_admix(data, k = ...)` | `k = "all"`, one K, or a vector |
| Layered plot | `ggpop(data) + geom_admix(k = ...)` | Main ggplot extension path |
| Original pophelper behavior | [`plot_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md) | Advanced compatibility layer |

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

![Joined admixture stacked bar chart with one panel per K value, showing
ancestry proportions for each
individual.](admixture_files/figure-html/unnamed-chunk-2-1.png)

``` r
plot_admix(admix, k = c(2, 4))
```

![Admixture stacked bar charts for selected K values 2 and 4, comparing
ancestry proportions across
individuals.](admixture_files/figure-html/unnamed-chunk-3-1.png)

``` r
ggpop(admix) + geom_admix(k = 3)
```

![Layered admixture stacked bar chart for K equals 3, with individuals
on the x-axis and ancestry proportions stacked within each
bar.](admixture_files/figure-html/unnamed-chunk-4-1.png)

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

![Admixture stacked bar chart for K equals 3 with individual labels and
population group labels used for
sorting.](admixture_files/figure-html/unnamed-chunk-6-1.png)

The layered ggplot path returns the same kind of ggplot object:

``` r
ggpop(admix) +
  geom_admix(k = 3, sort = "all", order_group = TRUE)
```

![Layered admixture stacked bar chart sorted by ancestry cluster and
population group
labels.](admixture_files/figure-html/unnamed-chunk-7-1.png)

## Direct vs layered use

[`plot_admix()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
is the direct plot wrapper.
[`geom_admix()`](https://wwz33.github.io/ggpop/reference/geom_admix.md)
is the layered interface when you want to build a larger `ggplot` object
yourself. Both routes use the same visual defaults;
[`plot_admix()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
is the reference style, and `ggpop(admix) + geom_admix()` reproduces
that publication-level look inside a ggplot composition.

``` r
plot_admix(admix, k = 3)
```

![Two admixture stacked bar charts comparing the direct plot_admix route
and the layered ggpop plus geom_admix
route.](admixture_files/figure-html/unnamed-chunk-8-1.png)

``` r
ggpop(admix) + geom_admix(k = 3)
```

![Two admixture stacked bar charts comparing the direct plot_admix route
and the layered ggpop plus geom_admix
route.](admixture_files/figure-html/unnamed-chunk-8-2.png)

## STRUCTURE-style input

[`import_admixture()`](https://wwz33.github.io/ggpop/reference/import_admixture.md)
also accepts limited STRUCTURE-style inputs. The importer always returns
the same typed long-format object.

``` r
structure <- import_admixture("structure_results.out", type = "structure")
plot_admix(structure, k = "all")
```
