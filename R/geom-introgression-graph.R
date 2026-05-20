.introgression_graph_layers <- function(data, dots, base_size, base_family, palette, na.rm, show.legend) {
  layout <- .introgression_graph_layout(data)
  edge_args <- c(list(linewidth = 0.6, alpha = 0.85, na.rm = na.rm, show.legend = show.legend), dots)
  list(
    do.call(
      ggplot2::geom_segment,
      c(list(
        mapping = ggplot2::aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend, colour = .data$stat),
        data = layout$edges,
        inherit.aes = FALSE
      ), edge_args)
    ),
    ggplot2::geom_point(
      mapping = ggplot2::aes(x = .data$x, y = .data$y),
      data = layout$nodes,
      size = 2.4,
      inherit.aes = FALSE
    ),
    ggplot2::geom_text(
      mapping = ggplot2::aes(x = .data$x, y = .data$y, label = .data$node),
      data = layout$nodes,
      nudge_y = 0.12,
      size = base_size / 4,
      inherit.aes = FALSE
    ),
    scale_colour_ggpop(max(length(unique(layout$edges$stat)), 1), palette, guide = "none"),
    ggplot2::labs(x = NULL, y = NULL, colour = "stat"),
    .theme_tidyplot(base_size = base_size, base_family = base_family) +
      ggplot2::theme(
        axis.text = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        axis.line = ggplot2::element_blank(),
        legend.position = "none"
      )
  )
}

.introgression_graph_layout <- function(data) {
  edges <- data[!is.na(data$from) & !is.na(data$to), , drop = FALSE]
  nodes <- unique(c(as.character(edges$from), as.character(edges$to)))
  node_data <- data.frame(node = nodes, x = 0, y = seq_along(nodes), stringsAsFactors = FALSE)
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
