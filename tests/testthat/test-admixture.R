test_that("admixture importers support ADMIXTURE and limited STRUCTURE", {
  admix <- import_admixture(extdata_path("small_admixture.Q"), type = "admixture")
  structure <- import_admixture(extdata_path("small_structure.out"), type = "structure")

  expect_s3_class(admix, "ggpop_admix")
  expect_equal(unique(admix$k), 2L)
  expect_equal(unique(structure$source), "structure")
})

test_that("admixture importer reads full K result directories", {
  data <- import_admix(extdata_dir("admixture"), type = "admixture")

  expect_s3_class(data, "ggpop_admix")
  expect_equal(sort(unique(data$k)), 2:8)
  expect_equal(nrow(data[data$k == 3, , drop = FALSE]), 912)
})

test_that("admixture tidy ggpop pipeline builds", {
  data <- import_admixture(extdata_path("small_admixture.Q"), type = "admixture")
  plot <- ggpop(data) + geom_admix()

  expect_s3_class(plot, "ggplot")
  expect_silent(ggplot2::ggplot_build(plot))
})

test_that("admixture plotting supports K selection", {
  data <- import_admix(extdata_dir("admixture"), type = "admixture")

  plot_k3 <- plot_admix(data, k = 3)
  plot_all <- plot_admix(data, k = "all")
  geom_k3 <- ggpop(data) + geom_admix(k = 3)
  geom_all <- ggpop(data) + geom_admix(k = "all")

  expect_equal(nrow(ggplot2::ggplot_build(plot_k3)$data[[1]]), 912)
  expect_equal(nrow(ggplot2::ggplot_build(geom_k3)$data[[1]]), 912)
  expect_equal(nrow(ggplot2::ggplot_build(plot_all)$data[[1]]), nrow(data))
  expect_equal(nrow(ggplot2::ggplot_build(geom_all)$data[[1]]), nrow(data))
  expect_setequal(as.character(ggplot2::ggplot_build(geom_k3)$layout$layout$run_id), unique(as.character(.filter_admix_k(data, 3)$run_id)))
  expect_equal(length(unique(ggplot2::ggplot_build(plot_all)$layout$layout$PANEL)), length(unique(data$k)))
  expect_equal(length(unique(ggplot2::ggplot_build(geom_all)$layout$layout$PANEL)), length(unique(data$k)))
  expect_equal(
    ggplot2::ggplot_build(plot_all)$plot$theme$panel.grid,
    ggplot2::ggplot_build(geom_all)$plot$theme$panel.grid
  )
})
