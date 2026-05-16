theme_ggpop_publication <- function(base_size = 11, base_family = "",
                                    legend_position = "top",
                                    grid = c("major", "none", "both")) {
  grid <- match.arg(grid)
  major_grid <- if (grid %in% c("major", "both")) {
    ggplot2::element_line(colour = "grey90", linewidth = 0.25)
  } else {
    ggplot2::element_blank()
  }
  minor_grid <- if (grid == "both") {
    ggplot2::element_line(colour = "grey95", linewidth = 0.15)
  } else {
    ggplot2::element_blank()
  }
  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", colour = "grey10", margin = ggplot2::margin(b = 5)),
      plot.subtitle = ggplot2::element_text(colour = "grey30", margin = ggplot2::margin(b = 6)),
      plot.caption = ggplot2::element_text(colour = "grey40", hjust = 1),
      axis.title = ggplot2::element_text(face = "bold", colour = "grey10"),
      axis.text = ggplot2::element_text(colour = "grey15"),
      axis.line = ggplot2::element_line(colour = "grey15", linewidth = 0.35),
      axis.ticks = ggplot2::element_line(colour = "grey15", linewidth = 0.3),
      panel.grid.major = major_grid,
      panel.grid.minor = minor_grid,
      strip.background = ggplot2::element_rect(fill = "grey95", colour = "grey75", linewidth = 0.35),
      strip.text = ggplot2::element_text(face = "bold", colour = "grey10"),
      legend.position = legend_position,
      legend.title = ggplot2::element_text(face = "bold"),
      legend.key = ggplot2::element_rect(fill = "white", colour = NA),
      plot.margin = ggplot2::margin(7, 9, 7, 9)
    )
}

.ggpop_apply_labels <- function(plot, title = NULL, subtitle = NULL, caption = NULL,
                                x = NULL, y = NULL, fill = NULL, colour = NULL) {
  plot + ggplot2::labs(
    title = title,
    subtitle = subtitle,
    caption = caption,
    x = x,
    y = y,
    fill = fill,
    colour = colour
  )
}
