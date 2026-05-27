.introgression_trio_layers <- function(data, mapping, dots, point_size, point_alpha,
                                       base_size, base_family, palette, na.rm, show.legend, inherit.aes) {
  default_mapping <- is.null(mapping)
  fixed_data <- data[data$stat == "fixed_diff", , drop = FALSE]
  point_data <- data[data$stat != "fixed_diff", , drop = FALSE]
  if (default_mapping) {
    point_data <- .introgression_trio_plot_data(point_data)
    mapping <- ggplot2::aes(
      x = .data$.trio_order,
      y = .data$value,
      colour = .data$stat,
      fill = .data$.signal
    )
  }
  mapping <- mapping %||% ggplot2::aes(x = stats::reorder(.data$trio, .data$value), y = .data$value, colour = .data$stat)
  point_args <- c(list(size = point_size, alpha = point_alpha, shape = 21, stroke = 0.35, na.rm = na.rm, show.legend = show.legend, inherit.aes = inherit.aes), dots)
  fixed_point_args <- c(list(size = point_size, alpha = point_alpha, na.rm = na.rm, show.legend = FALSE, inherit.aes = inherit.aes), dots)

  pieces <- list()
  if (nrow(point_data) > 0) {
    se_data <- .introgression_trio_se_data(point_data)
    stem_layer <- NULL
    se_layer <- NULL
    if (default_mapping) {
      stem_layer <- ggplot2::geom_segment(
        mapping = ggplot2::aes(
          x = .data$.trio_order,
          xend = .data$.trio_order,
          y = 0,
          yend = .data$value,
          colour = .data$stat
        ),
        data = point_data,
        linewidth = 0.35,
        alpha = 0.65,
        na.rm = na.rm,
        show.legend = FALSE,
        inherit.aes = FALSE
      )
    }
    if (default_mapping && nrow(se_data) > 0) {
      se_layer <- ggplot2::geom_errorbar(
        mapping = ggplot2::aes(
          x = .data$.trio_order,
          ymin = .data$ymin,
          ymax = .data$ymax,
          colour = .data$stat
        ),
        data = se_data,
        width = 0.25,
        linewidth = 0.35,
        alpha = point_alpha,
        na.rm = na.rm,
        show.legend = FALSE,
        inherit.aes = FALSE
      )
    }
    pieces <- c(
      pieces,
      list(
        stem_layer,
        se_layer,
        do.call(ggplot2::geom_point, c(list(mapping = mapping, data = point_data), point_args)),
        scale_colour_ggpop(max(length(unique(point_data$stat)), 1), palette, guide = "none"),
        if (default_mapping) ggplot2::scale_fill_manual(values = c(Significant = "#1F2933", Nominal = "#FFFFFF"), guide = "none"),
        ggplot2::labs(colour = "stat")
      )
    )
  }
  if (nrow(fixed_data) > 0) {
    fixed_mapping <- ggplot2::aes(x = stats::reorder(.data$trio, .data$value), y = .data$value)
    pieces <- c(
      pieces,
      list(
        do.call(
          ggplot2::geom_boxplot,
          list(
            mapping = fixed_mapping,
            data = fixed_data,
            fill = "cyan4",
            colour = "grey25",
            outlier.shape = NA,
            linewidth = 0.35,
            na.rm = na.rm,
            show.legend = FALSE,
            inherit.aes = FALSE
          )
        ),
        do.call(
          ggplot2::geom_point,
          c(list(mapping = fixed_mapping, data = fixed_data, colour = "cyan4"), fixed_point_args)
        )
      )
    )
  }

  pieces <- c(
    pieces,
    list(
      ggplot2::geom_hline(yintercept = 0, linewidth = 0.3, colour = "grey70", inherit.aes = FALSE),
      ggplot2::coord_flip(),
      if (default_mapping) ggplot2::scale_x_discrete(
        labels = function(x) .introgression_pretty_label(x, width = 52)
      ) else NULL,
      ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.06, 0.08))),
      if (.introgression_trio_needs_facet(data, fixed_data, point_data)) .introgression_facet(data) else NULL,
      ggplot2::labs(
        x = "Trio",
        y = if (nrow(fixed_data) > 0 && nrow(point_data) == 0) "Fixed-difference proportion" else "Introgression statistic",
        colour = "stat"
      ),
      .introgression_publication_theme(base_size = base_size, base_family = base_family) +
        ggplot2::theme(
          legend.position = "none",
          panel.spacing = grid::unit(0.16, "cm"),
          strip.placement = "outside",
          axis.text.y = ggplot2::element_text(size = base_size * 0.66, lineheight = 0.92),
          axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 7)),
          axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 7)),
          plot.margin = ggplot2::margin(6, 10, 6, 10)
        )
    )
  )
  Filter(Negate(is.null), pieces)
}

.introgression_trio_needs_facet <- function(data, fixed_data, point_data) {
  (nrow(fixed_data) > 0 && nrow(point_data) > 0) || length(unique(data$stat)) > 1
}

.introgression_trio_se_data <- function(data) {
  if (!"se" %in% names(data)) {
    return(data[FALSE, , drop = FALSE])
  }
  out <- data
  out$se <- suppressWarnings(as.numeric(out$se))
  out$value <- suppressWarnings(as.numeric(out$value))
  out <- out[is.finite(out$se) & is.finite(out$value), , drop = FALSE]
  if (nrow(out) == 0) {
    return(out)
  }
  out$ymin <- out$value - out$se
  out$ymax <- out$value + out$se
  out
}

.introgression_trio_plot_data <- function(data) {
  if (nrow(data) == 0) {
    return(data)
  }
  data$value <- suppressWarnings(as.numeric(data$value))
  data$.signal <- .introgression_signal_label(data)
  data$.trio_order <- stats::reorder(data$trio, data$value)
  data
}

.introgression_signal_label <- function(data) {
  p <- rep(NA_real_, nrow(data))
  z <- rep(NA_real_, nrow(data))
  if ("p_value" %in% names(data)) {
    p <- suppressWarnings(as.numeric(data$p_value))
  }
  if ("p" %in% names(data)) {
    p <- suppressWarnings(as.numeric(data$p))
  }
  if ("z_score" %in% names(data)) {
    z <- suppressWarnings(as.numeric(data$z_score))
  }
  if ("z" %in% names(data)) {
    z <- suppressWarnings(as.numeric(data$z))
  }
  signal <- (!is.na(p) & p < 0.05) | (!is.na(z) & abs(z) >= 3)
  factor(ifelse(signal, "Significant", "Nominal"), levels = c("Significant", "Nominal"))
}
