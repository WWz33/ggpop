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
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")

  base_plot <- (ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point()) |>
    adjust_font(base_size = 13, base_family = "mono")

  pca_plot <- plot_pca(pca, base_size = 13, base_family = "mono")
  manha_plot <- plot_manha(gwas, base_size = 13, base_family = "mono")
  qq_plot <- plot_qq(gwas, base_size = 13, base_family = "mono")
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
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")

  plots <- list(
    plot_manha(gwas),
    plot_qq(gwas),
    plot_pca(pca),
    plot_admix(admix)
  )

  for (plot in plots) {
    expect_s3_class(plot, "ggplot")
    expect_silent(ggplot2::ggplot_build(plot))
    expect_null(plot$labels$title)
  }
})

test_that("plot wrappers add no default titles while geoms remain layers", {
  gwas <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  pca <- import_pca(extdata_path("small_plink.eigenvec"), type = "plink")
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")

  expect_null(plot_manha(gwas)$labels$title)
  expect_null(plot_qq(gwas)$labels$title)
  expect_null(plot_pca(pca)$labels$title)
  expect_null(plot_admix(admix)$labels$title)
  expect_equal(plot_manha(gwas, title = "GWAS")$labels$title, "GWAS")

  expect_true(is.list(geom_manha()))
  expect_true(is.list(geom_qq()))
  expect_true(is.list(geom_pca()))
  expect_true(is.list(geom_admix()))
})

test_that("publication geom layers align with native plot wrappers", {
  gwas <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  pca <- import_pca(extdata_path("small_plink.eigenvec"), type = "plink")
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")

  manha_geom <- ggpop(gwas) + geom_manha()
  qq_geom <- ggpop(gwas) + geom_qq()
  pca_geom <- ggpop(pca) + geom_pca()
  admix_geom <- ggpop(admix) + geom_admix(data = admix)

  expect_equal(length(ggplot2::ggplot_build(manha_geom)$data), length(ggplot2::ggplot_build(plot_manha(gwas))$data))
  expect_equal(length(ggplot2::ggplot_build(qq_geom)$data), length(ggplot2::ggplot_build(plot_qq(gwas))$data))
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
    plot_manha()

  expect_s3_class(manha, "ggplot")
  expect_silent(ggplot2::ggplot_build(manha))

  if (requireNamespace("pophelper", quietly = TRUE)) {
    pophelper_plot <- suppressWarnings(
      import_admix(extdata_path("small_admixture.Q"), type = "admixture") |>
        plot_admixture_pophelper()
    )

    expect_type(pophelper_plot, "list")
  }
})

test_that("original-package compatibility adapters are available", {
  gwas <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")
  qlist <- as_pophelper_qlist(admix)

  expect_type(qlist, "list")
  expect_named(qlist)
  expect_equal(ncol(qlist[[1]]), 2)

  expect_s3_class(plot_manha(gwas), "ggplot")
  expect_s3_class(plot_qq(gwas), "ggplot")

  if (requireNamespace("pophelper", quietly = TRUE)) {
    expect_type(suppressWarnings(plot_admixture_pophelper(admix)), "list")
  }
})
