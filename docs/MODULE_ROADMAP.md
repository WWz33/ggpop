# ggpop Module Roadmap

This roadmap records candidate modules for `ggpop` as an all-in-one
`ggplot2` extension for population-genomics visualization.

Core rule:

> Add a new module only when it introduces a new result object type. If
> the task is filtering, highlighting, zooming, grouping, or restyling
> an existing object, implement it as parameters or layers inside the
> existing module.

Package philosophy:

> Import smart, return tidy S3 objects, plot grammatically.

## Existing Core Modules

| Module | Object | Scope |
|----|----|----|
| GWAS | `ggpop_gwas` | Manhattan and Q-Q visualization from GCTA/GEMMA/EMMAX-style results |
| PCA | `ggpop_pca` | PCA scatter plots from PLINK/GCTA/optional flashpca workflows |
| Admixture | `ggpop_admix` | ADMIXTURE/STRUCTURE-style ancestry barplots |
| Population statistics | `ggpop_stats` | Windowed FST, pi, Tajima’s D, Dxy, and related statistics |

## Priority 1: High-Value New Modules

### 1. Selection Scans

Proposed API:

``` r
import_selection(...) |> plot_selection()
import_selection(...) |> ggpop() + geom_selection()
```

Supported result families:

- XP-CLR
- XP-EHH
- iHS
- PBS
- CLR / SweepFinder-style scans
- FST outlier tables

Why this belongs as a new module:

- Selection scans have distinct statistics, scales, thresholds, and
  biological interpretation from GWAS.
- They are common in population-genomics papers.
- They can reuse Manhattan-like chromosome layout while keeping a
  separate S3 class such as `ggpop_selection`.

Initial plotting scope:

- Genome-wide scan plot.
- Region filtering through `chr`, `start`, and `end`.
- Candidate-region highlighting.
- Optional threshold lines.

### 2. LD Decay

Proposed API:

``` r
import_ld(...) |> plot_ld()
import_ld(...) |> ggpop() + geom_ld()
```

Supported result families:

- PopLDdecay output
- PLINK `--r2` summaries
- Pre-binned LD decay tables

Why this belongs as a new module:

- LD decay is a distinct curve-based result object.
- It is a standard population-genomics figure.
- It naturally supports group-wise colour and unified population
  palettes.

Initial plotting scope:

- Distance on x-axis.
- Mean or median `r^2` on y-axis.
- Multiple populations/groups in one plot.
- Optional confidence ribbon if input contains dispersion columns.

### 3. ROH / IBD

Proposed API:

``` r
import_roh(...) |> plot_roh()
import_roh(...) |> ggpop() + geom_roh()
```

Supported result families:

- PLINK `--homozyg`
- bcftools ROH output
- KING/IBD-style pairwise relatedness summaries as a later extension

Why this belongs as a new module:

- ROH has sample-level and interval-level data semantics.
- It is important for conservation genomics, domestication, inbreeding,
  and demographic history.

Initial plotting scope:

- ROH length distribution.
- Per-sample total ROH burden.
- Genome-wide ROH density by chromosome/window.
- Optional population grouping through `pop_group`.

### 4. SFS

Proposed API:

``` r
import_sfs(...) |> plot_sfs()
import_sfs(...) |> ggpop() + geom_sfs()
```

Supported result families:

- easySFS
- dadi
- fastsimcoal2
- Generic 1D/2D SFS matrices

Why this belongs as a new module:

- SFS is a distinct vector/matrix result object.
- The visualization grammar differs from tracks or scatter plots.

Initial plotting scope:

- 1D folded/unfolded SFS bar plot.
- 2D SFS heatmap.
- Optional log-scaled fill.

## Priority 2: Useful After Core Expansion

### 5. Gene Flow / Introgression

Proposed API:

``` r
import_geneflow(...) |> plot_geneflow()
import_geneflow(...) |> ggpop() + geom_geneflow()
```

