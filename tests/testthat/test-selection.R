test_that("selective sweep scans import selscan directories and explicit files", {
  selscan_dir <- extdata_dir("selective_sweep/selscan")

  auto <- import_selection(selscan_dir, type = "selscan")
  explicit <- import_selection(
    selscan_dir,
    ihs = "chr1.ihs.out.100bins.norm",
    xpehh = "chr1.xpehh.out.norm",
    type = "selscan"
  )

  expect_s3_class(auto, "ggpop_selection")
  expect_true(all(c("stat", "chr", "pos", "value", "score_type", ".group") %in% names(auto)))
  expect_true(all(c("ihs", "nsl", "ihh12", "xpehh", "xpnsl") %in% unique(auto$stat)))
  expect_true(all(c("ihs", "xpehh") %in% unique(explicit$stat)))
  expect_true(all(is.finite(explicit$pos)))
})

test_that("selective sweep scans import XPCLR windows", {
  xpclr_dir <- extdata_dir("selective_sweep/xpclr")

  auto <- import_selection(xpclr_dir, type = "auto")
  explicit <- import_selection(
    xpclr_dir,
    xpclr = "xpclr_allchr_merged.tsv",
    type = "xpclr"
  )

  expect_s3_class(auto, "ggpop_selection")
  expect_equal(unique(auto$stat), "xpclr")
  expect_equal(unique(auto$score_type), "normalized")
  expect_true(all(c("chr", "start", "end", "pos", "value", "pos_start", "pos_stop") %in% names(auto)))
  expect_true(all(is.finite(explicit$pos)))
  expect_true(all(explicit$start <= explicit$pos & explicit$pos <= explicit$end))
})

test_that("selective sweep plots support stat, chromosome, and region filters", {
  selscan_dir <- extdata_dir("selective_sweep/selscan")
  data <- import_selection(
    selscan_dir,
    ihs = "chr1.ihs.out.100bins.norm",
    nsl = "chr1.nsl.out.100bins.norm",
    type = "selscan"
  )

  one_stat <- plot_selection(data, stat = "ihs", chr = "1")
  region <- plot_selection(data, stat = "ihs", chr = "1", start = 4497018, end = 5000000)
  geom_plot <- ggpop(data) + geom_selection(stat = c("ihs", "nsl"), chr = "1")

  expect_s3_class(one_stat, "ggplot")
  expect_s3_class(region, "ggplot")
  expect_s3_class(geom_plot, "ggplot")
  expect_silent(ggplot2::ggplot_build(one_stat))
  expect_silent(ggplot2::ggplot_build(region))
  expect_silent(ggplot2::ggplot_build(geom_plot))
  expect_null(one_stat$labels$title)

  filtered_layout <- ggplot2::ggplot_build(geom_plot)$layout$layout
  expect_setequal(as.character(filtered_layout$stat), c("ihs", "nsl"))
})

test_that("selective sweep plots support XPCLR filters", {
  xpclr_dir <- extdata_dir("selective_sweep/xpclr")
  data <- import_selection(xpclr_dir, type = "xpclr")

  plot <- plot_selection(data, stat = "xpclr", chr = "1", start = 400000, end = 450000)
  manhattan <- plot_selection(data, stat = "xpclr", style = "manhattan")
  built_manhattan <- ggplot2::ggplot_build(manhattan)

  expect_s3_class(plot, "ggplot")
  expect_s3_class(manhattan, "ggplot")
  expect_silent(ggplot2::ggplot_build(plot))
  expect_silent(ggplot2::ggplot_build(manhattan))
  expect_null(plot$labels$title)
  expect_equal(manhattan$labels$x, "Chromosome")
  expect_equal(built_manhattan$data[[1]]$size[1], 1.5)
})

