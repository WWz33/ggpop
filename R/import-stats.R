import_stats <- function(dir = NULL, ..., type = c("pixy", "vcftools", "auto")) {
  type <- match.arg(type)
  files <- .stats_collect_files(dir, ...)
  if (length(files) == 0) {
    stop("No statistics files were provided or discovered.", call. = FALSE)
  }
  if (type == "auto") {
    type <- .guess_stats_type(files)
  }
  data <- switch(
    type,
    pixy = .import_stats_pixy(files),
    vcftools = .import_stats_vcftools(files)
  )
  .new_ggpop_stats(data, source = type)
}

.stats_collect_files <- function(dir = NULL, ...) {
  explicit <- list(...)
  explicit <- explicit[!vapply(explicit, is.null, logical(1))]
  explicit <- unlist(explicit, use.names = TRUE)
  files <- character()
  if (!is.null(dir)) {
    if (!dir.exists(dir)) {
      stop("`dir` must point to an existing directory.", call. = FALSE)
    }
    discovered <- list.files(dir, pattern = "\\.(txt|tsv|windowed\\..+|Tajima\\.D)$", full.names = TRUE, ignore.case = TRUE)
    files <- c(files, discovered)
  }
  if (length(explicit) > 0) {
    explicit <- ifelse(file.exists(explicit), explicit, file.path(dir %||% ".", explicit))
    files <- c(files, explicit)
  }
  files <- unique(files[file.exists(files)])
  stats::setNames(files, names(files) %||% basename(files))
}

.guess_stats_type <- function(files) {
  lower <- tolower(paste(basename(files), collapse = " "))
  if (grepl("pixy|watterson|tajima", lower)) return("pixy")
  if (grepl("windowed|weir|sites\\.pi|tajima\\.d", lower)) return("vcftools")
  "pixy"
}

.import_stats_pixy <- function(files) {
  rows <- lapply(files, .import_stats_pixy_file)
  .stats_bind_rows(rows)
}

.import_stats_pixy_file <- function(file) {
  raw <- .read_table_auto(file, sep = "\t")
  names(raw) <- .standardize_names(names(raw))
  stat <- .pixy_stat_from_file(file)
  chr_col <- .first_existing(raw, c("chromosome", "chr"))
  start_col <- .first_existing(raw, c("window_pos_1", "start", "bin_start"))
  end_col <- .first_existing(raw, c("window_pos_2", "end", "bin_end"))
  value_col <- .first_existing(raw, .pixy_value_candidates(stat))
  if (is.null(value_col)) {
    stop("Cannot find value column for pixy statistic `", stat, "` in ", basename(file), ".", call. = FALSE)
  }
  data <- data.frame(
    stat = stat,
    chr = raw[[chr_col]],
    start = raw[[start_col]],
    end = raw[[end_col]],
    value = raw[[value_col]],
    stringsAsFactors = FALSE
  )
  if ("pop" %in% names(raw)) {
    data$pop1 <- raw$pop
  }
  if ("pop1" %in% names(raw)) {
    data$pop1 <- raw$pop1
  }
  if ("pop2" %in% names(raw)) {
    data$pop2 <- raw$pop2
  }
  data$pos <- (as.numeric(data$start) + as.numeric(data$end)) / 2
  data$file <- basename(file)
  data
}

.pixy_stat_from_file <- function(file) {
  lower <- tolower(basename(file))
  if (grepl("watterson", lower)) return("watterson_theta")
  if (grepl("tajima", lower)) return("tajima_d")
  if (grepl("dxy", lower)) return("dxy")
  if (grepl("fst", lower)) return("fst")
  if (grepl("pi", lower)) return("pi")
  sub("\\.txt$", "", sub("^pixy_", "", lower))
}

.pixy_value_candidates <- function(stat) {
  switch(
    stat,
    pi = c("avg_pi", "pi"),
    fst = c("avg_wc_fst", "avg_hudson_fst", "fst"),
    dxy = c("avg_dxy", "dxy"),
    tajima_d = c("tajima_d"),
    watterson_theta = c("avg_watterson_theta", "watterson_theta"),
    c(stat)
  )
}

.import_stats_vcftools <- function(files) {
  rows <- lapply(files, .import_stats_vcftools_file)
  .stats_bind_rows(rows)
}

.import_stats_vcftools_file <- function(file) {
  raw <- .read_table_auto(file)
  names(raw) <- .standardize_names(names(raw))
  stat <- .vcftools_stat_from_file(file, raw)
  chr_col <- .first_existing(raw, c("chr", "chrom", "chromosome"))
  start_col <- .first_existing(raw, c("bin_start", "window_start", "start"))
  end_col <- .first_existing(raw, c("bin_end", "window_end", "end"))
  pos_col <- .first_existing(raw, c("pos", "position"))
  value_col <- .first_existing(raw, .vcftools_value_candidates(stat))
  if (is.null(chr_col) || is.null(value_col)) {
    stop("Cannot map vcftools statistics file: ", basename(file), call. = FALSE)
  }
  if (is.null(start_col)) start_col <- pos_col
  if (is.null(end_col)) end_col <- pos_col %||% start_col
  data <- data.frame(
    stat = stat,
    chr = raw[[chr_col]],
    start = raw[[start_col]],
    end = raw[[end_col]],
    value = raw[[value_col]],
    stringsAsFactors = FALSE
  )
  data$pos <- (as.numeric(data$start) + as.numeric(data$end)) / 2
  data$file <- basename(file)
  data
}

.vcftools_stat_from_file <- function(file, raw) {
  lower <- tolower(basename(file))
  if (grepl("tajima", lower)) return("tajima_d")
  if (grepl("windowed\\.pi|sites\\.pi|\\.pi", lower)) return("pi")
  if (grepl("fst|weir", lower)) return("fst")
  if ("tajima_d" %in% names(raw)) return("tajima_d")
  if ("pi" %in% names(raw)) return("pi")
  if ("weighted_fst" %in% names(raw) || "mean_fst" %in% names(raw)) return("fst")
  "stat"
}

.vcftools_value_candidates <- function(stat) {
  switch(
    stat,
    pi = c("pi"),
    fst = c("weighted_fst", "mean_fst", "fst"),
    tajima_d = c("tajima_d", "tajimad"),
    c(stat, "value")
  )
}

.stats_bind_rows <- function(rows) {
  columns <- unique(unlist(lapply(rows, names), use.names = FALSE))
  aligned <- lapply(rows, function(row) {
    missing <- setdiff(columns, names(row))
    for (column in missing) {
      row[[column]] <- NA
    }
    row[columns]
  })
  do.call(rbind, aligned)
}
