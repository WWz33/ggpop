# Plot Style Philosophy Review

## Scope

Reviewed the `ggpop` plotting code for whether modules collected from multiple open-source inspirations have converged into a single project style. This was a read-only review; no package code was changed.

Gemini was invited into the discussion through the local Gemini CLI. The first attempt failed because the workspace was not trusted; the second run succeeded after setting `GEMINI_CLI_TRUST_WORKSPACE=true`. Gemini later retried and hit model-capacity `429`, but it had already returned a usable review.

## Overall judgment

`ggpop` already has a coherent top-level philosophy: typed importers produce `ggpop_*` objects; users can either call direct `plot_*()` wrappers or compose `ggpop(data) + geom_*()` layers; direct plots are intended as the visual reference contract. This is stated clearly in `README.md:154-165` and implemented across `plot_manha()`, `plot_qq()`, `plot_pca()`, `plot_admix()`, and `plot_stats()`.

The code is not yet fully unified stylistically. The remaining friction is not functional correctness; it is design-language convergence. Different source-project lineages still show through in theme defaults, argument names, exported compatibility surface, and hard-coded visual constants.

## Findings

### 1. Warning: There are competing theme systems instead of one ggpop visual spine

Evidence:
- `theme_ggpop_publication()` exists as the named project style in `R/style.R:1`.
- `theme_tidyplot()` and `.theme_tidyplot()` use a separate `fontsize = 7` convention in `R/themes.R:1` and `R/themes.R:109`.
- Manhattan plots bypass both and use `.gwas_fastman_theme()` in `R/geom-manha.R:193` and `R/geom-manha.R:279`.
- Admixture plots use `ggplot2::theme_grey()` directly in `R/geom-admix.R:154`.

Impact:
The package presents itself as having a publication-style visual contract, but each module still carries its own theme ancestry: tidyplots, fastman, pophelper, and ggplot2 grey.

Recommendation:
Create one internal theme backbone, e.g. `.theme_ggpop_base(base_size, base_family, mode = ...)`, and make module-specific themes compose from it. Keep external theme helpers if useful, but treat them as wrappers over the same core.

### 2. Warning: Size defaults are inconsistent and encode external lineage

Evidence:
- Manhattan default point size is `1.404` in `R/geom-manha.R:5`.
- PCA default point size is `2.16` in `R/geom-pca.R:2`.
- Q-Q default point size is `0.8` in `R/geom-qq.R:2`.
- Admixture defaults to `base_size = 5` in `R/geom-admix.R:6` and `R/geom-admix.R:108`.
- Stats has the cleanest project-like pattern, deriving size from `base_size` in `R/geom-stats.R:86`.

Impact:
Users can pass `base_size`, but visual scaling is not consistently derived from it. Some defaults look copied from source packages or fitted examples rather than declared ggpop semantics.

Recommendation:
Use relative sizing helpers across modules, modeled after `geom_stats()`: e.g. `.ggpop_point_size(base_size, role = "dense"|"scatter")`, `.ggpop_linewidth(base_size, role = ...)`, and `.ggpop_text_size(base_size, role = ...)`.

### 3. Warning: Public API names mix ggplot2 conventions, compatibility conventions, and legacy aliases

Evidence:
- Direct plot wrappers use snake_case user parameters like `show_legend` in `R/geom-admix.R:5`, while geoms use ggplot2-style `show.legend` in `R/geom-admix.R:102`.
- Q-Q accepts both `diagonal_color` and `diagonal_colour` in `R/geom-qq.R:3-4` and resolves them at `R/geom-qq.R:211`.
- Admixture exposes pophelper-style names such as `sortind`, `indlabwithgrplab`, `indlabsep`, and `grplab*` in `R/geom-admix.R:2` and `R/geom-admix.R:103-106`.

Impact:
The package is doing compatibility work, but the compatibility vocabulary leaks into the primary API. This weakens the “small, tidy ggpop interface” described in the README.

