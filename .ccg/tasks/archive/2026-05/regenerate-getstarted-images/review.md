# Review

## Scope

- Assessed `inst/extdata/ne_history/SMC++/model.csv` through `plot_demographic_history()`.
- Added reproducible README figure generator: `inst/examples/make-readme-figures.R`.
- Regenerated current-code README/get-started PNGs except `readme-ne-history.png`.

## Findings

- Critical: none.
- Warning: `readme-stats.png` inherits long right-side facet strip labels from current module output; not changed because request was image regeneration, not theme semantics.
- Warning: `readme-ld-decay.png` inherits existing x-axis tick formatting where the rightmost tick appears as `100`; not changed because request was image regeneration, not LD axis logic.
- Info: `readme-introgression.png` shows `fd` on a wide y-scale due current example values; this is current module/data behavior.
- Info: spawned review agents did not return usable review output before timeout; manual visual QA and focused R verification were used.

## Verification

- `Rscript inst/examples/make-readme-figures.R`: passed.
- demographic history QA: 4 populations, 28 main points, 56 bootstrap points, years x-axis label: passed.
- `devtools::test(filter='ne-history', stop_on_failure=TRUE)`: passed, 45 OK.
- `devtools::test(filter='publication-plots', stop_on_failure=TRUE)`: passed, 51 OK.
