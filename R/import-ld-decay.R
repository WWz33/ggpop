import_ld_decay <- function(dir = NULL, ..., type = c("poplddecay", "plink", "auto"),
                            pop = NULL, pop_group = NULL, bin_size = 200) {
  type <- match.arg(type)
  files <- .ld_decay_collect_files(dir, ...)
  if (length(files) == 0) {
    stop("No LD decay files were provided or discovered.", call. = FALSE)
  }
  if (type == "auto") {
    type <- .guess_ld_decay_type(files)
  }
  data <- switch(
    type,
    poplddecay = .import_ld_decay_poplddecay(files, pop = pop),
    plink = .import_ld_decay_plink(files, pop = pop, bin_size = bin_size)
  )
  data <- .join_ld_decay_pop_group(data, pop_group)
  .new_ggpop_ld_decay(data, source = type)
}

.ld_decay_collect_files <- function(dir = NULL, ...) {
  explicit <- list(...)
  explicit <- explicit[!vapply(explicit, is.null, logical(1))]
  explicit_names <- names(explicit)
  explicit <- unlist(explicit, use.names = FALSE)
  files <- character()
  file_names <- character()
  if (!is.null(dir) && length(explicit) == 0) {
    if (!dir.exists(dir)) {
      stop("`dir` must point to an existing directory.", call. = FALSE)
    }
    discovered <- list.files(
      dir,
      pattern = "(\\.stat(\\.gz)?$|\\.ld(\\.gz)?$)",
      full.names = TRUE,
      recursive = TRUE,
      ignore.case = TRUE
    )
    files <- c(files, discovered)
    file_names <- c(file_names, rep("", length(discovered)))
  }
  if (length(explicit) > 0) {
    explicit <- ifelse(file.exists(explicit), explicit, file.path(dir %||% ".", explicit))
    files <- c(files, explicit)
    file_names <- c(file_names, explicit_names %||% rep("", length(explicit)))
  }
  keep <- file.exists(files)
  files <- files[keep]
  file_names <- file_names[keep]
  stats::setNames(files, file_names)
}

.guess_ld_decay_type <- function(files) {
  lower <- tolower(paste(basename(files), collapse = " "))
  if (grepl("\\.stat(\\.gz)?", lower)) {
    return("poplddecay")
  }
  if (grepl("\\.ld(\\.gz)?", lower)) {
    return("plink")
  }
  "poplddecay"
}

.import_ld_decay_poplddecay <- function(files, pop = NULL) {
  rows <- lapply(seq_along(files), function(index) {
    .import_ld_decay_poplddecay_file(files[[index]], pop = .ld_decay_pop_name(files, index, pop))
  })
  .stats_bind_rows(rows)
}

.import_ld_decay_poplddecay_file <- function(file, pop) {
  raw <- .read_table_auto(file, sep = "\t", comment.char = "", quote = "")
  names(raw) <- .ld_decay_standardize_names(names(raw))
  dist_col <- .ld_decay_required_column(raw, c("dist"), file, "distance")
  r2_col <- .ld_decay_required_column(raw, c("mean_r_2", "mean_r2", "r2"), file, "mean r2")
  n_col <- .first_existing(raw, c("numberpairs", "number_pairs", "n_pairs", "pairs"))
  data <- data.frame(
    dist = raw[[dist_col]],
    r2 = raw[[r2_col]],
    pop = pop,
    sample_id = pop,
    stringsAsFactors = FALSE
  )
  data$dist_kb <- as.numeric(data$dist) / 1000
  if (!is.null(n_col)) {
    data$n_pairs <- raw[[n_col]]
  }
  data$file <- basename(file)
  data[order(data$pop, as.numeric(data$dist)), , drop = FALSE]
}

.import_ld_decay_plink <- function(files, pop = NULL, bin_size = 200) {
  rows <- lapply(seq_along(files), function(index) {
    .import_ld_decay_plink_file(files[[index]], pop = .ld_decay_pop_name(files, index, pop), bin_size = bin_size)
  })
  .stats_bind_rows(rows)
}

.import_ld_decay_plink_file <- function(file, pop, bin_size = 200) {
  raw <- .read_table_auto(file)
  names(raw) <- .ld_decay_standardize_names(names(raw))
  bp_a_col <- .ld_decay_required_column(raw, c("bp_a", "bpa", "pos_a"), file, "first marker position")
  bp_b_col <- .ld_decay_required_column(raw, c("bp_b", "bpb", "pos_b"), file, "second marker position")
  r2_col <- .ld_decay_required_column(raw, c("r2"), file, "r2")
  dist <- abs(as.numeric(raw[[bp_b_col]]) - as.numeric(raw[[bp_a_col]]))
  r2 <- as.numeric(raw[[r2_col]])
  ok <- is.finite(dist) & is.finite(r2)
  dist <- dist[ok]
  r2 <- r2[ok]
  if (length(dist) == 0) {
    stop("No finite PLINK LD pairs were found in `", basename(file), "`.", call. = FALSE)
  }
  breaks <- seq(max(0, min(dist, na.rm = TRUE) - 1), max(dist, na.rm = TRUE) + bin_size, by = bin_size)
  dist_bin <- cut(dist, breaks = breaks, include.lowest = TRUE)
  means <- stats::aggregate(
    data.frame(dist = dist, r2 = r2),
    by = list(dist_bin = dist_bin),
    FUN = mean,
    na.rm = TRUE
  )
  counts <- stats::aggregate(r2 ~ dist_bin, data = data.frame(dist_bin = dist_bin, r2 = r2), FUN = length)
  data <- data.frame(
    dist = means$dist,
    dist_kb = means$dist / 1000,
    r2 = means$r2,
    n_pairs = counts$r2,
    pop = pop,
    sample_id = pop,
    file = basename(file),
    stringsAsFactors = FALSE
  )
  data[order(data$pop, data$dist), , drop = FALSE]
}

.join_ld_decay_pop_group <- function(data, pop_group = NULL) {
  if (is.null(pop_group)) {
    return(data)
  }
  group <- if (is.character(pop_group) && length(pop_group) == 1) {
    import_pop_group(pop_group)
  } else {
    .as_pop_group(pop_group)
  }
  matched <- match(as.character(data$sample_id), group$sample_id)
  has_match <- !is.na(matched)
  data$pop[has_match] <- group$pop[matched[has_match]]
  data
}

.ld_decay_standardize_names <- function(x) {
  gsub("^_+|_+$", "", .standardize_names(x))
}

.ld_decay_required_column <- function(raw, candidates, file, what) {
  column <- .first_existing(raw, candidates)
  if (is.null(column)) {
    stop(
      "Cannot find ", what, " column in LD decay file `", basename(file),
      "`. Tried: ", paste(candidates, collapse = ", "), ".",
      call. = FALSE
    )
  }
  column
}

.ld_decay_pop_name <- function(files, index, pop = NULL) {
  if (!is.null(pop)) {
    if (length(pop) == 1) {
      return(as.character(pop))
    }
    return(as.character(pop[[index]]))
  }
  file_name <- names(files)[[index]]
  if (!is.null(file_name) && nzchar(file_name)) {
    return(file_name)
  }
  parent <- basename(dirname(files[[index]]))
  if (nzchar(parent) && parent != ".") {
    return(parent)
  }
  tools::file_path_sans_ext(basename(files[[index]]))
}
