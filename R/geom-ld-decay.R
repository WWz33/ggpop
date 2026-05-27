geom_ld_decay <- function(mapping = ggplot2::aes(x = .data$dist_kb, y = .data$r2),
                          data = NULL, ..., pop = NULL,
                          pop_group = NULL,
                          style = c("point", "line", "fit"),
                          measure = c("r2", "D", "both"),
                          colour_by = c("pop", "file"),
                          size = NULL, alpha = NULL,
                          base_size = 11, base_family = "",
                          palette = "population",
                          na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE) {
  style <- match.arg(style)
  measure <- match.arg(measure)
  colour_by <- match.arg(colour_by)
  layer_data <- .filter_ld_decay_data(data, pop = pop)
  layer_data <- .ld_decay_pop_group_data(layer_data, pop_group = pop_group)
  if (style == "fit") {
    layer_data <- .ld_decay_summarise_pop_group(layer_data)
  }
  layer_data <- .ld_decay_group_data(layer_data, style = style)
  layer_data <- .ld_decay_measure_data(layer_data, measure = measure)
  mapping <- .ld_decay_measure_mapping(mapping, measure = measure)
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
      alpha = alpha %||% if (style %in% c("line", "fit")) NA else 0.9,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    .ld_decay_plot_data_layer(layer_data),
    if (colour_count > 0) scale_colour_ggpop(colour_count, palette),
    ggplot2::scale_x_continuous(expand = c(0, 0)),
    ggplot2::scale_y_continuous(expand = c(0, 0), limits = c(0, NA)),
    ggplot2::labs(x = "Distance (Kb)", y = .ld_decay_y_label(measure), colour = NULL),
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
    ggpop_ld_decay_filter = list(pop = pop, pop_group = pop_group, measure = measure, style = style)
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
      data <- .ld_decay_pop_group_data(
        .filter_ld_decay_data(plot$data, pop = filter$pop),
        pop_group = filter$pop_group
      )
      if (identical(filter$style, "fit")) {
        data <- .ld_decay_summarise_pop_group(data)
      }
      .ld_decay_measure_data(
        .ld_decay_group_data(data, style = filter$style),
        measure = filter$measure
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

plot_ld_decay <- function(data, pop = NULL, pop_group = NULL, style = c("point", "line", "fit"),
                          measure = c("r2", "D", "both"),
                          title = NULL, subtitle = NULL, caption = NULL,
                          base_size = 11, base_family = "",
                          palette = "population", ...) {
  .require_class(data, "ggpop_ld_decay", "LD decay data")
  style <- match.arg(style)
  measure <- match.arg(measure)
  selected <- .filter_ld_decay_data(data, pop = pop)
  selected <- .ld_decay_pop_group_data(selected, pop_group = pop_group)
  if (style == "fit") {
    selected <- .ld_decay_summarise_pop_group(selected)
  }
  selected <- .ld_decay_group_data(selected, style = style)
  plot <- ggpop(selected) +
    geom_ld_decay(
      data = selected,
      pop = NULL,
      pop_group = NULL,
      style = style,
      measure = measure,
      base_size = base_size,
      base_family = base_family,
      palette = palette,
      ...
    )
  .ggpop_apply_labels(plot, title, subtitle, caption, "Distance (Kb)", .ld_decay_y_label(measure))
}

.geom_ld_decay_layer <- function(mapping, data = NULL, style = "point", ..., size, alpha,
                                 na.rm = FALSE, show.legend = NA, inherit.aes = TRUE) {
  layer_fun <- switch(
    style,
    line = ggplot2::geom_line,
    fit = ggplot2::geom_smooth,
    ggplot2::geom_point
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
  if (style == "fit") {
    args$method <- args$method %||% "loess"
    args$formula <- args$formula %||% stats::as.formula("y ~ x")
    args$se <- args$se %||% FALSE
  }
  if (style %in% c("line", "fit")) {
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

.ld_decay_pop_group_data <- function(data, pop_group = NULL) {
  if (is.null(data)) {
    force(pop_group)
    return(function(plot_data) .ld_decay_pop_group_data(plot_data, pop_group = pop_group))
  }
  if (is.function(data)) {
    force(pop_group)
    return(function(plot_data) .ld_decay_pop_group_data(data(plot_data), pop_group = pop_group))
  }
  if (is.null(pop_group)) {
    return(data)
  }
  .require_class(data, "ggpop_ld_decay", "LD decay data")
  .join_ld_decay_pop_group(data, pop_group = pop_group)
}

.ld_decay_summarise_pop_group <- function(data) {
  if (is.null(data)) {
    return(function(plot_data) .ld_decay_summarise_pop_group(plot_data))
  }
  if (is.function(data)) {
    return(function(plot_data) .ld_decay_summarise_pop_group(data(plot_data)))
  }
  .require_class(data, "ggpop_ld_decay", "LD decay data")
  if (!".pop_grouped" %in% names(data) || !any(data$.pop_grouped %in% TRUE)) {
    return(data)
  }
  source_group <- ifelse(
    data$.pop_grouped %in% TRUE,
    as.character(data$pop),
    paste(as.character(data$pop), as.character(data$file %||% data$sample_id), sep = ":")
  )
  keys <- interaction(source_group, data$dist, data$ld_method, drop = TRUE, sep = "\r")
  rows <- lapply(split(data, keys), .ld_decay_pop_group_row)
  out <- .stats_bind_rows(rows)
  class(out) <- class(data)
  attr(out, "source") <- attr(data, "source", exact = TRUE)
  out[order(out$pop, out$dist), , drop = FALSE]
}

.ld_decay_pop_group_row <- function(group) {
  weight <- suppressWarnings(as.numeric(group$n_pairs))
  if (all(!is.finite(weight)) || sum(weight, na.rm = TRUE) <= 0) {
    weight <- rep(1, nrow(group))
  }
  has_d <- "d_prime" %in% names(group)
  out <- group[1, , drop = FALSE]
  out$r2 <- .ld_decay_weighted_mean_value(group$r2, weight)
  if (has_d) {
    out$d_prime <- .ld_decay_weighted_mean_value(group$d_prime, weight)
  }
  out$n_pairs <- sum(weight[is.finite(weight)], na.rm = TRUE)
  if ("sum_r2" %in% names(group)) {
    out$sum_r2 <- sum(suppressWarnings(as.numeric(group$sum_r2)), na.rm = TRUE)
  }
  if ("sum_d_prime" %in% names(group)) {
    out$sum_d_prime <- sum(suppressWarnings(as.numeric(group$sum_d_prime)), na.rm = TRUE)
  }
  out$sample_id <- paste(unique(as.character(group$sample_id)), collapse = ",")
  if ("file" %in% names(group)) {
    out$file <- paste(unique(as.character(group$file)), collapse = ",")
  }
  out$.pop_grouped <- all(group$.pop_grouped %in% TRUE)
  out
}

.ld_decay_weighted_mean_value <- function(x, weight) {
  x <- suppressWarnings(as.numeric(x))
  ok <- is.finite(x) & is.finite(weight) & weight > 0
  if (!any(ok)) {
    return(NA_real_)
  }
  stats::weighted.mean(x[ok], weight[ok])
}

.ld_decay_group_data <- function(data, style = c("point", "line", "fit")) {
  style <- match.arg(style)
  if (is.null(data)) {
    force(style)
    return(function(plot_data) .ld_decay_group_data(plot_data, style = style))
  }
  if (is.function(data)) {
    force(style)
    return(function(plot_data) .ld_decay_group_data(data(plot_data), style = style))
  }
  .require_class(data, "ggpop_ld_decay", "LD decay data")
  if (style == "fit") {
    data$.group <- interaction(as.character(data$pop), drop = TRUE, sep = ":")
  } else {
    source_group <- if ("sample_id" %in% names(data)) {
      as.character(data$sample_id)
    } else if ("file" %in% names(data)) {
      as.character(data$file)
    } else {
      as.character(data$pop)
    }
    data$.group <- interaction(as.character(data$pop), source_group, drop = TRUE, sep = ":")
  }
  data
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
  if (style %in% c("line", "fit")) {
    return(base_size / 22)
  }
  1
}

.ld_decay_measure_data <- function(data, measure = "r2") {
  if (is.function(data)) {
    force(measure)
    return(function(plot_data) .ld_decay_measure_data(data(plot_data), measure = measure))
  }
  if (measure %in% c("D", "both") && (!"d_prime" %in% names(data) || !any(is.finite(data$d_prime)))) {
    stop("D' is not available in this LD decay object. Re-run PopLDdecay with D' output or use `measure = \"r2\"`.", call. = FALSE)
  }
  if (measure == "D") {
    data$y_value <- data$d_prime
    data$measure <- "D'"
  } else if (measure == "both") {
    r2 <- data
    r2$y_value <- r2$r2
    r2$measure <- "r2"
    d <- data
    d$y_value <- d$d_prime
    d$measure <- "D'"
    data <- rbind(r2, d)
  } else {
    data$y_value <- data$r2
    data$measure <- "r2"
  }
  data
}

.ld_decay_measure_mapping <- function(mapping, measure = "r2") {
  values <- as.list(mapping)
  values$y <- rlang::expr(.data$y_value)
  if (measure == "both") {
    values$linetype <- rlang::expr(.data$measure)
  }
  do.call(ggplot2::aes, values)
}

.ld_decay_y_label <- function(measure = "r2") {
  if (measure == "D") return("D'")
  if (measure == "both") return("LD")
  quote(LD~(r^2))
}
