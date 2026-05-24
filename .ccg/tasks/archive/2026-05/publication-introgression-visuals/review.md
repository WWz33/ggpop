# Review

## Verification

- `devtools::test(filter = "introgression", stop_on_failure = TRUE)` passed
  after adding TreeMix migration-target label placement regression coverage:
  88 passed, 0 failed, 0 warnings, 0 skipped.
- `pkgdown::build_site(new_process = FALSE)` was started with RStudio Pandoc
  configured through `RSTUDIO_PANDOC`, but the full-site command exceeded the
  5-minute shell timeout. The generated introgression guide/reference files
  below were still updated and checked directly.
- `docs/articles/guides/introgression.html` and
  `docs/reference/geom_introgression.html` were regenerated after the matrix
  grid and reference documentation updates.
- `pkgdown::build_article("guides/introgression", new_process = FALSE)` and
  `pkgdown::build_reference(topics = c("geom_introgression",
  "import_introgression"))` completed successfully after installing the current
  package into a temporary local R library. The temporary `.r-lib` directory
  was removed after verification.
- The introgression guide was rebuilt again after setting `fig.bg = "white"`
  and `dev.args = list(bg = "white")`; the Dsuite matrix PNG now renders with
  an explicit white background when opened outside pkgdown.
- `R/geom-introgression-window.R` has no diff, so the already-liked
  genome-wide and chromosome-region Dsuite localFstats views were not modified
  in this pass.
- `.tmp/introgression_preview/dsuite_auto.png`,
  `.tmp/introgression_preview/admixtools_auto.png`, and
  `.tmp/introgression_preview/treemix_graph.png` were regenerated and visually
  inspected after the TreeMix drift-coordinate label/arrow changes.
- The TreeMix preview and guide figure were regenerated again after adding
  migration-target label placement. The compact PopD migration-target label now
  sits above/left of the tip instead of overlapping the red migration arrow.
- `tests/testthat/test-introgression.R` now asserts that a left-side TreeMix
  migration-target tip label is placed left/above its node, while a normal
  right-side tip remains labelled to the right.
- Rendered guide PNGs inspected directly:
  `docs/articles/guides/introgression_files/figure-html/unnamed-chunk-4-1.png`
  shows the Dsuite P2 x P3 matrix on a self-contained white background,
  `unnamed-chunk-8-1.png` shows the ADMIXTOOLS mixed-statistic forest facets,
  and `unnamed-chunk-10-1.png` shows the TreeMix drift-coordinate graph.

## Local review result

- Critical: none found in the local review.
- Warning: independent multi-agent review could not be completed. One
  read-only review agent was started but did not return findings within a
  5-minute wait and was closed to avoid a hanging background thread.
  This review is therefore based on local inspection, tests, rendered docs, and
  the earlier external GitHub plotting-script survey.
- Info: Dsuite BBAA/Dmin trio tables now resolve to the matrix view by default;
  users can still request an ordered D-statistic forest/lollipop summary with
  `style = "trio"`.
- Info: Dsuite matrix/raster now follows the common publication pattern seen in
  external scripts: complete white background grid, D-statistic tiles,
  significant-cell outlines, and labels for small matrices.
- Info: trio statistic plots now behave like forest/lollipop summaries with a
  zero baseline, stems, significance fill, and SE bars when present.
- Info: TreeMix remains intentionally lightweight in this introgression module:
  when `*.vertices.gz` accompanies `*.edges.gz`, imported `x`, `y`, `xend`, and
  `yend` coordinates preserve the TreeMix drift layout; grey tree edges and red
  curved migration arrows are drawn in that coordinate space. A full TreeMix
  tree/residual API should remain separate.
- Info: TreeMix tip labels are placed in display coordinates rather than by
  mutating graph coordinates. Migration-target tips on the left side of the
  graph are labelled to the left/above the node to keep arrows, nodes, and text
  legible in compact example data.
- Info: A final white-background visual pass fixed display-only publication
  issues: population labels now replace underscores with spaces, matrix P2
  labels are angled to avoid overlap, and TreeMix graph labels are restricted
  to population tips instead of internal `node_*` labels.
- Info: A follow-up typography pass reduced non-window introgression plots from
  large documentation-style text toward paper-panel scale: compact legend keys,
  smaller axis/strip text, lighter italic matrix labels, and less aggressive
  wrapping for ADMIXTOOLS forest labels.
