import_introgression <- function(dir = NULL, ..., type = c(
                                   "auto", "dsuite_dtrios", "dsuite_dinvestigate", "fixed_diff",
                                   "genomics_general", "admixtools", "treemix", "qpgraph"
                                 )) {
  type <- match.arg(type)
  files <- .introgression_collect_files(dir, ...)
  if (length(files) == 0) {
    stop("No introgression files were provided or discovered.", call. = FALSE)
  }
  if (type == "auto") {
    type <- .guess_introgression_type(files)
  }
  files_for_type <- .introgression_files_for_type(files, type)
  if (length(files_for_type) > 0) {
    files <- files_for_type
  }
  data <- switch(
    type,
    dsuite_dtrios = .import_introgression_dsuite_dtrios(files),
    dsuite_dinvestigate = .import_introgression_dsuite_dinvestigate(files),
    fixed_diff = .import_introgression_fixed_diff(files),
    genomics_general = .import_introgression_genomics_general(files),
    admixtools = .import_introgression_admixtools(files),
    treemix = .import_introgression_treemix(files),
    qpgraph = .import_introgression_graph(files, source = "qpgraph")
  )
  .new_ggpop_introgression(data, source = type)
}

.introgression_collect_files <- function(dir = NULL, ...) {
  explicit <- list(...)
  explicit <- explicit[!vapply(explicit, is.null, logical(1))]
  explicit <- unlist(explicit, use.names = TRUE)
  files <- character()
  if (!is.null(dir)) {
    if (file.exists(dir) && !dir.exists(dir)) {
      files <- c(files, dir)
    } else if (!dir.exists(dir)) {
      stop("`dir` must point to an existing directory.", call. = FALSE)
    } else {
      discovered <- list.files(
        dir,
        pattern = "(\\.tsv$|\\.txt$|\\.csv$|\\.edges(\\.gz)?$|\\.treeout(\\.gz)?$)",
        full.names = TRUE,
        recursive = TRUE,
        ignore.case = TRUE
      )
      files <- c(files, discovered)
    }
  }
  if (length(explicit) > 0) {
    explicit <- ifelse(file.exists(explicit), explicit, file.path(dir %||% ".", explicit))
    files <- c(files, explicit)
  }
  files <- unique(files[file.exists(files)])
  stats::setNames(files, names(files) %||% basename(files))
}

.introgression_files_for_type <- function(files, type) {
  lower <- tolower(basename(files))
  keep <- switch(
    type,
    dsuite_dtrios = grepl("dtrios|dmin|bbaa|global_dstat|_tree", lower),
    dsuite_dinvestigate = grepl("localfstats|dinvestigate|d_fd_fdm_df", lower),
    fixed_diff = grepl("fixed|fixeddiff|fixed_differences", lower),
    genomics_general = grepl("abbababa|fourpop|genomics", lower),
    admixtools = grepl("qpdstat|f4ratio|f3_result|admixtools", lower),
    treemix = grepl("treemix|\\.edges(\\.gz)?$|\\.treeout(\\.gz)?$", lower),
    qpgraph = grepl("qpgraph", lower),
    rep(TRUE, length(files))
  )
  files[keep]
}

.guess_introgression_type <- function(files) {
  lower <- tolower(paste(basename(files), collapse = " "))
  if (grepl("dtrios|dmin|_tree", lower)) return("dsuite_dtrios")
  if (grepl("localfstats|dinvestigate", lower)) return("dsuite_dinvestigate")
  if (grepl("fixed|fixeddiff|fixed_differences", lower)) return("fixed_diff")
  if (grepl("abbababa|fourpop|genomics", lower)) return("genomics_general")
  if (grepl("qpdstat|f4ratio|f3_result|admixtools", lower)) return("admixtools")
  if (grepl("treemix|\\.edges|\\.treeout", lower)) return("treemix")
  if (grepl("qpgraph|admixtools", lower)) return("qpgraph")
  "genomics_general"
}

