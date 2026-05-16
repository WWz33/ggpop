geom_pca <- function(mapping = ggplot2::aes(x = .data$pc1, y = .data$pc2),
                     data = NULL, ..., pc_x = 1, pc_y = 2, base_size = 11,
                     palette = NULL, pop_group = TRUE,
                     na.rm = FALSE,
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
  list(
    ggplot2::geom_point(
      mapping = mapping,
      data = layer_data,
      ...,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    if (.pca_should_add_colour_scale(layer_data, pop_group = pop_group)) scale_colour_ggpop(palette = palette %||% "population"),
    .theme_tidyplot(fontsize = base_size)
  )
}

geom_pca_pub <- function(mapping = ggplot2::aes(x = .data$pc1, y = .data$pc2),
                         data = NULL, ..., pc_x = 1, pc_y = 2,
                         size = 1.8, alpha = 0.85, na.rm = FALSE,
                         base_size = 11, show.legend = NA, palette = NULL, pop_group = TRUE,
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
