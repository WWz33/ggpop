# Requirements

- Move all ggpop theme helpers into `R/theme.R`.
- Delete `R/style.R` if it only contains theme/label helpers after the move.
- Leave `pophelper` compatibility-layer parameters unchanged.
- Normalize mixed parameter naming only in non-pophelper plotting APIs.
- Keep public behavior stable where possible by preserving existing argument aliases when renaming.
- Report exact file/function positions in the final summary.
