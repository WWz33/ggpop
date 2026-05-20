import_ld_decay <- function(dir = NULL, ..., type = c("poplddecay", "plink", "auto"),
                            pop = NULL, pop_group = NULL,
                            method = c("MeanBin", "none", "MedianBin", "PercentileBin"),
                            bin1 = 10, bin2 = 100, breakpoint = 100,
                            percent = 0.5, bin_size = NULL) {
  type <- match.arg(type)
  method <- match.arg(method)
  if (!is.null(bin_size)) {
    bin1 <- bin_size
    bin2 <- bin_size
    breakpoint <- Inf
    method <- "MeanBin"
  }
  files <- .ld_decay_collect_files(dir, ...)
  if (length(files) == 0) {
    stop("No LD decay files were provided or discovered.", call. = FALSE)
  }
  if (type == "auto") {
    type <- .guess_ld_decay_type(files)
  }
  data <- switch(
    type,
    poplddecay = .import_ld_decay_poplddecay(files, pop = pop, method = method, bin1 = bin1, bin2 = bin2, breakpoint = breakpoint, percent = percent),
    plink = .import_ld_decay_plink(files, pop = pop, method = method, bin1 = bin1, bin2 = bin2, breakpoint = breakpoint, percent = percent)
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
  base_dir <- if (!is.null(dir) && file.exists(dir) && !dir.exists(dir)) dirname(dir) else dir %||% "."
  if (!is.null(dir) && file.exists(dir) && !dir.exists(dir)) {
    files <- c(files, dir)
    file_names <- c(file_names, basename(dir))
  }
  if (!is.null(dir) && length(explicit) == 0) {
    if (!dir.exists(dir)) {
      if (file.exists(dir)) {
        return(stats::setNames(dir, basename(dir)))
      }
      stop("`dir` must point to an existing directory.", call. = FALSE)
    }
    discovered <- list.files(
      dir,
      pattern = "(\\.stat(\\.gz)?$|\\.bin(\\.gz)?$|\\.ld(\\.gz)?$)",
      full.names = TRUE,
      recursive = TRUE,
      ignore.case = TRUE
    )
    bin_files <- grepl("\\.bin(\\.gz)?$", discovered, ignore.case = TRUE)
    stat_files <- grepl("\\.stat(\\.gz)?$", discovered, ignore.case = TRUE)
    if (any(bin_files)) {
      discovered <- discovered[bin_files]
    } else if (any(stat_files)) {
      discovered <- discovered[stat_files]
    }
    files <- c(files, discovered)
    file_names <- c(file_names, rep("", length(discovered)))
  }
  if (length(explicit) > 0) {
    explicit <- ifelse(file.exists(explicit), explicit, file.path(base_dir, explicit))
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

.import_ld_decay_poplddecay <- function(files, pop = NULL, method = "MeanBin", bin1 = 10, bin2 = 100, breakpoint = 100, percent = 0.5) {
  rows <- lapply(seq_along(files), function(index) {
    .import_ld_decay_poplddecay_file(files[[index]], pop = .ld_decay_pop_name(files, index, pop),
                                     method = method, bin1 = bin1, bin2 = bin2, breakpoint = breakpoint, percent = percent)
  })
  .stats_bind_rows(rows)
}

.import_ld_decay_poplddecay_file <- function(file, pop, method = "MeanBin", bin1 = 10, bin2 = 100, breakpoint = 100, percent = 0.5) {
  raw <- .read_table_auto(file, sep = "\t", comment.char = "", quote = "")
  names(raw) <- .ld_decay_standardize_names(names(raw))
  dist_col <- .ld_decay_required_column(raw, c("dist"), file, "distance")
  r2_col <- .ld_decay_required_column(raw, c("mean_r_2", "mean_r2", "r2"), file, "mean r2")
  d_col <- .first_existing(raw, c("mean_d", "mean_d_", "d", "d_prime"))
  sum_r2_col <- .first_existing(raw, c("sum_r_2", "sum_r2"))
  sum_d_col <- .first_existing(raw, c("sum_d", "sum_d_"))
  n_col <- .first_existing(raw, c("numberpairs", "number_pairs", "n_pairs", "pairs"))
  data <- data.frame(
    dist = suppressWarnings(as.numeric(raw[[dist_col]])),
    r2 = suppressWarnings(as.numeric(raw[[r2_col]])),
    pop = pop,
    sample_id = pop,
    stringsAsFactors = FALSE
  )
  data$dist_kb <- as.numeric(data$dist) / 1000
  if (!is.null(n_col)) {
    data$n_pairs <- suppressWarnings(as.numeric(raw[[n_col]]))
  }
  if (!is.null(d_col)) {
    data$d_prime <- suppressWarnings(as.numeric(raw[[d_col]]))
  }
  if (!is.null(sum_r2_col)) {
    data$sum_r2 <- suppressWarnings(as.numeric(raw[[sum_r2_col]]))
  }
  if (!is.null(sum_d_col)) {
    data$sum_d_prime <- suppressWarnings(as.numeric(raw[[sum_d_col]]))
  }
  data$file <- basename(file)
  data <- data[order(data$pop, as.numeric(data$dist)), , drop = FALSE]
  .ld_decay_apply_method(data, method = method, bin1 = bin1, bin2 = bin2, breakpoint = breakpoint, percent = percent)
}

.import_ld_decay_plink <- function(files, pop = NULL, method = "MeanBin", bin1 = 200, bin2 = 200, breakpoint = Inf, percent = 0.5) {
  rows <- lapply(seq_along(files), function(index) {
    .import_ld_decay_plink_file(files[[index]], pop = .ld_decay_pop_name(files, index, pop),
                                method = method, bin1 = bin1, bin2 = bin2, breakpoint = breakpoint, percent = percent)
  })
  .stats_bind_rows(rows)
}

.import_ld_decay_plink_file <- function(file, pop, method = "MeanBin", bin1 = 200, bin2 = 200, breakpoint = Inf, percent = 0.5) {
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
  data <- data.frame(
    dist = dist,
    dist_kb = dist / 1000,
    r2 = r2,
    n_pairs = 1,
    pop = pop,
    sample_id = pop,
    file = basename(file),
    stringsAsFactors = FALSE
  )
  .ld_decay_apply_method(data, method = if (method == "none") "MeanBin" else method, bin1 = bin1, bin2 = bin2, breakpoint = breakpoint, percent = percent)
}

.ld_decay_apply_method <- function(data, method = "none", bin1 = 10, bin2 = 100, breakpoint = 100, percent = 0.5) {
  if (method == "none") {
    data$ld_method <- "none"
    return(data)
  }
  data$dist <- as.numeric(data$dist)
  if (!is.finite(bin1) || !is.finite(bin2) || bin1 <= 0 || bin2 <= 0) {
    stop("`bin1` and `bin2` must be positive finite numbers.", call. = FALSE)
  }
  bin_width <- ifelse(data$dist < breakpoint, bin1, bin2)
  data$.bin <- floor((data$dist - 0.1) / bin_width)
  data$.bin_width <- bin_width
  data$.bin_dist <- ifelse(data$dist < breakpoint, (data$.bin + 1) * bin1, (data$.bin + 1) * bin2)
  groups <- split(data, interaction(data$pop, data$file, data$.bin_width, data$.bin, drop = TRUE, sep = "\r"))
  rows <- lapply(groups, function(group) {
    if (method == "MeanBin") {
      .ld_decay_mean_bin(group)
    } else {
      .ld_decay_percentile_bin(group, percent = if (method == "MedianBin") 0.5 else percent, method = method)
    }
  })
  out <- .stats_bind_rows(rows)
  out$ld_method <- method
  out[order(out$pop, out$dist), setdiff(names(out), c(".bin", ".bin_width", ".bin_dist")), drop = FALSE]
}

.ld_decay_mean_bin <- function(group) {
  n <- suppressWarnings(as.numeric(group$n_pairs))
  if (all(!is.finite(n))) n <- rep(1, nrow(group))
  n[!is.finite(n)] <- 0
  sum_r2 <- if ("sum_r2" %in% names(group) && any(is.finite(group$sum_r2))) {
    sum(group$sum_r2, na.rm = TRUE)
  } else {
    sum(as.numeric(group$r2) * n, na.rm = TRUE)
  }
  n_r2 <- sum(n, na.rm = TRUE)
  if (!is.finite(n_r2) || n_r2 <= 0) {
    n_r2 <- sum(is.finite(group$r2))
    n <- rep(1, nrow(group))
  }
  has_d <- "d_prime" %in% names(group) && any(is.finite(group$d_prime))
  n_d <- if (has_d) {
    d_weight <- n
    d_weight[!is.finite(group$d_prime)] <- 0
    d_weight
  } else {
    numeric()
  }
  sum_d <- if ("sum_d_prime" %in% names(group) && any(is.finite(group$sum_d_prime))) {
    sum(group$sum_d_prime, na.rm = TRUE)
  } else if (has_d) {
    sum(as.numeric(group$d_prime) * n_d, na.rm = TRUE)
  } else {
    NA_real_
  }
  n_d_total <- sum(n_d, na.rm = TRUE)
  data.frame(
    dist = unique(group$.bin_dist)[1],
    dist_kb = unique(group$.bin_dist)[1] / 1000,
    r2 = sum_r2 / n_r2,
    d_prime = if (is.finite(sum_d) && n_d_total > 0) sum_d / n_d_total else NA_real_,
    sum_r2 = sum_r2,
    sum_d_prime = sum_d,
    n_pairs = n_r2,
    pop = unique(group$pop)[1],
    sample_id = unique(group$sample_id)[1],
    file = unique(group$file)[1],
    stringsAsFactors = FALSE
  )
}

.ld_decay_percentile_bin <- function(group, percent = 0.5, method = "PercentileBin") {
  percent <- max(min(percent, 1), 0)
  n <- suppressWarnings(as.numeric(group$n_pairs))
  if (all(!is.finite(n))) n <- rep(1, nrow(group))
  n[!is.finite(n)] <- 0
  data.frame(
    dist = unique(group$.bin_dist)[1],
    dist_kb = unique(group$.bin_dist)[1] / 1000,
    r2 = .ld_decay_weighted_quantile(group$r2, n, percent),
    d_prime = if ("d_prime" %in% names(group)) .ld_decay_weighted_quantile(group$d_prime, n, percent) else NA_real_,
    n_pairs = sum(n, na.rm = TRUE),
    pop = unique(group$pop)[1],
    sample_id = unique(group$sample_id)[1],
    file = unique(group$file)[1],
    stringsAsFactors = FALSE
  )
}

.ld_decay_weighted_quantile <- function(x, w, percent) {
  x <- suppressWarnings(as.numeric(x))
  w <- suppressWarnings(as.numeric(w))
  ok <- is.finite(x) & is.finite(w) & w > 0
  if (!any(ok)) return(NA_real_)
  x <- x[ok]
  w <- w[ok]
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  x[which(cumsum(w) >= sum(w) * percent)[1]]
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
  data$.pop_grouped <- has_match
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
  same_parent <- dirname(files) == dirname(files[[index]])
  if (sum(same_parent) > 1) {
    return(.ld_decay_file_stem(files[[index]]))
  }
  if (nzchar(parent) && parent != ".") {
    return(parent)
  }
  .ld_decay_file_stem(files[[index]])
}

.ld_decay_file_stem <- function(file) {
  stem <- basename(file)
  stem <- sub("\\.gz$", "", stem, ignore.case = TRUE)
  sub("\\.[^.]+$", "", stem)
}