- Info: The introgression guide and reference page now document those
  display-only label behaviors, so users can distinguish imported identifiers
  from presentation labels.
- Info: Mixed ADMIXTOOLS directory imports are now tested and plotted as
  `stat` facets, preventing D, f3, and f4-ratio estimates from sharing a single
  misleading axis.
- Info: A follow-up matrix semantics pass changed repeated P2/P3 aggregation
  from numeric maximum D to maximum absolute D while preserving sign. This
  keeps strong negative D-statistic signals visible when a Dsuite trio table is
  compressed into a P2 x P3 matrix.
- Info: Public GitHub code search corroborated the current non-window defaults:
  Dsuite D-statistic scripts commonly use heatmap/matrix or D-statistic
  estimate displays, ADMIXTOOLS qpdstat/f-statistic outputs are statistic
  tables rather than graph edges, and ggplot TreeMix implementations use grey
  tree segments plus curved migration arrows in TreeMix coordinates. Examples
  found included `ivanprates/Ctenotus_inornatus_group`,
  `wutianqin123/TrichiurusGenome`, `andrewparkermorgan/popcorn`,
  `ymat2/myrrr`, `ericksonp/Zindianus_individual_sequencing`, and
  `owensgl/helianthus_hybrid_species_2021`.
- Info: The introgression guide, `geom_introgression` reference page, and
  search index were rebuilt after the matrix aggregation documentation update.
  The source vignette and Rd now state that repeated P2/P3 combinations keep the
  row with the largest absolute D value while preserving sign.
- Info: Final targeted verification on this continuation:
  `devtools::test(filter = "introgression", stop_on_failure = TRUE)` passed
  with 91 passed, 0 failed, 0 warnings, 0 skipped.
- Info: Rendered guide PNGs were inspected again directly:
  `unnamed-chunk-4-1.png` shows the Dsuite matrix with diverging D-statistic
  fill, white missing-cell grid, direct labels, and significant-cell outlines;
  `unnamed-chunk-8-1.png` shows ADMIXTOOLS D/f3/f4-ratio forest facets with a
  zero line and SE bars; `unnamed-chunk-10-1.png` shows TreeMix drift-coordinate
  tree edges plus a red migration arrow without internal node labels.
- Info: A final figure-by-figure audit also inspected the Dsuite
  `style = "trio"` forest (`unnamed-chunk-5-1.png`) and ADMIXTOOLS qpdstat
  forest (`unnamed-chunk-7-1.png`). Both were adjusted through the shared trio
  layer to add continuous-axis expansion so points and SE bars do not sit on the
  panel boundary. The introgression guide, reference page, and search index were
  rebuilt after this visual fix.
- Info: Final targeted verification after the axis-expansion pass:
  `devtools::test(filter = "introgression", stop_on_failure = TRUE)` passed
  with 91 passed, 0 failed, 0 warnings, 0 skipped.
- Info: A stale-text audit for removed toy inputs and old semantics
  (`Dtrios.tsv`, `Dinvestigate.tsv`, `vcf_pop_example`, `migration_edges.tsv`,
  `qpgraph_edges`, `TreeMix-style edge`, `ADMIXTOOLS2 qpGraph`,
  `trio-level dot plots`) returned no matches in source/docs/man/tests/inst.
- Info: Temporary `.r-lib` used for pkgdown rebuild was removed after
  verification.
- Info: Final local completion audit verified that all touched introgression R
  files parse successfully, `git diff --check` reports no whitespace errors
  beyond existing CRLF conversion warnings, and `.r-lib` is absent.
- Info: A programmatic layer audit built all relevant plots and confirmed the
  expected semantics: window plots remain point/hline or line/point/hline,
  Dsuite matrix uses tile/text layers, Dsuite `style = "trio"` uses
  segment/point/hline, ADMIXTOOLS uses segment/errorbar/point/hline with mixed
  statistic families split into three panels, and TreeMix uses
  segment/curve/point/label layers with x label `Drift parameter`.
- Warning: A final subagent review could not be launched because the session's
  thread limit is occupied by stale shutdown agent records. The completion
  audit therefore relies on local code review, targeted tests, rendered PNG
  inspection, pkgdown rebuilds, stale-text search, parse checks, and earlier
  public GitHub plotting-code surveys.

## Remaining visual review

The local implementation, docs, generated guide figures, and targeted tests now
support the requested publication-grade semantics for non-window introgression
views. No blocking local evidence remains.
