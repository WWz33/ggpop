plot_pca <- function(data, title = NULL, subtitle = NULL, caption = NULL,
                     pc_x = 1, pc_y = 2, point_size = 2.16, point_alpha = 0.9,
                     base_size = 11, base_family = "", legend_position = "right",
                     palette = NULL, pop_group = TRUE, ...) {
  .require_class(data, "ggpop_pca", "PCA plot data")
  x_lab <- .pc_label(data, pc_x)
  y_lab <- .pc_label(data, pc_y)
  plot <- ggpop(data, pop_group = pop_group) +
    geom_pca(
      pc_x = pc_x,
      pc_y = pc_y,
      size = point_size,
      alpha = point_alpha,
      base_size = base_size,
      base_family = base_family,
      palette = palette,
      pop_group = pop_group,
      ...
    )
  plot <- .ggpop_apply_labels(plot, title, subtitle, caption, x_lab, y_lab)
  plot <- plot + ggplot2::theme(legend.position = legend_position)
  plot
}

geom_pca <- function(mapping = ggplot2::aes(x = .data$pc1, y = .data$pc2),
                     data = NULL, ..., pc_x = 1, pc_y = 2, base_size = 11,
                     base_family = "", palette = NULL, pop_group = TRUE,
                     size = 2.16, alpha = 0.9, na.rm = FALSE,
                     show.legend = NA, inherit.aes = TRUE) {
  layer_data <- data
  if (isFALSE(pop_group) && !is.null(layer_data) && "pop" %in% names(layer_data)) {
    layer_data$pop <- NULL
  }
  if (pc_x != 1 || pc_y != 2) {
    mapping <- ggplot2::aes(x = .data[[paste0("pc", pc_x)]], y = .data[[paste0("pc", pc_y)]])
  }
  if (isTRUE(pop_group) && .pca_has_pop(layer_data, mapping)) {
    mapping <- .add_pop_colour_mapping(mapping)
  }
  labels <- .pca_axis_labels(layer_data, pc_x = pc_x, pc_y = pc_y)
  list(
    ggplot2::geom_point(
      mapping = mapping,
      data = layer_data,
      ...,
      size = size,
      alpha = alpha,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    if (!is.null(labels)) ggplot2::labs(x = labels$x, y = labels$y),
    if (.pca_should_add_colour_scale(layer_data, pop_group = pop_group)) scale_colour_ggpop(palette = palette %||% "population"),
    .theme_tidyplot(base_size = base_size, base_family = base_family)
  )
}

geom_pca_pub <- function(mapping = ggplot2::aes(x = .data$pc1, y = .data$pc2),
                         data = NULL, ..., pc_x = 1, pc_y = 2,
                         size = 2.16, alpha = 0.9, na.rm = FALSE,
                         base_size = 11, base_family = "", show.legend = NA,
                         palette = NULL, pop_group = TRUE,
                         inherit.aes = TRUE) {
  geom_pca(
    mapping = mapping,
    data = data,
    ...,
    pc_x = pc_x,
    pc_y = pc_y,
    size = size,
    alpha = alpha,
    base_size = base_size,
    base_family = base_family,
    palette = palette,
    pop_group = pop_group,
    na.rm = na.rm,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
}

.pca_has_pop <- function(data, mapping) {
  if (!is.null(mapping$colour) || !is.null(mapping$color)) {
    return(FALSE)
  }
  if (is.null(data)) {
    return(FALSE)
  }
  "pop" %in% names(data)
}

.pca_should_add_colour_scale <- function(data, pop_group = TRUE) {
  isTRUE(pop_group) && (is.null(data) || "pop" %in% names(data))
}

.add_pop_colour_mapping <- function(mapping) {
  values <- as.list(mapping)
  values$colour <- rlang::expr(.data$pop)
  do.call(ggplot2::aes, values)
}

.pca_axis_labels <- function(data, pc_x = 1, pc_y = 2) {
  if (!is.null(data)) {
    return(list(x = .pc_label(data, pc_x), y = .pc_label(data, pc_y)))
  }
  if (pc_x != 1 || pc_y != 2) {
    return(list(x = paste0("PC", pc_x), y = paste0("PC", pc_y)))
  }
  NULL
}

.pc_label <- function(data, pc) {
  variance <- attr(data, "variance_explained")
  label <- paste0("PC", pc)
  if (!is.null(variance) && length(variance) >= pc && is.finite(variance[pc])) {
    label <- paste0(label, " (", round(variance[pc] * 100, 1), "%)")
  }
  label
}
