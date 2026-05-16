#' Adjust ggpop font settings
#'
#' Apply a consistent text scale to a ggpop/ggplot object.
#'
#' @param plot A ggplot object.
#' @param base_size Base font size in points.
#' @param base_family Base font family.
#' @param title_size,subtitle_size,caption_size Optional sizes for plot title,
#'   subtitle, and caption.
#' @param axis_title_size,axis_text_size Optional sizes for axis titles and text.
#' @param legend_title_size,legend_text_size Optional sizes for legend title and
#'   text.
#' @param strip_text_size Optional size for facet strip text.
#' @param face Optional font face passed to text elements.
#'
#' @return A ggplot object.
#' @export
adjust_font <- function(plot, base_size = 11, base_family = "",
                        title_size = NULL, subtitle_size = NULL,
                        caption_size = NULL, axis_title_size = NULL,
                        axis_text_size = NULL, legend_title_size = NULL,
                        legend_text_size = NULL, strip_text_size = NULL,
                        face = NULL) {
  plot <- .check_ggpop_plot(plot)
  plot + .ggpop_text_theme(
    base_size = base_size,
    base_family = base_family,
    title_size = title_size,
    subtitle_size = subtitle_size,
    caption_size = caption_size,
    axis_title_size = axis_title_size,
    axis_text_size = axis_text_size,
    legend_title_size = legend_title_size,
    legend_text_size = legend_text_size,
    strip_text_size = strip_text_size,
    face = face
  )
}

.ggpop_text_theme <- function(base_size = 11, base_family = "",
                              title_size = NULL, subtitle_size = NULL,
                              caption_size = NULL, axis_title_size = NULL,
                              axis_text_size = NULL, legend_title_size = NULL,
                              legend_text_size = NULL, strip_text_size = NULL,
                              face = NULL) {
  title_size <- title_size %||% (base_size * 1.1)
  subtitle_size <- subtitle_size %||% base_size
  caption_size <- caption_size %||% (base_size * 0.85)
  axis_title_size <- axis_title_size %||% base_size
  axis_text_size <- axis_text_size %||% (base_size * 0.9)
  legend_title_size <- legend_title_size %||% base_size
  legend_text_size <- legend_text_size %||% (base_size * 0.9)
  strip_text_size <- strip_text_size %||% base_size

  ggplot2::theme(
    text = ggplot2::element_text(
      size = base_size,
      family = base_family,
      face = face
    ),
    plot.title = ggplot2::element_text(
      size = title_size,
      family = base_family,
      face = face
    ),
    plot.subtitle = ggplot2::element_text(
      size = subtitle_size,
      family = base_family,
      face = face
    ),
    plot.caption = ggplot2::element_text(
      size = caption_size,
      family = base_family,
      face = face
    ),
    axis.title = ggplot2::element_text(
      size = axis_title_size,
      family = base_family,
      face = face
    ),
    axis.text = ggplot2::element_text(
      size = axis_text_size,
      family = base_family,
      face = face
    ),
    legend.title = ggplot2::element_text(
      size = legend_title_size,
      family = base_family,
      face = face
    ),
    legend.text = ggplot2::element_text(
      size = legend_text_size,
      family = base_family,
      face = face
    ),
    strip.text = ggplot2::element_text(
      size = strip_text_size,
      family = base_family,
      face = face
    )
  )
}
