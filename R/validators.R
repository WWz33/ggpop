.require_columns <- function(data, columns, what) {
  missing <- setdiff(columns, names(data))
  if (length(missing) > 0) {
    stop(what, " must contain columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
}

.require_class <- function(data, class, what) {
  if (!inherits(data, class)) {
    stop(what, " must be an object produced by the matching import function.", call. = FALSE)
  }
}

.validate_gwas <- function(data) {
  if (any(!is.finite(data$pos))) {
    stop("GWAS column `pos` must be finite numeric.", call. = FALSE)
  }
  if (any(is.na(data$p))) {
    stop("GWAS column `p` must be numeric with no missing values.", call. = FALSE)
  }
  if (any(data$p < 0 | data$p > 1, na.rm = TRUE)) {
    warning("GWAS p-values outside [0, 1] were clamped.", call. = FALSE)
    data$p <- pmin(pmax(data$p, 0), 1)
  }
  data
}

.validate_admix <- function(data, tolerance = 0.01) {
  if (any(data$proportion < 0 | data$proportion > 1, na.rm = TRUE)) {
    stop("Admixture proportions must be between 0 and 1.", call. = FALSE)
  }
  sums <- stats::aggregate(proportion ~ run_id + sample_id, data, sum)
  off <- abs(sums$proportion - 1) > tolerance
  if (any(off, na.rm = TRUE)) {
    warning("Some sample admixture proportions do not sum to 1 within tolerance.", call. = FALSE)
  }
  invisible(data)
}

.read_table_auto <- function(file, header = TRUE, ...) {
  utils::read.table(file, header = header, stringsAsFactors = FALSE, check.names = FALSE, ...)
}

.standardize_names <- function(x) {
  tolower(gsub("[^A-Za-z0-9]+", "_", x))
}

.first_existing <- function(data, candidates) {
  hit <- candidates[candidates %in% names(data)][1]
  if (is.na(hit)) NULL else hit
}