.import_introgression_dsuite_dtrios <- function(files) {
  .stats_bind_rows(lapply(files, .import_introgression_dsuite_dtrios_file))
}

.import_introgression_dsuite_dtrios_file <- function(file) {
  raw <- .introgression_read_table(file)
  names(raw) <- .standardize_names(names(raw))
  pop1_col <- .introgression_required_column(raw, c("p1", "pop1"), file, "P1")
  pop2_col <- .introgression_required_column(raw, c("p2", "pop2"), file, "P2")
  pop3_col <- .introgression_required_column(raw, c("p3", "pop3"), file, "P3")
  value_col <- .introgression_required_column(raw, c("dstatistic", "d_statistic", "d"), file, "D statistic")
  data <- data.frame(
    analysis = "trio",
    stat = "D",
    pop1 = raw[[pop1_col]],
    pop2 = raw[[pop2_col]],
    pop3 = raw[[pop3_col]],
    value = raw[[value_col]],
    stringsAsFactors = FALSE
  )
  data$trio <- paste(data$pop1, data$pop2, data$pop3, sep = " / ")
  for (column in c(
    "z_score", "zscore", "p_value", "pvalue", "f4_ratio", "f4ratio",
    "bbaa", "baba", "abba"
  )) {
    if (column %in% names(raw)) {
      data[[column]] <- raw[[column]]
    }
  }
  data$file <- basename(file)
  data
}

.import_introgression_fixed_diff <- function(files) {
  .stats_bind_rows(lapply(files, .import_introgression_fixed_diff_file))
}

.import_introgression_fixed_diff_file <- function(file) {
  raw <- .introgression_read_table(file)
  names(raw) <- .standardize_names(names(raw))
  pop1_col <- .introgression_required_column(raw, c("p1", "pop1", "species1", "spp1"), file, "population 1")
  pop2_col <- .introgression_required_column(raw, c("p2", "pop2", "species2", "spp2"), file, "population 2")
  pop3_col <- .first_existing(raw, c("p3", "pop3", "species3", "spp3"))
  value_col <- .first_existing(raw, c("proportion", "prop_fixed", "value", "fixed_prop", "fraction"))
  if (is.null(value_col)) {
    if (all(c("n_fixed", "n_total") %in% names(raw))) {
      value <- as.numeric(raw[["n_fixed"]]) / as.numeric(raw[["n_total"]])
    } else {
      stop("Cannot find fixed-diff value column in `", basename(file), "`.", call. = FALSE)
    }
  } else {
    value <- raw[[value_col]]
  }
  data <- data.frame(
    analysis = "trio",
    stat = "fixed_diff",
    pop1 = raw[[pop1_col]],
    pop2 = raw[[pop2_col]],
    value = value,
    stringsAsFactors = FALSE
  )
  if (!is.null(pop3_col)) {
    data$pop3 <- raw[[pop3_col]]
  }
  if ("n_fixed" %in% names(raw)) {
    data$n_fixed <- raw[["n_fixed"]]
  }
  if ("n_total" %in% names(raw)) {
    data$n_total <- raw[["n_total"]]
  }
  if ("pop3" %in% names(data) && any(!is.na(data$pop3))) {
    data$trio <- paste(data$pop1, data$pop2, data$pop3, sep = " / ")
  } else {
    data$trio <- paste(data$pop1, data$pop2, sep = " / ")
  }
  data$file <- basename(file)
  data$format <- "fixed_diff"
  data
}

.import_introgression_dsuite_dinvestigate <- function(files) {
  .stats_bind_rows(lapply(files, .import_introgression_dsuite_dinvestigate_file))
}

