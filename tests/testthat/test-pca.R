test_that("PCA importers normalize PLINK and GCTA eigenvectors", {
  plink <- import_pca(
    extdata_path("small_plink.eigenvec"),
    type = "plink",
    eigenval = extdata_path("small_plink.eigenval")
  )
  gcta <- import_pca(extdata_path("small_gcta.eigenvec"), type = "gcta")

  expect_s3_class(plink, "ggpop_pca")
  expect_equal(plink$sample_id, c("I1", "I2", "I3"))
  expect_equal(attr(plink, "eigenvalues"), c(2, 1))
  expect_s3_class(gcta, "ggpop_pca")
})

test_that("PCA tidy ggpop pipeline builds", {
  data <- import_pca(extdata_path("small_plink.eigenvec"), type = "plink")
  plot <- ggpop(data) + geom_pca()

  expect_s3_class(plot, "ggplot")
  expect_silent(ggplot2::ggplot_build(plot))
})

test_that("PCA geom labels axes with variance contribution when available", {
  data <- import_pca(
    extdata_path("small_plink.eigenvec"),
    type = "plink",
    eigenval = extdata_path("small_plink.eigenval")
  )

  geom_plot <- ggpop(data) + geom_pca()
  explicit_geom_plot <- ggpop(data) + geom_pca(data = data)
  wrapper_plot <- plot_pca(data)

  expect_equal(geom_plot$labels$x, wrapper_plot$labels$x)
  expect_equal(geom_plot$labels$y, wrapper_plot$labels$y)
  expect_equal(explicit_geom_plot$labels$x, wrapper_plot$labels$x)
  expect_equal(explicit_geom_plot$labels$y, wrapper_plot$labels$y)
})
