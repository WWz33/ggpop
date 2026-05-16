# Package index

## Core Data Workflows

Import typed data and start tidy ggplot workflows.

- [`ggpop()`](https://wwz33.github.io/ggpop/reference/ggpop.md) : Create
  a ggplot object from ggpop data
- [`import_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md)
  [`improt_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md)
  [`prot_gwas()`](https://wwz33.github.io/ggpop/reference/import_gwas.md)
  : Import GWAS result files
- [`import_pca()`](https://wwz33.github.io/ggpop/reference/import_pca.md)
  [`compute_pca()`](https://wwz33.github.io/ggpop/reference/import_pca.md)
  : Import or compute PCA results
- [`import_pop_group()`](https://wwz33.github.io/ggpop/reference/import_pop_group.md)
  : Import population group labels
- [`import_admixture()`](https://wwz33.github.io/ggpop/reference/import_admixture.md)
  [`import_admix()`](https://wwz33.github.io/ggpop/reference/import_admixture.md)
  : Import admixture proportion files

## GWAS Plots

Manhattan and Q-Q plots for GCTA, GEMMA, and EMMAX results.

- [`plot_manha()`](https://wwz33.github.io/ggpop/reference/plot_manha.md)
  [`plot_gwas()`](https://wwz33.github.io/ggpop/reference/plot_manha.md)
  : Publication-oriented Manhattan plots
- [`geom_manha()`](https://wwz33.github.io/ggpop/reference/geom_manha.md)
  [`geom_manha_pub()`](https://wwz33.github.io/ggpop/reference/geom_manha.md)
  : Manhattan plot layer
- [`plot_qq()`](https://wwz33.github.io/ggpop/reference/plot_qq.md) :
  Publication-oriented GWAS Q-Q plots
- [`geom_qq()`](https://wwz33.github.io/ggpop/reference/geom_qq.md)
  [`geom_qq_pub()`](https://wwz33.github.io/ggpop/reference/geom_qq.md)
  : Q-Q plot layer for GWAS p-values

## PCA Plots

PLINK/GCTA imports and optional flashpcaR computation.

- [`plot_pca()`](https://wwz33.github.io/ggpop/reference/plot_pca.md) :
  Publication-oriented PCA plots
- [`geom_pca()`](https://wwz33.github.io/ggpop/reference/geom_pca.md)
  [`geom_pca_pub()`](https://wwz33.github.io/ggpop/reference/geom_pca.md)
  : PCA scatter layer
- [`import_pca()`](https://wwz33.github.io/ggpop/reference/import_pca.md)
  [`compute_pca()`](https://wwz33.github.io/ggpop/reference/import_pca.md)
  : Import or compute PCA results

## Admixture Plots

Narrow user-facing admixture plotting API.

- [`plot_admix()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
  [`as_pophelper_qlist()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
  [`plot_admixture_pophelper()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
  : Publication-oriented admixture plots
- [`geom_admix()`](https://wwz33.github.io/ggpop/reference/geom_admix.md)
  [`geom_admix_pub()`](https://wwz33.github.io/ggpop/reference/geom_admix.md)
  : Admixture barplot layer

## Styling

Shared palettes, scales, and publication theme helpers.

- [`new_pop_palette()`](https://wwz33.github.io/ggpop/reference/pop_palettes.md)
  [`ggpop_palette()`](https://wwz33.github.io/ggpop/reference/pop_palettes.md)
  [`scale_colour_ggpop()`](https://wwz33.github.io/ggpop/reference/pop_palettes.md)
  [`scale_color_ggpop()`](https://wwz33.github.io/ggpop/reference/pop_palettes.md)
  [`scale_fill_ggpop()`](https://wwz33.github.io/ggpop/reference/pop_palettes.md)
  : Discrete ggpop population palettes
- [`theme_ggpop_publication()`](https://wwz33.github.io/ggpop/reference/theme_ggpop_publication.md)
  [`ggpop_palette()`](https://wwz33.github.io/ggpop/reference/theme_ggpop_publication.md)
  [`scale_fill_ggpop()`](https://wwz33.github.io/ggpop/reference/theme_ggpop_publication.md)
  [`scale_colour_ggpop()`](https://wwz33.github.io/ggpop/reference/theme_ggpop_publication.md)
  : Publication-oriented ggpop styles
- [`theme_tidyplot()`](https://wwz33.github.io/ggpop/reference/themes.md)
  [`theme_ggplot2()`](https://wwz33.github.io/ggpop/reference/themes.md)
  [`theme_minimal_xy()`](https://wwz33.github.io/ggpop/reference/themes.md)
  [`theme_minimal_x()`](https://wwz33.github.io/ggpop/reference/themes.md)
  [`theme_minimal_y()`](https://wwz33.github.io/ggpop/reference/themes.md)
  [`style_void()`](https://wwz33.github.io/ggpop/reference/themes.md) :
  ggpop theme helpers

## Advanced Compatibility

Exported integration hooks and original-package compatibility layers.

- [`geom_admix()`](https://wwz33.github.io/ggpop/reference/geom_admix.md)
  [`geom_admix_pub()`](https://wwz33.github.io/ggpop/reference/geom_admix.md)
  : Admixture barplot layer
- [`geom_manha()`](https://wwz33.github.io/ggpop/reference/geom_manha.md)
  [`geom_manha_pub()`](https://wwz33.github.io/ggpop/reference/geom_manha.md)
  : Manhattan plot layer
- [`geom_pca()`](https://wwz33.github.io/ggpop/reference/geom_pca.md)
  [`geom_pca_pub()`](https://wwz33.github.io/ggpop/reference/geom_pca.md)
  : PCA scatter layer
- [`geom_qq()`](https://wwz33.github.io/ggpop/reference/geom_qq.md)
  [`geom_qq_pub()`](https://wwz33.github.io/ggpop/reference/geom_qq.md)
  : Q-Q plot layer for GWAS p-values
- [`plot_admix()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
  [`as_pophelper_qlist()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
  [`plot_admixture_pophelper()`](https://wwz33.github.io/ggpop/reference/plot_admix.md)
  : Publication-oriented admixture plots
- [`pophelper_functions()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`pophelper_call()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`import_pophelper_qlist()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`pophelper_as_qlist()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`pophelper_is_qlist()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`read_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`plot_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`plot_pophelper_q_multiline()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`align_pophelper_k()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`sort_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`split_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`merge_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`join_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`tabulate_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`summarise_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`analyse_pophelper_q()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`evanno_pophelper_structure()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`pophelper_distruct_colours()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  [`pophelper_verify_grplab()`](https://wwz33.github.io/ggpop/reference/pophelper_compat.md)
  : pophelper compatibility layer
