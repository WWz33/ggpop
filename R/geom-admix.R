StatAdmixOrder <- ggplot2::ggproto(
  "StatAdmixOrder", ggplot2::Stat,
  required_aes = c("sample_id", "cluster", "proportion"),
  default_aes = ggplot2::aes(
    x = ggplot2::after_stat(sample_order),
    y = ggplot2::after_stat(proportion),
    fill = ggplot2::after_stat(cluster)
  ),
  setup_params = function(data, params) {
    params$sort <- match.arg(params$sort %||% "none", c("none", "cluster", "all", "label"))
    params
  },
  compute_panel = function(data, scales, sort = "none", na.rm = FALSE) {
    samples <- unique(as.character(data$sample_id))
    clusters <- sort(unique(as.character(data$cluster)))
    if (sort == "label") {
      samples <- sort(samples)
    }
    if (sort %in% c("cluster", "all")) {
      wide <- stats::xtabs(proportion ~ sample_id + cluster, data)
      wide <- wide[samples, clusters, drop = FALSE]
      max_value <- apply(wide, 1, max)
      max_cluster <- apply(wide, 1, function(x) match(max(x), x))
      samples <- rownames(wide)[order(max_cluster, -max_value)]
    }
    data$sample_order <- match(as.character(data$sample_id), samples)
    data$sample_label <- factor(as.character(data$sample_id), levels = samples)
    data
  }
)

.geom_admix_layer <- function(data = NULL, ..., width = 1, na.rm = FALSE, show.legend = NA,
                              inherit.aes = FALSE) {
  ggplot2::geom_col(
    mapping = ggplot2::aes(x = .data$sample_label, y = .data$proportion, fill = .data$cluster),
    data = data,
    ...,
    width = width,
    position = "fill",
    na.rm = na.rm,
    show.legend = show.legend,
    inherit.aes = inherit.aes
  )
}

geom_admix <- function(mapping = NULL, data = NULL, ...,
                       sort = c("none", "cluster", "all", "label"), sortind = NULL,
                       k = "all", palette = NULL, group = "pop", pop_group = TRUE,
                       order_group = FALSE,
                       show_group_labels = NULL, subset_group = NULL,
                       bar_width = 1, show.legend = FALSE, show_sample_labels = FALSE,
                       indlabwithgrplab = FALSE, indlabsep = " ",
                       indlabsize = NULL, indlabangle = 90, indlabvjust = 0.5,
                       indlabhjust = 1, indlabcol = "grey30", indlabspacer = 0,
                       grplabsize = NULL, grplabcol = "grey30", grplabbgcol = NA,
                       show_y_axis = FALSE, show_ticks = FALSE, ticksize = 0.1,
                       ticklength = 0.03, base_size = 5, base_family = "",
                       legend_position = "top",
                       na.rm = FALSE, inherit.aes = TRUE) {
  if (!is.null(mapping)) {
    mapping <- NULL
  }
  if (!is.null(sortind)) {
    sort <- sortind
  } else {
    sort <- match.arg(sort)
  }
  if (isFALSE(pop_group)) {
    group <- NULL
    order_group <- FALSE
    show_group_labels <- FALSE
  }
  indlabsize <- indlabsize %||% base_size
  grplabsize <- grplabsize %||% (base_size + 2)
  layer_data <- .admix_layer_data(
    data,
    k = k,
    sort = sort,
    group = group,
    order_group = order_group,
    subset_group = subset_group,
    indlabwithgrplab = indlabwithgrplab,
    indlabsep = indlabsep
  )
  palette <- .admix_palette(layer_data, palette)
  group_available <- .admix_group_available(layer_data)
  if (is.null(show_group_labels)) {
    show_group_labels <- group_available || is.function(layer_data)
  }
  layers <- list(
    .geom_admix_layer(
      data = layer_data,
      ...,
      width = bar_width,
      na.rm = na.rm,
      show.legend = show.legend,
      inherit.aes = FALSE
    ),
    ggplot2::scale_y_continuous(expand = c(0, 0)),
    ggplot2::coord_cartesian(ylim = c(0, 1)),
    ggplot2::scale_fill_manual(values = palette, breaks = names(palette)),
    ggplot2::labs(x = NULL, y = NULL, fill = "Cluster"),
    ggplot2::theme_grey(base_size = base_size, base_family = base_family),
    ggplot2::theme(
      legend.position = if (show.legend) legend_position else "none",
      legend.direction = "horizontal",
      legend.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(size = indlabsize, colour = indlabcol, angle = indlabangle, vjust = indlabvjust, hjust = indlabhjust, margin = ggplot2::margin(t = indlabspacer)),
      axis.text.y = ggplot2::element_text(size = indlabsize, colour = indlabcol, margin = ggplot2::margin(r = indlabspacer)),
      axis.ticks = ggplot2::element_line(linewidth = ticksize, colour = indlabcol),
      axis.ticks.length = grid::unit(ticklength, "cm"),
      strip.background = ggplot2::element_rect(colour = NA, fill = NA),
      strip.text = ggplot2::element_text(colour = "grey30", face = "plain"),
      panel.spacing = grid::unit(0.1, "cm"),
      plot.margin = grid::unit(c(0.2, 0.05, 0.2, 0), "cm")
    ),
    .admix_facet(layer_data),
    if (!show_sample_labels) {
      ggplot2::theme(axis.text.x = ggplot2::element_blank(), axis.ticks.x = ggplot2::element_blank())
    },
    if (!show_y_axis) {
      ggplot2::theme(axis.text.y = ggplot2::element_blank(), axis.ticks.y = ggplot2::element_blank())
    },
    if (!show_ticks) {
      ggplot2::theme(axis.ticks = ggplot2::element_blank())
    },
    if (group_available || is.function(layer_data)) {
      ggplot2::theme(
        strip.background = ggplot2::element_rect(fill = grplabbgcol, colour = NA),
        strip.text = ggplot2::element_text(size = grplabsize, colour = grplabcol)
      )
    },
    if ((group_available || is.function(layer_data)) && !show_group_labels) {
      ggplot2::theme(strip.text.x = ggplot2::element_blank())
    }
  )
  Filter(Negate(is.null), layers)
}

