test_that("GWAS example files generate image plots", {
  examples <- list(
    gcta = extdata_path("example_gcta.mlma"),
    gemma = extdata_path("example_gemma.assoc.txt"),
    emmax = extdata_path("example_emmax.ps")
  )

  out_dir <- file.path(tempdir(), "ggpop-gwas-examples")
  dir.create(out_dir, showWarnings = FALSE)

  for (type in names(examples)) {
    gwas <- import_gwas(examples[[type]], type = type)
    manha <- ggpop(gwas) + geom_manha()
    qq <- ggpop(gwas) + geom_qq()

    manha_file <- file.path(out_dir, paste0(type, "_manhattan.png"))
    qq_file <- file.path(out_dir, paste0(type, "_qq.png"))

    ggplot2::ggsave(manha_file, manha, width = 5, height = 3, dpi = 72)
    ggplot2::ggsave(qq_file, qq, width = 3, height = 3, dpi = 72)

    expect_true(file.exists(manha_file))
    expect_true(file.info(manha_file)$size > 1000)
    expect_true(file.exists(qq_file))
    expect_true(file.info(qq_file)$size > 1000)
  }
})
