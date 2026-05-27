\name{plot_admix2}
\alias{plot_admix2}
\alias{geom_admix2}
\title{Pure ggplot-style admixture plots}
\usage{
plot_admix2(data, title = NULL, subtitle = NULL, caption = NULL,
  sort = c("assignment", "none", "label"), k = "all", palette = "Paired",
  group = "pop", show_legend = FALSE, show_sample_labels = FALSE,
  base_size = 12, base_family = "", bar_width = 1, strip_angle = 30, ...)

geom_admix2(mapping = NULL, data = NULL, ...,
  sort = c("assignment", "none", "label"), k = "all", palette = "Paired",
  group = "pop", bar_width = 1, show.legend = FALSE,
  show_sample_labels = FALSE, base_size = 12, base_family = "",
  strip_angle = 30, na.rm = FALSE, inherit.aes = TRUE)
}
\arguments{
\item{data}{A `ggpop_admix` object, or optional layer data for `geom_admix2()`.}
\item{title, subtitle, caption}{Plot text.}
\item{sort}{Sample ordering: `assignment` orders by most likely cluster and descending assignment probability, `none` keeps input order, and `label` orders sample labels.}
\item{k}{K selection: `"all"`, a single integer, or an integer vector.}
\item{palette}{A single RColorBrewer palette name such as `"Paired"`, or a manual cluster colour vector.}
\item{group}{Population group column used for script-style free facets. Set to `NULL` to draw without group facets.}
\item{show_legend, show.legend}{Legend display switches.}
\item{show_sample_labels}{Display sample labels on the x axis.}
\item{base_size, base_family}{Theme font settings.}
\item{bar_width}{Admixture bar width.}
\item{strip_angle}{Facet strip text angle.}
\item{mapping}{Ignored. Admixture layers define their own required aesthetics.}
\item{...}{Additional arguments passed to `ggplot2::geom_col()`.}
\item{na.rm}{Remove missing values.}
\item{inherit.aes}{Inherit plot aesthetics.}
}
\description{
`plot_admix2()` and `geom_admix2()` provide the pure ggplot-style ADMIXTURE layout: stacked bars, assignment-based sample ordering, `theme_minimal()`, Brewer `Paired` fills by default, and script-style free facets by K and population group. The original `plot_admix()` and `geom_admix()` remain the pophelper-style interfaces.
}