geom_admix_pub <- function(mapping = ggplot2::aes(sample_id = .data$sample_id, cluster = .data$cluster, proportion = .data$proportion),
                           data = NULL, ..., sort = c("none", "cluster", "all", "label"),
                           k = "all", palette = NULL, pop_group = TRUE,
                           bar_width = 1, show.legend = FALSE,
                           show_sample_labels = FALSE, inherit.aes = TRUE) {
  geom_admix(
    mapping = mapping,
    data = data,
    ...,
    sort = sort,
    k = k,
    palette = palette,
    pop_group = pop_group,
    bar_width = bar_width,
    show.legend = show.legend,
    show_sample_labels = show_sample_labels,
    inherit.aes = inherit.aes
  )
}

.filter_admix_k <- function(data, k = "all") {
  if (is.null(data) || identical(k, "all")) {
    return(data)
  }
  if (!"k" %in% names(data)) {
    stop("Admixture data must contain `k` for K filtering.", call. = FALSE)
  }
  selected <- suppressWarnings(as.integer(k))
  if (any(is.na(selected))) {
    stop("`k` must be 'all' or integer K values.", call. = FALSE)
  }
  data[data$k %in% selected, , drop = FALSE]
}

.admix_layer_data <- function(data, k = "all", sort = "none", group = "pop",
                              order_group = FALSE, subset_group = NULL,
                              indlabwithgrplab = FALSE, indlabsep = " ") {
  if (is.null(data)) {
    force(k)
    force(sort)
    force(group)
    force(order_group)
    force(subset_group)
    force(indlabwithgrplab)
    force(indlabsep)
    return(function(plot_data) .prepare_admix_plot_data(
      plot_data, k = k, sort = sort, group = group, order_group = order_group,
      subset_group = subset_group, indlabwithgrplab = indlabwithgrplab,
      indlabsep = indlabsep
    ))
  }
  .prepare_admix_plot_data(
    data, k = k, sort = sort, group = group, order_group = order_group,
    subset_group = subset_group, indlabwithgrplab = indlabwithgrplab,
    indlabsep = indlabsep
  )
}

.admix_palette <- function(data = NULL, palette = NULL) {
  if (!is.null(palette)) {
    if (is.null(names(palette)) && !is.null(data) && "cluster" %in% names(data)) {
      names(palette) <- sort(unique(as.character(data$cluster)))
    }
    return(palette)
  }
  if (!is.null(data) && "cluster" %in% names(data)) {
    clusters <- sort(unique(as.character(data$cluster)))
    palette <- ggpop_palette(length(clusters), "admixture")
    names(palette) <- clusters
    return(palette)
  }
  base <- ggpop_palette(8, "admixture")
  palette <- rep(base, length.out = 64)
  names(palette) <- paste0("K", seq_along(palette))
  palette
}

.admix_should_facet <- function(data = NULL, k = "all") {
  if (!is.null(data) && "k" %in% names(data)) {
    return(length(unique(.filter_admix_k(data, k)$k)) > 1)
  }
  identical(k, "all") || length(k) > 1
}

.prepare_admix_plot_data <- function(data, k = "all", sort = "none", group = "pop",
                                     order_group = FALSE, subset_group = NULL,
                                     indlabwithgrplab = FALSE, indlabsep = " ") {
  data <- .filter_admix_k(data, k)
  if (nrow(data) == 0) {
    stop("No admixture rows remain after K filtering.", call. = FALSE)
  }
  if (!is.null(group) && group %in% names(data) && !is.null(subset_group)) {
    data <- data[data[[group]] %in% subset_group, , drop = FALSE]
  }
  runs <- split(data, data$run_id)
  out <- do.call(rbind, lapply(runs, .prepare_admix_run, sort = sort, group = group,
                               order_group = order_group, indlabwithgrplab = indlabwithgrplab,
                               indlabsep = indlabsep))
  rownames(out) <- NULL
  out
}

