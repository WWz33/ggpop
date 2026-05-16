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

.gwas_fastman_theme <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 0, vjust = 0.5),
      axis.title = ggplot2::element_text(),
      panel.border = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_line(color = "black"),
      axis.line.x = ggplot2::element_line(color = NA),
      axis.ticks.y = ggplot2::element_line(color = "black"),
      axis.line.y = ggplot2::element_line(color = "black"),
      plot.margin = ggplot2::margin(30, 20, 5, 5, "points"),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(7, 7, 7, 7, "points")),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(7, 7, 7, 7, "points")),
      legend.position = "none"
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
                       threshold_colour = "red",
                       suggestive_colour = "blue",
                       size = 0.9, shape = 20, speedup = TRUE,
                       logp = TRUE, maxP = 14, bybp = FALSE,
                       palette = "manhattan", binary = FALSE,
                       base_size = 11,
                       na.rm = FALSE, show.legend = FALSE,
                       inherit.aes = TRUE) {
  colour_count <- 64
  if (!is.null(data) && "chr" %in% names(data)) {
    colour_count <- max(length(.gwas_chr_levels(as.character(data$chr))), 2)
  }
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
    .gwas_fastman_theme(base_size = base_size),
    .gwas_fastman_scale(data, speedup = speedup, logp = logp, maxP = maxP, bybp = bybp),
    if (isTRUE(binary)) {
      .gwas_binary_colour_scale(colour_count, palette)
    } else {
      scale_colour_ggpop(colour_count, palette, guide = "none")
    }
  )
  Filter(Negate(is.null), layers)
}

geom_manha_pub <- function(mapping = ggplot2::aes(chr = .data$chr, pos = .data$pos, p = .data$p),
                           data = NULL, ..., size = 0.9, alpha = NA,
                           threshold = 5e-8, suggestive = 1e-5,
                           threshold_colour = "red",
                           suggestive_colour = "blue",
                           speedup = TRUE, logp = TRUE, maxP = 14,
                           bybp = FALSE, palette = "manhattan", binary = FALSE,
                           base_size = 11, show.legend = FALSE,
                           inherit.aes = TRUE) {
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
