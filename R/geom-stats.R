geom_stats <- function(mapping = ggplot2::aes(x = .data$pos / 1e6, y = .data$value),
                       data = NULL, ..., stat = "all", chr = NULL,
                       start = NULL, end = NULL, geom = c("line", "point"),
                       colour_by = c("stat", "chr"),
                       size = NULL, alpha = NULL, base_size = 11,
                       base_family = "", palette = "publication",
                       na.rm = FALSE, show.legend = NA,
                       inherit.aes = TRUE) {
  geom <- match.arg(geom)
  colour_by <- match.arg(colour_by)
  layer_data <- .filter_stats_data(data, stat = stat, chr = chr, start = start, end = end)
  if (.stats_should_map_colour(layer_data, mapping)) {
    mapping <- .add_stats_colour_mapping(mapping, colour_by)
  }
  if (is.null(mapping$group)) {
    mapping <- .add_stats_group_mapping(mapping)
  }
  colour_count <- .stats_colour_count(layer_data, colour_by)
  layers <- list(
    .geom_stats_layer(
      mapping = mapping,
      data = layer_data,
      geom = geom,
      ...,
      size = size %||% .stats_default_size(geom, base_size),
      alpha = alpha %||% if (geom == "line") NA else 0.5,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    if (colour_count > 0) scale_colour_ggpop(colour_count, palette, guide = "none"),
    ggplot2::scale_x_continuous(expand = c(0, 0)),
    ggplot2::scale_y_continuous(expand = c(0, 0)),
    ggplot2::labs(x = "Position (Mb)", y = "Statistic value", colour = colour_by),
    .stats_facet(layer_data),
    .theme_tidyplot(fontsize = base_size, base_family = base_family) +
      ggplot2::theme(
        panel.spacing = grid::unit(0.1, "cm"),
        strip.background = ggplot2::element_blank(),
        legend.position = "none"
      )
  )
  Filter(Negate(is.null), layers)
}

.stats_default_size <- function(geom, base_size = 11) {
  if (geom == "line") {
    return(base_size / 44)
  }
  base_size / 22
}

plot_stats <- function(data, stat = "all", chr = NULL, start = NULL, end = NULL,
                       geom = NULL, title = NULL, subtitle = NULL,
                       caption = NULL, base_size = 11, base_family = "",
                       palette = "publication", ...) {
  .require_class(data, "ggpop_stats", "Population genomics statistics data")
  selected <- .filter_stats_data(data, stat = stat, chr = chr, start = start, end = end)
  plot_geom <- geom %||% if (length(unique(selected$chr)) == 1) "line" else "point"
  plot <- ggpop(selected) +
    geom_stats(
      data = selected,
      stat = "all",
      geom = plot_geom,
      base_size = base_size,
      base_family = base_family,
      palette = palette,
      ...
    )
  .ggpop_apply_labels(plot, title, subtitle, caption, NULL, NULL)
}

.geom_stats_layer <- function(mapping, data = NULL, geom = "line", ..., size, alpha,
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

.filter_stats_data <- function(data, stat = "all", chr = NULL, start = NULL, end = NULL) {
  if (is.null(data)) {
    force(stat)
    force(chr)
    force(start)
    force(end)
    return(function(plot_data) .filter_stats_data(plot_data, stat = stat, chr = chr, start = start, end = end))
  }
  .require_class(data, "ggpop_stats", "Population genomics statistics data")
  out <- data
  if (!identical(stat, "all")) {
    out <- out[out$stat %in% .normalize_stats(stat), , drop = FALSE]
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
    stop("No statistics rows remain after filtering.", call. = FALSE)
  }
  out
}

.normalize_stats <- function(stat) {
  aliases <- c(
    fst = "fst",
    pi = "pi",
    tajima = "tajima_d",
    tajima_d = "tajima_d",
    dxy = "dxy",
    watterson = "watterson_theta",
    theta = "watterson_theta",
    watterson_theta = "watterson_theta"
  )
  lowered <- tolower(stat)
  out <- unname(aliases[lowered])
  out[is.na(out)] <- lowered[is.na(out)]
  out
}

.stats_should_map_colour <- function(data, mapping) {
  is.null(mapping$colour) && is.null(mapping$color)
}

.add_stats_colour_mapping <- function(mapping, colour_by) {
  values <- as.list(mapping)
  values$colour <- rlang::expr(.data[[colour_by]])
  do.call(ggplot2::aes, values)
}

.add_stats_group_mapping <- function(mapping) {
  values <- as.list(mapping)
  values$group <- rlang::expr(.data[[".group"]])
  do.call(ggplot2::aes, values)
}

.stats_colour_count <- function(data, colour_by) {
  if (is.function(data)) {
    return(8)
  }
  if (is.null(data) || !colour_by %in% names(data)) {
    return(0)
  }
  max(length(unique(data[[colour_by]])), 1)
}

.stats_facet <- function(data) {
  if (is.null(data) || is.function(data) || length(unique(data$chr)) == 1) {
    return(ggplot2::facet_grid(stat ~ ., scales = "free_y", switch = "x"))
  }
  ggplot2::facet_grid(stat ~ ., scales = "free_y", switch = "x")
}
