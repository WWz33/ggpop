import_gwas <- function(file, type = c("auto", "gcta", "gemma", "emmax"), ...) {
  type <- match.arg(type)
  if (type == "auto") type <- .guess_gwas_type(file)
  data <- switch(
    type,
    gcta = .import_gwas_gcta(file, ...),
    gemma = .import_gwas_gemma(file, ...),
    emmax = .import_gwas_emmax(file, ...)
  )
  .new_ggpop_gwas(data, source = type)
}

improt_gwas <- function(file, type = c("auto", "gcta", "gemma", "emmax"), ...) {
  import_gwas(file = file, type = type, ...)
}

prot_gwas <- function(file, type = c("auto", "gcta", "gemma", "emmax"), ...) {
  import_gwas(file = file, type = type, ...)
}

.guess_gwas_type <- function(file) {
  lower <- tolower(file)
  if (grepl("\\.mlma(\\.gz)?$", lower)) return("gcta")
  if (grepl("gemma|assoc\\.txt$", lower)) return("gemma")
  if (grepl("\\.ps$|emmax", lower)) return("emmax")
  stop("Cannot infer GWAS type. Use `type` explicitly.", call. = FALSE)
}

.import_gwas_gcta <- function(file, ...) {
  raw <- .read_table_auto(file, ...)
  names(raw) <- .standardize_names(names(raw))
  .map_gwas_columns(raw, chr = c("chr"), pos = c("bp", "pos"), p = c("p"), snp = c("snp"))
}

.import_gwas_gemma <- function(file, ...) {
  raw <- .read_table_auto(file, ...)
  names(raw) <- .standardize_names(names(raw))
  .map_gwas_columns(raw, chr = c("chr"), pos = c("ps", "bp", "pos"), p = c("p_wald", "p_lrt", "p_score", "p"), snp = c("rs", "snp"))
}

.import_gwas_emmax <- function(file, ...) {
  raw <- .read_table_auto(file, ...)
  names(raw) <- .standardize_names(names(raw))
  .map_gwas_columns(raw, chr = c("chr"), pos = c("bp", "ps", "pos"), p = c("p", "pvalue"), snp = c("snp", "rs"))
}

.map_gwas_columns <- function(raw, chr, pos, p, snp) {
  chr_col <- .first_existing(raw, chr)
  pos_col <- .first_existing(raw, pos)
  p_col <- .first_existing(raw, p)
  snp_col <- .first_existing(raw, snp)
  data <- data.frame(
    chr = raw[[chr_col]],
    pos = raw[[pos_col]],
    p = raw[[p_col]],
    stringsAsFactors = FALSE
  )
  if (!is.null(snp_col)) data$snp <- raw[[snp_col]]
  data
}
