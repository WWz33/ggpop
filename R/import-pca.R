import_pca <- function(file, type = c("auto", "plink", "gcta"), eigenval = NULL,
                       pop_group = NULL, ...) {
  type <- match.arg(type)
  if (type == "auto") type <- .guess_pca_type(file)
  data <- switch(
    type,
    plink = .import_pca_plink(file, ...),
    gcta = .import_pca_gcta(file, ...)
  )
  data <- .join_pop_group(data, pop_group)
  eigenvalues <- if (is.null(eigenval)) NULL else scan(eigenval, quiet = TRUE)
  .new_ggpop_pca(data, source = type, eigenvalues = eigenvalues)
}

compute_pca <- function(genotype, method = c("flashpca"), pop_group = NULL, ...) {
  method <- match.arg(method)
  if (!requireNamespace("flashpcaR", quietly = TRUE)) {
    stop("Package `flashpcaR` is required for `compute_pca(method = \"flashpca\")`.", call. = FALSE)
  }
  result <- flashpcaR::flashpca(genotype, ...)
  vectors <- as.data.frame(result$vectors, stringsAsFactors = FALSE)
  names(vectors) <- paste0("pc", seq_along(vectors))
  vectors$sample_id <- rownames(vectors) %||% as.character(seq_len(nrow(vectors)))
  vectors <- vectors[c("sample_id", setdiff(names(vectors), "sample_id"))]
  vectors <- .join_pop_group(vectors, pop_group)
  .new_ggpop_pca(vectors, source = method, eigenvalues = result$values)
}

.guess_pca_type <- function(file) {
  lower <- tolower(file)
  if (grepl("eigenvec$", lower)) return("plink")
  stop("Cannot infer PCA type. Use `type` explicitly.", call. = FALSE)
}

.import_pca_plink <- function(file, ...) {
  raw <- .read_table_auto(file, header = FALSE, ...)
  n_pc <- ncol(raw) - 2
  names(raw) <- c("family_id", "sample_id", paste0("pc", seq_len(n_pc)))
  raw
}

.import_pca_gcta <- function(file, ...) {
  raw <- .read_table_auto(file, header = FALSE, ...)
  n_pc <- ncol(raw) - 2
  names(raw) <- c("family_id", "sample_id", paste0("pc", seq_len(n_pc)))
  raw
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
