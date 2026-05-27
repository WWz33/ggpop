.introgression_matrix_layers <- function(data, dots, base_size, base_family, palette, na.rm, show.legend) {
  layout <- .introgression_matrix_layout(data)
  mapping <- ggplot2::aes(
    x = .data$pop2,
    y = .data$pop3,
    fill = .data$value
  )
  fill_scale <- .introgression_matrix_fill_scale(palette)
  label_data <- if (nrow(layout$data) <= 64) layout$data else layout$data[FALSE, , drop = FALSE]
  layers <- list(
    ggplot2::geom_tile(
      mapping = ggplot2::aes(x = .data$pop2, y = .data$pop3),
      data = layout$grid,
      width = 1,
      height = 1,
      fill = "white",
      colour = "grey86",
      linewidth = 0.25,
      inherit.aes = FALSE,
      na.rm = TRUE,
      show.legend = FALSE
    ),
    do.call(
      ggplot2::geom_tile,
      c(
        list(
          mapping = mapping,
          data = layout$data,
          width = 1,
          height = 1,
          colour = "grey88",
          linewidth = 0.25,
          inherit.aes = FALSE,
          na.rm = na.rm,
          show.legend = show.legend
        ),
        dots
      )
    ),
    if (layout$has_significance) ggplot2::geom_tile(
      mapping = ggplot2::aes(x = .data$pop2, y = .data$pop3),
      data = layout$data[layout$data$.significant %in% TRUE, , drop = FALSE],
      width = 1,
      height = 1,
      fill = NA,
      colour = "grey15",
      linewidth = 0.65,
      inherit.aes = FALSE,
      na.rm = na.rm,
      show.legend = FALSE
    ),
    if (nrow(label_data) > 0) ggplot2::geom_text(
      mapping = ggplot2::aes(x = .data$pop2, y = .data$pop3, label = .data$.label),
      data = label_data,
      size = base_size / 4.2,
      colour = "grey15",
      inherit.aes = FALSE,
      na.rm = TRUE,
      show.legend = FALSE
    ),
    fill_scale,
    ggplot2::scale_x_discrete(
      expand = c(0, 0),
      limits = layout$x_levels,
      labels = function(x) .introgression_pretty_label(x, width = 16)
    ),
    ggplot2::scale_y_discrete(
      expand = c(0, 0),
      limits = layout$y_levels,
      labels = function(x) .introgression_pretty_label(x, width = 18)
    ),
    ggplot2::coord_equal(),
    ggplot2::labs(
      x = "P2",
      y = "P3",
      fill = "D-statistic"
    ),
    .introgression_publication_theme(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        legend.position = "top",
        legend.justification = "left",
        legend.box.just = "left",
        legend.key.width = grid::unit(0.9, "cm"),
        legend.key.height = grid::unit(0.22, "cm"),
        axis.text.x = ggplot2::element_text(face = "italic", angle = 45, hjust = 1, vjust = 1),
        axis.text.y = ggplot2::element_text(face = "italic"),
        axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 7)),
        axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 7)),
        panel.grid = ggplot2::element_blank(),
        plot.margin = ggplot2::margin(6, 10, 6, 10)
      )
  )
  Filter(Negate(is.null), layers)
}

.introgression_matrix_layout <- function(data) {
  .require_class(data, "ggpop_introgression", "Introgression data")
  required <- c("pop2", "pop3", "value")
  missing <- setdiff(required, names(data))
  if (length(missing) > 0) {
    stop(
      "Dsuite matrix view requires `", paste(missing, collapse = "`, `"), "` columns.",
      call. = FALSE
    )
  }
  data <- data[!is.na(data$pop2) & !is.na(data$pop3), , drop = FALSE]
  if (nrow(data) == 0) {
    stop("No introgression rows remain after matrix aggregation.", call. = FALSE)
  }
  data$pop2 <- as.character(data$pop2)
  data$pop3 <- as.character(data$pop3)
  x_levels <- unique(data$pop2)
  y_levels <- unique(data$pop3)
  rows <- lapply(split(data, interaction(data$pop2, data$pop3, drop = TRUE, sep = "\r")), .introgression_matrix_row)
  out <- .stats_bind_rows(rows)
  out$pop2 <- factor(as.character(out$pop2), levels = x_levels)
  out$pop3 <- factor(as.character(out$pop3), levels = y_levels)
  grid <- expand.grid(
    pop2 = x_levels,
    pop3 = y_levels,
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )
  grid$pop2 <- factor(grid$pop2, levels = x_levels)
  grid$pop3 <- factor(grid$pop3, levels = y_levels)
  list(
    data = out,
    grid = grid,
    x_levels = x_levels,
    y_levels = y_levels,
    has_significance = ".significant" %in% names(out) && any(out$.significant %in% TRUE)
  )
}

.introgression_matrix_row <- function(group) {
  out <- group[1, c("pop2", "pop3"), drop = FALSE]
  out$value <- .introgression_numeric_max_abs(group$value)
  out$.label <- if (is.finite(out$value)) sprintf("%.2f", out$value) else NA_character_
  if ("p_value" %in% names(group)) {
    p <- .introgression_numeric_min(group$p_value)
    out$p_value <- p
    out$.significant <- is.finite(p) && p < 0.05
  } else {
    out$.significant <- FALSE
  }
  out
}

.introgression_matrix_fill_scale <- function(palette) {
  colours <- .introgression_matrix_colours(palette)
  ggplot2::scale_fill_gradient2(low = colours[[1]], mid = colours[[2]], high = colours[[3]], midpoint = 0)
}

.introgression_matrix_colours <- function(palette) {
  if (is.null(palette)) {
    palette <- "publication"
  }
  if (is.character(palette) && length(palette) == 1 && !grepl("^#", palette)) {
    if (identical(palette, "publication")) {
      return(c("#3B6EA8", "#F7F7F7", "#B6403A"))
    }
    colours <- tryCatch(
      grDevices::hcl.colors(3, palette),
      error = function(e) c("#3B6EA8", "#F7F7F7", "#B6403A")
    )
    return(colours)
  }
  if (length(palette) < 3) {
    palette <- grDevices::colorRampPalette(palette)(3)
  }
  grDevices::colorRampPalette(palette)(3)
}

.introgression_numeric_max_abs <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  x <- x[is.finite(x)]
  if (length(x) == 0) {
    return(NA_real_)
  }
  x[which.max(abs(x))]
}

.introgression_numeric_min <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  x <- x[is.finite(x)]
  if (length(x) == 0) {
    return(NA_real_)
  }
  min(x)
}
