plot_qq <- function(data, title = NULL, subtitle = NULL, caption = NULL,
                    show_lambda = TRUE, point_size = 0.8,
                    diagonal_colour = .gwas_qq_diagonal_color(),
                    diagonal_color = NULL,
                    point_alpha = 0.8, base_size = 11, base_family = "",
                    legend_position = "none", ...) {
  .require_class(data, "ggpop_gwas", "Q-Q plot data")
  .require_columns(data, "p", "GWAS data")
  if (!is.null(diagonal_color)) {
    diagonal_colour <- diagonal_color
  }
  plot <- ggpop(data) +
    geom_qq(
      data = data,
      size = point_size,
      alpha = point_alpha,
      diagonal_colour = diagonal_colour,
      show_lambda = show_lambda,
      base_size = base_size,
      base_family = base_family,
      ...
    )
  plot <- .ggpop_apply_labels(plot, title, subtitle, caption, expression(Expected ~ -log[10](italic(P))), expression(Observed ~ -log[10](italic(P))))
  plot + ggplot2::theme(legend.position = legend_position)
}

StatQQGwas <- ggplot2::ggproto(
  "StatQQGwas", ggplot2::Stat,
  required_aes = "p",
  dropped_aes = "p",
  default_aes = ggplot2::aes(
    x = ggplot2::after_stat(expected),
    y = ggplot2::after_stat(observed)
  ),
  compute_group = function(data, scales, maxP = 14, fix_zero = TRUE,
                           speedup = TRUE, na.rm = FALSE) {
    .gwas_fastqq_layout(
      data$p,
      maxP = maxP,
      fix_zero = fix_zero,
      speedup = speedup
    )$data
  }
)

StatQQLambda <- ggplot2::ggproto(
  "StatQQLambda", ggplot2::Stat,
  required_aes = "p",
  dropped_aes = "p",
  default_aes = ggplot2::aes(
    x = ggplot2::after_stat(x),
    y = ggplot2::after_stat(y),
    label = ggplot2::after_stat(label)
  ),
  compute_group = function(data, scales, maxP = 14, fix_zero = TRUE,
                           speedup = TRUE, na.rm = FALSE) {
    layout <- .gwas_fastqq_layout(
      data$p,
      maxP = maxP,
      fix_zero = fix_zero,
      speedup = speedup
    )
    if (nrow(layout$data) == 0) {
      return(data.frame(x = numeric(), y = numeric(), label = character()))
    }
    data.frame(
      x = max(layout$data$expected, na.rm = TRUE) * 0.05,
      y = max(layout$data$observed, na.rm = TRUE),
      label = paste("\u03BB", "=", round(layout$lambda, 4))
    )
  }
)

.gwas_fastqq_layout <- function(p, maxP = 14, fix_zero = TRUE, speedup = TRUE) {
  p <- .gwas_fastqq_clean_p(p, fix_zero = fix_zero)
  if (length(p) == 0) {
    return(.gwas_fastqq_empty_layout())
  }

  lambda <- stats::qchisq(stats::median(p), 1, lower.tail = FALSE) / 0.4549364
  observed <- -log10(sort(p))
  expected <- -log10(stats::ppoints(length(p)))
  values <- .gwas_fastqq_truncate(expected, observed, maxP = maxP)

  out <- data.frame(
    expected = values$expected,
    observed = values$observed,
    rank = seq_along(values$observed)
  )
  out <- .gwas_fastqq_speedup(out, speedup = speedup)

  list(
    data = out,
    lambda = lambda,
    x_limits = c(0, max(out$expected, na.rm = TRUE) + 0.4),
    y_limits = c(0, max(out$observed, na.rm = TRUE) + 0.4)
  )
}

.gwas_fastqq_clean_p <- function(p, fix_zero = TRUE) {
  p <- p[!is.na(p) & !is.nan(p) & is.finite(p)]
  if (length(p) == 0) {
    return(p)
  }

  p[p < 0] <- 0
  p[p > 1] <- 1
  zero <- p == 0
  if (any(zero)) {
    if (fix_zero) {
      non_zero <- p[!zero]
      p[zero] <- if (length(non_zero) == 0) .Machine$double.xmin else min(non_zero, na.rm = TRUE)
    } else {
      p <- p[!zero]
    }
  }
  p
}

.gwas_fastqq_truncate <- function(expected, observed, maxP = 14) {
  if (!is.null(maxP)) {
    observed[observed <= -maxP] <- -maxP
    observed[observed >= maxP] <- maxP
    expected[expected <= -maxP] <- -maxP
    expected[expected >= maxP] <- maxP
  } else {
    observed[is.infinite(observed)] <- max(observed[is.finite(observed)], na.rm = TRUE)
    expected[is.infinite(expected)] <- max(expected[is.finite(expected)], na.rm = TRUE)
  }
  list(expected = expected, observed = observed)
}

.gwas_fastqq_speedup <- function(out, speedup = TRUE) {
  if (speedup) {
    out$expected <- round(out$expected, digits = 3)
    out$observed <- round(out$observed, digits = 3)
    out <- out[!duplicated(out[, c("expected", "observed")]), , drop = FALSE]
  }
  out
}

