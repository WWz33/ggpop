library(ggplot2)
library(ggPopi)

out_dir <- file.path("inst", "examples", "figures")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

examples <- list(
  gcta = file.path("inst", "extdata", "example_gcta.mlma"),
  gemma = file.path("inst", "extdata", "example_gemma.assoc.txt"),
  emmax = file.path("inst", "extdata", "example_emmax.ps")
)

for (type in names(examples)) {
  gwas <- ggpop::import_gwas(examples[[type]], type = type)

  manha <- ggpop::ggpop(gwas) +
    ggpop::geom_manha(threshold = 5e-8, size = 1.4, alpha = 0.85) +
    ggplot2::labs(
      title = paste(toupper(type), "Manhattan example"),
      x = "Genomic position",
      y = expression(-log[10](p))
    ) +
    ggplot2::theme_bw()

  qq <- ggpop::ggpop(gwas) +
    ggpop::geom_qq(size = 1.4, alpha = 0.85) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey40") +
    ggplot2::labs(
      title = paste(toupper(type), "Q-Q example"),
      x = "Expected",
      y = "Observed"
    ) +
    ggplot2::theme_bw()

  ggplot2::ggsave(file.path(out_dir, paste0(type, "_manhattan.png")), manha, width = 6, height = 4, dpi = 120)
  ggplot2::ggsave(file.path(out_dir, paste0(type, "_qq.png")), qq, width = 4, height = 4, dpi = 120)
}