Recommendation:
Define a strict primary-API naming policy:
- direct wrappers: user-friendly snake_case;
- geoms: ggplot2-style names where they mirror ggplot2 (`show.legend`, `inherit.aes`);
- compatibility names: accepted but documented as aliases or moved into compatibility wrappers.

### 4. Warning: Compatibility layer is too large for the stated small user-facing API

Evidence:
- README says the recommended user-facing API is intentionally small in `README.md:154`.
- `NAMESPACE` exports many pophelper wrappers, including `plot_pophelper_q`, `plot_pophelper_q_multiline`, `pophelper_call`, `pophelper_functions`, and other pass-through utilities at `NAMESPACE:44-51`.
- `R/pophelper-compat.R:1-6` lists a broad upstream function surface, while `R/pophelper-compat.R:79`, `R/pophelper-compat.R:92`, and `R/pophelper-compat.R:105` keep direct plotting passthroughs.

Impact:
The package says ordinary workflows should prefer `import_*() |> plot_*()` and `ggpop() + geom_*()`, but the exported surface invites users back into upstream pophelper semantics.

Recommendation:
Split compatibility into tiers:
- primary ggpop API: import/plot/geom functions;
- conversion API: `import_pophelper_qlist()`, `as_pophelper_qlist()`;
- advanced compatibility: possibly still exported, but grouped, clearly labeled, and not presented as equal to ggpop-native plotting.

### 5. Info: Stats module shows the most ggpop-native design pattern

Evidence:
- `geom_stats()` derives sizes from `base_size` through `.stats_default_size()` in `R/geom-stats.R:86`.
- It uses the package palette through `scale_colour_ggpop()` in `R/geom-stats.R:32`.
- It supports both direct and layered paths through `plot_stats()` at `R/geom-stats.R:93` and `geom_stats()` at `R/geom-stats.R:1`.

Impact:
This module is a good template for convergence: ggplot-native, palette-aware, base-size-aware, and not visibly dominated by an upstream package’s argument grammar.

Recommendation:
Use `geom_stats()` as the house-style template for size derivation and layer composition.

## Gemini discussion summary

Gemini agreed with the main diagnosis:
- The architecture is correctly ggplot2-native, with `plot_*()` convenience wrappers and `geom_*()` composability.
- The biggest inconsistencies are typography (`fontsize = 7` vs `base_size = 11`), magic point sizes, mixed `color`/`colour` handling, and multiple theme pathways.
- It specifically called out fastman/fastqq residue, tidyplots residue, and pophelper surface-area leakage.
- Its top priorities were standardizing base sizes, replacing magic sizes with relative calculations, consolidating themes, absorbing fastman/fastqq logic into ggpop-native semantics, and narrowing pophelper wrappers.

## Suggested style philosophy

Use this as the project rule:

> ggpop is a ggplot2-native population-genomics plotting grammar. Direct `plot_*()` functions provide the reference publication style; `ggpop() + geom_*()` reproduces the same visual contract compositionally. External projects may inform data transforms or compatibility adapters, but visual defaults, argument naming, palette selection, typography, and exported primary APIs should speak ggpop.

## Refactor priority

1. Define one internal ggpop theme backbone and route `.theme_tidyplot()`, `.gwas_fastman_theme()`, and admixture styling through it.
2. Introduce shared sizing helpers and replace hard-coded visual constants module by module.
3. Normalize primary API argument names; keep compatibility aliases but make them explicit.
4. Reduce or relabel exported pophelper plotting pass-throughs so they do not compete with `plot_admix()` / `geom_admix()`.
5. Add tests that compare theme family, base size, palette path, and layer counts across `plot_*()` and `ggpop() + geom_*()` for every module.

## Non-goals

Do not remove compatibility support abruptly. The value of ggpop is partly that it bridges existing tools. The target is to put compatibility behind a clear boundary, not erase it.