.import_introgression_dsuite_dinvestigate_file <- function(file) {
  raw <- .introgression_read_table(file)
  names(raw) <- .standardize_names(names(raw))
  chr_col <- .introgression_required_column(raw, c("chromosome", "chrom", "chr", "scaffold"), file, "chromosome")
  start_col <- .introgression_required_column(raw, c("window_start", "windowstart", "start"), file, "window start")
  end_col <- .introgression_required_column(raw, c("window_end", "windowend", "end"), file, "window end")
  stat_cols <- intersect(c("d", "dstatistic", "f_d", "fd", "f_dm", "fdm", "d_f", "df"), names(raw))
  if (length(stat_cols) == 0) {
    stop("Cannot find Dsuite local window statistics in `", basename(file), "`.", call. = FALSE)
  }
  .introgression_window_long(raw, stat_cols, chr_col, start_col, end_col, file, source = "dsuite")
}

.import_introgression_genomics_general <- function(files) {
  .stats_bind_rows(lapply(files, .import_introgression_genomics_general_file))
}

.import_introgression_genomics_general_file <- function(file) {
  raw <- .introgression_read_table(file, sep = .introgression_sep(file))
  names(raw) <- .standardize_names(names(raw))
  chr_col <- .introgression_required_column(raw, c("scaffold", "chromosome", "chrom", "chr"), file, "scaffold")
  start_col <- .introgression_required_column(raw, c("start", "window_start"), file, "window start")
  end_col <- .introgression_required_column(raw, c("end", "window_end"), file, "window end")
  stat_cols <- intersect(c("d", "fd", "fdm", "fd_", "fdm_", "fdh", "fdh2", "fh"), names(raw))
  if (length(stat_cols) == 0) {
    stop("Cannot find genomics_general introgression statistics in `", basename(file), "`.", call. = FALSE)
  }
  .introgression_window_long(raw, stat_cols, chr_col, start_col, end_col, file, source = "genomics_general")
}

.introgression_window_long <- function(raw, stat_cols, chr_col, start_col, end_col, file, source) {
  rows <- lapply(stat_cols, function(stat_col) {
    data <- data.frame(
      analysis = "window",
      stat = .introgression_stat_label(stat_col),
      chr = raw[[chr_col]],
      start = raw[[start_col]],
      end = raw[[end_col]],
      value = raw[[stat_col]],
      stringsAsFactors = FALSE
    )
    data$pos <- (as.numeric(data$start) + as.numeric(data$end)) / 2
    for (column in intersect(c("pop1", "pop2", "pop3", "sites", "sitesused", "abba", "baba", "abaa", "baaa"), names(raw))) {
      data[[column]] <- raw[[column]]
    }
    data$file <- basename(file)
    data$format <- source
    data
  })
  .stats_bind_rows(rows)
}

.import_introgression_graph <- function(files, source) {
  .stats_bind_rows(lapply(files, function(file) .import_introgression_graph_file(file, source = source)))
}

.import_introgression_admixtools <- function(files) {
  .stats_bind_rows(lapply(files, .import_introgression_admixtools_file))
}

.import_introgression_admixtools_file <- function(file) {
  raw <- .introgression_read_table(file, sep = .introgression_sep(file))
  names(raw) <- .standardize_names(names(raw))
  lower <- tolower(basename(file))
  if (grepl("f4ratio", lower) || "alpha" %in% names(raw)) {
    return(.introgression_admixtools_f4ratio(raw, file))
  }
  if (grepl("qpdstat|dstat", lower) || all(c("pop1", "pop2", "pop3", "pop4", "est") %in% names(raw))) {
    return(.introgression_admixtools_qpdstat(raw, file))
  }
  if (grepl("f3", lower) || all(c("pop1", "pop2", "pop3", "est") %in% names(raw))) {
    return(.introgression_admixtools_f3(raw, file))
  }
  stop("Cannot recognize ADMIXTOOLS statistic table `", basename(file), "`.", call. = FALSE)
}

