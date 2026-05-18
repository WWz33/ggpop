.new_ggpop_gwas <- function(data, source) {
  required <- c("chr", "pos", "p")
  .require_columns(data, required, "GWAS data")
  data$chr <- as.character(data$chr)
  data$pos <- as.numeric(data$pos)
  data$p <- as.numeric(data$p)
  if (!"snp" %in% names(data)) {
    data$snp <- paste(data$chr, data$pos, sep = ":")
  }
  data$source <- source
  data <- .validate_gwas(data)
  class(data) <- unique(c("ggpop_gwas", class(data)))
  data
}

.new_ggpop_pca <- function(data, source, eigenvalues = NULL) {
  .require_columns(data, c("sample_id", "pc1", "pc2"), "PCA data")
  data$sample_id <- as.character(data$sample_id)
  data$source <- source
  class(data) <- unique(c("ggpop_pca", class(data)))
  attr(data, "eigenvalues") <- eigenvalues
  if (!is.null(eigenvalues)) {
    attr(data, "variance_explained") <- eigenvalues / sum(eigenvalues)
  }
  data
}

.new_ggpop_admix <- function(data, source, tolerance = 0.01) {
  .require_columns(data, c("sample_id", "run_id", "k", "cluster", "proportion"), "admixture data")
  data$sample_id <- as.character(data$sample_id)
  data$run_id <- as.character(data$run_id)
  data$k <- as.integer(data$k)
  data$cluster <- as.character(data$cluster)
  data$proportion <- as.numeric(data$proportion)
  data$source <- source
  .validate_admix(data, tolerance = tolerance)
  class(data) <- unique(c("ggpop_admix", class(data)))
  data
}

.new_ggpop_stats <- function(data, source) {
  .require_columns(data, c("stat", "chr", "start", "end", "pos", "value"), "Population genomics statistics data")
  data$stat <- as.character(data$stat)
  data$chr <- as.character(data$chr)
  data$start <- as.numeric(data$start)
  data$end <- as.numeric(data$end)
  data$pos <- as.numeric(data$pos)
  data$value <- as.numeric(data$value)
  data$source <- source
  data$.group <- .stats_group_id(data)
  if (any(!is.finite(data$start) | !is.finite(data$end) | !is.finite(data$pos), na.rm = TRUE)) {
    stop("Population genomics statistics positions must be finite numeric values.", call. = FALSE)
  }
  class(data) <- unique(c("ggpop_stats", class(data)))
  data
}

.new_ggpop_selection <- function(data, source) {
  .require_columns(data, c("stat", "chr", "pos", "value"), "Selective sweep scan data")
  data$stat <- as.character(data$stat)
  data$chr <- as.character(data$chr)
  data$pos <- as.numeric(data$pos)
  data$value <- as.numeric(data$value)
  if (!"start" %in% names(data)) {
    data$start <- data$pos
  }
  if (!"end" %in% names(data)) {
    data$end <- data$pos
  }
  if (!"score_type" %in% names(data)) {
    data$score_type <- "raw"
  }
  data$start <- as.numeric(data$start)
  data$end <- as.numeric(data$end)
  data$score_type <- as.character(data$score_type)
  data$source <- source
  data$.group <- .selection_group_id(data)
  if (any(!is.finite(data$pos), na.rm = TRUE)) {
    stop("Selective sweep scan positions must be finite numeric values.", call. = FALSE)
  }
  class(data) <- unique(c("ggpop_selection", class(data)))
  data
}

.stats_group_id <- function(data) {
  parts <- list(data$stat)
  if ("pop1" %in% names(data)) {
    parts <- c(parts, list(data$pop1))
  }
  if ("pop2" %in% names(data)) {
    parts <- c(parts, list(data$pop2))
  }
  do.call(interaction, c(parts, list(drop = TRUE, sep = ":")))
}

.selection_group_id <- function(data) {
  parts <- list(data$stat)
  if ("score_type" %in% names(data)) {
    parts <- c(parts, list(data$score_type))
  }
  do.call(interaction, c(parts, list(drop = TRUE, sep = ":")))
}
