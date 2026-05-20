geom_ne_history <- function(mapping = ggplot2::aes(x = .data$time, y = .data$ne, colour = .data$sample_id),
                            data = NULL, ..., sample_id = NULL, method = NULL,
                            style = c("auto", "step", "line", "point"), ci = TRUE,
                            colour_by = c("sample_id", "method"),
                            size = NULL, alpha = NULL, base_size = 11,
                            base_family = "", palette = "population",
                            log_x = TRUE, log_y = TRUE,
                            na.rm = FALSE, show.legend = NA,
                            inherit.aes = TRUE) {
  style <- match.arg(style)
  colour_by <- match.arg(colour_by)
  layer_data <- .filter_ne_history_data(data, sample_id = sample_id, method = method)
  style <- .ne_history_resolve_style(layer_data, style)
  if (.ne_history_should_map_colour(layer_data, mapping, colour_by)) {
    mapping <- .add_ne_history_colour_mapping(mapping, colour_by)
  }
  if (is.null(mapping$group)) {
    mapping <- .add_ne_history_group_mapping(mapping)
  }
  colour_count <- .ne_history_colour_count(layer_data, colour_by)
  layers <- list(
    .ne_history_ci_layers(layer_data, colour_by, palette, ci),
    .geom_ne_history_layer(
      mapping = mapping,
      data = layer_data,
      style = style,
      ...,
      size = size %||% .ne_history_default_size(style, base_size),
      alpha = alpha %||% if (style == "line") NA else 0.9,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    .ne_history_plot_data_layer(layer_data),
    if (colour_count > 0) scale_colour_ggpop(colour_count, palette),
    if (isTRUE(log_x)) ggplot2::scale_x_log10(),
    if (isTRUE(log_y)) ggplot2::scale_y_log10(),
    ggplot2::labs(x = .ne_history_x_label(layer_data), y = "Effective population size", colour = NULL),
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        legend.position = "top",
        legend.title = ggplot2::element_blank()
      )
  )
  structure(
    Filter(Negate(is.null), layers),
    class = c("ggpop_ne_history_layers", "list"),
    ggpop_ne_history_data = layer_data,
    ggpop_ne_history_filter = list(sample_id = sample_id, method = method)
  )
}

ggplot_add.ggpop_ne_history_layers <- function(object, plot, object_name) {
  layer_data <- attr(object, "ggpop_ne_history_data", exact = TRUE)
  filter <- attr(object, "ggpop_ne_history_filter", exact = TRUE)
  if (inherits(plot$data, "ggpop_ne_history")) {
    plot$data <- if (is.function(layer_data)) {
      .filter_ne_history_data(plot$data, sample_id = filter$sample_id, method = filter$method)
    } else {
      layer_data
    }
  }
  for (layer in unclass(object)) {
    plot <- plot + layer
  }
  plot
}

plot_ne_history <- function(data, sample_id = NULL, method = NULL,
                            style = c("auto", "step", "line", "point"), ci = TRUE,
                            title = NULL, subtitle = NULL, caption = NULL,
                            base_size = 11, base_family = "",
                            palette = "population", log_x = TRUE,
                            log_y = TRUE, ...) {
  .require_class(data, "ggpop_ne_history", "Ne history data")
  style <- match.arg(style)
  selected <- .filter_ne_history_data(data, sample_id = sample_id, method = method)
  plot <- ggpop(selected) +
    geom_ne_history(
      data = selected,
      sample_id = NULL,
      method = NULL,
      style = style,
      ci = ci,
      base_size = base_size,
      base_family = base_family,
      palette = palette,
      log_x = log_x,
      log_y = log_y,
      ...
    )
  .ggpop_apply_labels(plot, title, subtitle, caption, .ne_history_x_label(selected), "Effective population size")
}

