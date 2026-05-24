# Publication Introgression Visuals Research

## External plotting patterns reviewed

- `ivanprates/Ctenotus_inornatus_group/scripts/11_Dsuite_outputs_2022-08-09.R`
  uses Dsuite `P2 x P3` heatmaps with a complete white background grid,
  D-statistic fill for observed cells, and black outlines for significant
  adjusted P values.
- `pstokespmb/Chapter1/11_Dsuite/scripts/DStatsVisuals.R` uses D-statistic
  point/errorbar plots, Z-score significance colouring, and a visible zero
  baseline for tested samples.
- TreeMix plotting helpers such as
  `owensgl/helianthus_hybrid_species_2021/bin/rscripts/treemix_plotting_tidy_functions.R`
  draw tree edges as subdued grey segments and migration edges as curved arrows
  with colour/weight emphasis.
- A follow-up search found the same display conventions in additional scripts:
  Dsuite matrix scripts clean population names and rotate dense x-axis labels,
  D-statistic summaries use ordered sample labels plus error bars, and TreeMix
  ggplot helpers label population tips rather than exposing internal node IDs.

## Decisions for ggPopi

- Keep the already-liked Dsuite localFstats window and chromosome-region views
  unchanged.
- Make Dsuite trio matrix/raster views use a complete background grid, observed
  D-statistic tiles, direct labels for small matrices, and black outlines for
  significant cells.
- Make trio statistic defaults read as forest/lollipop summaries: ordered
  trios, zero baseline, stems from zero, point fill for significance, and SE
  bars when available.
- Facet mixed trio statistic families by `stat`, because D-statistics, f3, and
  f4-ratio estimates answer related but differently scaled questions and should
  not be overplotted on one axis by default.
- Keep TreeMix here lightweight: grey tree edges plus red migration arrows.
  Full TreeMix tree layout and residual heatmaps should remain a future
  dedicated API rather than being forced into generic introgression semantics.
- Treat label cleanup as display-only: underscores are replaced with spaces on
  axes/labels, while imported population identifiers remain unchanged.

## Example data

Sparse one-row examples were a major reason non-window figures looked weak.
The Dsuite and ADMIXTOOLS example tables now use a small highland/lowland/hybrid
toy system with positive, negative, significant, and near-zero contrasts.
