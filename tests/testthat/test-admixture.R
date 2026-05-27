test_that("admixture importers support ADMIXTURE and limited STRUCTURE", {
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")
  structure <- import_admix(extdata_path("small_structure.out"), type = "structure")

  expect_s3_class(admix, "ggpop_admix")
  expect_equal(unique(admix$k), 2L)
  expect_equal(unique(structure$source), "structure")
})

test_that("admixture compatibility alias returns the same typed data", {
  file <- extdata_path("small_admixture.Q")

  expect_equal(import_admixture(file, type = "admixture"), import_admix(file, type = "admixture"))
})

test_that("admixture importer reads full K result directories", {
  data <- import_admix(extdata_dir("admixture"), type = "admixture")

  expect_s3_class(data, "ggpop_admix")
  expect_equal(sort(unique(data$k)), 2:8)
  expect_equal(nrow(data[data$k == 3, , drop = FALSE]), 912)
})

test_that("admixture tidy ggpop pipeline builds", {
  data <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")
  plot <- ggpop(data) + geom_admix()
  built <- ggplot2::ggplot_build(plot)

  expect_s3_class(plot, "ggplot")
  expect_s3_class(built, "ggplot_built")
})

test_that("admixture plotting supports K selection", {
  data <- import_admix(extdata_dir("admixture"), type = "admixture")
  layer_rows <- function(built, index = 1L) {
    layer <- built$data[[index]]
    if (is.data.frame(layer)) {
      return(nrow(layer))
    }
    if (is.list(layer)) {
      return(sum(vapply(layer, function(x) if (is.data.frame(x)) nrow(x) else 0L, integer(1))))
    }
    NA_integer_
  }

  plot_k3 <- plot_admix(data, k = 3)
  plot_all <- plot_admix(data, k = "all")
  geom_k3 <- ggpop(data) + geom_admix(k = 3)
  geom_all <- ggpop(data) + geom_admix(k = "all")

  expect_equal(layer_rows(ggplot2::ggplot_build(plot_k3)), 912)
  expect_equal(layer_rows(ggplot2::ggplot_build(geom_k3)), 912)
  expect_equal(layer_rows(ggplot2::ggplot_build(plot_all)), nrow(data))
  expect_equal(layer_rows(ggplot2::ggplot_build(geom_all)), nrow(data))
  expect_setequal(as.character(ggplot2::ggplot_build(geom_k3)$layout$layout$run_id), unique(as.character(.filter_admix_k(data, 3)$run_id)))
  expect_equal(length(unique(ggplot2::ggplot_build(plot_all)$layout$layout$PANEL)), length(unique(data$k)))
  expect_equal(length(unique(ggplot2::ggplot_build(geom_all)$layout$layout$PANEL)), length(unique(data$k)))
  expect_equal(
    ggplot2::ggplot_build(plot_all)$plot$theme$panel.grid,
    ggplot2::ggplot_build(geom_all)$plot$theme$panel.grid
  )
})

test_that("admixture style argument moved to admix2", {
  data <- import_admix(extdata_dir("admixture"), type = "admixture")

  expect_error(plot_admix(data, k = 3, style = "publication"), "no longer supported")
  expect_error(ggpop(data) + geom_admix(k = 3, style = "publication"), "no longer supported")
})

test_that("admixture ggplot-style admix2 builds with script-like defaults", {
  data <- import_admix(extdata_dir("admixture"), type = "admixture")
  group <- data.frame(
    sample_id = unique(data$sample_id),
    pop = rep(c("PopA", "PopB"), length.out = length(unique(data$sample_id)))
  )
  layer_rows <- function(built, index = 1L) {
    layer <- built$data[[index]]
    if (is.data.frame(layer)) {
      return(nrow(layer))
    }
    if (is.list(layer)) {
      return(sum(vapply(layer, function(x) if (is.data.frame(x)) nrow(x) else 0L, integer(1))))
    }
    NA_integer_
  }
  grouped <- import_admix(
    extdata_dir("admixture"),
    type = "admixture",
    pop_group = group
  )

  plot_admix2_k3 <- plot_admix2(data, k = 3)
  geom_admix2_k3 <- ggpop(data) + geom_admix2(k = 3)
  grouped_k3 <- plot_admix2(grouped, k = 3)

  built_plot <- ggplot2::ggplot_build(plot_admix2_k3)
  built_geom <- ggplot2::ggplot_build(geom_admix2_k3)
  built_grouped <- ggplot2::ggplot_build(grouped_k3)

  expect_s3_class(plot_admix2_k3, "ggplot")
  expect_s3_class(geom_admix2_k3, "ggplot")
  expect_equal(layer_rows(built_plot), 912)
  expect_equal(layer_rows(built_geom), 912)
  expect_s3_class(built_plot$plot$theme$panel.grid, "element_blank")
  expect_s3_class(built_geom$plot$theme$panel.grid, "element_blank")
  expect_equal(plot_admix2_k3$labels$x, "Samples")
  expect_equal(plot_admix2_k3$labels$y, "Ancestry proportion")
  expect_true(inherits(built_plot$plot$scales$get_scales("fill"), "ScaleDiscrete"))
  expect_gt(length(unique(built_grouped$data[[1]]$PANEL)), 1)
})

