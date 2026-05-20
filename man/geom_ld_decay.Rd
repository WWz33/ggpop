\name{geom_ld_decay}
\alias{geom_ld_decay}
\alias{plot_ld_decay}
\title{LD decay plots}
\usage{
geom_ld_decay(
  mapping = ggplot2::aes(x = .data$dist_kb, y = .data$r2),
  data = NULL,
  ...,
  pop = NULL,
  pop_group = NULL,
  style = c("point", "line"),
  measure = c("r2", "D", "both"),
  colour_by = c("pop", "file"),
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_ld_decay(
  data,
  pop = NULL,
  pop_group = NULL,
  style = c("point", "line"),
  measure = c("r2", "D", "both"),
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  ...
)
}
\arguments{
\item{mapping}{Aesthetic mapping. Defaults to pairwise distance in Kb and mean LD \eqn{r^2}.}
\item{data}{A \code{ggpop_ld_decay} object from \code{import_ld_decay()}.}
\item{...}{Additional geom parameters.}
\item{pop}{Optional population labels to keep.}
\item{pop_group}{Optional population group table or path to the standard two-column \code{sample pop} file. File labels are matched through \code{sample}, then regrouped by the mapped population labels.}
\item{style}{Draw \code{"point"} or \code{"line"} layers.}
\item{measure}{Plot \code{r^2}, D-prime, or both measures together.}
\item{colour_by}{Colour by population or source file.}
\item{size, alpha}{Layer appearance. Point plots default to size 1, matching common LD decay summaries.}
\item{base_size, base_family}{Base theme font controls.}
\item{palette}{ggpop discrete palette.}
\item{na.rm, show.legend, inherit.aes}{Standard ggplot2 layer arguments.}
\item{title, subtitle, caption}{Optional plot labels. No default title is added.}
}
\value{
\code{geom_ld_decay()} returns a list of ggplot layers. \code{plot_ld_decay()} returns a ggplot object.
}
\description{
Plot LD decay summaries as either point or line plots. The x-axis is pairwise distance in kilobases and the y-axis defaults to mean LD \eqn{r^2}, with optional D-prime or combined \eqn{r^2}/D-prime views. All styles support population colouring through the package-wide \code{pop} column, and \code{pop_group} can relabel and regroup imported files.
}
\examples{
ld_dir <- system.file("extdata", "ld_decay", "PopLDdecay", package = "ggpop")
ld <- import_ld_decay(ld_dir, type = "poplddecay")
groups <- import_pop_group(system.file("extdata", "pop_group.txt", package = "ggpop"))
ld |> plot_ld_decay(pop_group = groups, style = "point")
ld |> plot_ld_decay(pop_group = groups, style = "line")
ld |> ggpop() + geom_ld_decay(pop_group = groups, style = "point")
}
