import_selection <- function(dir = NULL, ..., type = c("selscan", "xpclr", "auto")) {
  type <- match.arg(type)
  files <- .selection_collect_files(dir, ...)
  if (length(files) == 0) {
    stop("No selective sweep scan files were provided or discovered.", call. = FALSE)
  }
  if (type == "auto") {
    type <- .guess_selection_type(files)
  }
  data <- switch(
    type,
    selscan = .import_selection_selscan(files),
    xpclr = .import_selection_xpclr(files)
  )
  .new_ggpop_selection(data, source = type)
}

.selection_collect_files <- function(dir = NULL, ...) {
  explicit <- list(...)
  explicit <- explicit[!vapply(explicit, is.null, logical(1))]
  explicit <- unlist(explicit, use.names = TRUE)
  files <- character()
  if (!is.null(dir)) {
    if (!dir.exists(dir)) {
      stop("`dir` must point to an existing directory.", call. = FALSE)
    }
    discovered <- list.files(
      dir,
      pattern = "(\\.(ihs|nsl|ihh12|xpehh|xpnsl)\\.out(\\..*norm)?$|xpclr.*\\.(tsv|txt)$)",
      full.names = TRUE,
      ignore.case = TRUE
    )
    files <- c(files, discovered)
  }
  if (length(explicit) > 0) {
    explicit <- ifelse(file.exists(explicit), explicit, file.path(dir %||% ".", explicit))
    files <- c(files, explicit)
  }
  files <- unique(files[file.exists(files)])
  stats::setNames(files, names(files) %||% basename(files))
}

.guess_selection_type <- function(files) {
  lower <- tolower(paste(basename(files), collapse = " "))
  if (grepl("xpclr", lower)) {
    return("xpclr")
  }
  if (grepl("ihs|nsl|ihh12|xpehh|xpnsl|selscan", lower)) {
    return("selscan")
  }
  "selscan"
}

.import_selection_selscan <- function(files) {
  rows <- lapply(files, .import_selection_selscan_file)
  .stats_bind_rows(rows)
}

.import_selection_selscan_file <- function(file) {
  raw <- .read_table_auto(file, sep = "\t")
  names(raw) <- .standardize_names(names(raw))
  stat <- .selection_stat_from_file(file, raw)
  chr_col <- .selection_required_column(raw, c("chr", "chrom", "chromosome"), file, "chromosome")
  pos_col <- .selection_required_column(raw, c("pos", "position", "bp"), file, "position")
  value_col <- .selection_value_column(raw, stat, file)
  data <- data.frame(
    stat = stat,
    chr = raw[[chr_col]],
    pos = raw[[pos_col]],
    value = raw[[value_col]],
    score_type = if (grepl("^norm_", value_col)) "normalized" else "raw",
    stringsAsFactors = FALSE
  )
  id_col <- .first_existing(raw, c("id", "snp", "rs"))
  if (!is.null(id_col)) {
    data$id <- raw[[id_col]]
  }
  freq_col <- .first_existing(raw, c("freq", "p1", "p2"))
  if (!is.null(freq_col)) {
    data$freq <- raw[[freq_col]]
  }
  crit_col <- .first_existing(raw, c("crit"))
  if (!is.null(crit_col)) {
    data$crit <- raw[[crit_col]]
  }
  data$start <- data$pos
  data$end <- data$pos
  data$file <- basename(file)
  data
}

.selection_required_column <- function(raw, candidates, file, what) {
  column <- .first_existing(raw, candidates)
  if (is.null(column)) {
    stop(
      "Cannot find ", what, " column in selection file `", basename(file),
      "`. Tried: ", paste(candidates, collapse = ", "), ".",
      call. = FALSE
    )
  }
  column
}

.selection_stat_from_file <- function(file, raw) {
  lower <- tolower(basename(file))
  if (grepl("xpnsl", lower)) return("xpnsl")
  if (grepl("xpehh", lower)) return("xpehh")
  if (grepl("ihh12", lower)) return("ihh12")
  if (grepl("ihs", lower)) return("ihs")
  if (grepl("nsl", lower)) return("nsl")
  hits <- intersect(c("xpnsl", "xpehh", "ihh12", "ihs", "nsl"), names(raw))
  if (length(hits) > 0) return(hits[1])
  stop("Cannot infer selscan statistic from file `", basename(file), "`.", call. = FALSE)
}

.selection_value_column <- function(raw, stat, file) {
  candidates <- c(paste0("norm_", stat), stat)
  column <- .first_existing(raw, candidates)
  if (is.null(column)) {
    stop(
      "Cannot find score column for selscan statistic `", stat, "` in `",
      basename(file), "`. Tried: ", paste(candidates, collapse = ", "), ".",
      call. = FALSE
    )
  }
  column
}

.import_selection_xpclr <- function(files) {
  rows <- lapply(files, .import_selection_xpclr_file)
  .stats_bind_rows(rows)
}

.import_selection_xpclr_file <- function(file) {
  raw <- .read_table_auto(file, sep = "\t")
  names(raw) <- .standardize_names(names(raw))
  chr_col <- .selection_required_column(raw, c("chrom", "chr", "chromosome"), file, "chromosome")
  start_col <- .selection_required_column(raw, c("start", "window_start"), file, "window start")
  end_col <- .selection_required_column(raw, c("stop", "end", "window_end"), file, "window end")
  value_col <- .selection_required_column(raw, c("xpclr_norm", "norm_xpclr", "xpclr"), file, "XPCLR score")
  pos_start_col <- .first_existing(raw, c("pos_start", "snp_start"))
  pos_stop_col <- .first_existing(raw, c("pos_stop", "snp_stop"))
  data <- data.frame(
    stat = "xpclr",
    chr = raw[[chr_col]],
    start = raw[[start_col]],
    end = raw[[end_col]],
    value = raw[[value_col]],
    score_type = if (value_col %in% c("xpclr_norm", "norm_xpclr")) "normalized" else "raw",
    stringsAsFactors = FALSE
  )
  data$pos <- (as.numeric(data$start) + as.numeric(data$end)) / 2
  id_col <- .first_existing(raw, c("id", "window_id"))
  if (!is.null(id_col)) {
    data$id <- raw[[id_col]]
  }
  if (!is.null(pos_start_col)) {
    data$pos_start <- raw[[pos_start_col]]
  }
  if (!is.null(pos_stop_col)) {
    data$pos_stop <- raw[[pos_stop_col]]
  }
  for (column in intersect(c("modell", "nulll", "sel_coef", "nsnps", "nsnps_avail", "xpclr"), names(raw))) {
    data[[column]] <- raw[[column]]
  }
  data$file <- basename(file)
  data
}
