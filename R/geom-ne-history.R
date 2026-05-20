geom_ne_history <- function(mapping = ggplot2::aes(x = .data$time, y = .data$ne),
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
