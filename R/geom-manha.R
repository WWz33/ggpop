plot_manha <- function(data, title = NULL, subtitle = NULL, caption = NULL,
                       threshold = 5e-8, suggestive = 1e-5,
                       threshold_colour = .gwas_threshold_color(),
                       suggestive_colour = .gwas_suggestive_color(),
                       threshold_color = NULL,
                       suggestive_color = NULL,
                       point_size = 1.5, point_alpha = 0.9,
                       base_size = 11, base_family = "", legend_position = "none",
                       logp = TRUE, maxP = 14, bybp = FALSE,
                       palette = "manhattan", binary = FALSE,
                       ...) {
  .require_class(data, "ggpop_gwas", "Manhattan plot data")
  .require_columns(data, c("chr", "pos", "p"), "GWAS data")
  if (!is.null(threshold_color)) {
    threshold_colour <- threshold_color
  }
  if (!is.null(suggestive_color)) {
    suggestive_colour <- suggestive_color
  }
  plot <- ggpop(data) +
    geom_manha(
      data = data,
      size = point_size,
      alpha = point_alpha,
      base_size = base_size,
      threshold = threshold,
      suggestive = suggestive,
      threshold_colour = threshold_colour,
      suggestive_colour = suggestive_colour,
      logp = logp,
      maxP = maxP,
      bybp = bybp,
      palette = palette,
      binary = binary,
      base_family = base_family,
      ...
    )
  y_label <- if (isTRUE(logp)) expression(-log[10]~(p)) else "p"
  plot <- .ggpop_apply_labels(plot, title, subtitle, caption, "Chromosome", y_label)
  plot + ggplot2::theme(legend.position = legend_position)
}

StatManha <- ggplot2::ggproto(
  "StatManha", ggplot2::Stat,
  required_aes = c("chr", "pos", "p"),
  default_aes = ggplot2::aes(
    x = ggplot2::after_stat(BPn),
    y = ggplot2::after_stat(logp),
    colour = ggplot2::after_stat(chr_group)
  ),
  compute_panel = function(data, scales, threshold = NULL, speedup = TRUE,
                           logp = TRUE, maxP = 14, bybp = FALSE,
                           na.rm = FALSE) {
    layout <- .gwas_fastman_layout(data, speedup = speedup, logp = logp, maxP = maxP, bybp = bybp)
    data <- layout$data
    data$is_peak <- if (is.null(threshold)) FALSE else data$p <= threshold
    data
  }
)

.gwas_chr_levels <- function(chr) {
  chr <- unique(chr)
  chr_numeric <- suppressWarnings(as.numeric(as.character(chr)))
  if (all(!is.na(chr_numeric))) {
    chr[order(chr_numeric)]
  } else {
    sort(chr)
  }
}

