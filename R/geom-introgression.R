geom_introgression <- function(mapping = NULL, data = NULL, ..., stat = "all",
                               analysis = c("auto", "window", "trio", "graph"),
                               chr = NULL, start = NULL, end = NULL,
                               style = c("auto", "window", "manhattan", "region", "trio", "graph"),
                               colour_by = c("stat", "chr"),
                               point_size = NULL, point_alpha = 0.9,
                               base_size = 11, base_family = "",
                               palette = "publication", na.rm = FALSE,
                               show.legend = NA, inherit.aes = TRUE) {
  analysis <- match.arg(analysis)
  style <- match.arg(style)
  colour_by <- match.arg(colour_by)
  structure(
    list(
      mapping = mapping,
      data = data,
      dots = list(...),
      stat = stat,
      analysis = analysis,
      chr = chr,
      start = start,
      end = end,
      style = style,
      colour_by = colour_by,
      point_size = point_size,
      point_alpha = point_alpha,
      base_size = base_size,
      base_family = base_family,
      palette = palette,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    class = c("ggpop_introgression_layers", "list")
  )
}

ggplot_add.ggpop_introgression_layers <- function(object, plot, object_name) {
  data <- object$data %||% plot$data
  args <- object
  args$data <- data
  layers <- do.call(.introgression_build_layers, args)
  for (layer in layers) {
    plot <- plot + layer
  }
  plot
}

plot_introgression <- function(data, stat = "all",
                               analysis = c("auto", "window", "trio", "graph"),
                               chr = NULL, start = NULL, end = NULL,
                               style = c("auto", "window", "manhattan", "region", "trio", "graph"),
                               title = NULL, subtitle = NULL, caption = NULL,
                               base_size = 11, base_family = "",
                               palette = "publication", point_size = NULL,
                               point_alpha = 0.9, ...) {
  .require_class(data, "ggpop_introgression", "Introgression data")
  analysis <- match.arg(analysis)
  style <- match.arg(style)
  selected <- .filter_introgression_data(data, stat = stat, analysis = analysis, chr = chr, start = start, end = end)
  resolved_style <- .introgression_resolve_style(selected, style, chr = chr, start = start, end = end)
  plot <- ggpop(selected) +
    geom_introgression(
      data = selected,
      stat = "all",
      analysis = analysis,
      chr = NULL,
      start = NULL,
      end = NULL,
      style = resolved_style,
      base_size = base_size,
      base_family = base_family,
      palette = palette,
      point_size = point_size,
      point_alpha = point_alpha,
      ...
    )
  labels <- .introgression_labels(selected, style = resolved_style, chr = chr, start = start, end = end)
  .ggpop_apply_labels(plot, title, subtitle, caption, labels$x, labels$y)
}

.introgression_build_layers <- function(mapping, data, dots, stat, analysis, chr, start, end,
                                        style, colour_by, point_size, point_alpha,
                                        base_size, base_family, palette, na.rm,
                                        show.legend, inherit.aes) {
  selected <- .filter_introgression_data(data, stat = stat, analysis = analysis, chr = chr, start = start, end = end)
  style <- .introgression_resolve_style(selected, style, chr = chr, start = start, end = end)
  switch(
    style,
    window = .introgression_window_layers(selected, dots, point_size %||% 1.5, point_alpha, base_size, base_family, palette, na.rm, show.legend),
    manhattan = .introgression_window_layers(selected, dots, point_size %||% 1.5, point_alpha, base_size, base_family, palette, na.rm, show.legend),
    region = .introgression_region_layers(selected, mapping, dots, colour_by, point_size %||% 0.8, point_alpha, base_size, base_family, palette, na.rm, show.legend, inherit.aes),
    trio = .introgression_trio_layers(selected, mapping, dots, point_size %||% 2, point_alpha, base_size, base_family, palette, na.rm, show.legend, inherit.aes),
    graph = .introgression_graph_layers(selected, dots, base_size, base_family, palette, na.rm, show.legend)
  )
}

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

.introgression_graph_layers <- function(data, dots, base_size, base_family, palette, na.rm, show.legend) {
  layout <- .introgression_graph_layout(data)
  edge_args <- c(list(linewidth = 0.6, alpha = 0.85, na.rm = na.rm, show.legend = show.legend), dots)
  list(
    do.call(
      ggplot2::geom_segment,
      c(list(
        mapping = ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend, colour = .data$stat),
        data = layout$edges,
        inherit.aes = FALSE
      ), edge_args)
    ),
    ggplot2::geom_point(
      mapping = ggplot2::aes(x = .data$x, y = .data$y),
      data = layout$nodes,
      size = 2.4,
      inherit.aes = FALSE
    ),
    ggplot2::geom_text(
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$node),
      data = layout$nodes,
      nudge_y = 0.12,
      size = base_size / 4,
      inherit.aes = FALSE
    ),
    scale_colour_ggpop(max(length(unique(layout$edges$stat)), 1), palette, guide = "none"),
    ggplot2::labs(x = NULL, y = NULL, colour = "stat"),
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        axis.text = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.line = ggplot2::element_blank(),
        legend.position = "none"
      )
  )
}

