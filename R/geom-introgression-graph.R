.introgression_graph_layers <- function(data, dots, base_size, base_family, palette, na.rm, show.legend) {
  layout <- .introgression_graph_layout(data)
  tree_edges <- layout$edges[layout$edges$stat != "migration", , drop = FALSE]
  migration_edges <- layout$edges[layout$edges$stat == "migration", , drop = FALSE]
  labelled_nodes <- layout$nodes[layout$nodes$is_tip, , drop = FALSE]
  treemix_layout <- "layout" %in% names(layout$edges) && any(layout$edges$layout == "treemix", na.rm = TRUE)
  if (treemix_layout) {
    x_range <- diff(range(c(layout$edges$x, layout$edges$xend), na.rm = TRUE))
    label_nudge_x <- max(x_range * 0.06, 0.002, na.rm = TRUE)
    label_nudge_y <- 0.045
    migration_edges <- .introgression_graph_shorten_edges(migration_edges, x_range * 0.018)
    labelled_nodes <- .introgression_graph_label_nodes(labelled_nodes, migration_edges, label_nudge_x, label_nudge_y)
  } else {
    label_nudge_x <- 0
    label_nudge_y <- 0.14
  }
  tree_args <- c(list(linewidth = 0.45, alpha = 0.85, na.rm = na.rm, show.legend = FALSE), dots)
  migration_args <- c(list(linewidth = 0.65, alpha = 0.9, na.rm = na.rm, show.legend = FALSE), dots)
  list(
    if (nrow(tree_edges) > 0) do.call(
      ggplot2::geom_segment,
      c(list(
        mapping = ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend),
        data = tree_edges,
        colour = "grey35",
        inherit.aes = FALSE
      ), tree_args)
    ),
    if (nrow(migration_edges) > 0) do.call(
      ggplot2::geom_curve,
      c(list(
        mapping = ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend),
        data = migration_edges,
        colour = "#B6403A",
        curvature = 0.25,
        arrow = grid::arrow(length = grid::unit(5, "pt"), type = "closed"),
        inherit.aes = FALSE
      ), migration_args)
    ),
    ggplot2::geom_point(
      mapping = ggplot2::aes(x = .data$x, y = .data$y),
      data = layout$nodes,
      size = 2.1,
      shape = 21,
      fill = "white",
      colour = "grey20",
      stroke = 0.45,
      inherit.aes = FALSE
    ),
    if (treemix_layout) {
      ggplot2::geom_label(
        mapping = ggplot2::aes(
          x = .data$.label_x,
          y = .data$.label_y,
          label = .data$.label,
          hjust = .data$.label_hjust
        ),
        data = labelled_nodes,
        size = base_size / 4.2,
        fill = "white",
        colour = "grey10",
        linewidth = 0,
        label.padding = grid::unit(0.05, "lines"),
        inherit.aes = FALSE
      )
    } else {
      ggplot2::geom_text(
        mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$.label),
        data = labelled_nodes,
        nudge_y = label_nudge_y,
        hjust = 0.5,
        size = base_size / 4.2,
        inherit.aes = FALSE
      )
    },
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0.08, 0.14))),
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = if (treemix_layout) c(0.08, 0.12) else c(0.05, 0.05))),
    ggplot2::labs(x = if (treemix_layout) "Drift parameter" else NULL, y = NULL),
    .introgression_publication_theme(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        axis.text.y = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank(),
        axis.line.y = ggplot2::element_blank(),
        axis.text.x = if (treemix_layout) ggplot2::element_text() else ggplot2::element_blank(),
        axis.ticks.x = if (treemix_layout) ggplot2::element_line(linewidth = 0.25) else ggplot2::element_blank(),
        axis.line.x = if (treemix_layout) ggplot2::element_line(linewidth = 0.25) else ggplot2::element_blank(),
        axis.title.x = if (treemix_layout) ggplot2::element_text(margin = ggplot2::margin(t = 5)) else ggplot2::element_blank(),
        panel.grid = ggplot2::element_blank(),
        legend.position = "none",
        plot.margin = ggplot2::margin(10, 14, 10, 14)
      )
  )
}

