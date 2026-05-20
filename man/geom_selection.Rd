\name{geom_selection}
\alias{geom_selection}
\alias{plot_selection}
\title{Selective sweep scan plots}
\usage{
geom_selection(
  mapping = ggplot2::aes(x = .data$pos/1e+06, y = .data$value),
  data = NULL,
  ...,
  stat = "all",
  chr = NULL,
  start = NULL,
  end = NULL,
  geom = c("point", "line"),
  colour_by = c("stat", "chr"),
  value = c("signed", "absolute"),
  threshold = NULL,
  threshold_type = c("value", "quantile"),
  threshold_color = "#D55E00",
  threshold_linetype = "dashed",
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "publication",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_selection(
  data,
  stat = "all",
  chr = NULL,
  start = NULL,
  end = NULL,
  geom = "point",
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "publication",
  value = c("signed", "absolute"),
  threshold = NULL,
  threshold_type = c("value", "quantile"),
  style = c("auto", "single", "manhattan"),
  binary = FALSE,
  threshold_color = "#D55E00",
  threshold_linetype = "dashed",
  point_size = NULL,
  point_alpha = NULL,
  ...
)
}
\arguments{
\item{mapping}{Aesthetic mapping. Defaults to position in Mb and selection score.}
\item{data}{A \code{ggpop_selection} object from \code{import_selection()}.}
\item{...}{Additional geom parameters.}
\item{stat}{Selection statistic names to plot, e.g. \code{c("ihs", "xpehh")} or \code{"all"}.}
\item{chr}{Optional chromosome vector.}
\item{start, end}{Optional genomic region boundaries in base pairs.}
\item{geom}{Draw \code{"point"} or \code{"line"} layers.}
\item{colour_by}{Colour by statistic or chromosome.}
\item{value}{Plot signed scores or absolute scores. Absolute mode replaces \code{value} with \code{abs(value)} and draws only positive threshold lines.}
\item{threshold}{Optional threshold. With \code{threshold_type = "value"}, this is a score cutoff such as \code{2}. With \code{threshold_type = "quantile"}, values between 0 and 1 are interpreted as quantile probabilities such as \code{0.95}.}
\item{threshold_type}{Interpret \code{threshold} as fixed score values or quantile probabilities. Quantiles are computed from absolute scores after statistic, chromosome, and region filtering.}
\item{style}{Direct plot layout. \code{"auto"} uses a Manhattan-like chromosome axis unless \code{chr}, \code{start}, or \code{end} is supplied; local calls use the single-region position axis. Use \code{"manhattan"} or \code{"single"} to force a layout.}
\item{binary}{Use two alternating chromosome colours for Manhattan-like selection plots. The default \code{"manhattan"} palette alternates \code{#4E79A7} and \code{#C4E2F3}.}
\item{threshold_color, threshold_linetype}{Threshold line appearance.}
\item{size, alpha}{Layer appearance for \code{geom_selection()}.}
\item{point_size, point_alpha}{Point appearance for \code{plot_selection()}. Single-region plots default to smaller points; Manhattan-like plots default to the GWAS Manhattan point style.}
\item{base_size, base_family}{Base theme font controls.}
\item{palette}{ggpop discrete palette.}
\item{na.rm, show.legend, inherit.aes}{Standard ggplot2 layer arguments.}
\item{title, subtitle, caption}{Optional plot labels. No default title is added.}
}
\value{
\code{geom_selection()} returns a list of ggplot layers. \code{plot_selection()} returns a ggplot object.
}
\description{
Plot selective sweep scan statistics along chromosomes or selected genomic regions. Supports common selscan outputs such as iHS, nSL, iHH12, XP-EHH, and XP-nSL tables, plus XPCLR window tables imported with \code{import_selection()}.
}
\examples{
selscan_dir <- system.file("extdata", "selective_sweep", "selscan", package = "ggpop")
selection <- import_selection(selscan_dir, type = "selscan")
selection |> plot_selection(stat = "ihs", value = "absolute")
selection |> plot_selection(stat = c("ihs", "xpehh"), chr = "1")
selection |> ggpop() + geom_selection(stat = "ihs", chr = "1", threshold = 2)
selection |> plot_selection(stat = "ihs", chr = "1", value = "absolute",
  threshold = 0.95, threshold_type = "quantile")
}
