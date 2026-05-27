theme_ggpop_publication <- function(base_size = 11, base_family = "",
                                    legend_position = "top",
                                    grid = c("major", "none", "both")) {
  grid <- match.arg(grid)
  major_grid <- if (grid %in% c("major", "both")) {
    ggplot2::element_line(colour = "grey90", linewidth = 0.25)
  } else {
    ggplot2::element_blank()
  }
  minor_grid <- if (grid == "both") {
    ggplot2::element_line(colour = "grey95", linewidth = 0.15)
  } else {
    ggplot2::element_blank()
  }
  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    .ggpop_text_theme(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", colour = "grey10", margin = ggplot2::margin(b = 5)),
      plot.subtitle = ggplot2::element_text(colour = "grey30", margin = ggplot2::margin(b = 6)),
      plot.caption = ggplot2::element_text(colour = "grey40", hjust = 1),
      axis.title = ggplot2::element_text(face = "bold", colour = "grey10"),
      axis.text = ggplot2::element_text(colour = "grey15"),
      axis.line = ggplot2::element_line(colour = "grey15", linewidth = 0.35),
      axis.ticks = ggplot2::element_line(colour = "grey15", linewidth = 0.3),
      panel.grid.major = major_grid,
      panel.grid.minor = minor_grid,
      strip.background = ggplot2::element_rect(fill = "grey95", colour = "grey75", linewidth = 0.35),
      strip.text = ggplot2::element_text(face = "bold", colour = "grey10"),
      legend.position = legend_position,
      legend.title = ggplot2::element_text(face = "bold"),
      legend.key = ggplot2::element_rect(fill = "white", colour = NA),
      plot.margin = ggplot2::margin(7, 9, 7, 9)
    )
}

.ggpop_apply_labels <- function(plot, title = NULL, subtitle = NULL, caption = NULL,
                                x = NULL, y = NULL, fill = NULL, colour = NULL) {
  labels <- list(
    title = title,
    subtitle = subtitle,
    caption = caption,
    x = x,
    y = y
  )
  if (!is.null(fill)) {
    labels$fill <- fill
  }
  if (!is.null(colour)) {
    labels$colour <- colour
  }
  plot + do.call(ggplot2::labs, labels)
}

theme_tidyplot <- function(plot, base_size = 7, base_family = "",
                           fontsize = NULL) {
  base_size <- .ggpop_resolve_base_size(base_size, fontsize)
  plot <- .check_ggpop_plot(plot)
  plot + .theme_tidyplot(base_size = base_size, base_family = base_family)
}

theme_ggplot2 <- function(plot, base_size = 7, base_family = "",
                          fontsize = NULL) {
  base_size <- .ggpop_resolve_base_size(base_size, fontsize)
  plot <- .check_ggpop_plot(plot)
  plot +
    ggplot2::theme_grey(base_size = base_size, base_family = base_family) +
    .ggpop_text_theme(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(colour = NA, fill = NA)
    )
}

theme_minimal_xy <- function(plot, base_size = 7, base_family = "",
                             fontsize = NULL) {
  base_size <- .ggpop_resolve_base_size(base_size, fontsize)
  plot <- .check_ggpop_plot(plot)
  plot <- theme_tidyplot(plot, base_size = base_size, base_family = base_family)
  plot +
    ggplot2::theme(
      axis.line.x = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      axis.line.y = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      panel.grid.major.x = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      panel.grid.major.y = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      axis.ticks.x = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      axis.ticks.y = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      )
    )
}

theme_minimal_x <- function(plot, base_size = 7, base_family = "",
                            fontsize = NULL) {
  base_size <- .ggpop_resolve_base_size(base_size, fontsize)
  plot <- .check_ggpop_plot(plot)
  plot <- theme_tidyplot(plot, base_size = base_size, base_family = base_family)
  plot +
    ggplot2::theme(
      axis.line.x = ggplot2::element_blank(),
      axis.line.y = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      panel.grid.major.x = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      axis.ticks.y = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      axis.ticks.x = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      )
    )
}

theme_minimal_y <- function(plot, base_size = 7, base_family = "",
                            fontsize = NULL) {
  base_size <- .ggpop_resolve_base_size(base_size, fontsize)
  plot <- .check_ggpop_plot(plot)
  plot <- theme_tidyplot(plot, base_size = base_size, base_family = base_family)
  plot +
    ggplot2::theme(
      axis.line.y = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      panel.grid.major.y = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      axis.ticks.x = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      ),
      axis.ticks.y = ggplot2::element_line(
        colour = .ggpop_mix_colour("grey10", "white", 0.8),
        linewidth = 0.15
      )
    )
}