.gwas_fastman_layout <- function(data, speedup = TRUE, logp = TRUE, maxP = 14, bybp = FALSE) {
  data <- data[is.finite(data$pos) & is.finite(data$p) & !is.na(data$chr), , drop = FALSE]
  if (nrow(data) == 0) {
    return(list(
      data = data,
      breaks = numeric(),
      labels = character(),
      limits = c(0, 1),
      y_limits = c(0, 1)
    ))
  }
  data$chr <- as.character(data$chr)
  data$p <- pmax(data$p, .Machine$double.xmin)
  data$logp <- if (logp) -log10(data$p) else data$p
  data$BP <- as.double(data$pos) / 1e6

  chr_levels <- .gwas_chr_levels(data$chr)
  num_chr <- length(chr_levels)
  by_bp <- bybp || num_chr == 1

  if (by_bp) {
    bp_range <- range(data$BP, na.rm = TRUE)
    factor_x <- if (diff(bp_range) == 0) 1 else 23 / diff(bp_range)
    data$BPn <- data$BP * factor_x
    midpoints <- mean(range(data$BPn, na.rm = TRUE))
  } else {
    chr_meta <- data.frame(
      chr = chr_levels,
      min = NA_real_,
      max = NA_real_,
      width = NA_real_,
      medgap = NA_real_,
      base = 0,
      midp = 0,
      stringsAsFactors = FALSE
    )
    for (index in seq_along(chr_levels)) {
      idx <- data$chr == chr_levels[index]
      bp <- data$BP[idx]
      chr_meta$min[index] <- min(bp, na.rm = TRUE)
      chr_meta$max[index] <- max(bp, na.rm = TRUE)
      chr_meta$width[index] <- chr_meta$max[index] - chr_meta$min[index]
      chr_meta$medgap[index] <- stats::median(diff(sort(bp)), na.rm = TRUE)
      data$BP[idx] <- bp - chr_meta$min[index]
    }
    max_gap <- max(chr_meta$medgap, na.rm = TRUE)
    if (!is.finite(max_gap)) {
      max_gap <- 0
    }
    chr_meta$midp[1] <- chr_meta$width[1] / 2
    if (num_chr > 1) {
      for (index in 2:num_chr) {
        chr_meta$base[index] <- chr_meta$base[index - 1] + chr_meta$width[index - 1] + max_gap
        chr_meta$midp[index] <- chr_meta$base[index] + chr_meta$width[index] / 2
      }
    }
    factor_x <- if (chr_meta$midp[num_chr] == 0) 1 else num_chr / chr_meta$midp[num_chr]
    data$BP <- factor_x * data$BP
    chr_meta$basef <- factor_x * chr_meta$base
    chr_meta$midpf <- factor_x * chr_meta$midp
    data$BPn <- data$BP
    if (num_chr > 1) {
      for (index in 2:num_chr) {
        idx <- data$chr == chr_levels[index]
        data$BPn[idx] <- data$BP[idx] + chr_meta$basef[index]
      }
    }
    midpoints <- chr_meta$midpf
  }

  if (!is.null(maxP)) {
    data$logp[data$logp <= -maxP] <- -maxP
    data$logp[data$logp >= maxP] <- maxP
  } else if (any(!is.finite(data$logp))) {
    finite_logp <- sort(data$logp[is.finite(data$logp)])
    if (length(finite_logp) > 1) {
      data$logp[data$logp == Inf] <- finite_logp[length(finite_logp)]
      data$logp[data$logp == -Inf] <- finite_logp[1]
    }
  }

  data$chr_group <- factor(match(data$chr, chr_levels), levels = seq_along(chr_levels))
  factor_y <- diff(range(data$logp, na.rm = TRUE))
  factor_y <- if (!is.finite(factor_y) || factor_y == 0) 1 else 10 / factor_y
  data$logp <- data$logp * factor_y
  if (speedup) {
    data$logp <- round(data$logp, digits = 3)
    data$BPn <- round(data$BPn, digits = 3)
    data <- data[!duplicated(data[, c("chr_group", "BPn", "logp")]), , drop = FALSE]
  }
  if (by_bp) {
    data$BPn <- data$BPn / factor_x
    midpoints <- NULL
  }
  data$logp <- data$logp / factor_y

  x_pad <- 0.015 * diff(range(data$BPn, na.rm = TRUE))
  if (!is.finite(x_pad)) {
    x_pad <- 0
  }
  x_limits <- if (by_bp) {
    range(data$BPn, na.rm = TRUE) + c(-x_pad, x_pad)
  } else {
    c(-x_pad, max(data$BPn, na.rm = TRUE) + x_pad)
  }
  y_limits <- c(floor(min(c(min(data$logp, na.rm = TRUE), 0))), ceiling(max(data$logp, na.rm = TRUE)))

  list(
    data = data,
    breaks = midpoints,
    labels = chr_levels,
    limits = x_limits,
    y_limits = y_limits
  )
}

.gwas_fastman_scale <- function(data, speedup = TRUE, logp = TRUE, maxP = 14, bybp = FALSE) {
  if (is.null(data) || !all(c("chr", "pos", "p") %in% names(data))) {
    return(NULL)
  }
  layout <- .gwas_fastman_layout(data, speedup = speedup, logp = logp, maxP = maxP, bybp = bybp)
  ggplot2::scale_x_continuous(
    limits = layout$limits,
    expand = c(0, 0),
    breaks = layout$breaks,
    labels = layout$labels,
    guide = ggplot2::guide_axis(check.overlap = TRUE)
  )
}

.geom_manha_layer <- function(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
                              data = NULL, geom = "point", position = "identity",
                              ..., threshold = NULL, speedup = TRUE, logp = TRUE,
                              maxP = 14, bybp = FALSE, na.rm = FALSE, show.legend = NA,
                              inherit.aes = TRUE) {
  ggplot2::layer(
    stat = StatManha,
    geom = geom,
    data = data,
    mapping = mapping,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(threshold = threshold, speedup = speedup, logp = logp, maxP = maxP, bybp = bybp, na.rm = na.rm, ...)
  )
}

