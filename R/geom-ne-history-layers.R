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

.ne_history_split_bootstrap <- function(data) {
  if (is.function(data) || is.null(data)) {
    return(list(main = data, bootstrap = NULL))
  }
  is_bootstrap <- rep(FALSE, nrow(data))
  if ("type" %in% names(data)) {
    is_bootstrap <- is_bootstrap | grepl("boot|bs|rep", tolower(as.character(data$type)))
  }
  if ("line_type" %in% names(data)) {
    is_bootstrap <- is_bootstrap | grepl("boot|bs|rep", tolower(as.character(data$line_type)))
  }
  if ("plot_type" %in% names(data)) {
    is_bootstrap <- is_bootstrap | grepl("boot|bs|rep", tolower(as.character(data$plot_type)))
  }
  for (column in c("replicate", "bootstrap", "bs", "n")) {
    if (column %in% names(data)) {
      value <- tolower(as.character(data[[column]]))
      is_bootstrap <- is_bootstrap | (!is.na(value) & nzchar(value) & !value %in% c("main", "direct", "path", "0"))
    }
  }
  list(
    main = data[!is_bootstrap, , drop = FALSE],
    bootstrap = data[is_bootstrap, , drop = FALSE]
  )
}