.introgression_graph_layout <- function(data) {
  edges <- data[!is.na(data$from) & !is.na(data$to), , drop = FALSE]
  if (all(c("x", "y", "xend", "yend") %in% names(edges)) &&
      all(stats::complete.cases(edges[, c("x", "y", "xend", "yend"), drop = FALSE]))) {
    node_data <- .introgression_graph_nodes_from_edges(edges)
    return(list(nodes = node_data, edges = edges))
  }
  nodes <- unique(c(as.character(edges$from), as.character(edges$to)))
  node_data <- data.frame(node = nodes, x = 0, y = seq_along(nodes), stringsAsFactors = FALSE)
  node_data$is_tip <- !node_data$node %in% as.character(edges$from)
  node_data$.label <- .introgression_pretty_label(node_data$node)
  roots <- setdiff(as.character(edges$from), as.character(edges$to))
  node_data$x[node_data$node %in% roots] <- 0
  for (i in seq_len(length(nodes) + 1)) {
    for (row in seq_len(nrow(edges))) {
      from_x <- node_data$x[match(edges$from[row], node_data$node)]
      to_idx <- match(edges$to[row], node_data$node)
      node_data$x[to_idx] <- max(node_data$x[to_idx], from_x + 1, na.rm = TRUE)
    }
  }
  node_data$y <- ave(node_data$y, node_data$x, FUN = seq_along)
  edges$x <- node_data$x[match(edges$from, node_data$node)]
  edges$y <- node_data$y[match(edges$from, node_data$node)]
  edges$xend <- node_data$x[match(edges$to, node_data$node)]
  edges$yend <- node_data$y[match(edges$to, node_data$node)]
  list(nodes = node_data, edges = edges)
}

.introgression_graph_nodes_from_edges <- function(edges) {
  from_nodes <- data.frame(
    node = as.character(edges$from),
    x = edges$x,
    y = edges$y,
    stringsAsFactors = FALSE
  )
  to_nodes <- data.frame(
    node = as.character(edges$to),
    x = edges$xend,
    y = edges$yend,
    stringsAsFactors = FALSE
  )
  nodes <- rbind(from_nodes, to_nodes)
  nodes <- stats::aggregate(cbind(x, y) ~ node, data = nodes, FUN = mean)
  nodes$is_tip <- !nodes$node %in% as.character(edges$from)
  nodes$.label <- .introgression_pretty_label(nodes$node)
  nodes
}

.introgression_graph_shorten_edges <- function(edges, amount) {
  if (nrow(edges) == 0 || !is.finite(amount) || amount <= 0) {
    return(edges)
  }
  dx <- edges$xend - edges$x
  dy <- edges$yend - edges$y
  distance <- sqrt(dx^2 + dy^2)
  keep <- is.finite(distance) & distance > 0
  step <- pmin(amount, distance / 4)
  edges$x[keep] <- edges$x[keep] + dx[keep] / distance[keep] * step[keep]
  edges$y[keep] <- edges$y[keep] + dy[keep] / distance[keep] * step[keep]
  edges$xend[keep] <- edges$xend[keep] - dx[keep] / distance[keep] * step[keep]
  edges$yend[keep] <- edges$yend[keep] - dy[keep] / distance[keep] * step[keep]
  edges
}

.introgression_graph_label_nodes <- function(nodes, migration_edges, nudge_x, nudge_y) {
  nodes$.label_x <- nodes$x + nudge_x
  nodes$.label_y <- nodes$y
  nodes$.label_hjust <- 0
  if (nrow(nodes) == 0 || nrow(migration_edges) == 0) {
    return(nodes)
  }
  migration_targets <- as.character(migration_edges$to)
  left_cutoff <- stats::median(nodes$x, na.rm = TRUE)
  left_target <- nodes$node %in% migration_targets & nodes$x <= left_cutoff
  nodes$.label_x[left_target] <- nodes$x[left_target] - nudge_x
  nodes$.label_y[left_target] <- nodes$y[left_target] + nudge_y
  nodes$.label_hjust[left_target] <- 1
  nodes
}
