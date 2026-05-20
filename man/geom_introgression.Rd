\name{geom_introgression}
\alias{geom_introgression}
\alias{plot_introgression}
\title{Introgression plots}
\usage{
geom_introgression(
  mapping = NULL,
  data = NULL,
  ...,
  stat = "all",
  analysis = c("auto", "window", "trio", "graph"),
  chr = NULL,
  start = NULL,
  end = NULL,
  style = c("auto", "window", "manhattan", "region", "trio", "graph"),
  colour_by = c("stat", "chr"),
  point_size = NULL,
  point_alpha = 0.9,
  base_size = 11,
  base_family = "",
  palette = "publication",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_introgression(
  data,
  stat = "all",
  analysis = c("auto", "window", "trio", "graph"),
  chr = NULL,
  start = NULL,
  end = NULL,
  style = c("auto", "window", "manhattan", "region", "trio", "graph"),
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "publication",
  point_size = NULL,
  point_alpha = 0.9,
  ...
)
}
\arguments{
\item{mapping}{Optional aesthetic mapping. Defaults are chosen from the resolved plot style.}
\item{data}{A \code{ggpop_introgression} object from \code{import_introgression()}.}
\item{...}{Additional geom parameters.}
\item{stat}{Introgression statistic names to plot, e.g. \code{c("D", "fdM")} or \code{"all"}.}
\item{analysis}{Optional analysis class filter: \code{"window"}, \code{"trio"}, or \code{"graph"}.}
\item{chr}{Optional chromosome vector for windowed results.}
\item{start, end}{Optional genomic region boundaries in base pairs for windowed results.}
\item{style}{Plot layout. \code{"auto"} uses chromosome-wise Manhattan-like points for genome-wide window statistics, a point-and-line regional axis for local window calls, a trio dot plot for Dtrios-style summaries, and an edge diagram for graph data. \code{"manhattan"} is accepted as a compatibility alias for \code{"window"}.}
\item{colour_by}{Colour window plots by statistic or chromosome.}
\item{point_size, point_alpha}{Layer appearance. Genome-wide window plots use this value as point size; region plots use it as point size and draw a thinner connecting line.}
\item{base_size, base_family}{Base theme font controls.}
\item{palette}{ggpop discrete palette.}
\item{na.rm, show.legend, inherit.aes}{Standard ggplot2 layer arguments.}
\item{title, subtitle, caption}{Optional plot labels. No default title is added.}
}
\value{
\code{geom_introgression()} returns a list of ggplot layers. \code{plot_introgression()} returns a ggplot object.
}
\description{
Plot introgression summaries from Dsuite, genomics_general, TreeMix-style edge summaries, or ADMIXTOOLS2 qpGraph edge tables. Windowed statistics use chromosome-wise Manhattan-like points or regional point-and-line traces, trio summaries use a horizontal dot plot, and graph inputs use a compact edge diagram.
}
\examples{
intro_dir <- system.file("extdata", "introgression", "genomics_general", package = "ggpop")
intro <- import_introgression(intro_dir, type = "genomics_general")
intro |> plot_introgression(stat = c("D", "fdM"))
intro |> plot_introgression(stat = "D", chr = "1")
intro |> ggpop() + geom_introgression(stat = "D")
}
