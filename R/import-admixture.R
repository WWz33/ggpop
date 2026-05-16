import_admixture <- function(file, type = c("auto", "structure", "admixture"), ind = NULL,
                             pattern = "\\.Q$", recursive = FALSE, pop_group = NULL, ...) {
  type <- match.arg(type)
  files <- .resolve_admix_files(file, pattern = pattern, recursive = recursive)
  if (type == "auto") type <- .guess_admix_type(files[1])
  data <- switch(
    type,
    admixture = .import_admixture_files(files, ind = ind, ..., importer = .import_admixture_q),
    structure = .import_admixture_files(files, ind = ind, ..., importer = .import_structure_q)
  )
  data <- .join_pop_group(data, pop_group)
  .new_ggpop_admix(data, source = type)
}

import_admix <- function(file, type = c("auto", "structure", "admixture"), ind = NULL,
                         pattern = "\\.Q$", recursive = FALSE, pop_group = NULL, ...) {
  import_admixture(file = file, type = type, ind = ind, pattern = pattern, recursive = recursive, pop_group = pop_group, ...)
}

.guess_admix_type <- function(file) {
  lower <- tolower(file)
  if (grepl("\\.q$", lower)) return("admixture")
  if (grepl("structure", lower)) return("structure")
  stop("Cannot infer admixture type. Use `type` explicitly.", call. = FALSE)
}

.import_admixture_q <- function(file, ind = NULL, ...) {
  raw <- .read_table_auto(file, header = FALSE, ...)
  .qmatrix_to_long(raw, file, ind)
}

.import_admixture_files <- function(files, ind = NULL, ..., importer) {
  data <- do.call(rbind, lapply(files, function(file) {
    importer(file = file, ind = ind, ...)
  }))
  rownames(data) <- NULL
  data
}

.resolve_admix_files <- function(file, pattern = "\\.Q$", recursive = FALSE) {
  if (length(file) == 1 && dir.exists(file)) {
    files <- list.files(file, pattern = pattern, full.names = TRUE, recursive = recursive)
  } else {
    files <- file
  }
  files <- normalizePath(files, winslash = "/", mustWork = FALSE)
  missing <- files[!file.exists(files)]
  if (length(missing) > 0) {
    stop("Admixture input files do not exist: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  if (length(files) == 0) {
    stop("No admixture input files found.", call. = FALSE)
  }
  files[order(.k_from_admix_file(files), files)]
}

.import_structure_q <- function(file, ind = NULL, ...) {
  raw <- .read_table_auto(file, header = FALSE, ...)
  numeric_cols <- vapply(raw, is.numeric, logical(1))
  q <- raw[numeric_cols]
  if (ncol(q) < 2) {
    stop("STRUCTURE import currently requires a table with at least two numeric cluster columns.", call. = FALSE)
  }
  .qmatrix_to_long(q, file, ind)
}

.qmatrix_to_long <- function(q, file, ind = NULL) {
  k <- .k_from_admix_file(file)
  if (is.na(k)) k <- ncol(q)
  sample_id <- .sample_ids(nrow(q), ind)
  out <- do.call(rbind, lapply(seq_len(k), function(i) {
    data.frame(
      sample_id = sample_id,
      run_id = basename(file),
      k = k,
      cluster = paste0("K", i),
      proportion = as.numeric(q[[i]]),
      stringsAsFactors = FALSE
    )
  }))
  rownames(out) <- NULL
  out
}

.k_from_admix_file <- function(file) {
  base <- basename(file)
  match <- regexpr("(?<=\\.)[0-9]+(?=\\.Q$)", base, perl = TRUE)
  hit <- rep(NA_character_, length(base))
  has_match <- match > 0
  hit[has_match] <- regmatches(base, match)[has_match]
  suppressWarnings(as.integer(hit))
}

.sample_ids <- function(n, ind = NULL) {
  if (is.null(ind)) return(paste0("ind", seq_len(n)))
  if (is.data.frame(ind)) return(as.character(ind[[1]]))
  ids <- scan(ind, what = character(), quiet = TRUE)
  if (length(ids) != n && length(ids) %% n == 0) {
    ids <- ids[seq(1, length(ids), by = length(ids) / n)]
  }
  if (length(ids) != n) {
    stop("Length of `ind` labels must match rows in admixture data.", call. = FALSE)
  }
  ids
}
