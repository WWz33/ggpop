base <- "inst/extdata/Population_genomics_statistics"
pixy <- file.path(base, "pixy")
vcf <- file.path(base, "vcftools")
dir.create(vcf, recursive = TRUE, showWarnings = FALSE)

pi <- read.table(file.path(pixy, "pixy_pi.txt"), header = TRUE, sep = "\t", stringsAsFactors = FALSE)
pi_out <- data.frame(
  CHROM = pi$chromosome,
  BIN_START = pi$window_pos_1,
  BIN_END = pi$window_pos_2,
  N_VARIANTS = pmax(round(pi$count_diffs / 20), 1),
  PI = pi$avg_pi
)
write.table(pi_out, file.path(vcf, "vcftools.windowed.pi"), sep = "\t", quote = FALSE, row.names = FALSE)

fst <- read.table(file.path(pixy, "pixy_fst.txt"), header = TRUE, sep = "\t", stringsAsFactors = FALSE)
fst_out <- data.frame(
  CHROM = fst$chromosome,
  BIN_START = fst$window_pos_1,
  BIN_END = fst$window_pos_2,
  N_VARIANTS = fst$no_snps,
  WEIGHTED_FST = fst$avg_wc_fst,
  MEAN_FST = fst$avg_wc_fst
)
write.table(fst_out, file.path(vcf, "vcftools.windowed.weir.fst"), sep = "\t", quote = FALSE, row.names = FALSE)

taj <- read.table(file.path(pixy, "pixy_tajima_d.txt"), header = TRUE, sep = "\t", stringsAsFactors = FALSE)
taj_out <- data.frame(
  CHROM = taj$chromosome,
  BIN_START = taj$window_pos_1,
  N_SNPS = pmax(round(taj$raw_pi / 10), 1),
  TajimaD = taj$tajima_d
)
write.table(taj_out, file.path(vcf, "vcftools.Tajima.D"), sep = "\t", quote = FALSE, row.names = FALSE)