Candidate inputs:

- D-statistics / ABBA-BABA result tables
- f4-ratio summaries
- TreeMix edges
- qpGraph-style summaries as an advanced target

Reason to delay:

- Input formats differ substantially.
- Plot types may split into tables, forest plots, and graph-like
  layouts.

### 6. Demographic Inference

Proposed API:

``` r
import_demography(...) |> plot_demography()
import_demography(...) |> ggpop() + geom_demography()
```

Candidate inputs:

- PSMC
- MSMC / MSMC2
- SMC++
- stairwayplot
- dadi / fastsimcoal2 model outputs

Reason to delay:

- Multiple tools use different time and Ne conventions.
- This needs careful import normalization before plotting.

### 7. Relatedness / Kinship

Proposed API:

``` r
import_relatedness(...) |> plot_relatedness()
import_relatedness(...) |> ggpop() + geom_relatedness()
```

Candidate inputs:

- KING
- PLINK relatedness outputs
- GCTA GRM-derived summaries

Reason to delay:

- Plot forms may include heatmaps, networks, and pairwise scatter plots.
- It needs a clear minimal first version.

## Priority 3: Specialized Modules

### 8. Haplotype Visualization

Candidate scope:

- Candidate-region haplotype blocks.
- Haplotype frequency by population.
- Allele-pattern heatmaps for small regions.

Reason to delay:

- Raw haplotype visualization can become data-heavy.
- The module must avoid becoming a genotype-processing framework.

### 9. SV / CNV Population Summaries

Candidate scope:

- SV frequency by population.
- CNV burden plots.
- Presence/absence heatmaps.

Reason to delay:

- Input standards vary widely.
- Better added after core SNP-result visualization is stable.

### 10. Sampling Map

Candidate scope:

- `sample`, `pop`, `lat`, `lon` metadata import.
- Geographic sample distribution with ggplot-compatible map layers.

Reason to delay:

- Useful, but it may introduce geospatial dependencies.
- It is auxiliary metadata visualization rather than a
  population-genomics result module.

## Not Separate Modules

These should stay inside existing modules as parameters or helper
layers:

| Feature | Where it belongs |
|----|----|
| Regional GWAS | `plot_manha(chr = ..., start = ..., end = ...)` / `geom_manha(...)` |
| Regional population statistics | `plot_stats(chr = ..., start = ..., end = ...)` / `geom_stats(...)` |
| GWAS SNP highlighting | `plot_manha(highlight = ...)` / `geom_manha(highlight = ...)` |
| PCA ellipses, labels, convex hulls | `plot_pca(...)` / `geom_pca(...)` parameters or add-on layers |
| Admixture K selection and sorting | `plot_admix(k = ..., sort = ...)` / `geom_admix(...)` |
| Multi-panel structure summary | Composition helper using existing PCA/admixture/stats/GWAS plots |

## Safe Implementation Order

1.  Stabilize current style contract before adding modules.
2.  Add `selection` first because it reuses GWAS-like layout but has
    distinct biology and object semantics.
3.  Add `ld` second because the data model is simple and the figure is
    common.
4.  Add `roh` third because it benefits from `pop_group` and has high
    manuscript value.
5.  Add `sfs` fourth because it introduces a new vector/matrix
    visualization grammar.
6.  Defer `gene_flow`, `demography`, and `relatedness` until the import
    contract and visual contract tests are stable.

## Minimum Contract for Every New Module

Each new module should provide:

- `import_*()` returning one typed S3 tidy object.
- `plot_*()` as the ordinary user-facing publication plot.
- `ggpop() + geom_*()` as the grammar path.
- Optional metadata joining through the shared `pop_group` mechanism
  when relevant.
- Shared ggpop palette, font, and theme controls unless a module has a
  justified visual compatibility exception.
- Tests for import structure, plot object type, plot/geom parity,
  filtering parameters, labels, scales, and theme contract.
