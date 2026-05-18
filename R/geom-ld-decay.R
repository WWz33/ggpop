geom_ld_decay <- function(mapping = ggplot2::aes(x = .data$dist_kb, y = .data$r2),
                          data = NULL, ..., pop = NULL,
                          style = c("point", "line"),
                          colour_by = c("pop", "file"),
                          size = NULL, alpha = NULL,
                          base_size = 11, base_family = "",
                          palette = "population",
                          na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE) {
  style <- match.arg(style)
  colour_by <- match.arg(colour_by)
  layer_data <- .filter_ld_decay_data(data, pop = pop)
  if (.ld_decay_should_map_colour(layer_data, mapping, colour_by)) {
    mapping <- .add_ld_decay_colour_mapping(mapping, colour_by)
  }
  if (is.null(mapping$group)) {
    mapping <- .add_ld_decay_group_mapping(mapping)
  }
  colour_count <- .ld_decay_colour_count(layer_data, colour_by)
  layers <- list(
    .geom_ld_decay_layer(
      mapping = mapping,
      data = layer_data,
      style = style,
      ...,
      size = size %||% .ld_decay_default_size(style, base_size),
      alpha = alpha %||% if (style == "line") NA else 0.9,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    .ld_decay_plot_data_layer(layer_data),
    if (colour_count > 0) scale_colour_ggpop(colour_count, palette),
    ggplot2::scale_x_continuous(expand = c(0, 0)),
    ggplot2::scale_y_continuous(expand = c(0, 0), limits = c(0, NA)),
    ggplot2::labs(x = "Pairwise distance in Kb", y = .ld_decay_y_label(), colour = NULL),
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        legend.position = "top",
        legend.title = ggplot2::element_blank()
      )
  )
  structure(
    Filter(Negate(is.null), layers),
    class = c("ggpop_ld_decay_layers", "list"),
    ggpop_ld_decay_data = layer_data,
    ggpop_ld_decay_filter = list(pop = pop)
  )
}

.ld_decay_plot_data_layer <- function(data) {
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

ggplot_add.ggpop_ld_decay_layers <- function(object, plot, object_name) {
  layer_data <- attr(object, "ggpop_ld_decay_data", exact = TRUE)
  filter <- attr(object, "ggpop_ld_decay_filter", exact = TRUE)
  if (inherits(plot$data, "ggpop_ld_decay")) {
    plot$data <- if (is.function(layer_data)) {
      .filter_ld_decay_data(plot$data, pop = filter$pop)
    } else {
      layer_data
    }
  }
  for (layer in unclass(object)) {
    plot <- plot + layer
  }
  plot
}

plot_ld_decay <- function(data, pop = NULL, style = c("point", "line"),
                          title = NULL, subtitle = NULL, caption = NULL,
                          base_size = 11, base_family = "",
                          palette = "population", ...) {
  .require_class(data, "ggpop_ld_decay", "LD decay data")
  style <- match.arg(style)
  selected <- .filter_ld_decay_data(data, pop = pop)
  plot <- ggpop(selected) +
    geom_ld_decay(
      data = selected,
      pop = NULL,
      style = style,
      base_size = base_size,
      base_family = base_family,
      palette = palette,
      ...
    )
  .ggpop_apply_labels(plot, title, subtitle, caption, "Pairwise distance in Kb", .ld_decay_y_label())
}

.geom_ld_decay_layer <- function(mapping, data = NULL, style = "point", ..., size, alpha,
                                 na.rm = FALSE, show.legend = NA, inherit.aes = TRUE) {
  layer_fun <- if (style == "line") ggplot2::geom_line else ggplot2::geom_point
  args <- list(
    mapping = mapping,
    data = data,
    ...,
    alpha = alpha,
    na.rm = na.rm,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
  if (style == "line") {
    args$linewidth <- size
  } else {
    args$size <- size
  }
  do.call(layer_fun, args)
}

.filter_ld_decay_data <- function(data, pop = NULL) {
  if (is.null(data)) {
    force(pop)
    return(function(plot_data) .filter_ld_decay_data(plot_data, pop = pop))
  }
  .require_class(data, "ggpop_ld_decay", "LD decay data")
  out <- data
  if (!is.null(pop)) {
    out <- out[out$pop %in% pop, , drop = FALSE]
  }
  if (nrow(out) == 0) {
    stop("No LD decay rows remain after filtering.", call. = FALSE)
  }
  out
}

.ld_decay_should_map_colour <- function(data, mapping, colour_by) {
  is.null(mapping$colour) && is.null(mapping$color) &&
    (is.function(data) || (!is.null(data) && colour_by %in% names(data)))
}

.add_ld_decay_colour_mapping <- function(mapping, colour_by) {
  values <- as.list(mapping)
  values$colour <- rlang::expr(.data[[colour_by]])
  do.call(ggplot2::aes, values)
}

.add_ld_decay_group_mapping <- function(mapping) {
  values <- as.list(mapping)
  values$group <- rlang::expr(.data[[".group"]])
  do.call(ggplot2::aes, values)
}

.ld_decay_colour_count <- function(data, colour_by) {
  if (is.function(data)) {
    return(8)
  }
  if (is.null(data) || !colour_by %in% names(data)) {
    return(0)
  }
  max(length(unique(data[[colour_by]])), 1)
}

.ld_decay_default_size <- function(style, base_size = 11) {
  if (style == "line") {
    return(base_size / 22)
  }
  1
}

.ld_decay_y_label <- function() {
  quote(LD~(r^2))
}
