geom_selection <- function(mapping = ggplot2::aes(x = .data$pos / 1e6, y = .data$value),
                           data = NULL, ..., stat = "all", chr = NULL,
                           start = NULL, end = NULL, geom = c("point", "line"),
                           colour_by = c("stat", "chr"),
                           value = c("signed", "absolute"),
                           threshold = NULL, threshold_type = c("value", "quantile"),
                           threshold_color = ggpop_palette(4, "publication")[4],
                           threshold_linetype = "dashed",
                           size = NULL, alpha = NULL, base_size = 11,
                           base_family = "", palette = "publication",
                           na.rm = FALSE, show.legend = NA,
                           inherit.aes = TRUE) {
  geom <- match.arg(geom)
  colour_by <- match.arg(colour_by)
  value <- match.arg(value)
  threshold_type <- match.arg(threshold_type)
  layer_data <- .filter_selection_data(data, stat = stat, chr = chr, start = start, end = end, value = value)
  if (.selection_should_map_colour(layer_data, mapping)) {
    mapping <- .add_selection_colour_mapping(mapping, colour_by)
  }
  if (is.null(mapping$group)) {
    mapping <- .add_selection_group_mapping(mapping)
  }
  colour_count <- .selection_colour_count(layer_data, colour_by)
  layers <- list(
    .geom_selection_layer(
      mapping = mapping,
      data = layer_data,
      geom = geom,
      ...,
      size = size %||% .selection_default_size(geom, base_size),
      alpha = alpha %||% if (geom == "line") NA else 0.9,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    .selection_plot_data_layer(layer_data),
    .selection_threshold_layers(threshold, threshold_type, layer_data, threshold_color, threshold_linetype, value = value),
    if (colour_count > 0) scale_colour_ggpop(colour_count, palette, guide = "none"),
    ggplot2::scale_x_continuous(expand = c(0, 0)),
    ggplot2::labs(x = "Position (Mb)", y = .selection_y_label(value), colour = colour_by),
    .selection_facet(layer_data),
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        panel.spacing = grid::unit(0.1, "cm"),
        strip.background = ggplot2::element_blank(),
        legend.position = "none"
      )
  )
  structure(
    Filter(Negate(is.null), layers),
    class = c("ggpop_selection_layers", "list"),
    ggpop_selection_data = layer_data,
    ggpop_selection_filter = list(stat = stat, chr = chr, start = start, end = end, value = value)
  )
}

.selection_plot_data_layer <- function(data) {
  ggplot2::layer(
    data = data,
    mapping = ggplot2::aes(),
    stat = "identity",
    geom = "blank",
    position = "identity",
    inherit.aes = FALSE,
    show.legend = FALSE
  )
}

ggplot_add.ggpop_selection_layers <- function(object, plot, object_name) {
  layer_data <- attr(object, "ggpop_selection_data", exact = TRUE)
  filter <- attr(object, "ggpop_selection_filter", exact = TRUE)
  if (inherits(plot$data, "ggpop_selection")) {
    plot$data <- if (is.function(layer_data)) {
      .filter_selection_data(
        plot$data,
        stat = filter$stat,
        chr = filter$chr,
        start = filter$start,
        end = filter$end,
        value = filter$value
      )
    } else {
      layer_data
    }
  }
  for (layer in unclass(object)) {
    plot <- plot + layer
  }
  plot
}