test_that("admix2 follows the Daphnia script ordering, faceting, and theme contract", {
  q <- data.frame(
    sample_id = rep(c("zeta", "alpha", "middle"), each = 3),
    run_id = "example.3.Q",
    k = 3L,
    cluster = rep(c("K1", "K2", "K3"), times = 3),
    proportion = c(0.10, 0.80, 0.10, 0.90, 0.05, 0.05, 0.70, 0.20, 0.10),
    Species = rep(c("SpA", "SpB", "SpC"), each = 3),
    Continent = rep(c("NA", "EU", "AS"), each = 3),
    stringsAsFactors = FALSE
  )
  class(q) <- unique(c("ggpop_admix", class(q)))

  prepared <- .prepare_admix2_plot_data(q, k = 3, group = c("Species", "Continent"))
  plot <- plot_admix2(q, k = 3, group = c("Species", "Continent"))
  built <- ggplot2::ggplot_build(plot)
  theme <- built$plot$theme

  expect_identical(levels(prepared$sample_label), c("2", "3", "1"))
  expect_identical(unique(as.character(prepared$sample_label)), c("2", "3", "1"))
  expect_identical(levels(prepared$.facet_group), c("SpB EU", "SpC AS", "SpA NA"))
  expect_identical(levels(prepared$.run_label), "K=3")
  expect_s3_class(built$plot$facet, "FacetGrid")
  expect_identical(built$plot$facet$params$free$x, TRUE)
  expect_identical(built$plot$facet$params$free$y, TRUE)
  expect_identical(built$plot$facet$params$space_free$x, FALSE)
  expect_identical(built$plot$facet$params$space_free$y, FALSE)
  expect_true(inherits(built$plot$scales$get_scales("fill"), "ScaleDiscrete"))
  expect_s3_class(theme$panel.grid, "element_blank")
  expect_equal(theme$strip.text$face, "bold.italic")
  expect_equal(theme$strip.text$size, 12)
  expect_equal(theme$strip.text$angle, 30)
  expect_equal(theme$legend.position, "none")
  expect_s3_class(theme$axis.text.x, "element_blank")
  expect_s3_class(theme$axis.text.y, "element_blank")
  expect_equal(theme$axis.title.x$face, "bold")
  expect_equal(theme$axis.title.x$size, 18)
  expect_equal(theme$axis.title$size, 20)
})

test_that("admix2 orders multi-K facets numerically", {
  q <- data.frame(
    sample_id = c("s1", "s1"),
    run_id = c("example.10.Q", "example.2.Q"),
    k = c(10L, 2L),
    cluster = c("K1", "K1"),
    proportion = c(1, 1),
    pop = c("PopA", "PopA"),
    stringsAsFactors = FALSE
  )
  class(q) <- unique(c("ggpop_admix", class(q)))

  plot <- plot_admix2(q, k = "all")
  built <- ggplot2::ggplot_build(plot)
  prepared <- .prepare_admix2_plot_data(q, k = "all")

  expect_identical(levels(built$plot$data$.run_label), c("K=2", "K=10"))
  expect_identical(unique(as.character(prepared$.run_label)), c("K=2", "K=10"))
  expect_identical(levels(prepared$cluster), "K1")
})

test_that("admix2 orders numeric-looking clusters numerically", {
  q <- data.frame(
    sample_id = rep(c("s1", "s2"), each = 3),
    run_id = "example.3.Q",
    k = 3L,
    cluster = rep(c("K1", "K10", "K2"), times = 2),
    proportion = c(0.2, 0.5, 0.3, 0.3, 0.2, 0.5),
    pop = rep(c("PopA", "PopB"), each = 3),
    stringsAsFactors = FALSE
  )
  class(q) <- unique(c("ggpop_admix", class(q)))

  prepared <- .prepare_admix2_plot_data(q, k = 3)

  expect_identical(levels(prepared$cluster), c("K1", "K2", "K10"))
})
