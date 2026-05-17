\name{geom_stats}
\alias{geom_stats}
\alias{plot_stats}
\title{Population genomics statistics plots}
\usage{
geom_stats(
  mapping = ggplot2::aes(x = .data$pos/1e+06, y = .data$value),
  data = NULL,
  ...,
  stat = "all",
  chr = NULL,
  start = NULL,
  end = NULL,
  geom = c("line", "point"),
  colour_by = c("stat", "chr"),
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "publication",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_stats(
  data,
  stat = "all",
  chr = NULL,
  start = NULL,
  end = NULL,
  geom = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "publication",
  ...
)
}
\arguments{
\item{mapping}{Aesthetic mapping. Defaults to window midpoint in Mb and statistic value.}
\item{data}{A \code{ggpop_stats} object from \code{import_stats()}.}
\item{...}{Additional geom parameters.}
\item{stat}{Statistic names to plot, e.g. \code{c("fst", "pi")} or \code{"all"}.}
\item{chr}{Optional chromosome vector.}
\item{start, end}{Optional genomic region boundaries in base pairs.}
\item{geom}{Draw \code{"line"} or \code{"point"} layers. \code{plot_stats()} chooses line for one chromosome and point for multiple chromosomes.}
\item{colour_by}{Colour by statistic or chromosome.}
\item{size, alpha}{Layer appearance. Defaults follow the pixy plotting examples.}
\item{base_size, base_family}{Base theme font controls.}
\item{palette}{ggpop discrete palette.}
\item{na.rm, show.legend, inherit.aes}{Standard ggplot2 layer arguments.}
\item{title, subtitle, caption}{Optional plot labels. No default title is added.}
}
\value{
\code{geom_stats()} returns a list of ggplot layers. \code{plot_stats()} returns a ggplot object.
}
\description{
Plot windowed population genomics summary statistics along a chromosome, selected region, or multiple chromosomes. By default, selected statistics are stacked vertically with an aligned x-axis, following the pixy plotting style.
}
\examples{
pixy_dir <- system.file("extdata", "Population_genomics_statistics", "pixy", package = "ggpop")
stats <- import_stats(pixy_dir, type = "pixy")
stats |> plot_stats(stat = c("fst", "pi"), chr = "chr2L")
stats |> plot_stats(chr = "chr2L", start = 1, end = 20000)
stats |> ggpop() + geom_stats(stat = "all", chr = c("chr2L", "chr3L"))
}
