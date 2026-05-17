test_that("population genomics statistics import pixy directories and explicit files", {
  pixy_dir <- extdata_dir("Population_genomics_statistics/pixy")

  auto <- import_stats(pixy_dir, type = "pixy")
  explicit <- import_stats(
    pixy_dir,
    pi = "pixy_pi.txt",
    fst = "pixy_fst.txt",
    tajima = "pixy_tajima_d.txt",
    type = "pixy"
  )

  expect_s3_class(auto, "ggpop_stats")
  expect_true(all(c("stat", "chr", "start", "end", "pos", "value", ".group") %in% names(auto)))
  expect_true(all(c("pi", "fst", "tajima_d") %in% unique(explicit$stat)))
  expect_true(all(c("dxy", "fst", "pi", "tajima_d", "watterson_theta") %in% unique(auto$stat)))
})

test_that("population genomics statistics import vcftools result directories", {
  vcftools_dir <- extdata_dir("Population_genomics_statistics/vcftools")

  auto <- import_stats(vcftools_dir, type = "vcftools")
  explicit <- import_stats(
    vcftools_dir,
    pi = "vcftools.windowed.pi",
    fst = "vcftools.windowed.weir.fst",
    tajima = "vcftools.Tajima.D",
    type = "vcftools"
  )

  expect_s3_class(auto, "ggpop_stats")
  expect_true(all(c("pi", "fst", "tajima_d") %in% unique(auto$stat)))
  expect_true(all(c("stat", "chr", "start", "end", "pos", "value", ".group") %in% names(explicit)))
  expect_true(all(is.finite(explicit$pos)))
  expect_true(all(explicit$end >= explicit$start))
})

test_that("population genomics statistics plots support stat, chromosome, and region filters", {
  pixy_dir <- extdata_dir("Population_genomics_statistics/pixy")
  data <- import_stats(pixy_dir, type = "pixy")

  one_chr <- plot_stats(data, stat = c("fst", "pi"), chr = "chr2L")
  region <- plot_stats(data, chr = "chr2L", start = 1, end = 20000)
  multi_chr <- plot_stats(data, chr = c("chr2L", "chr3L"))
  geom_plot <- ggpop(data) + geom_stats(stat = "all", chr = c("chr2L", "chr3L"))

  expect_s3_class(one_chr, "ggplot")
  expect_s3_class(region, "ggplot")
  expect_s3_class(multi_chr, "ggplot")
  expect_s3_class(geom_plot, "ggplot")
  expect_silent(ggplot2::ggplot_build(one_chr))
  expect_silent(ggplot2::ggplot_build(region))
  expect_silent(ggplot2::ggplot_build(multi_chr))
  expect_silent(ggplot2::ggplot_build(geom_plot))
  expect_null(one_chr$labels$title)
  all_stats_layout <- ggplot2::ggplot_build(plot_stats(data, stat = "all"))$layout$layout
  expect_equal(length(unique(all_stats_layout$COL)), 1)
  expect_equal(length(unique(all_stats_layout$ROW)), length(unique(data$stat)))

  filtered_layout <- ggplot2::ggplot_build(
    ggpop(data) + geom_stats(stat = c("fst", "pi"), chr = "chr2L")
  )$layout$layout
  expect_setequal(as.character(filtered_layout$stat), c("fst", "pi"))
})

test_that("population genomics statistics use unified theme and palette controls", {
  pixy_dir <- extdata_dir("Population_genomics_statistics/pixy")
  data <- import_stats(pixy_dir, type = "pixy")

  plot <- plot_stats(data, stat = "fst", chr = "chr2L", base_size = 14, base_family = "mono", palette = "population")
  built <- ggplot2::ggplot_build(plot)

  expect_equal(built$plot$theme$text$family, "mono")
  expect_equal(built$plot$theme$text$size, 14)
  expect_equal(built$data[[1]]$linewidth[1], 14 / 44)
  expect_true(all(unique(built$data[[1]]$colour) %in% ggpop_palette(8, "population")))
})
