args <- commandArgs(trailingOnly = FALSE)
options(scipen = 999)
file_arg <- args[grepl("^--file=", args)]
if (length(file_arg) > 0) {
  script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[[1]]), mustWork = TRUE))
} else {
  script_dir <- file.path(getwd(), "tools")
}
root <- normalizePath(file.path(script_dir, ".."), mustWork = TRUE)

vcf_file <- file.path(root, "inst", "extdata", "snp", "finalsnp_ld.vcf")
pop_file <- file.path(root, "inst", "extdata", "pop_group.txt")
out_dir <- file.path(root, "inst", "extdata", "introgression", "vcf_pop_example")
out_file <- file.path(out_dir, "ABBABABA_window.csv")

pop_group <- utils::read.table(pop_file, header = TRUE, stringsAsFactors = FALSE)
pop_group$sample <- as.character(pop_group$sample)
pop_group$pop <- as.character(pop_group$pop)

lines <- readLines(vcf_file, warn = FALSE)
header_line <- lines[startsWith(lines, "#CHROM")]
if (length(header_line) != 1) {
  stop("Expected one VCF #CHROM header line.", call. = FALSE)
}
header <- strsplit(header_line, "\t", fixed = TRUE)[[1]]
sample_names <- header[-seq_len(9)]

sample_pop <- pop_group$pop[match(sample_names, pop_group$sample)]
names(sample_pop) <- sample_names
keep_pops <- c("PopA", "PopB", "PopC", "PopD")
if (!all(keep_pops %in% sample_pop)) {
  stop("Expected PopA, PopB, PopC, and PopD in pop_group.txt.", call. = FALSE)
}

variant_lines <- lines[!startsWith(lines, "#")]
fields <- strsplit(variant_lines, "\t", fixed = TRUE)
rows <- lapply(fields, function(x) {
  genotypes <- x[-seq_len(9)]
  alt_dosage <- suppressWarnings(as.numeric(substr(genotypes, 1, 1)) + as.numeric(substr(genotypes, 3, 3)))
  alt_frequency <- vapply(keep_pops, function(pop) {
    values <- alt_dosage[sample_pop == pop]
    mean(values, na.rm = TRUE) / 2
  }, numeric(1))
  p1 <- alt_frequency[["PopA"]]
  p2 <- alt_frequency[["PopB"]]
  p3 <- alt_frequency[["PopC"]]
  outgroup <- alt_frequency[["PopD"]]
  abba <- (1 - p1) * p2 * p3 * (1 - outgroup)
  baba <- p1 * (1 - p2) * p3 * (1 - outgroup)
  data.frame(
    scaffold = x[[1]],
    pos = as.numeric(x[[2]]),
    sites = 1,
    sitesUsed = as.integer(is.finite(abba) && is.finite(baba)),
    ABBA = abba,
    BABA = baba,
    stringsAsFactors = FALSE
  )
})
site_data <- do.call(rbind, rows)
site_data <- site_data[site_data$sitesUsed > 0, , drop = FALSE]

window_size <- 5000000
site_data$start <- floor((site_data$pos - 1) / window_size) * window_size + 1
site_data$end <- site_data$start + window_size - 1

windows <- stats::aggregate(
  site_data[c("sites", "sitesUsed", "ABBA", "BABA")],
  site_data[c("scaffold", "start", "end")],
  sum
)
windows <- windows[order(as.numeric(windows$scaffold), windows$start), , drop = FALSE]
windows$mid <- (windows$start + windows$end) / 2
denom <- windows$ABBA + windows$BABA
delta <- windows$ABBA - windows$BABA
windows$D <- ifelse(denom > 0, delta / denom, NA_real_)
windows$fd <- ifelse(windows$ABBA > windows$BABA & windows$ABBA > 0, delta / windows$ABBA, 0)
windows$fdM <- ifelse(pmax(windows$ABBA, windows$BABA) > 0, delta / pmax(windows$ABBA, windows$BABA), NA_real_)
windows <- windows[
  ,
  c("scaffold", "start", "end", "mid", "sites", "sitesUsed", "ABBA", "BABA", "D", "fd", "fdM")
]

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
utils::write.csv(windows, out_file, quote = FALSE, row.names = FALSE)
