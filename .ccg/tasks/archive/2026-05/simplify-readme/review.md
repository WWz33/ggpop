## Review

Scope: simplify README into a concise R package landing page and rebuild pkgdown home files.

Verification:
- README quick-start import and `plot_manha()` build succeeded with local package library.
- `pkgdown` site build completed successfully.
- Updated `docs/index.html` contains the simplified README content.

Notes:
- `pkgdown` reported pre-existing missing image references in `manuscript-positioning.md`; this task did not change that file.
- Untracked `.tmp/` and `pkgdown/` directories were intentionally left unstaged.
