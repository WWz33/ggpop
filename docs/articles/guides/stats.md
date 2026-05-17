# Population genomics statistics

`ggpop` imports windowed population genomics statistics into a typed
`ggpop_stats` object. The current module supports pixy and
vcftools-style outputs for common summaries including FST, pi, Tajima’s
D, Dxy, and Watterson’s theta.

## API summary

| Task | API | Notes |
|----|----|----|
| Import a result directory | `import_stats(dir, type = "pixy")` | Auto-discovers supported suffixes |
| Import selected files | `import_stats(dir, pi = "...", fst = "...")` | Relative paths resolve inside `dir` |
| Direct plot | `plot_stats(data, stat = ..., chr = ...)` | Returns a `ggplot` object |
| Layered plot | `ggpop(data) + geom_stats(...)` | Tidy ggplot extension path |
| Region filter | `chr`, `start`, `end` | Keeps windows overlapping the region |

## Import pixy results

``` r
pixy_dir <- ggpop_extdata("Population_genomics_statistics", "pixy")
stats <- import_stats(pixy_dir, type = "pixy")
class(stats)
#> [1] "ggpop_stats" "data.frame"
unique(stats$stat)
#> [1] "dxy"             "fst"             "pi"             
#> [4] "tajima_d"        "watterson_theta"
```

You can also import selected files explicitly:

``` r
selected <- import_stats(
  pixy_dir,
  pi = "pixy_pi.txt",
  fst = "pixy_fst.txt",
  tajima = "pixy_tajima_d.txt",
  type = "pixy"
)
unique(selected$stat)
#> [1] "dxy"             "fst"             "pi"             
#> [4] "tajima_d"        "watterson_theta"
```

## Plot all statistics

By default, `stat = "all"` stacks the selected statistics vertically and
keeps the x-axis aligned. This mirrors the usual pixy plotting layout
for comparing windowed summaries across the same genomic coordinate
system.

``` r
plot_stats(stats, stat = "all", chr = "chr2L")
```

![Faceted line plot of population genomics statistics. Statistic names
define vertically stacked panels, genomic position in megabases is on
the x-axis, and statistic value is on the y-axis. The shared x-axis lets
FST, pi, Tajima's D, Dxy, and Watterson's theta be compared across the
same chromosome windows.](stats_files/figure-html/unnamed-chunk-3-1.png)

## Select statistics and regions

Use `stat` to choose one or more summaries, `chr` to select chromosomes,
and `start` / `end` to focus on windows overlapping a region.

``` r
plot_stats(stats, stat = c("fst", "pi"), chr = "chr2L")
```

![Two-panel line plot. FST and pi are stacked vertically for chromosome
chr2L, with genomic position in megabases on the x-axis and each
statistic value on its own
y-axis.](stats_files/figure-html/unnamed-chunk-4-1.png)

``` r
plot_stats(stats, chr = "chr2L", start = 1, end = 20000)
```

![Regional line plot of population genomics statistics. Windows on
chromosome chr2L overlapping the first 20,000 bases are shown, focusing
the x-axis on a small genomic
interval.](stats_files/figure-html/unnamed-chunk-5-1.png)

Multiple chromosomes can be selected. When more than one chromosome is
shown, the default plot uses points to avoid implying continuous genomic
distance between chromosomes.

``` r
plot_stats(stats, chr = c("chr2L", "chr3L"))
```

![Faceted point plot of population genomics statistics across two
chromosomes. Statistic panels are stacked vertically, point position
shows genomic window midpoint, and colour separates chromosome
categories.](stats_files/figure-html/unnamed-chunk-6-1.png)

## Layered workflow

The layered API follows the same grammar as the other modules:

``` r
stats |>
  ggpop() +
  geom_stats(stat = c("fst", "pi"), chr = "chr2L")
```

![Layered line plot of FST and pi. The ggpop object supplies imported
population statistics and geom_stats draws two vertically stacked
statistic panels for chromosome
chr2L.](stats_files/figure-html/unnamed-chunk-7-1.png)

The module uses ggpop’s shared theme, font sizing, and discrete palette
interfaces. Use `palette`, `base_size`, and `base_family` the same way
as the GWAS and PCA modules.
