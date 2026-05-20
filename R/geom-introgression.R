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
