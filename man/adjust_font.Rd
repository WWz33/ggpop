\name{adjust_font}
\alias{adjust_font}
\title{Adjust ggpop font settings}
\usage{
adjust_font(
  plot,
  base_size = 11,
  base_family = "",
  title_size = NULL,
  subtitle_size = NULL,
  caption_size = NULL,
  axis_title_size = NULL,
  axis_text_size = NULL,
  legend_title_size = NULL,
  legend_text_size = NULL,
  strip_text_size = NULL,
  face = NULL
)
}
\arguments{
\item{plot}{A ggplot object.}
\item{base_size}{Base font size in points.}
\item{base_family}{Base font family.}
\item{title_size, subtitle_size, caption_size}{Optional sizes for plot title, subtitle, and caption.}
\item{axis_title_size, axis_text_size}{Optional sizes for axis titles and text.}
\item{legend_title_size, legend_text_size}{Optional sizes for legend title and text.}
\item{strip_text_size}{Optional size for facet strip text.}
\item{face}{Optional font face passed to text elements.}
}
\value{
A ggplot object.
}
\description{
Apply a consistent text scale to a ggpop/ggplot object.
}