style_void <- function(plot, base_size = 7, base_family = "",
                       fontsize = NULL) {
  base_size <- .ggpop_resolve_base_size(base_size, fontsize)
  plot <- .check_ggpop_plot(plot)
  plot +
    ggplot2::theme_void(base_size = base_size, base_family = base_family) +
    .ggpop_text_theme(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      panel.spacing = grid::unit(0, "mm"),
      strip.text = ggplot2::element_text(margin = ggplot2::margin(7, 0, 0, 0))
    )
}

.theme_tidyplot <- function(base_size = 7, base_family = "",
                            fontsize = NULL) {
  base_size <- .ggpop_resolve_base_size(base_size, fontsize)
  ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    .ggpop_text_theme(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(colour = NA, fill = NA),
      panel.border = ggplot2::element_blank(),
      axis.line = ggplot2::element_line(linewidth = 0.25),
      axis.ticks = ggplot2::element_line(linewidth = 0.25),
      strip.background = ggplot2::element_rect(colour = NA, fill = NA)
    )
}

.ggpop_resolve_base_size <- function(base_size, fontsize = NULL) {
  if (!is.null(fontsize)) {
    base_size <- fontsize
  }
  base_size
}

.gwas_fastman_theme <- function(base_size = 11, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    .ggpop_text_theme(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 0, vjust = 0.5),
      axis.title = ggplot2::element_text(),
      panel.border = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_line(colour = "black"),
      axis.line.x = ggplot2::element_line(colour = NA),
      axis.ticks.y = ggplot2::element_line(colour = "black"),
      axis.line.y = ggplot2::element_line(colour = "black"),
      plot.margin = ggplot2::margin(30, 20, 5, 5, "points"),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(7, 7, 7, 7, "points")),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(7, 7, 7, 7, "points")),
      legend.position = "none"
    )
}

.check_ggpop_plot <- function(plot) {
  if (!inherits(plot, "ggplot")) {
    stop("`plot` must be a ggplot object.", call. = FALSE)
  }
  plot
}

.ggpop_mix_colour <- function(colour_a, colour_b, amount = 0.5) {
  amount <- max(min(amount, 1), 0)
  rgb_a <- grDevices::col2rgb(colour_a)
  rgb_b <- grDevices::col2rgb(colour_b)
  mixed <- round(rgb_a * amount + rgb_b * (1 - amount))
  grDevices::rgb(mixed[1], mixed[2], mixed[3], maxColorValue = 255)
}

.ggpop_text_theme <- function(base_size = 11, base_family = "",
                              title_size = NULL, subtitle_size = NULL,
                              caption_size = NULL, axis_title_size = NULL,
                              axis_text_size = NULL, legend_title_size = NULL,
                              legend_text_size = NULL, strip_text_size = NULL,
                              face = NULL) {
  title_size <- title_size %||% (base_size * 1.1)
  subtitle_size <- subtitle_size %||% base_size
  caption_size <- caption_size %||% (base_size * 0.85)
  axis_title_size <- axis_title_size %||% base_size
  axis_text_size <- axis_text_size %||% (base_size * 0.9)
  legend_title_size <- legend_title_size %||% base_size
  legend_text_size <- legend_text_size %||% (base_size * 0.9)
  strip_text_size <- strip_text_size %||% base_size

  ggplot2::theme(
    text = ggplot2::element_text(
      size = base_size,
      family = base_family,
      face = face
    ),
    plot.title = ggplot2::element_text(
      size = title_size,
      family = base_family,
      face = face
    ),
    plot.subtitle = ggplot2::element_text(
      size = subtitle_size,
      family = base_family,
      face = face
    ),
    plot.caption = ggplot2::element_text(
      size = caption_size,
      family = base_family,
      face = face
    ),
    axis.title = ggplot2::element_text(
      size = axis_title_size,
      family = base_family,
      face = face
    ),
    axis.text = ggplot2::element_text(
      size = axis_text_size,
      family = base_family,
      face = face
    ),
    legend.title = ggplot2::element_text(
      size = legend_title_size,
      family = base_family,
      face = face
    ),
    legend.text = ggplot2::element_text(
      size = legend_text_size,
      family = base_family,
      face = face
    ),
    strip.text = ggplot2::element_text(
      size = strip_text_size,
      family = base_family,
      face = face
    )
  )
}
