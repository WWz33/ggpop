library(ggplot2)

if (requireNamespace("devtools", quietly = TRUE) && file.exists("DESCRIPTION")) {
  devtools::load_all(".", quiet = TRUE)
} else {
  library(ggPopi)
}

extdata <- function(...) {
  file.path("inst", "extdata", ...)
}

save_readme <- function(plot, file, width = 6, height = 4, dpi = 180) {
  ggplot2::ggsave(
    filename = file.path("man", "figures", file),
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white"
  )
}

gwas <- import_gwas(extdata("gwas", "gcta.mlma"), type = "gcta")
pca <- import_pca(
  extdata("pca", "gcta.eigenvec"),
  type = "gcta",
  eigenval = extdata("pca", "gcta.eigenval"),
  pop_group = extdata("pop_group.txt")
)
admix <- import_admix(
  extdata("admixture"),
  type = "admixture",
  ind = extdata("snp", "finalsnp_ld.fam"),
  pop_group = extdata("pop_group.txt")
)
stats <- import_stats(extdata("Population_genomics_statistics", "pixy"), type = "pixy")
ld_decay <- import_ld_decay(extdata("ld_decay", "poplddcay"), type = "poplddecay")
selscan_chr1 <- import_selection(
  extdata("selective_sweep", "selscan"),
  ihs = "chr1.ihs.out.100bins.norm",
  nsl = "chr1.nsl.out.100bins.norm",
  xpehh = "chr1.xpehh.out.norm",
  xpnsl = "chr1.xpnsl.out.norm",
  type = "selscan"
)
introgression <- import_introgression(
  extdata("introgression", "Dsuite", "PopB_PopC_PopA_localFstats_run1_100_50.txt"),
  type = "dsuite_dinvestigate"
)

save_readme(plot_manha(gwas), "readme-manhattan.png", width = 7.5, height = 4.2)
save_readme(plot_pca(pca), "readme-pca.png", width = 6, height = 4)
save_readme(
  plot_admix(admix, k = 3, sort = "all", order_group = TRUE),
  "readme-admixture.png",
  width = 6,
  height = 3.4
)
save_readme(plot_stats(stats, stat = "all", chr = "chr2L"), "readme-stats.png", width = 6, height = 4.4)
save_readme(plot_ld_decay(ld_decay, style = "point"), "readme-ld-decay.png", width = 6, height = 4)
save_readme(
  plot_selection(
    selscan_chr1,
    stat = c("ihs", "nsl", "xpehh", "xpnsl"),
    chr = "1"
  ),
  "readme-selection.png",
  width = 6,
  height = 4.4
)
save_readme(
  plot_introgression(introgression, stat = c("D", "fd", "fdM")),
  "readme-introgression.png",
  width = 6,
  height = 4.2
)
