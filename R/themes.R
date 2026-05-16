theme_tidyplot <- function(plot, fontsize = 7) {
  plot <- .check_ggpop_plot(plot)
  plot + .theme_tidyplot(fontsize = fontsize)
}

theme_ggplot2 <- function(plot, fontsize = 7) {
  plot <- .check_ggpop_plot(plot)
  plot +
    ggplot2::theme_grey(base_size = fontsize) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(colour = NA, fill = NA)
    )
}

theme_minimal_xy <- function(plot, fontsize = 7) {
  plot <- .check_ggpop_plot(plot)
  plot <- theme_tidyplot(plot, fontsize = fontsize)
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

theme_minimal_x <- function(plot, fontsize = 7) {
  plot <- .check_ggpop_plot(plot)
  plot <- theme_tidyplot(plot, fontsize = fontsize)
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

theme_minimal_y <- function(plot, fontsize = 7) {
  plot <- .check_ggpop_plot(plot)
  plot <- theme_tidyplot(plot, fontsize = fontsize)
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

style_void <- function(plot, fontsize = 7) {
  plot <- .check_ggpop_plot(plot)
  plot +
    ggplot2::theme_void(base_size = fontsize) +
    ggplot2::theme(
      panel.spacing = grid::unit(0, "mm"),
      strip.text = ggplot2::element_text(margin = ggplot2::margin(7, 0, 0, 0))
    )
}

.theme_tidyplot <- function(fontsize = 7) {
  ggplot2::theme_classic(base_size = fontsize) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(colour = NA, fill = NA),
      panel.border = ggplot2::element_blank(),
      axis.line = ggplot2::element_line(linewidth = 0.25),
      axis.ticks = ggplot2::element_line(linewidth = 0.25),
      strip.background = ggplot2::element_rect(colour = NA, fill = NA)
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
