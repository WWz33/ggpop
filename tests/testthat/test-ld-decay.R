test_that("LD decay imports PopLDdecay stat files", {
  ld_dir <- extdata_dir("ld_decay/PopLDdecay")

  auto <- import_ld_decay(ld_dir, type = "auto")
  explicit <- import_ld_decay(
    ld_dir,
    soybean = "final_ld.stat.gz",
    type = "poplddecay"
  )

  expect_s3_class(auto, "ggpop_ld_decay")
  expect_true(all(c("dist", "dist_kb", "r2", "pop", "n_pairs", ".group") %in% names(auto)))
  expect_true(all(is.finite(auto$dist)))
  expect_true(all(is.finite(auto$dist_kb)))
  expect_true(all(is.finite(auto$r2)))
  expect_equal(auto$dist_kb[1], auto$dist[1] / 1000)
  expect_equal(unique(explicit$pop), "soybean")
  expect_true(is.unsorted(auto$dist, strictly = FALSE) == FALSE)
})

test_that("LD decay plots support point and line styles", {
  ld_dir <- extdata_dir("ld_decay/PopLDdecay")
  data <- import_ld_decay(ld_dir, pop = "PopLDdecay", type = "poplddecay")

  point_plot <- plot_ld_decay(data, style = "point")
  line_plot <- plot_ld_decay(data, style = "line")
  geom_plot <- ggpop(data) + geom_ld_decay(style = "point")

  expect_s3_class(point_plot, "ggplot")
  expect_s3_class(line_plot, "ggplot")
  expect_s3_class(geom_plot, "ggplot")
  expect_silent(ggplot2::ggplot_build(point_plot))
  expect_silent(ggplot2::ggplot_build(line_plot))
  expect_silent(ggplot2::ggplot_build(geom_plot))
  expect_null(point_plot$labels$title)

  point_built <- ggplot2::ggplot_build(point_plot)
  line_built <- ggplot2::ggplot_build(line_plot)
  expect_equal(point_built$data[[1]]$size[1], 1)
  expect_equal(line_built$data[[1]]$linewidth[1], 11 / 22)
  expect_equal(point_plot$labels$x, "Pairwise distance in Kb")
})

test_that("LD decay plots support population filtering and palettes", {
  ld_dir <- extdata_dir("ld_decay/PopLDdecay")
  a <- import_ld_decay(ld_dir, pop = "A", type = "poplddecay")
  b <- import_ld_decay(ld_dir, pop = "B", type = "poplddecay")
  data <- .new_ggpop_ld_decay(rbind(as.data.frame(a), as.data.frame(b)), source = "poplddecay")

  filtered <- plot_ld_decay(data, pop = "A", palette = "publication", base_size = 14, base_family = "mono")
  built <- ggplot2::ggplot_build(filtered)

  expect_equal(unique(built$plot$data$pop), "A")
  expect_equal(built$plot$theme$text$family, "mono")
  expect_equal(built$plot$theme$text$size, 14)
  expect_true(all(unique(built$data[[1]]$colour) %in% ggpop_palette(8, "publication")))
})

test_that("LD decay imports map file labels through pop_group", {
  ld_dir <- extdata_dir("ld_decay/PopLDdecay")
  group <- data.frame(sample = "sample_a", pop = "PopA")

  data <- import_ld_decay(
    ld_dir,
    pop = "sample_a",
    pop_group = group,
    type = "poplddecay"
  )

  expect_equal(unique(data$sample_id), "sample_a")
  expect_equal(unique(data$pop), "PopA")
})
