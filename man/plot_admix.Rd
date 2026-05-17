\name{plot_admix}
\alias{plot_admix}
\alias{plot_admixture_pophelper}
\alias{as_pophelper_qlist}
\title{Publication-oriented admixture plots}
\usage{
plot_admix(data, title = NULL, subtitle = NULL, caption = NULL,
  sort = c("none", "cluster", "all", "label"), sortind = NULL,
  k = "all", palette = NULL, group = "pop", order_group = FALSE,
  show_group_labels = NULL, subset_group = NULL, show_legend = FALSE,
  show_sample_labels = FALSE, base_size = 5, base_family = "",
  legend_position = "top", bar_width = 1, ...)
as_pophelper_qlist(data)
plot_admixture_pophelper(data, ..., exportplot = FALSE, returnplot = TRUE,
  theme = "theme_bw", basesize = 8)
}
\arguments{
\item{data}{A `ggpop_admix` object.}
\item{title, subtitle, caption}{Plot text.}
\item{sort, sortind}{Native and pophelper-compatible sample ordering modes.}
\item{k}{K selection: `"all"`, a single integer, or an integer vector such as `c(2, 4)`.}
\item{palette}{Named or unnamed cluster colours.}
\item{group, order_group, show_group_labels, subset_group}{Population group column and pophelper-style group controls.}
\item{show_legend, show_sample_labels}{Legend and sample-label display switches.}
\item{base_size, base_family, legend_position}{Admixture plot theme settings aligned with the supported pophelper `plotQ()` subset.}
\item{bar_width}{Admixture bar width.}
\item{...}{Additional arguments passed to `geom_admix()` or `pophelper::plotQ()`.}
\item{exportplot, returnplot, theme, basesize}{Arguments forwarded to `pophelper::plotQ()`.}
}
\description{
`plot_admix()` is ggpop's native ggplot wrapper and always returns a ggplot object. It accepts full multi-K `ggpop_admix` data from `import_admix()` and filters with `k`; `k = "all"` renders joined K panels in the supported pophelper `plotQ(imgoutput = "join")` style. With `pop_group`, it supports individual labels, sorted individuals, group labels, and group-aware sorting. `plot_admixture_pophelper()` converts ggpop long-form admixture data to a pophelper qlist and calls `pophelper::plotQ()` for direct original-package compatibility; its return structure follows pophelper.
}
\details{
The recommended user-facing admixture plotting interfaces are `plot_admix()` and `geom_admix()`. `plot_admixture_pophelper()` is an advanced compatibility escape hatch for users who need original pophelper behavior.
}