plot_selection <- function(data, stat = "all", chr = NULL, start = NULL, end = NULL,
                           geom = "point", title = NULL, subtitle = NULL,
                           caption = NULL, base_size = 11, base_family = "",
                           palette = "publication", value = c("signed", "absolute"),
                           threshold = NULL, threshold_type = c("value", "quantile"),
                           style = c("auto", "single", "manhattan"), binary = FALSE,
                           threshold_color = ggpop_palette(4, "publication")[4],
                           threshold_linetype = "dashed", point_size = NULL,
                           point_alpha = NULL, ...) {
  .require_class(data, "ggpop_selection", "Selective sweep scan data")
  palette_missing <- missing(palette)
  value <- match.arg(value)
  threshold_type <- match.arg(threshold_type)
  style <- match.arg(style)
  selected <- .filter_selection_data(data, stat = stat, chr = chr, start = start, end = end, value = value)
  if (style == "auto") {
    style <- if (is.null(chr) && is.null(start) && is.null(end)) "manhattan" else "single"
  }
  if (style == "manhattan") {
    dots <- list(...)
    return(.plot_selection_manhattan(
      selected,
      title = title,
      subtitle = subtitle,
      caption = caption,
      base_size = base_size,
      base_family = base_family,
      palette = if (palette_missing) "manhattan" else palette,
      binary = binary,
      value = value,
      threshold = threshold,
      threshold_type = threshold_type,
      threshold_color = threshold_color,
      threshold_linetype = threshold_linetype,
      point_size = point_size %||% 1.5,
      point_alpha = point_alpha %||% 0.9,
      dots = dots
    ))
  }
  geom_args <- list(
    data = selected,
    stat = "all",
    geom = geom,
    value = value,
    base_size = base_size,
    base_family = base_family,
    palette = palette,
    threshold = threshold,
    threshold_type = threshold_type,
    threshold_color = threshold_color,
    threshold_linetype = threshold_linetype
  )
  dots <- list(...)
  if (!is.null(point_size)) {
    dots$size <- point_size
  }
  if (!is.null(point_alpha)) {
    dots$alpha <- point_alpha
  }
  plot <- ggpop(selected) +
    do.call(geom_selection, c(geom_args, dots))
  .ggpop_apply_labels(plot, title, subtitle, caption, "Position (Mb)", .selection_y_label(value))
}

.plot_selection_manhattan <- function(selected, title = NULL, subtitle = NULL, caption = NULL,
                                      base_size = 11, base_family = "",
                                      palette = "manhattan", binary = FALSE,
                                      value = c("signed", "absolute"),
                                      threshold = NULL, threshold_type = c("value", "quantile"),
                                      threshold_color = ggpop_palette(4, "publication")[4],
                                      threshold_linetype = "dashed",
                                      point_size = 1.5, point_alpha = 0.9, dots = list()) {
  value <- match.arg(value)
  layout <- .selection_genome_layout(selected)
  colour_count <- max(length(layout$labels %||% unique(layout$data$chr)), 2)
  point_args <- dots
  if (is.null(point_args$size)) {
    point_args$size <- point_size
  }
  if (is.null(point_args$alpha)) {
    point_args$alpha <- point_alpha
  }
  plot <- ggplot2::ggplot(
    layout$data,
    ggplot2::aes(x = .data$genome_pos, y = .data$value, colour = .data$chr_group, group = .data$.group)
  ) +
    do.call(ggplot2::geom_point, point_args) +
    .selection_threshold_layers(threshold, threshold_type, selected, threshold_color, threshold_linetype, value = value) +
    ggplot2::scale_x_continuous(
      limits = layout$limits,
      breaks = layout$breaks,
      labels = layout$labels,
      expand = c(0, 0),
      guide = ggplot2::guide_axis(check.overlap = TRUE)
    ) +
    ggplot2::labs(x = layout$x_label, y = .selection_y_label(value), colour = "chr") +
    .selection_facet(layout$data) +
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.spacing = grid::unit(0.1, "cm"),
      strip.background = ggplot2::element_blank(),
      legend.position = "none"
    )
  plot <- if (isTRUE(binary)) {
    plot + .gwas_binary_colour_scale(colour_count, palette)
  } else {
    plot + scale_colour_ggpop(colour_count, palette, guide = "none")
  }
  .ggpop_apply_labels(plot, title, subtitle, caption, layout$x_label, .selection_y_label(value))
}

