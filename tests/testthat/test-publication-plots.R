test_that("publication theme and palettes are configurable", {
  expect_s3_class(theme_ggpop_publication(), "theme")
  base_plot <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) + ggplot2::geom_point()
  expect_s3_class(theme_tidyplot(base_plot), "ggplot")
  expect_s3_class(adjust_font(base_plot), "ggplot")
  expect_s3_class(theme_ggplot2(base_plot), "ggplot")
  expect_s3_class(theme_minimal_xy(base_plot), "ggplot")
  expect_s3_class(theme_minimal_x(base_plot), "ggplot")
  expect_s3_class(theme_minimal_y(base_plot), "ggplot")
  expect_length(ggpop_palette(4, "admixture"), 4)
  expect_s3_class(scale_fill_ggpop(3), "ScaleDiscrete")
})

test_that("font adjustment propagates through publication plotting helpers", {
  gwas <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  pca <- import_pca(extdata_path("small_plink.eigenvec"), type = "plink")
  admix <- import_admixture(extdata_path("small_admixture.Q"), type = "admixture")

  base_plot <- (ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()) |>
    adjust_font(base_size = 13, base_family = "mono")

  pca_plot <- plot_pca(pca, base_size = 13, base_family = "mono")
  manha_plot <- plot_manha(gwas, use_fastman = FALSE, base_size = 13, base_family = "mono")
  qq_plot <- plot_qq(gwas, use_fastman = FALSE, base_size = 13, base_family = "mono")
  admix_plot <- plot_admix(admix, base_size = 8, show_sample_labels = TRUE)

  expect_equal(ggplot2::ggplot_build(base_plot)$plot$theme$text$family, "mono")
  expect_equal(ggplot2::ggplot_build(pca_plot)$plot$theme$text$family, "mono")
  expect_equal(ggplot2::ggplot_build(manha_plot)$plot$theme$text$family, "mono")
  expect_equal(ggplot2::ggplot_build(qq_plot)$plot$theme$text$family, "mono")
  expect_equal(ggplot2::ggplot_build(admix_plot)$plot$theme$axis.text.x$size, 8)
})

test_that("publication plotting wrappers build native ggplot outputs", {
  gwas <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  pca <- import_pca(
    extdata_path("small_plink.eigenvec"),
    type = "plink",
    eigenval = extdata_path("small_plink.eigenval")
  )
  admix <- import_admixture(extdata_path("small_admixture.Q"), type = "admixture")

  plots <- list(
    plot_manha(gwas, use_fastman = FALSE),
    plot_qq(gwas, use_fastman = FALSE),
    plot_pca(pca),
    plot_admix(admix)
  )

  for (plot in plots) {
    expect_s3_class(plot, "ggplot")
    expect_silent(ggplot2::ggplot_build(plot))
  }
})

test_that("publication geom layers align with native plot wrappers", {
  gwas <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  pca <- import_pca(extdata_path("small_plink.eigenvec"), type = "plink")
  admix <- import_admixture(extdata_path("small_admixture.Q"), type = "admixture")

  manha_geom <- ggpop(gwas) + geom_manha_pub()
  qq_geom <- ggpop(gwas) + geom_qq_pub()
  pca_geom <- ggpop(pca) + geom_pca_pub()
  admix_geom <- ggpop(admix) + geom_admix_pub(data = admix)

  expect_equal(length(ggplot2::ggplot_build(manha_geom)$data), length(ggplot2::ggplot_build(plot_manha(gwas, use_fastman = FALSE))$data))
  expect_equal(length(ggplot2::ggplot_build(qq_geom)$data), length(ggplot2::ggplot_build(plot_qq(gwas, use_fastman = FALSE))$data))
  expect_equal(nrow(ggplot2::ggplot_build(pca_geom)$data[[1]]), nrow(ggplot2::ggplot_build(plot_pca(pca))$data[[1]]))
  expect_equal(nrow(ggplot2::ggplot_build(admix_geom)$data[[1]]), nrow(ggplot2::ggplot_build(plot_admix(admix))$data[[1]]))
  expect_equal(
    ggplot2::ggplot_build(qq_geom)$plot$theme$axis.line,
    ggplot2::ggplot_build(theme_tidyplot(ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y))))$plot$theme$axis.line
  )
  expect_equal(
    ggplot2::ggplot_build(pca_geom)$plot$theme$axis.line,
    ggplot2::ggplot_build(theme_tidyplot(ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y))))$plot$theme$axis.line
  )
  expect_equal(
    ggplot2::ggplot_build(admix_geom)$plot$theme$axis.text.x,
    ggplot2::ggplot_build(plot_admix(admix))$plot$theme$axis.text.x
  )
})

test_that("publication wrappers support tidy pipe style", {
  manha <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta") |>
    plot_manha(use_fastman = FALSE)

  expect_s3_class(manha, "ggplot")
  expect_silent(ggplot2::ggplot_build(manha))

  if (requireNamespace("pophelper", quietly = TRUE)) {
    pophelper_plot <- suppressWarnings(
      import_admixture(extdata_path("small_admixture.Q"), type = "admixture") |>
        plot_admixture_pophelper()
    )

    expect_type(pophelper_plot, "list")
  }
})

test_that("original-package compatibility adapters are available", {
  gwas <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  admix <- import_admixture(extdata_path("small_admixture.Q"), type = "admixture")
  qlist <- as_pophelper_qlist(admix)

  expect_type(qlist, "list")
  expect_named(qlist)
  expect_equal(ncol(qlist[[1]]), 2)

  if (requireNamespace("fastman", quietly = TRUE)) {
    expect_s3_class(plot_manha(gwas, use_fastman = TRUE), "ggplot")
    expect_s3_class(plot_qq(gwas, use_fastman = TRUE), "ggplot")
  }

  if (requireNamespace("pophelper", quietly = TRUE)) {
    expect_type(suppressWarnings(plot_admixture_pophelper(admix)), "list")
  }
})
