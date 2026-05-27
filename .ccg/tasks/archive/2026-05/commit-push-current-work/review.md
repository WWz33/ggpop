# Review

## Scope

- Commit and push current ggPopi source, example data, documentation, generated README figures, and pkgdown site output.
- Exclude local scratch output: `.tmp/`.
- Exclude unreferenced local pkgdown source-asset directory: `pkgdown/`.

## Verification

- `devtools::test(stop_on_failure=TRUE)`: passed.
- Result: 478 OK, 0 failures, 0 warnings, 0 skips.
- `pkgdown_build.R` had already completed successfully before this commit task.

## Notes

- Worktree was already broad and dirty when commit request was received.
- User explicitly requested commit and push, so current package/docs work is committed together.
