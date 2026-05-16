import_pop_group <- function(file, sample_col = "sample", pop_col = "pop", ...) {
  group <- .read_table_auto(file, header = TRUE, ...)
  if (!all(c(sample_col, pop_col) %in% names(group))) {
    stop("Population group file must contain `sample` and `pop` columns by default.", call. = FALSE)
  }
  out <- data.frame(
    sample_id = as.character(group[[sample_col]]),
    pop = as.character(group[[pop_col]]),
    stringsAsFactors = FALSE
  )
  if (anyDuplicated(out$sample_id)) {
    stop("Population group file contains duplicated samples.", call. = FALSE)
  }
  out
}

.join_pop_group <- function(data, pop_group = NULL) {
  if (is.null(pop_group)) {
    return(data)
  }
  group <- if (is.character(pop_group) && length(pop_group) == 1) {
    import_pop_group(pop_group)
  } else {
    .as_pop_group(pop_group)
  }
  matched <- match(as.character(data$sample_id), group$sample_id)
  data$pop <- group$pop[matched]
  data
}

.as_pop_group <- function(pop_group) {
  if (!is.data.frame(pop_group)) {
    stop("`pop_group` must be a file path or data frame.", call. = FALSE)
  }
  if (all(c("sample_id", "pop") %in% names(pop_group))) {
    return(data.frame(
      sample_id = as.character(pop_group$sample_id),
      pop = as.character(pop_group$pop),
      stringsAsFactors = FALSE
    ))
  }
  if (all(c("sample", "pop") %in% names(pop_group))) {
    return(data.frame(
      sample_id = as.character(pop_group$sample),
      pop = as.character(pop_group$pop),
      stringsAsFactors = FALSE
    ))
  }
  stop("`pop_group` must contain `sample pop` or `sample_id pop` columns.", call. = FALSE)
}
