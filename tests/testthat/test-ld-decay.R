test_that("LD decay imports PopLDdecay stat files", {
  ld_dir <- extdata_dir("ld_decay/PopLDdecay")
  ld_file <- file.path(ld_dir, "final_ld.bin.gz")

  auto <- import_ld_decay(ld_file, type = "auto")
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
  expect_equal(point_plot$labels$x, "Distance (Kb)")
})

test_that("LD decay MeanBin matches PopLDdecay weighted summaries", {
  file <- tempfile(fileext = ".stat")
  writeLines(c(
    "#Dist\tMean_r^2\tMean_D'\tSum_r^2\tSum_D'\tNumberPairs",
    "5\t0.2\tNA\t2\tNA\t10",
    "8\t0.4\t0.7\t8\t7\t20",
    "110\t0.8\t0.5\t24\t15\t30"
  ), file)

  data <- import_ld_decay(
    file,
    type = "poplddecay",
    pop = "PopA",
    method = "MeanBin",
    bin1 = 10,
    bin2 = 100,
    breakpoint = 100
  )

  expect_equal(data$dist, c(10, 200))
  expect_equal(data$r2[1], 10 / 30)
  expect_equal(data$d_prime[1], 7 / 20)
  expect_equal(data$n_pairs[1], 30)
  expect_equal(data$ld_method, rep("MeanBin", 2))
})

test_that("LD decay percentile methods use pair-count weighted quantiles", {
  file <- tempfile(fileext = ".stat")
  writeLines(c(
    "#Dist\tMean_r^2\tMean_D'\tSum_r^2\tSum_D'\tNumberPairs",
    "5\t0.2\t0.1\t2\t1\t10",
    "6\t0.4\t0.3\t4\t3\t10",
    "7\t0.9\t0.8\t72\t64\t80"
  ), file)

  median <- import_ld_decay(file, type = "poplddecay", method = "MedianBin", bin1 = 10)
  percentile <- import_ld_decay(file, type = "poplddecay", method = "PercentileBin", bin1 = 10, percent = 0.95)

  expect_equal(median$r2, 0.9)
  expect_equal(median$d_prime, 0.8)
  expect_equal(percentile$r2, 0.9)
  expect_equal(percentile$ld_method, "PercentileBin")
})

test_that("LD decay plots support D prime and combined measures", {
  data <- .new_ggpop_ld_decay(data.frame(
    dist = c(10, 20),
    dist_kb = c(0.01, 0.02),
    r2 = c(0.4, 0.3),
    d_prime = c(0.7, 0.6),
    pop = "A"
  ), source = "poplddecay")

  d_plot <- plot_ld_decay(data, measure = "D")
  both_plot <- plot_ld_decay(data, measure = "both", style = "line")

  expect_silent(ggplot2::ggplot_build(d_plot))
  expect_silent(ggplot2::ggplot_build(both_plot))
  expect_equal(d_plot$labels$y, "D'")
  expect_equal(both_plot$labels$y, "LD")
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