.introgression_admixtools_qpdstat <- function(raw, file) {
  .require_columns(raw, c("pop1", "pop2", "pop3", "pop4", "est"), basename(file))
  data <- data.frame(
    analysis = "trio",
    stat = "D",
    pop1 = raw$pop1,
    pop2 = raw$pop2,
    pop3 = raw$pop3,
    outgroup = raw$pop4,
    value = raw$est,
    stringsAsFactors = FALSE
  )
  .introgression_copy_columns(data, raw, c("se", "z", "p"), c("se", "z_score", "p_value"), file, "admixtools_qpdstat")
}

.introgression_admixtools_f3 <- function(raw, file) {
  .require_columns(raw, c("pop1", "pop2", "pop3", "est"), basename(file))
  data <- data.frame(
    analysis = "trio",
    stat = "f3",
    pop1 = raw$pop1,
    pop2 = raw$pop2,
    pop3 = raw$pop3,
    value = raw$est,
    stringsAsFactors = FALSE
  )
  .introgression_copy_columns(data, raw, c("se", "z", "p"), c("se", "z_score", "p_value"), file, "admixtools_f3")
}

.introgression_admixtools_f4ratio <- function(raw, file) {
  .require_columns(raw, c("pop1", "pop2", "pop3", "pop4", "pop5", "alpha"), basename(file))
  data <- data.frame(
    analysis = "trio",
    stat = "f4_ratio",
    pop1 = raw$pop1,
    pop2 = raw$pop2,
    pop3 = raw$pop3,
    pop4 = raw$pop4,
    pop5 = raw$pop5,
    value = raw$alpha,
    stringsAsFactors = FALSE
  )
  .introgression_copy_columns(data, raw, c("se", "z"), c("se", "z_score"), file, "admixtools_f4ratio")
}

.introgression_copy_columns <- function(data, raw, from, to, file, format) {
  for (i in seq_along(from)) {
    if (from[[i]] %in% names(raw)) {
      data[[to[[i]]]] <- raw[[from[[i]]]]
    }
  }
  data$trio <- paste(data$pop1, data$pop2, data$pop3, sep = " / ")
  data$file <- basename(file)
  data$format <- format
  data
}

.import_introgression_treemix <- function(files) {
  edge_files <- files[grepl("\\.edges(\\.gz)?$", files, ignore.case = TRUE)]
  if (length(edge_files) == 0) {
    tree_files <- files[grepl("\\.treeout(\\.gz)?$", files, ignore.case = TRUE)]
    edge_files <- tree_files
  }
  if (length(edge_files) == 0) {
    return(.import_introgression_graph(files, source = "treemix"))
  }
  .stats_bind_rows(lapply(edge_files, function(file) .import_introgression_treemix_file(file, files)))
}

.import_introgression_treemix_file <- function(file, files) {
  if (grepl("\\.treeout(\\.gz)?$", file, ignore.case = TRUE)) {
    return(.import_introgression_treemix_treeout(file))
  }
  edges <- utils::read.table(file, header = FALSE, stringsAsFactors = FALSE, fill = TRUE)
  if (ncol(edges) < 5) {
    stop("Cannot parse TreeMix edges file `", basename(file), "`.", call. = FALSE)
  }
  vertices <- .introgression_treemix_vertices(file, files)
  from <- .introgression_treemix_node_label(edges[[1]], vertices)
  to <- .introgression_treemix_node_label(edges[[2]], vertices)
  layout <- .introgression_treemix_layout(vertices, edges)
  data <- data.frame(
    analysis = "graph",
    stat = ifelse(edges[[5]] == "MIG", "migration", "tree"),
    from = from,
    to = to,
    from_id = as.character(edges[[1]]),
    to_id = as.character(edges[[2]]),
    value = as.numeric(edges[[4]]),
    drift = as.numeric(edges[[3]]),
    stringsAsFactors = FALSE
  )
  if (!is.null(layout)) {
    data$x <- layout$x
    data$y <- layout$y
    data$xend <- layout$xend
    data$yend <- layout$yend
    data$layout <- "treemix"
  }
  data$file <- basename(file)
  data$format <- "treemix_edges"
  data
}