.geom_ne_history_layer <- function(mapping, data = NULL, style = "line", ..., size, alpha,
                                   na.rm = FALSE, show.legend = NA, inherit.aes = TRUE) {
  layer_fun <- switch(
    style,
    point = ggplot2::geom_point,
    step = ggplot2::geom_step,
    ggplot2::geom_line
  )
  args <- list(
    mapping = mapping,
    data = data,
    ...,
    alpha = alpha,
    na.rm = na.rm,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
  if (style == "point") {
    args$size <- size
  } else {
    args$linewidth <- size
  }
  do.call(layer_fun, args)
}

.filter_ne_history_data <- function(data, sample_id = NULL, method = NULL) {
  if (is.null(data)) {
    force(sample_id)
    force(method)
    return(function(plot_data) .filter_ne_history_data(plot_data, sample_id = sample_id, method = method))
  }
  .require_class(data, "ggpop_ne_history", "Ne history data")
  out <- data
  if (!is.null(sample_id)) out <- out[out$sample_id %in% sample_id, , drop = FALSE]
  if (!is.null(method)) out <- out[out$method %in% method, , drop = FALSE]
  out <- out[is.finite(out$time) & is.finite(out$ne) & out$time > 0 & out$ne > 0, , drop = FALSE]
  if (nrow(out) == 0) {
    stop("No Ne history rows remain after filtering.", call. = FALSE)
  }
  out[order(out$sample_id, out$method, out$time), , drop = FALSE]
}

.ne_history_ci_layers <- function(data, colour_by, palette, ci) {
  if (!isTRUE(ci) || is.function(data) || !all(c("ne_lower", "ne_upper") %in% names(data))) {
    return(NULL)
  }
  ci_data <- data[is.finite(data$ne_lower) & is.finite(data$ne_upper) & data$ne_lower > 0 & data$ne_upper > 0, , drop = FALSE]
  if (nrow(ci_data) == 0) return(NULL)
  fill_values <- ggpop_palette(max(length(unique(ci_data[[colour_by]])), 1), palette)
  list(
    ggplot2::geom_ribbon(
      mapping = ggplot2::aes(x = .data$time, ymin = .data$ne_lower, ymax = .data$ne_upper, fill = .data[[colour_by]], group = .data$.group),
      data = ci_data,
      alpha = 0.18,
      colour = NA,
      inherit.aes = FALSE,
      show.legend = FALSE
    ),
    ggplot2::scale_fill_manual(values = fill_values, guide = "none")
  )
}

.ne_history_plot_data_layer <- function(data) {
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

.ne_history_should_map_colour <- function(data, mapping, colour_by) {
  is.null(mapping$colour) && is.null(mapping$color) &&
    (is.function(data) || (!is.null(data) && colour_by %in% names(data)))
}

.add_ne_history_colour_mapping <- function(mapping, colour_by) {
  values <- as.list(mapping)
  values$colour <- rlang::expr(.data[[colour_by]])
  do.call(ggplot2::aes, values)
}

.add_ne_history_group_mapping <- function(mapping) {
  values <- as.list(mapping)
  values$group <- rlang::expr(.data[[".group"]])
  do.call(ggplot2::aes, values)
}

.ne_history_colour_count <- function(data, colour_by) {
  if (is.function(data)) return(8)
  if (is.null(data) || !colour_by %in% names(data)) return(0)
  max(length(unique(data[[colour_by]])), 1)
}

.ne_history_default_size <- function(style, base_size = 11) {
  if (style %in% c("line", "step")) return(base_size / 22)
  1
}

.ne_history_resolve_style <- function(data, style) {
  if (style != "auto") {
    return(style)
  }
  if (is.function(data)) {
    return("step")
  }
  methods <- unique(data$method)
  if (length(methods) == 1 && identical(methods, "SMC++")) {
    return("line")
  }
  "step"
}

.ne_history_x_label <- function(data) {
  if (is.function(data)) {
    return("Time before present (generations)")
  }
  unit <- unique(data$time_unit)[1]
  if (identical(unit, "years")) return("Time before present (years)")
  if (identical(unit, "scaled")) return("Scaled time")
  "Time before present (generations)"
}
