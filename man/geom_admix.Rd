\name{geom_admix}
\alias{geom_admix}
\alias{geom_admix_pub}
\title{Admixture barplot layer}
\usage{
geom_admix(mapping = NULL, data = NULL, ...,
  sort = c("none", "cluster", "all", "label"), sortind = NULL,
  k = "all", palette = NULL, group = "pop", order_group = FALSE,
  show_group_labels = NULL, subset_group = NULL, bar_width = 1,
  show.legend = FALSE, show_sample_labels = FALSE,
  indlabwithgrplab = FALSE, indlabsep = " ", indlabsize = 5,
  indlabangle = 90, indlabvjust = 0.5, indlabhjust = 1,
  indlabcol = "grey30", indlabspacer = 0, grplabsize = 7,
  grplabcol = "grey30", grplabbgcol = "#DCDCDC",
  show_y_axis = FALSE, show_ticks = FALSE, ticksize = 0.1,
  ticklength = 0.03, base_size = 5, base_family = "",
  legend_position = "top", na.rm = FALSE, inherit.aes = TRUE)
geom_admix_pub(mapping = ggplot2::aes(sample_id = .data$sample_id,
  cluster = .data$cluster, proportion = .data$proportion), data = NULL, ...,
  sort = c("none", "cluster", "label"), k = "all", palette = NULL,
  bar_width = 1, show.legend = FALSE, show_sample_labels = FALSE,
  inherit.aes = TRUE)
}
\arguments{
\item{mapping}{Ignored. Admixture layers require pophelper-style stacked Q bars.}
\item{data}{Optional layer data.}
\item{...}{Additional layer parameters.}
\item{sort, sortind}{Sample ordering strategy: `none`, `all`, `cluster`, `label`, or a cluster name such as `K1`. `sortind` is a pophelper-compatible alias.}
\item{k}{K selection: `"all"`, a single integer, or an integer vector.}
\item{palette}{Optional cluster palette for publication style.}
\item{group}{Population group column, usually `pop` from `import_pop_group()`.}
\item{order_group, show_group_labels, subset_group}{Pophelper-style group ordering, strip display, and subsetting controls.}
\item{bar_width}{Admixture bar width.}
\item{indlabwithgrplab, indlabsep, indlabsize, indlabangle, indlabvjust, indlabhjust, indlabcol, indlabspacer}{Individual label controls aligned with pophelper naming.}
\item{grplabsize, grplabcol, grplabbgcol}{Group facet strip controls aligned with pophelper naming.}
\item{show_y_axis, show_ticks, ticksize, ticklength}{Axis and tick controls aligned with pophelper defaults.}
\item{base_size, base_family, legend_position}{Admixture plot theme settings.}
\item{na.rm}{Remove missing values.}
\item{show.legend}{Legend display.}
\item{show_sample_labels}{Display sample labels on the x axis.}
\item{inherit.aes}{Inherit plot aesthetics.}
}
\description{
Adds a stacked admixture proportion barplot layer for `ggpop_admix` data. The recommended ggplot extension path is `import_admix(...) |> ggpop() + geom_admix(k = ...)`, and the same visual style powers `plot_admix()`. The native implementation mirrors the supported pophelper `plotQ()` behavior for individual labels, sample sorting, group labels, and sorting with group labels while returning a ggplot object.
}