.introgression_treemix_vertices <- function(edge_file, files) {
  vertex_file <- sub("\\.edges(\\.gz)?$", ".vertices\\1", edge_file, ignore.case = TRUE)
  if (!file.exists(vertex_file)) {
    prefix <- sub("\\.edges(\\.gz)?$", "", basename(edge_file), ignore.case = TRUE)
    candidates <- files[grepl(paste0("^", gsub("([.])", "\\\\\\1", prefix), "\\.vertices(\\.gz)?$"), basename(files), ignore.case = TRUE)]
    vertex_file <- candidates[[1]] %||% NA_character_
  }
  if (is.na(vertex_file) || !file.exists(vertex_file)) {
    return(NULL)
  }
  vertices <- utils::read.table(vertex_file, header = FALSE, stringsAsFactors = FALSE, fill = TRUE)
  if (ncol(vertices) < 2) {
    return(NULL)
  }
  vertices
}

.introgression_treemix_node_label <- function(node, vertices) {
  node <- as.character(node)
  if (is.null(vertices)) {
    return(paste0("node_", node))
  }
  idx <- match(node, as.character(vertices[[1]]))
  label <- as.character(vertices[[2]][idx])
  label[is.na(label) | label == "" | label == "<NA>"] <- paste0("node_", node[is.na(label) | label == "" | label == "<NA>"])
  label
}

.introgression_treemix_layout <- function(vertices, edges) {
  if (is.null(vertices) || ncol(vertices) < 10 || ncol(edges) < 6) {
    return(NULL)
  }
  vertices <- vertices
  vertices$x <- NA_real_
  vertices$y <- NA_real_
  vertices$ymin <- NA_real_
  vertices$ymax <- NA_real_
  layout <- tryCatch(
    {
      vertices <- .introgression_treemix_set_y_coords(vertices)
      vertices <- .introgression_treemix_set_x_coords(vertices, edges)
      vertices <- .introgression_treemix_set_mig_coords(vertices, edges)
      from_idx <- match(as.character(edges[[1]]), as.character(vertices[[1]]))
      to_idx <- match(as.character(edges[[2]]), as.character(vertices[[1]]))
      if (any(is.na(from_idx) | is.na(to_idx))) {
        return(NULL)
      }
      data.frame(
        x = vertices$x[from_idx],
        y = vertices$y[from_idx],
        xend = vertices$x[to_idx],
        yend = vertices$y[to_idx],
        stringsAsFactors = FALSE
      )
    },
    error = function(e) NULL
  )
  layout
}

.introgression_treemix_set_y_coords <- function(d) {
  root <- which(d[[3]] == "ROOT")
  if (length(root) != 1) {
    stop("TreeMix vertices must contain one ROOT row.", call. = FALSE)
  }
  y <- as.numeric(d[root, 8]) / (as.numeric(d[root, 8]) + as.numeric(d[root, 10]))
  d[root, "y"] <- 1 - y
  d[root, "ymin"] <- 0
  d[root, "ymax"] <- 1

  child_1 <- d[root, 7]
  child_2 <- d[root, 9]
  idx <- which(d[[1]] == child_1)
  ny <- as.numeric(d[idx, 8]) / (as.numeric(d[idx, 8]) + as.numeric(d[idx, 10]))
  d[idx, "ymin"] <- 1 - y
  d[idx, "ymax"] <- 1
  d[idx, "y"] <- 1 - ny * y

  idx <- which(d[[1]] == child_2)
  ny <- as.numeric(d[idx, 8]) / (as.numeric(d[idx, 8]) + as.numeric(d[idx, 10]))
  d[idx, "ymin"] <- 0
  d[idx, "ymax"] <- 1 - y
  d[idx, "y"] <- (1 - y) - ny * (1 - y)

  for (i in seq_len(nrow(d))) {
    d <- .introgression_treemix_set_y_coord(d, i)
  }
  d
}