.gwas_fastqq_empty_layout <- function() {
  list(
    data = data.frame(expected = numeric(), observed = numeric(), rank = integer()),
    lambda = NA_real_,
    x_limits = c(0, 1),
    y_limits = c(0, 1)
  )
}

.gwas_fastqq_scales <- function(data, maxP = 14, fix_zero = TRUE, speedup = TRUE) {
  if (is.null(data) || !"p" %in% names(data)) {
    return(list(
      ggplot2::scale_x_continuous(name = expression(Expected ~ ~-log[10](italic(p)))),
      ggplot2::scale_y_continuous(name = expression(Observed ~ ~-log[10](italic(p))))
    ))
  }
  layout <- .gwas_fastqq_layout(data$p, maxP = maxP, fix_zero = fix_zero, speedup = speedup)
  list(
    ggplot2::scale_x_continuous(
      limits = layout$x_limits,
      name = expression(Expected ~ ~-log[10](italic(p)))
    ),
    ggplot2::scale_y_continuous(
      limits = layout$y_limits,
      name = expression(Observed ~ ~-log[10](italic(p)))
    )
  )
}

.geom_qq_layer <- function(mapping = ggplot2::aes(p = .data$p), data = NULL,
                           geom = "point", position = "identity", ...,
                           maxP = 14, fix_zero = TRUE, speedup = TRUE,
                           na.rm = FALSE, show.legend = NA,
                           inherit.aes = TRUE) {
  ggplot2::layer(
    stat = StatQQGwas,
    geom = geom,
    data = data,
    mapping = mapping,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(maxP = maxP, fix_zero = fix_zero, speedup = speedup, na.rm = na.rm, ...)
  )
}

.geom_qq_lambda <- function(mapping = ggplot2::aes(p = .data$p), data = NULL,
                            position = "identity", ..., maxP = 14,
                            fix_zero = TRUE, speedup = TRUE, na.rm = FALSE,
                            inherit.aes = TRUE) {
  ggplot2::layer(
    stat = StatQQLambda,
    geom = "text",
    data = data,
    mapping = mapping,
    position = position,
    show.legend = FALSE,
    inherit.aes = inherit.aes,
    params = list(maxP = maxP, fix_zero = fix_zero, speedup = speedup, na.rm = na.rm, hjust = 0, vjust = 1, ...)
  )
}

geom_qq <- function(mapping = ggplot2::aes(p = .data$p), data = NULL,
                    geom = "point", position = "identity", ..., size = 0.8,
                    alpha = 0.8, colour = "black", diagonal = TRUE,
                    diagonal_colour = .gwas_qq_diagonal_color(),
                    diagonal_color = NULL, show_lambda = TRUE,
                    maxP = 14, fix_zero = TRUE, speedup = TRUE,
                    base_size = 11, base_family = "",
                    lambda_size = base_size * 0.65,
                    na.rm = FALSE, show.legend = FALSE,
                    inherit.aes = TRUE) {
  if (!is.null(diagonal_color)) {
    diagonal_colour <- diagonal_color
  }
  layers <- c(
    list(
      .geom_qq_layer(
        mapping = mapping,
        data = data,
        geom = geom,
        position = position,
        ...,
        size = size,
        alpha = alpha,
        colour = colour,
        maxP = maxP,
        fix_zero = fix_zero,
        speedup = speedup,
        na.rm = na.rm,
        show.legend = show.legend,
        inherit.aes = inherit.aes
      ),
      if (diagonal) {
        ggplot2::geom_abline(
          intercept = 0,
          slope = 1,
          linewidth = 0.5,
          linetype = "solid",
          colour = diagonal_colour
        )
      },
      if (show_lambda) {
        .geom_qq_lambda(
          mapping = mapping,
          data = data,
          maxP = maxP,
          fix_zero = fix_zero,
          speedup = speedup,
          na.rm = na.rm,
          size = lambda_size,
          inherit.aes = inherit.aes
        )
      }
    ),
    .gwas_fastqq_scales(data, maxP = maxP, fix_zero = fix_zero, speedup = speedup),
    list(
      .theme_tidyplot(base_size = base_size, base_family = base_family),
      ggplot2::theme(legend.position = "none")
    )
  )
  Filter(Negate(is.null), layers)
}

geom_qq_pub <- function(mapping = ggplot2::aes(p = .data$p), data = NULL,
                        ..., size = 0.8, alpha = 0.8,
                        diagonal = TRUE,
                        diagonal_colour = .gwas_qq_diagonal_color(),
                        diagonal_color = NULL,
                        show_lambda = TRUE, maxP = 14, fix_zero = TRUE,
                        speedup = TRUE, base_size = 11, base_family = "",
                        lambda_size = base_size * 0.65,
                        show.legend = FALSE, inherit.aes = TRUE) {
  if (!is.null(diagonal_color)) {
    diagonal_colour <- diagonal_color
  }
  geom_qq(
    mapping = mapping,
    data = data,
    ...,
    size = size,
    alpha = alpha,
    diagonal = diagonal,
    diagonal_colour = diagonal_colour,
    show_lambda = show_lambda,
    maxP = maxP,
    fix_zero = fix_zero,
    speedup = speedup,
    base_size = base_size,
    base_family = base_family,
    lambda_size = lambda_size,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
}

.gwas_qq_diagonal_color <- function() {
  ggpop_palette(4, "publication")[4]
}