test_that("selective sweep plots use unified theme and palette controls", {
  selscan_dir <- extdata_dir("selective_sweep/selscan")
  data <- import_selection(selscan_dir, ihs = "chr1.ihs.out.100bins.norm", type = "selscan")

  plot <- plot_selection(data, stat = "ihs", chr = "1", base_size = 14, base_family = "mono", palette = "population", threshold = 2)
  built <- ggplot2::ggplot_build(plot)

  expect_equal(built$plot$theme$text$family, "mono")
  expect_equal(built$plot$theme$text$size, 14)
  expect_equal(built$data[[1]]$size[1], 0.75)
  expect_true(any(vapply(built$data, function(layer) "yintercept" %in% names(layer), logical(1))))
  expect_true(all(unique(built$data[[1]]$colour) %in% ggpop_palette(8, "population")))
})

test_that("selective sweep plots support absolute values and quantile thresholds", {
  selscan_dir <- extdata_dir("selective_sweep/selscan")
  data <- import_selection(selscan_dir, ihs = "chr1.ihs.out.100bins.norm", type = "selscan")
  filtered <- data[data$stat == "ihs" & data$chr == "1", , drop = FALSE]
  expected_quantile <- stats::quantile(abs(filtered$value), probs = 0.95, na.rm = TRUE, names = FALSE)

  absolute_plot <- plot_selection(
    data,
    stat = "ihs",
    chr = "1",
    value = "absolute",
    threshold = 0.95,
    threshold_type = "quantile"
  )
  signed_plot <- plot_selection(
    data,
    stat = "ihs",
    chr = "1",
    threshold = 2,
    threshold_type = "value"
  )

  absolute_built <- ggplot2::ggplot_build(absolute_plot)
  signed_built <- ggplot2::ggplot_build(signed_plot)
  get_thresholds <- function(built) {
    unlist(lapply(built$data, function(layer) {
      if ("yintercept" %in% names(layer)) layer$yintercept else numeric()
    }), use.names = FALSE)
  }
  get_threshold_colours <- function(built) {
    unlist(lapply(built$data, function(layer) {
      if ("yintercept" %in% names(layer)) layer$colour else character()
    }), use.names = FALSE)
  }
  absolute_thresholds <- get_thresholds(absolute_built)
  signed_thresholds <- get_thresholds(signed_built)

  expect_true(all(absolute_built$data[[1]]$y >= 0, na.rm = TRUE))
  expect_equal(absolute_built$plot$labels$y, "|Selection score|")
  expect_equal(absolute_thresholds, expected_quantile, tolerance = 1e-8)
  expect_setequal(signed_thresholds, c(-2, 2))
  expect_true(all(get_threshold_colours(signed_built) == ggpop_palette(4, "publication")[4]))
  expect_equal(signed_built$data[[1]]$size[1], absolute_built$data[[1]]$size[1])
  expect_equal(absolute_built$data[[1]]$size[1], 0.75)
})

test_that("selective sweep quantile thresholds validate probabilities", {
  selscan_dir <- extdata_dir("selective_sweep/selscan")
  data <- import_selection(selscan_dir, ihs = "chr1.ihs.out.100bins.norm", type = "selscan")

  expect_error(
    ggplot2::ggplot_build(plot_selection(data, stat = "ihs", threshold = 2, threshold_type = "quantile")),
    "Quantile thresholds must be between 0 and 1"
  )
})

test_that("selective sweep plots support Manhattan-like genome style", {
  selscan_dir <- extdata_dir("selective_sweep/selscan")
  data <- import_selection(
    selscan_dir,
    ihs1 = "chr1.ihs.out.100bins.norm",
    ihs2 = "chr2.ihs.out.100bins.norm",
    type = "selscan"
  )

  explicit <- plot_selection(data, stat = "ihs", style = "manhattan", value = "absolute")
  automatic <- plot_selection(data, stat = "ihs")
  built <- ggplot2::ggplot_build(explicit)

  expect_s3_class(explicit, "ggplot")
  expect_silent(ggplot2::ggplot_build(explicit))
  expect_equal(explicit$labels$x, "Chromosome")
  expect_equal(automatic$labels$x, "Chromosome")
  expect_true(all(built$data[[1]]$y >= 0, na.rm = TRUE))
  expect_true(all(unique(built$data[[1]]$colour) %in% c("#4E79A7", "#C4E2F3")))
  expect_true(length(built$layout$panel_params[[1]]$x$get_breaks()) >= 2)
})