.introgression_treemix_set_y_coord <- function(d, i) {
  if (!is.na(d[i, "y"])) {
    return(d)
  }
  node <- d[i, 1]
  parent <- d[i, 6]
  parent_idx <- which(d[[1]] == parent)
  if (length(parent_idx) != 1) {
    return(d)
  }
  if (is.na(d[parent_idx, "y"])) {
    d <- .introgression_treemix_set_y_coord(d, parent_idx)
  }
  parent_y <- d[parent_idx, "y"]
  parent_ymin <- d[parent_idx, "ymin"]
  parent_ymax <- d[parent_idx, "ymax"]
  fraction <- as.numeric(d[i, 8]) / (as.numeric(d[i, 8]) + as.numeric(d[i, 10]))
  if (is.na(fraction) && d[i, 5] != "TIP") {
    return(d)
  }
  if (is.na(fraction)) {
    fraction <- 0.5
  }
  if (d[parent_idx, 7] == node) {
    d[i, "ymin"] <- parent_y
    d[i, "ymax"] <- parent_ymax
    d[i, "y"] <- parent_ymax - fraction * (parent_ymax - parent_y)
    if (d[i, 5] == "TIP") {
      d[i, "y"] <- (parent_y + parent_ymax) / 2
    }
  } else {
    d[i, "ymin"] <- parent_ymin
    d[i, "ymax"] <- parent_y
    d[i, "y"] <- parent_y - fraction * (parent_y - parent_ymin)
    if (d[i, 5] == "TIP") {
      d[i, "y"] <- (parent_ymin + parent_y) / 2
    }
  }
  d
}

.introgression_treemix_set_x_coords <- function(d, e) {
  root <- which(d[[3]] == "ROOT")
  if (length(root) != 1) {
    stop("TreeMix vertices must contain one ROOT row.", call. = FALSE)
  }
  root_id <- d[root, 1]
  d[root, "x"] <- 0
  for (child in c(d[root, 7], d[root, 9])) {
    idx <- which(d[[1]] == child)
    d[idx, "x"] <- .introgression_treemix_edge_distance(d, e, root_id, child)
  }
  for (i in seq_len(nrow(d))) {
    d <- .introgression_treemix_set_x_coord(d, e, i)
  }
  d
}

.introgression_treemix_set_x_coord <- function(d, e, i) {
  if (!is.na(d[i, "x"])) {
    return(d)
  }
  parent <- d[i, 6]
  parent_idx <- which(d[[1]] == parent)
  if (length(parent_idx) != 1) {
    return(d)
  }
  if (is.na(d[parent_idx, "x"])) {
    d <- .introgression_treemix_set_x_coord(d, e, parent_idx)
  }
  d[i, "x"] <- d[parent_idx, "x"] + .introgression_treemix_edge_distance(d, e, parent, d[i, 1])
  d
}

.introgression_treemix_edge_distance <- function(d, e, from, to) {
  direct <- e[e[[1]] == from & e[[2]] == to, 3]
  if (length(direct) > 0) {
    return(max(as.numeric(direct[[1]]), 0, na.rm = TRUE))
  }
  candidates <- e[e[[1]] == from, , drop = FALSE]
  if (nrow(candidates) == 0) {
    return(0)
  }
  candidate <- candidates[[2]][[1]]
  if (length(candidate) > 0 && d[d[[1]] == candidate, 4] != "MIG" && nrow(candidates) > 1) {
    candidate <- candidates[[2]][[2]]
  }
  .introgression_treemix_dist_to_non_migration(d, e, from, candidate)
}

.introgression_treemix_dist_to_non_migration <- function(d, e, from, to) {
  distance <- as.numeric(e[e[[1]] == from & e[[2]] == to, 3][[1]] %||% 0)
  while (length(to) == 1 && any(d[[1]] == to) && d[d[[1]] == to, 4] == "MIG") {
    next_edge <- e[e[[1]] == to & e[[5]] == "NOT_MIG", , drop = FALSE]
    if (nrow(next_edge) == 0) {
      break
    }
    distance <- distance + as.numeric(next_edge[[3]][[1]])
    to <- next_edge[[2]][[1]]
  }
  max(distance, 0, na.rm = TRUE)
}

