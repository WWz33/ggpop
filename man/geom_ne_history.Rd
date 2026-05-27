\name{geom_ne_history}
\alias{geom_ne_history}
\alias{geom_demographic_history}
\alias{plot_ne_history}
\alias{plot_demographic_history}
\title{Effective population size history plots}
\usage{
geom_ne_history(
  mapping = ggplot2::aes(x = .data$time, y = .data$ne, colour = .data$sample_id),
  data = NULL,
  ...,
  sample_id = NULL,
  method = NULL,
  style = c("auto", "step", "line", "point"),
  ci = TRUE,
  colour_by = c("sample_id", "method"),
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  log_x = TRUE,
  log_y = TRUE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_ne_history(
  data,
  sample_id = NULL,
  method = NULL,
  style = c("auto", "step", "line", "point"),
  ci = TRUE,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  log_x = TRUE,
  log_y = TRUE,
  ...
)

geom_demographic_history(
  mapping = ggplot2::aes(x = .data$time, y = .data$ne, colour = .data$sample_id),
  data = NULL,
  ...,
  sample_id = NULL,
  method = NULL,
  style = c("auto", "step", "line", "point"),
  ci = TRUE,
  colour_by = c("sample_id", "method"),
  size = NULL,
  alpha = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  log_x = TRUE,
  log_y = TRUE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
)

plot_demographic_history(
  data,
  sample_id = NULL,
  method = NULL,
  style = c("auto", "step", "line", "point"),
  ci = TRUE,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  palette = "population",
  log_x = TRUE,
  log_y = TRUE,
  ...
)
}
\arguments{
\item{mapping}{Aesthetic mapping. Defaults to time, Ne, and sample colour.}
\item{data}{A \code{ggpop_ne_history} object from \code{import_ne_history()}.}
\item{...}{Additional geom parameters.}
\item{sample_id, method}{Optional sample/population or method filters.}
\item{style}{Draw \code{"auto"}, \code{"step"}, \code{"line"}, or \code{"point"} layers. \code{"auto"} follows common tool conventions: SMC++ histories use lines, while PSMC, MSMC2, and Stairway Plot 2 histories use step curves.}
\item{ci}{Draw confidence interval ribbons when \code{ne_lower} and \code{ne_upper} are available.}
\item{colour_by}{Colour by sample or method.}
\item{size, alpha}{Layer appearance.}
\item{base_size, base_family}{Base theme font controls.}
\item{palette}{ggpop discrete palette.}
\item{log_x, log_y}{Use log10 time and Ne axes.}
\item{na.rm, show.legend, inherit.aes}{Standard ggplot2 layer arguments.}
\item{title, subtitle, caption}{Optional plot labels. No default title is added.}
}
\value{
\code{geom_ne_history()} and \code{geom_demographic_history()} return a list of ggplot layers. \code{plot_ne_history()} and \code{plot_demographic_history()} return a ggplot object.
}
\description{
Plot effective population size through time from PSMC, MSMC2, SMC++, and Stairway Plot 2 outputs.
}
\details{
SMC++ bootstrap or replicate trajectories are drawn first as thin low-alpha lines when common columns such as \code{type}, \code{plot_type}, \code{replicate}, or \code{bootstrap} identify them. Main trajectories remain visually dominant.
}
\examples{
smcpp <- import_ne_history(
  system.file("extdata", "ne_history", "SMC++", "model.csv", package = "ggpop"),
  type = "smcpp"
)
smcpp |> plot_ne_history()
smcpp |> ggpop() + geom_ne_history()
}
