# LD decay

`ggpop` imports LD decay summaries into a typed `ggpop_ld_decay` object.
The module supports PopLDdecay `*.stat.gz` summaries and PLINK pairwise
LD tables summarized into distance bins.

## API summary

| Task | API | Notes |
|----|----|----|
| Import PopLDdecay summaries | `import_ld_decay(dir, type = "poplddecay")` | Reads `*.stat.gz` files directly |
| Import PLINK LD pairs | `import_ld_decay(file, type = "plink")` | Summarizes pairwise LD into distance bins |
| Direct plot | `plot_ld_decay(data, style = "point")` | Returns a `ggplot` object |
| Layered plot | `ggpop(data) + geom_ld_decay(...)` | Tidy ggplot extension path |
| Plot style | `style = "point"` / `"line"` | Point summaries or continuous decay curves |
| Population labels | `pop_group` | Uses the package-wide two-column `sample pop` file |

## Import PopLDdecay results

The bundled example contains a PopLDdecay `final_ld.stat.gz` result
file. The importer standardizes `Dist` to `dist`, `Mean_r^2` to `r2`,
and `NumberPairs` to `n_pairs`.

``` r
ld_dir <- ggpop_extdata("ld_decay", "PopLDdecay")
ld_decay <- import_ld_decay(ld_dir, type = "poplddecay")
class(ld_decay)
#> [1] "ggpop_ld_decay" "data.frame"
head(ld_decay)
#>   dist     r2        pop  sample_id dist_kb n_pairs             file
#> 1    5 0.7569 PopLDdecay PopLDdecay   0.005     401 final_ld.stat.gz
#> 2    6 0.7733 PopLDdecay PopLDdecay   0.006     425 final_ld.stat.gz
#> 3    7 0.7564 PopLDdecay PopLDdecay   0.007     379 final_ld.stat.gz
#> 4    8 0.7497 PopLDdecay PopLDdecay   0.008     370 final_ld.stat.gz
#> 5    9 0.7755 PopLDdecay PopLDdecay   0.009     338 final_ld.stat.gz
#> 6   10 0.7513 PopLDdecay PopLDdecay   0.010     344 final_ld.stat.gz
#>       source     .group
#> 1 poplddecay PopLDdecay
#> 2 poplddecay PopLDdecay
#> 3 poplddecay PopLDdecay
#> 4 poplddecay PopLDdecay
#> 5 poplddecay PopLDdecay
#> 6 poplddecay PopLDdecay
```

Population grouping follows the same `pop_group.txt` convention used by
PCA and admixture. The LD decay file label is stored as `sample_id`; if
a matching `sample` appears in `pop_group`, the corresponding `pop`
value is used for colouring.

``` r
ld_grouped <- import_ld_decay(
  ld_dir,
  pop = "P001",
  pop_group = ggpop_extdata("pop_group.txt"),
  type = "poplddecay"
)
unique(ld_grouped$pop)
#> [1] "PopC"
```

## Point style

The point style follows the common LD summary plot: pairwise distance in
Kb on the x-axis and mean LD $`r^2`$ on the y-axis, with population
labels mapped to colour.

``` r
plot_ld_decay(ld_decay, style = "point")
```

![LD decay point plot. Pairwise distance in kilobases is on the x-axis
and mean LD r squared is on the y-axis, with points coloured by
population label.](ld-decay_files/figure-html/unnamed-chunk-3-1.png)

## Line style

The line style uses the same data and population colour mapping, but
draws a continuous decay curve.

``` r
plot_ld_decay(ld_decay, style = "line")
```

![LD decay line plot. Pairwise distance in kilobases is on the x-axis
and mean LD r squared is on the y-axis, with a continuous curve showing
the decay pattern.](ld-decay_files/figure-html/unnamed-chunk-4-1.png)

## Layered path

Use [`ggpop()`](https://wwz33.github.io/ggpop/reference/ggpop.md) plus
[`geom_ld_decay()`](https://wwz33.github.io/ggpop/reference/geom_ld_decay.md)
when composing with other ggplot layers.

``` r
ld_decay |>
  ggpop() +
  geom_ld_decay(style = "point")
```

![Layered LD decay point plot using ggpop plus geom_ld_decay. Pairwise
distance in kilobases is on the x-axis and mean LD r squared is on the
y-axis.](ld-decay_files/figure-html/unnamed-chunk-5-1.png)
