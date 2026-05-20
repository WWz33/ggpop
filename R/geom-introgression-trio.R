.introgression_trio_layers <- function(data, mapping, dots, point_size, point_alpha,
                                       base_size, base_family, palette, na.rm, show.legend, inherit.aes) {
  mapping <- mapping %||% ggplot2::aes(x = stats::reorder(.data$trio, .data$value), y = .data$value, colour = .data$stat)
  point_args <- c(list(size = point_size, alpha = point_alpha, na.rm = na.rm, show.legend = show.legend, inherit.aes = inherit.aes), dots)
  list(
    do.call(ggplot2::geom_point, c(list(mapping = mapping, data = data), point_args)),
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey70", inherit.aes = FALSE),
    ggplot2::coord_flip(),
    scale_colour_ggpop(max(length(unique(data$stat)), 1), palette, guide = "none"),
    ggplot2::labs(x = "Trio", y = "Introgression statistic", colour = "stat"),
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
      ggplot2::theme(legend.position = "none")
  )
}