.geom_selection_layer <- function(mapping, data = NULL, geom = "point", ..., size, alpha,
                                  na.rm = FALSE, show.legend = NA, inherit.aes = TRUE) {
  layer_fun <- if (geom == "line") ggplot2::geom_line else ggplot2::geom_point
  args <- list(
    mapping = mapping,
    data = data,
    ...,
    alpha = alpha,
    na.rm = na.rm,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
  if (geom == "line") {
    args$linewidth <- size
  } else {
    args$size <- size
  }
  do.call(layer_fun, args)
}

.filter_selection_data <- function(data, stat = "all", chr = NULL, start = NULL, end = NULL,
                                   value = c("signed", "absolute")) {
  value <- match.arg(value)
  if (is.null(data)) {
    force(stat)
    force(chr)
    force(start)
    force(end)
    force(value)
    return(function(plot_data) .filter_selection_data(plot_data, stat = stat, chr = chr, start = start, end = end, value = value))
  }
  .require_class(data, "ggpop_selection", "Selective sweep scan data")
  out <- data
  if (!identical(stat, "all")) {
    out <- out[out$stat %in% .normalize_selection_stats(stat), , drop = FALSE]
  }
  if (!is.null(chr)) {
    out <- out[out$chr %in% chr, , drop = FALSE]
  }
  if (!is.null(start)) {
    out <- out[out$end >= start, , drop = FALSE]
  }
  if (!is.null(end)) {
    out <- out[out$start <= end, , drop = FALSE]
  }
  if (nrow(out) == 0) {
    stop("No selective sweep scan rows remain after filtering.", call. = FALSE)
  }
  if (value == "absolute") {
    out$value <- abs(out$value)
  }
  out
}

.normalize_selection_stats <- function(stat) {
  aliases <- c(
    ihs = "ihs",
    nsl = "nsl",
    ihh12 = "ihh12",
    xpehh = "xpehh",
    xp_ehh = "xpehh",
    xpnsl = "xpnsl",
    xp_nsl = "xpnsl",
    xpclr = "xpclr"
  )
  lowered <- tolower(stat)
  out <- unname(aliases[lowered])
  out[is.na(out)] <- lowered[is.na(out)]
  out
}

.selection_should_map_colour <- function(data, mapping) {
  is.null(mapping$colour) && is.null(mapping$color)
}

.add_selection_colour_mapping <- function(mapping, colour_by) {
  values <- as.list(mapping)
  values$colour <- rlang::expr(.data[[colour_by]])
  do.call(ggplot2::aes, values)
}

.add_selection_group_mapping <- function(mapping) {
  values <- as.list(mapping)
  values$group <- rlang::expr(.data[[".group"]])
  do.call(ggplot2::aes, values)
}

.selection_colour_count <- function(data, colour_by) {
  if (is.function(data)) {
    return(8)
  }
  if (is.null(data) || !colour_by %in% names(data)) {
    return(0)
  }
  max(length(unique(data[[colour_by]])), 1)
}

.selection_default_size <- function(geom, base_size = 11) {
  if (geom == "line") {
    return(base_size / 44)
  }
  0.75
}

.selection_facet <- function(data) {
  ggplot2::facet_grid(stat ~ ., scales = "free_y", switch = "x")
}

.selection_genome_layout <- function(data) {
  data <- data[is.finite(data$pos) & is.finite(data$value) & !is.na(data$chr), , drop = FALSE]
  if (nrow(data) == 0) {
    stop("No finite selective sweep scan rows are available for genome plotting.", call. = FALSE)
  }
  data$chr <- as.character(data$chr)
  data$bp_mb <- as.double(data$pos) / 1e6
  chr_levels <- .gwas_chr_levels(data$chr)
  num_chr <- length(chr_levels)
  if (num_chr == 1) {
    data$genome_pos <- data$bp_mb
    data$chr_group <- factor(1, levels = seq_along(chr_levels))
    x_range <- range(data$genome_pos, na.rm = TRUE)
    x_pad <- 0.015 * diff(x_range)
    if (!is.finite(x_pad) || x_pad == 0) {
      x_pad <- 0
    }
    return(list(
      data = data,
      breaks = NULL,
      labels = NULL,
      limits = x_range + c(-x_pad, x_pad),
      x_label = "Position (Mb)"
    ))
  }

  chr_meta <- data.frame(
    chr = chr_levels,
    min = NA_real_,
    max = NA_real_,
    width = NA_real_,
    medgap = NA_real_,
    base = 0,
    midp = 0,
    stringsAsFactors = FALSE
  )
  data$within_chr_pos <- data$bp_mb
  for (index in seq_along(chr_levels)) {
    idx <- data$chr == chr_levels[index]
    bp <- data$bp_mb[idx]
    chr_meta$min[index] <- min(bp, na.rm = TRUE)
    chr_meta$max[index] <- max(bp, na.rm = TRUE)
    chr_meta$width[index] <- chr_meta$max[index] - chr_meta$min[index]
    chr_meta$medgap[index] <- stats::median(diff(sort(unique(bp))), na.rm = TRUE)
    data$within_chr_pos[idx] <- bp - chr_meta$min[index]
  }
  max_gap <- max(chr_meta$medgap, na.rm = TRUE)
  if (!is.finite(max_gap)) {
    max_gap <- 0
  }
  chr_meta$midp[1] <- chr_meta$width[1] / 2
  for (index in 2:num_chr) {
    chr_meta$base[index] <- chr_meta$base[index - 1] + chr_meta$width[index - 1] + max_gap
    chr_meta$midp[index] <- chr_meta$base[index] + chr_meta$width[index] / 2
  }
  factor_x <- if (chr_meta$midp[num_chr] == 0) 1 else num_chr / chr_meta$midp[num_chr]
  data$genome_pos <- data$within_chr_pos * factor_x
  chr_meta$basef <- chr_meta$base * factor_x
  chr_meta$midpf <- chr_meta$midp * factor_x
  for (index in 2:num_chr) {
    idx <- data$chr == chr_levels[index]
    data$genome_pos[idx] <- data$genome_pos[idx] + chr_meta$basef[index]
  }
  data$chr_group <- factor(match(data$chr, chr_levels), levels = seq_along(chr_levels))
  x_pad <- 0.015 * diff(range(data$genome_pos, na.rm = TRUE))
  if (!is.finite(x_pad)) {
    x_pad <- 0
  }
  list(
    data = data,
    breaks = chr_meta$midpf,
    labels = chr_levels,
    limits = c(-x_pad, max(data$genome_pos, na.rm = TRUE) + x_pad),
    x_label = "Chromosome"
  )
}

.selection_y_label <- function(value) {
  if (value == "absolute") {
    return("|Selection score|")
  }
  "Selection score"
}

.selection_threshold_values <- function(threshold, threshold_type, data) {
  if (is.null(threshold)) {
    return(NULL)
  }
  threshold <- as.numeric(threshold)
  threshold <- threshold[is.finite(threshold)]
  if (length(threshold) == 0) {
    return(NULL)
  }
  if (threshold_type == "value") {
    return(threshold)
  }
  if (any(threshold < 0 | threshold > 1)) {
    stop("Quantile thresholds must be between 0 and 1.", call. = FALSE)
  }
  stats::quantile(abs(data$value), probs = threshold, na.rm = TRUE, names = FALSE)
}

.selection_threshold_data <- function(threshold, threshold_type, data, value) {
  threshold_values <- .selection_threshold_values(threshold, threshold_type, data)
  if (is.null(threshold_values)) {
    return(data.frame(yintercept = numeric()))
  }
  if (value == "absolute") {
    return(data.frame(yintercept = threshold_values))
  }
  data.frame(yintercept = c(threshold_values, -threshold_values))
}

.selection_threshold_layers <- function(threshold, threshold_type, data, threshold_color, threshold_linetype,
                                        value = c("signed", "absolute")) {
  value <- match.arg(value)
  if (is.null(threshold)) {
    return(NULL)
  }
  threshold_data <- if (is.function(data)) {
    function(plot_data) .selection_threshold_data(threshold, threshold_type, data(plot_data), value)
  } else {
    .selection_threshold_data(threshold, threshold_type, data, value)
  }
  ggplot2::geom_hline(
    mapping = ggplot2::aes(yintercept = .data$yintercept),
    data = threshold_data,
    linewidth = 0.4,
    linetype = threshold_linetype,
    colour = threshold_color,
    inherit.aes = FALSE
  )
}