.prepare_admix_run <- function(data, sort = "none", group = "pop", order_group = FALSE,
                               indlabwithgrplab = FALSE, indlabsep = " ") {
  samples <- unique(as.character(data$sample_id))
  clusters <- sort(unique(as.character(data$cluster)))
  wide <- stats::xtabs(proportion ~ sample_id + cluster, data)
  wide <- wide[samples, clusters, drop = FALSE]
  group_values <- .admix_sample_groups(data, samples, group)
  order_index <- .admix_order(wide, samples, group_values, sort = sort, order_group = order_group)
  ordered_samples <- samples[order_index]
  ordered_group <- group_values[order_index]
  labels <- ordered_samples
  if (indlabwithgrplab && !is.null(ordered_group)) {
    labels <- paste(ordered_samples, ordered_group, sep = indlabsep)
  }
  data$sample_order <- match(as.character(data$sample_id), ordered_samples)
  data <- data[order(data$sample_order, match(as.character(data$cluster), clusters)), , drop = FALSE]
  data$sample_label <- factor(labels[data$sample_order], levels = labels)
  if (!is.null(group) && !is.null(ordered_group)) {
    data[[group]] <- factor(ordered_group[data$sample_order], levels = unique(ordered_group))
    data$.facet_group <- factor(ordered_group[data$sample_order], levels = unique(ordered_group))
  } else {
    data$.facet_group <- factor("", levels = "")
  }
  data$cluster <- factor(as.character(data$cluster), levels = clusters)
  data$run_id <- factor(as.character(data$run_id), levels = unique(as.character(data$run_id)))
  data
}

.admix_sample_groups <- function(data, samples, group = "pop") {
  if (is.null(group) || !group %in% names(data)) {
    return(NULL)
  }
  by_sample <- data[!duplicated(data$sample_id), c("sample_id", group), drop = FALSE]
  out <- as.character(by_sample[[group]][match(samples, by_sample$sample_id)])
  out[is.na(out)] <- "Ungrouped"
  out
}

.admix_order <- function(wide, samples, group_values = NULL, sort = "none", order_group = FALSE) {
  sort <- if (is.null(sort) || identical(sort, "none") || is.na(sort)) "none" else sort
  max_value <- apply(wide, 1, max)
  max_cluster <- apply(wide, 1, function(x) match(max(x), x))
  cluster_index <- .admix_sort_cluster_index(sort, colnames(wide))
  order_args <- list()
  if (!is.null(group_values) && order_group) {
    order_args <- c(order_args, list(group_values))
  }
  if (sort == "all" || sort == "cluster") {
    order_args <- c(order_args, list(max_cluster, -max_value))
  } else if (sort == "label") {
    order_args <- c(order_args, list(samples))
  } else if (!is.na(cluster_index)) {
    order_args <- c(order_args, list(wide[, cluster_index]))
  }
  if (length(order_args) == 0) {
    if (!is.null(group_values) && order_group) {
      return(order(group_values))
    }
    return(seq_along(samples))
  }
  do.call(order, order_args)
}

.admix_sort_cluster_index <- function(sort, clusters) {
  if (sort %in% c("none", "all", "cluster", "label")) {
    return(NA_integer_)
  }
  hit <- match(sort, clusters)
  if (is.na(hit)) {
    alt <- paste0("K", suppressWarnings(as.integer(gsub("[^0-9]", "", sort))))
    hit <- match(alt, clusters)
  }
  if (is.na(hit)) {
    stop("`sort` must be one of 'none', 'all', 'cluster', 'label', or a cluster name.", call. = FALSE)
  }
  hit
}

.admix_facet <- function(data = NULL) {
  if (is.function(data)) {
    return(ggplot2::facet_grid(run_id ~ .facet_group, scales = "free_x", space = "free_x", labeller = ggplot2::labeller(run_id = .admix_run_label)))
  }
  has_runs <- !is.null(data) && "run_id" %in% names(data) && length(unique(data$run_id)) > 1
  has_group <- .admix_group_available(data)
  if (has_runs || has_group) {
    return(ggplot2::facet_grid(run_id ~ .facet_group, scales = "free_x", space = "free_x", labeller = ggplot2::labeller(run_id = .admix_run_label)))
  }
  NULL
}

.admix_group_available <- function(data) {
  !is.null(data) && !is.function(data) && ".facet_group" %in% names(data) &&
    length(unique(as.character(data$.facet_group))) > 1
}

.admix_run_label <- function(run_id) {
  base <- sub("\\.(txt|csv|tsv|meanq|meanQ|structure)$", "", run_id)
  parsed_k <- .k_from_admix_file(run_id)
  ifelse(is.na(parsed_k), base, paste0(base, "\nK=", parsed_k))
}
