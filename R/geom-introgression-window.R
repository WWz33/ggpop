.introgression_window_layers <- function(data, dots, point_size, point_alpha, base_size, base_family, palette, na.rm, show.legend) {
  data <- .introgression_order_window_data(data)
  layout <- .selection_genome_layout(data)
  layout$data$.window_group <- interaction(layout$data$.group, layout$data$chr, drop = TRUE, sep = ":")
  point_args <- c(list(size = point_size, alpha = point_alpha, na.rm = na.rm, show.legend = show.legend), dots)
  colour_count <- max(length(unique(layout$data$chr_group)), 2)
  list(
    do.call(
      ggplot2::geom_point,
      c(list(
        mapping = ggplot2::aes(x = .data$genome_pos, y = .data$value, colour = .data$chr_group),
        data = layout$data,
        inherit.aes = FALSE
      ), point_args)
    ),
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey70", inherit.aes = FALSE),
    ggplot2::scale_x_continuous(
      limits = layout$limits,
      breaks = layout$breaks,
      labels = layout$labels,
      expand = c(0, 0),
      guide = ggplot2::guide_axis(check.overlap = TRUE)
    ),
    scale_colour_ggpop(colour_count, "manhattan", guide = "none"),
    ggplot2::labs(x = layout$x_label, y = "Introgression statistic", colour = "chr"),
    .introgression_facet(data),
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        panel.spacing = grid::unit(0.1, "cm"),
        strip.background = ggplot2::element_blank(),
        legend.position = "none"
      )
  )
}

.introgression_region_layers <- function(data, mapping, dots, colour_by, point_size, point_alpha,
                                         base_size, base_family, palette, na.rm, show.legend, inherit.aes) {
  data <- .introgression_order_window_data(data)
  data$.window_group <- interaction(data$.group, data$chr, drop = TRUE, sep = ":")
  mapping <- mapping %||% ggplot2::aes(x = .data$pos / 1e6, y = .data$value)
  if (is.null(mapping$colour) && is.null(mapping$color) && colour_by %in% names(data)) {
    values <- as.list(mapping)
    values$colour <- rlang::expr(.data[[colour_by]])
    mapping <- do.call(ggplot2::aes, values)
  }
  if (is.null(mapping$group)) {
    values <- as.list(mapping)
    values$group <- rlang::expr(.data[[".window_group"]])
    mapping <- do.call(ggplot2::aes, values)
  }
  point_args <- c(list(size = point_size, alpha = point_alpha, na.rm = na.rm, show.legend = show.legend, inherit.aes = inherit.aes), dots)
  line_args <- c(list(linewidth = max(point_size / 2, 0.2), alpha = point_alpha, na.rm = na.rm, show.legend = FALSE, inherit.aes = inherit.aes), dots)
  line_args$size <- NULL
  list(
    do.call(ggplot2::geom_line, c(list(mapping = mapping, data = data), line_args)),
    do.call(ggplot2::geom_point, c(list(mapping = mapping, data = data), point_args)),
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey70", inherit.aes = FALSE),
    scale_colour_ggpop(max(length(unique(data[[colour_by]])), 1), palette, guide = "none"),
    ggplot2::scale_x_continuous(expand = c(0, 0)),
    ggplot2::labs(x = "Position (Mb)", y = "Introgression statistic", colour = colour_by),
    .introgression_facet(data),
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        panel.spacing = grid::unit(0.1, "cm"),
        strip.background = ggplot2::element_blank(),
        legend.position = "none"
      )
  )
}
