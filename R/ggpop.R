ggpop <- function(data, mapping = ggplot2::aes(), ..., module = NULL) {
  UseMethod("ggpop")
}

ggpop.ggpop_gwas <- function(data, mapping = ggplot2::aes(), ..., module = NULL) {
  ggplot2::ggplot(data = data, mapping = mapping)
}

ggpop.ggpop_pca <- function(data, mapping = ggplot2::aes(), ..., module = NULL, pop_group = TRUE) {
  if (isTRUE(pop_group) && "pop" %in% names(data) && is.null(mapping$colour) && is.null(mapping$color)) {
    mapping$colour <- rlang::expr(.data$pop)
  }
  ggplot2::ggplot(data = data, mapping = mapping)
}

ggpop.ggpop_admix <- function(data, mapping = ggplot2::aes(), ..., module = NULL) {
  ggplot2::ggplot(data = data, mapping = mapping)
}
