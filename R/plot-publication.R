plot_manha <- function(data, title = "Manhattan plot", subtitle = NULL, caption = NULL,
                       threshold = 5e-8, suggestive = 1e-5,
                       use_fastman = TRUE, point_size = 0.9, point_alpha = NA,
                       base_size = 11, base_family = "", legend_position = "none",
                       logp = TRUE, maxP = 14, bybp = FALSE,
                       ...) {
  .require_class(data, "ggpop_gwas", "Manhattan plot data")
  .require_columns(data, c("chr", "pos", "p"), "GWAS data")
  if (use_fastman && requireNamespace("fastman", quietly = TRUE)) {
    fastman_data <- data
    chr_numeric <- suppressWarnings(as.numeric(as.character(fastman_data$chr)))
    if (all(!is.na(chr_numeric))) {
      fastman_data$chr <- chr_numeric
    }
    plot <- fastman::fastman_gg(
      fastman_data,
      chr = "chr",
      bp = "pos",
      p = "p",
      snp = "snp",
      genomewideline = if (is.null(threshold)) NULL else -log10(threshold),
      suggestiveline = if (is.null(suggestive)) NULL else -log10(suggestive),
      size = point_size,
      logp = logp,
      maxP = maxP,
      bybp = bybp,
      ...
    )
    return(.ggpop_apply_labels(plot, title, subtitle, caption, NULL, NULL))
  }
  plot <- ggpop(data) +
    geom_manha_pub(
      data = data,
      size = point_size,
      alpha = point_alpha,
      base_size = base_size,
      threshold = threshold,
      suggestive = suggestive,
      logp = logp,
      maxP = maxP,
      bybp = bybp,
      ...
    )
  plot <- .ggpop_apply_labels(plot, title, subtitle, caption, "Chromosome", expression(-log[10]~(p)))
  plot
}

plot_gwas <- function(data, ...) {
  plot_manha(data, ...)
}

plot_qq <- function(data, title = "Q-Q plot", subtitle = NULL, caption = NULL,
                    show_lambda = TRUE, use_fastman = TRUE, point_size = 0.8,
                    point_alpha = 0.8, base_size = 11, base_family = "",
                    legend_position = "none", ...) {
  .require_class(data, "ggpop_gwas", "Q-Q plot data")
  .require_columns(data, "p", "GWAS data")
  if (use_fastman && requireNamespace("fastman", quietly = TRUE)) {
    result <- fastman::fastqq_gg(data$p, size = point_size, lambda = show_lambda, ...)
    plot <- if (is.list(result)) result[[1]] else result
    return(.ggpop_apply_labels(plot, title, subtitle, caption, NULL, NULL) +
      theme_ggpop_publication(base_size, base_family, legend_position))
  }
  plot <- ggpop(data) +
    geom_qq_pub(
      data = data,
      size = point_size,
      alpha = point_alpha,
      show_lambda = show_lambda,
      base_size = base_size,
      ...
    )
  .ggpop_apply_labels(plot, title, subtitle, caption, expression(Expected ~ -log[10](italic(P))), expression(Observed ~ -log[10](italic(P))))
}

plot_pca <- function(data, title = "PCA plot", subtitle = NULL, caption = NULL,
                     pc_x = 1, pc_y = 2, point_size = 1.8, point_alpha = 0.85,
                     base_size = 11, base_family = "", legend_position = "right",
                     palette = NULL, ...) {
  .require_class(data, "ggpop_pca", "PCA plot data")
  x_lab <- .pc_label(data, pc_x)
  y_lab <- .pc_label(data, pc_y)
  plot <- ggpop(data) +
    geom_pca_pub(pc_x = pc_x, pc_y = pc_y, size = point_size, alpha = point_alpha, base_size = base_size, palette = palette, ...)
  plot <- .ggpop_apply_labels(plot, title, subtitle, caption, x_lab, y_lab)
  plot <- plot + ggplot2::theme(legend.position = legend_position)
  plot
}

plot_admix <- function(data, title = "Admixture plot", subtitle = NULL, caption = NULL,
                       sort = c("none", "cluster", "all", "label"), sortind = NULL,
                       k = "all", palette = NULL, group = "pop", order_group = FALSE,
                       show_group_labels = NULL, subset_group = NULL,
                       show_legend = FALSE, show_sample_labels = FALSE,
                       base_size = 5, base_family = "", legend_position = "top",
                       bar_width = 1, ...) {
  .require_class(data, "ggpop_admix", "Admixture plot data")
  if (!is.null(sortind)) {
    sort <- sortind
  } else {
    sort <- match.arg(sort)
  }
  data <- .filter_admix_k(data, k)
  if (nrow(data) == 0) {
    stop("No admixture rows remain after K filtering.", call. = FALSE)
  }
  clusters <- sort(unique(as.character(data$cluster)))
  if (is.null(palette)) {
    palette <- ggpop_palette(length(clusters), "admixture")
  }
  names(palette) <- clusters
  plot <- ggpop(data) +
    geom_admix(
      data = data,
      sort = sort,
      sortind = sortind,
      k = "all",
      palette = palette,
      group = group,
      order_group = order_group,
      show_group_labels = show_group_labels,
      subset_group = subset_group,
      bar_width = bar_width,
      show.legend = show_legend,
      show_sample_labels = show_sample_labels,
      base_size = base_size,
      base_family = base_family,
      legend_position = legend_position,
      ...
    )
  .ggpop_apply_labels(plot, title, subtitle, caption, NULL, NULL, fill = "Cluster")
}

as_pophelper_qlist <- function(data) {
  if (is.list(data) && !is.data.frame(data)) {
    .require_pophelper()
    invisible(pophelper::is.qlist(data))
    return(data)
  }
  .require_columns(data, c("sample_id", "run_id", "cluster", "proportion"), "admixture data")
  runs <- split(data, data$run_id)
  qlist <- lapply(runs, function(run_data) {
    clusters <- sort(unique(as.character(run_data$cluster)))
    samples <- unique(as.character(run_data$sample_id))
    matrix_data <- stats::xtabs(proportion ~ sample_id + cluster, run_data)
    matrix_data <- matrix_data[samples, clusters, drop = FALSE]
    out <- as.data.frame.matrix(matrix_data, stringsAsFactors = FALSE)
    names(out) <- paste0("Cluster", seq_along(out))
    attr(out, "ind") <- nrow(out)
    attr(out, "k") <- ncol(out)
    out
  })
  names(qlist) <- names(runs)
  qlist
}

plot_admixture_pophelper <- function(data, ..., exportplot = FALSE, returnplot = TRUE,
                                     theme = "theme_bw", basesize = 8) {
  plot_pophelper_q(
    data,
    ...,
    exportplot = exportplot,
    returnplot = returnplot,
    theme = theme,
    basesize = basesize
  )
}

.gwas_lambda <- function(p) {
  p <- p[is.finite(p) & !is.na(p)]
  p <- pmin(pmax(p, .Machine$double.xmin), 1)
  stats::qchisq(stats::median(p), 1, lower.tail = FALSE) / 0.4549364
}

.pc_label <- function(data, pc) {
  variance <- attr(data, "variance_explained")
  label <- paste0("PC", pc)
  if (!is.null(variance) && length(variance) >= pc && is.finite(variance[pc])) {
    label <- paste0(label, " (", round(variance[pc] * 100, 1), "%)")
  }
  label
}