geom_manha <- function(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
                       data = NULL, geom = "point", position = "identity",
                       ..., threshold = 5e-8, suggestive = 1e-5,
                       threshold_colour = .gwas_threshold_color(),
                       suggestive_colour = .gwas_suggestive_color(),
                       threshold_color = NULL,
                       suggestive_color = NULL,
                       size = 1.5, shape = 20, speedup = TRUE,
                       logp = TRUE, maxP = 14, bybp = FALSE,
                       palette = "manhattan", binary = FALSE,
                       base_size = 11, base_family = "",
                       na.rm = FALSE, show.legend = FALSE,
                       inherit.aes = TRUE) {
  if (!is.null(threshold_color)) {
    threshold_colour <- threshold_color
  }
  if (!is.null(suggestive_color)) {
    suggestive_colour <- suggestive_color
  }
  scale_data <- data
  layers <- list(
    .geom_manha_layer(
      mapping = mapping,
      data = data,
      geom = geom,
      position = position,
      ...,
      size = size,
      shape = shape,
      threshold = threshold,
      speedup = speedup,
      logp = logp,
      maxP = maxP,
      bybp = bybp,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = inherit.aes
    ),
    if (!is.null(suggestive)) {
      ggplot2::geom_hline(
        yintercept = -log10(suggestive),
        linewidth = 0.5,
        linetype = "solid",
        colour = suggestive_colour
      )
    },
    if (!is.null(threshold)) {
      ggplot2::geom_hline(
        yintercept = -log10(threshold),
        linewidth = 0.5,
        linetype = "solid",
        colour = threshold_colour
      )
    },
    ggplot2::scale_y_continuous(expand = c(0, 0)),
    .gwas_fastman_theme(base_size = base_size, base_family = base_family),
    ggplot2::labs(x = "Chromosome", y = if (isTRUE(logp)) expression(-log[10]~(p)) else "p")
  )
  structure(
    Filter(Negate(is.null), layers),
    class = c("ggpop_manha_layers", "list"),
    ggpop_manha_scale_data = scale_data,
    ggpop_manha_scale_params = list(
      speedup = speedup,
      logp = logp,
      maxP = maxP,
      bybp = bybp,
      palette = palette,
      binary = binary
    )
  )
}

ggplot_add.ggpop_manha_layers <- function(object, plot, object_name) {
  scale_data <- attr(object, "ggpop_manha_scale_data", exact = TRUE)
  scale_params <- attr(object, "ggpop_manha_scale_params", exact = TRUE)
  if (is.null(scale_data) && inherits(plot$data, "ggpop_gwas")) {
    scale_data <- plot$data
  }
  for (layer in unclass(object)) {
    plot <- plot + layer
  }
  if (!is.null(scale_data)) {
    plot <- plot + .gwas_fastman_scale(
      scale_data,
      speedup = scale_params$speedup,
      logp = scale_params$logp,
      maxP = scale_params$maxP,
      bybp = scale_params$bybp
    )
  }
  colour_count <- 64
  if (!is.null(scale_data) && "chr" %in% names(scale_data)) {
    colour_count <- max(length(.gwas_chr_levels(as.character(scale_data$chr))), 2)
  }
  plot <- plot + if (isTRUE(scale_params$binary)) {
    .gwas_binary_colour_scale(colour_count, scale_params$palette)
  } else {
    scale_colour_ggpop(colour_count, scale_params$palette, guide = "none")
  }
  plot
}

geom_manha_pub <- function(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
                           data = NULL, ..., size = 1.5, alpha = 0.9,
                           threshold = 5e-8, suggestive = 1e-5,
                           threshold_colour = .gwas_threshold_color(),
                           suggestive_colour = .gwas_suggestive_color(),
                           threshold_color = NULL,
                           suggestive_color = NULL,
                           speedup = TRUE, logp = TRUE, maxP = 14,
                           bybp = FALSE, palette = "manhattan", binary = FALSE,
                           base_size = 11, base_family = "", show.legend = FALSE,
                           inherit.aes = TRUE) {
  if (!is.null(threshold_color)) {
    threshold_colour <- threshold_color
  }
  if (!is.null(suggestive_color)) {
    suggestive_colour <- suggestive_color
  }
  geom_manha(
    mapping = mapping,
    data = data,
    ...,
    size = size,
    alpha = alpha,
    threshold = threshold,
    suggestive = suggestive,
    threshold_colour = threshold_colour,
    suggestive_colour = suggestive_colour,
    speedup = speedup,
    logp = logp,
    maxP = maxP,
    bybp = bybp,
    palette = palette,
    binary = binary,
    base_size = base_size,
    base_family = base_family,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
}

.gwas_binary_colour_scale <- function(n, palette) {
  values <- ggpop_palette(2, palette)
  values <- rep_len(values, n)
  values <- stats::setNames(values, as.character(seq_len(n)))
  ggplot2::scale_colour_manual(values = values, guide = "none")
}

.gwas_threshold_color <- function() {
  ggpop_palette(4, "publication")[4]
}

.gwas_suggestive_color <- function() {
  ggpop_palette(1, "publication")
}