.introgression_treemix_set_mig_coords <- function(d, e) {
  for (i in seq_len(nrow(d))) {
    if (d[i, 4] != "MIG") {
      next
    }
    parent <- d[d[[1]] == d[i, 6], , drop = FALSE]
    child <- d[d[[1]] == d[i, 7], , drop = FALSE]
    edge <- e[e[[1]] == d[i, 1], , drop = FALSE]
    if (nrow(parent) == 0 || nrow(child) == 0 || nrow(edge) == 0) {
      next
    }
    fraction <- as.numeric(edge[[6]][[1]])
    if (is.nan(fraction) || is.na(fraction)) {
      fraction <- 0
    }
    d[i, "y"] <- parent$y + (child$y - parent$y) * fraction
    d[i, "x"] <- parent$x + (child$x - parent$x) * fraction
  }
  d
}

.import_introgression_treemix_treeout <- function(file) {
  lines <- readLines(file, warn = FALSE)
  migration <- lines[grepl("^[0-9.eE+-]+\\s+", lines)]
  if (length(migration) == 0) {
    stop("TreeMix treeout file `", basename(file), "` does not contain migration edge summaries.", call. = FALSE)
  }
  fields <- strsplit(migration, "\\s+")
  rows <- lapply(fields, function(x) {
    data.frame(
      analysis = "graph",
      stat = "migration",
      from = x[[5]] %||% NA_character_,
      to = x[[6]] %||% NA_character_,
      value = as.numeric(x[[1]]),
      stringsAsFactors = FALSE
    )
  })
  data <- .stats_bind_rows(rows)
  data$file <- basename(file)
  data$format <- "treemix_treeout"
  data
}

.import_introgression_graph_file <- function(file, source) {
  raw <- .introgression_read_table(file)
  names(raw) <- .standardize_names(names(raw))
  if (!all(c("from", "to") %in% names(raw)) && ncol(raw) >= 2) {
    names(raw)[1:2] <- c("from", "to")
  }
  .require_columns(raw, c("from", "to"), paste(source, "graph data"))
  value_col <- .first_existing(raw, c("weight", "proportion", "length", "drift", "edge", "value", "upper", "lower"))
  data <- data.frame(
    analysis = "graph",
    stat = if (source == "treemix") "migration" else "edge",
    from = raw$from,
    to = raw$to,
    value = if (is.null(value_col)) 1 else raw[[value_col]],
    stringsAsFactors = FALSE
  )
  for (column in intersect(c("weight", "proportion", "length", "drift", "lower", "upper"), names(raw))) {
    data[[column]] <- raw[[column]]
  }
  data$file <- basename(file)
  data
}

.introgression_read_table <- function(file, sep = "") {
  utils::read.table(file, header = TRUE, stringsAsFactors = FALSE, check.names = FALSE, sep = sep, comment.char = "")
}

.introgression_sep <- function(file) {
  if (grepl("\\.csv(\\.gz)?$", file, ignore.case = TRUE)) "," else ""
}

.introgression_required_column <- function(raw, candidates, file, what) {
  column <- .first_existing(raw, candidates)
  if (is.null(column)) {
    stop(
      "Cannot find ", what, " column in introgression file `", basename(file),
      "`. Tried: ", paste(candidates, collapse = ", "), ".",
      call. = FALSE
    )
  }
  column
}

.introgression_stat_label <- function(x) {
  aliases <- c(
    d = "D",
    dstatistic = "D",
    fd = "fd",
    f_d = "fd",
    fdm = "fdM",
    f_dm = "fdM",
    df = "df",
    d_f = "df",
    fd_ = "fd_prime",
    fdm_ = "fdM_prime"
  )
  aliases[[x]] %||% x
}
