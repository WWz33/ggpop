# Admixture barplot layer

Adds a stacked admixture proportion barplot layer for \`ggpop_admix\`
data. The recommended ggplot extension path is \`import_admix(...) \|\>
ggpop() + geom_admix(k = ...)\`, and the same visual style powers
\`plot_admix()\`. The native implementation mirrors the supported
pophelper \`plotQ()\` behavior for individual labels, sample sorting,
group labels, and sorting with group labels while returning a ggplot
object.

## Usage

``` r
geom_admix(mapping = NULL, data = NULL, ...,
  sort = c("none", "cluster", "all", "label"), sortind = NULL,
  k = "all", palette = NULL, group = "pop", pop_group = TRUE,
  order_group = FALSE, show_group_labels = NULL, subset_group = NULL,
  bar_width = 1, show.legend = FALSE, show_sample_labels = FALSE,
  indlabwithgrplab = FALSE, indlabsep = " ", indlabsize = 5,
  indlabangle = 90, indlabvjust = 0.5, indlabhjust = 1,
  indlabcol = "grey30", indlabspacer = 0, grplabsize = 7,
  grplabcol = "grey30", grplabbgcol = "#DCDCDC",
  show_y_axis = FALSE, show_ticks = FALSE, ticksize = 0.1,
  ticklength = 0.03, base_size = 5, base_family = "",
  legend_position = "top", na.rm = FALSE, inherit.aes = TRUE)
```

## Arguments

- mapping:

  Ignored. Admixture layers require pophelper-style stacked Q bars.

- data:

  Optional layer data.

- ...:

  Additional layer parameters.

- sort, sortind:

  Sample ordering strategy: \`none\`, \`all\`, \`cluster\`, \`label\`,
  or a cluster name such as \`K1\`. \`sortind\` is a
  pophelper-compatible alias.

- k:

  K selection: \`"all"\`, a single integer, or an integer vector.

- palette:

  Optional cluster palette.

- group:

  Population group column, usually \`pop\` from \`import_pop_group()\`.

- pop_group:

  Set to \`FALSE\` to disable population group facets.

- order_group, show_group_labels, subset_group:

  Pophelper-style group ordering, strip display, and subsetting
  controls.

- bar_width:

  Admixture bar width.

- indlabwithgrplab, indlabsep, indlabsize, indlabangle, indlabvjust,
  indlabhjust, indlabcol, indlabspacer:

  Individual label controls aligned with pophelper naming.

- grplabsize, grplabcol, grplabbgcol:

  Group facet strip controls aligned with pophelper naming.

- show_y_axis, show_ticks, ticksize, ticklength:

  Axis and tick controls aligned with pophelper defaults.

- base_size, base_family, legend_position:

  Admixture plot theme settings.

- na.rm:

  Remove missing values.

- show.legend:

  Legend display.

- show_sample_labels:

  Display sample labels on the x axis.

- inherit.aes:

  Inherit plot aesthetics.
