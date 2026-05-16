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
