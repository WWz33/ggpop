.ne_history_should_map_colour <- function(data, mapping, colour_by) {
  is.null(mapping$colour) && is.null(mapping$color) &&
    (is.function(data) || (!is.null(data) && colour_by %in% names(data)))
}

.add_ne_history_colour_mapping <- function(mapping, colour_by) {
  values <- as.list(mapping)
  values$colour <- rlang::expr(.data[[colour_by]])
  do.call(ggplot2::aes, values)
}

.add_ne_history_group_mapping <- function(mapping) {
  values <- as.list(mapping)
  values$group <- rlang::expr(.data[[".group"]])
  do.call(ggplot2::aes, values)
}

.ne_history_colour_count <- function(data, colour_by) {
  if (is.function(data)) return(8)
  if (is.null(data) || !colour_by %in% names(data)) return(0)
  max(length(unique(data[[colour_by]])), 1)
}
