import_introgression <- function(dir = NULL, ..., type = c(
                                   "auto", "dsuite_dtrios", "dsuite_dinvestigate",
                                   "genomics_general", "treemix", "qpgraph"
                                 )) {
  type <- match.arg(type)
  files <- .introgression_collect_files(dir, ...)
  if (length(files) == 0) {
    stop("No introgression files were provided or discovered.", call. = FALSE)
  }
  if (type == "auto") {
    type <- .guess_introgression_type(files)
  }
  data <- switch(
    type,
    dsuite_dtrios = .import_introgression_dsuite_dtrios(files),
    dsuite_dinvestigate = .import_introgression_dsuite_dinvestigate(files),
    genomics_general = .import_introgression_genomics_general(files),
    treemix = .import_introgression_graph(files, source = "treemix"),
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

.guess_introgression_type <- function(files) {
  lower <- tolower(paste(basename(files), collapse = " "))
  if (grepl("dtrios|dmin|_tree", lower)) return("dsuite_dtrios")
  if (grepl("localfstats|dinvestigate", lower)) return("dsuite_dinvestigate")
  if (grepl("abbababa|fourpop|genomics", lower)) return("genomics_general")
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
