# Review

## Scope

- Ran the existing pkgdown workflow: `../.workflow/pkgdown_build.R`.
- Workflow cleaned and rebuilt `docs/`.

## Result

- pkgdown build completed successfully.
- Verified generated files:
  - `docs/index.html`
  - `docs/articles/ggPopi.html`
  - `docs/reference/plot_admix2.html`
  - `docs/reference/figures/readme-manhattan.png`

## Warnings

- pkgdown reported missing images in `manuscript-positioning.md`:
  `reference/figures/readme-manhattan.png`, `reference/figures/readme-pca.png`,
  `reference/figures/readme-admixture.png`, and `reference/figures/readme-stats.png`.
- This appears to be a source-path issue for that manuscript page; pkgdown later copied
  `man/figures/readme-*.png` into `docs/reference/figures/`.
- No source-path fix was made because this task was only to build pkgdown.

## Verification

- `Rscript ../.workflow/pkgdown_build.R`: passed.
- File existence checks: passed.