.filter_introgression_data <- function(data, stat = "all", analysis = "auto", chr = NULL, start = NULL, end = NULL) {
  .require_class(data, "ggpop_introgression", "Introgression data")
  out <- data
  if (!identical(analysis, "auto")) {
    out <- out[out$analysis %in% analysis, , drop = FALSE]
  }
  if (!identical(stat, "all")) {
    out <- out[out$stat %in% stat, , drop = FALSE]
  }
  if (!is.null(chr) && "chr" %in% names(out)) {
    out <- out[out$chr %in% chr, , drop = FALSE]
  }
  if (!is.null(start) && "end" %in% names(out)) {
    out <- out[out$end >= start, , drop = FALSE]
  }
  if (!is.null(end) && "start" %in% names(out)) {
    out <- out[out$start <= end, , drop = FALSE]
  }
  if (nrow(out) == 0) {
    stop("No introgression rows remain after filtering.", call. = FALSE)
  }
  out
}

.introgression_resolve_style <- function(data, style, chr = NULL, start = NULL, end = NULL) {
  if (style != "auto") {
    return(style)
  }
  analyses <- unique(data$analysis)
  if ("graph" %in% analyses) return("graph")
  if ("trio" %in% analyses) return("trio")
  if (is.null(chr) && is.null(start) && is.null(end)) "window" else "region"
}

.introgression_facet <- function(data) {
  ggplot2::facet_grid(stat ~ ., scales = "free_y", switch = "x")
}

.introgression_order_window_data <- function(data) {
  if (all(c("chr", "pos") %in% names(data))) {
    data[order(factor(data$chr, levels = .gwas_chr_levels(data$chr)), data$pos), , drop = FALSE]
  } else {
    data
  }
}

.introgression_graph_layout <- function(data) {
  edges <- data[!is.na(data$from) & !is.na(data$to), , drop = FALSE]
  nodes <- unique(c(as.character(edges$from), as.character(edges$to)))
  node_data <- data.frame(node = nodes, x = 0, y = seq_along(nodes), stringsAsFactors = FALSE)
  roots <- setdiff(as.character(edges$from), as.character(edges$to))
  node_data$x[node_data$node %in% roots] <- 0
  for (i in seq_len(length(nodes) + 1)) {
    for (row in seq_len(nrow(edges))) {
      from_x <- node_data$x[match(edges$from[row], node_data$node)]
      to_idx <- match(edges$to[row], node_data$node)
      node_data$x[to_idx] <- max(node_data$x[to_idx], from_x + 1, na.rm = TRUE)
    }
  }
  node_data$y <- ave(node_data$y, node_data$x, FUN = seq_along)
  edges$x <- node_data$x[match(edges$from, node_data$node)]
  edges$y <- node_data$y[match(edges$from, node_data$node)]
  edges$xend <- node_data$x[match(edges$to, node_data$node)]
  edges$yend <- node_data$y[match(edges$to, node_data$node)]
  list(nodes = node_data, edges = edges)
}

.introgression_labels <- function(data, style, chr = NULL, start = NULL, end = NULL) {
  style <- .introgression_resolve_style(data, style, chr = chr, start = start, end = end)
  switch(
    style,
    window = list(x = "Chromosome", y = "Introgression statistic"),
    manhattan = list(x = "Chromosome", y = "Introgression statistic"),
    region = list(x = "Position (Mb)", y = "Introgression statistic"),
    trio = list(x = "Trio", y = "Introgression statistic"),
    graph = list(x = NULL, y = NULL)
  )
}
