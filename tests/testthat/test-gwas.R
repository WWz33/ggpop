test_that("GWAS importers normalize supported sources", {
  gcta <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  gemma <- import_gwas(extdata_path("small_gemma.assoc.txt"), type = "gemma")
  emmax <- import_gwas(extdata_path("small_emmax.ps"), type = "emmax")

  expect_s3_class(gcta, "ggpop_gwas")
  expect_named(gcta, c("chr", "pos", "p", "snp", "source"), ignore.order = TRUE)
  expect_equal(gemma$source[1], "gemma")
  expect_equal(emmax$source[1], "emmax")
})

test_that("GWAS typo aliases import the same normalized data", {
  file <- extdata_path("small_gcta.mlma")

  expect_equal(improt_gwas(file, type = "gcta"), import_gwas(file, type = "gcta"))
  expect_equal(prot_gwas(file, type = "gcta"), import_gwas(file, type = "gcta"))
})

test_that("GWAS tidy ggpop pipeline builds Manhattan and QQ layers", {
  data <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")

  manha <- ggpop(data) + geom_manha()
  qq <- ggpop(data) + geom_qq()

  expect_s3_class(manha, "ggplot")
  expect_equal(length(ggplot2::ggplot_build(manha)$data), 3)
  expect_silent(ggplot2::ggplot_build(manha))
  expect_silent(ggplot2::ggplot_build(qq))
})

test_that("GWAS direct plot aligns with Manhattan geom defaults", {
  data <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")

  plot <- plot_manha(data)
  geom <- ggpop(data) + geom_manha()

  expect_s3_class(plot, "ggplot")
  expect_equal(length(ggplot2::ggplot_build(plot)$data), length(ggplot2::ggplot_build(geom)$data))
})

test_that("plot_manha and geom_manha share the same internal fastman visual contract", {
  data <- import_gwas(extdata_path("gwas/gcta.mlma"), type = "gcta")

  plot <- ggplot2::ggplot_build(plot_manha(data))
  geom_layer <- geom_manha()
  geom <- ggplot2::ggplot_build(ggpop(data) + geom_manha(data = data))

  expect_true(is.list(geom_layer))

  plot_points <- plot$data[[1]]
  geom_points <- geom$data[[1]]

  expect_equal(range(plot_points$x, na.rm = TRUE), range(geom_points$x, na.rm = TRUE))
  expect_equal(plot$layout$panel_params[[1]]$x$breaks, geom$layout$panel_params[[1]]$x$breaks)
  expect_equal(as.character(plot$layout$panel_params[[1]]$x$get_labels()), as.character(geom$layout$panel_params[[1]]$x$get_labels()))
  expect_equal(plot_points$size[1], 0.9)
  expect_equal(plot$data[[2]]$colour, "blue")
  expect_equal(plot$data[[3]]$colour, "red")
})

test_that("Manhattan geom exposes core fastman controls", {
  data <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  data$p[1] <- 1e-20

  capped <- ggplot2::ggplot_build(ggpop(data) + geom_manha(data = data, maxP = 3))
  uncapped <- ggplot2::ggplot_build(ggpop(data) + geom_manha(data = data, maxP = NULL))
  raw_p <- ggplot2::ggplot_build(ggpop(data) + geom_manha(data = data, logp = FALSE))
  bybp <- ggplot2::ggplot_build(ggpop(data) + geom_manha(data = data, bybp = TRUE))

  expect_lte(max(capped$data[[1]]$y, na.rm = TRUE), 3)
  expect_gt(max(uncapped$data[[1]]$y, na.rm = TRUE), 3)
  expect_equal(range(raw_p$data[[1]]$y, na.rm = TRUE), range(data$p, na.rm = TRUE))
  expect_length(bybp$layout$panel_params[[1]]$x$breaks, 0)
})

test_that("Manhattan geom accepts explicit chromosomal and binary palettes", {
  data <- import_gwas(extdata_path("gwas/gcta.mlma"), type = "gcta")

  chromosomal <- ggplot2::ggplot_build(ggpop(data) + geom_manha(data = data, palette = "publication"))
  binary <- ggplot2::ggplot_build(ggpop(data) + geom_manha(data = data, palette = c("#123456", "#654321"), binary = TRUE))

  expect_gt(length(unique(chromosomal$data[[1]]$colour)), 2)
  expect_true(all(unique(binary$data[[1]]$colour) %in% c("#123456", "#654321")))
})

test_that("QQ geom follows fastqq defaults for native ggplot path", {
  data <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")

  qq <- ggplot2::ggplot_build(ggpop(data) + geom_qq(data = data))
  p <- data$p[is.finite(data$p) & !is.na(data$p)]
  p[p < 0] <- 0
  p[p > 1] <- 1
  p[p == 0] <- min(p[p > 0], na.rm = TRUE)
  expected <- round(-log10(stats::ppoints(length(p))), digits = 3)
  observed <- round(-log10(sort(p)), digits = 3)
  fastqq_points <- unique(data.frame(expected = expected, observed = observed))

  expect_equal(length(qq$data), 3)
  expect_equal(range(qq$data[[1]]$x, na.rm = TRUE), range(fastqq_points$expected, na.rm = TRUE))
  expect_equal(range(qq$data[[1]]$y, na.rm = TRUE), range(fastqq_points$observed, na.rm = TRUE))
  expect_equal(qq$data[[2]]$colour, "red")
  expect_equal(qq$data[[2]]$linetype, "solid")
  expect_match(qq$data[[3]]$label, "\u03BB = ")
})

test_that("QQ geom exposes fastqq edge-case controls", {
  data <- import_gwas(extdata_path("small_gcta.mlma"), type = "gcta")
  data$p[1:3] <- c(0, 1e-20, 0.5)

  capped <- ggplot2::ggplot_build(ggpop(data) + geom_qq(data = data, maxP = 3))
  uncapped <- ggplot2::ggplot_build(ggpop(data) + geom_qq(data = data, maxP = NULL))
  no_zero_fix <- ggplot2::ggplot_build(ggpop(data) + geom_qq(data = data, fix_zero = FALSE))
  no_speedup <- ggplot2::ggplot_build(ggpop(data) + geom_qq(data = data, speedup = FALSE))

  expect_lte(max(capped$data[[1]]$y, na.rm = TRUE), 3)
  expect_gt(max(uncapped$data[[1]]$y, na.rm = TRUE), 3)
  expect_lt(nrow(no_zero_fix$data[[1]]), nrow(no_speedup$data[[1]]))
  expect_equal(nrow(no_speedup$data[[1]]), sum(is.finite(data$p) & !is.na(data$p)))
})
