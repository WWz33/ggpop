test_that("Ne history imports PSMC with scaled and absolute modes", {
  file <- extdata_path("ne_history/PSMC/sample.psmc")
  scaled <- import_ne_history(file, type = "psmc", sample_id = "psmc_a")
  absolute <- import_ne_history(
    file,
    type = "psmc",
    sample_id = "psmc_a",
    mutation_rate = 1e-8,
    generation_time = 2,
    bin_size = 100
  )

  expect_s3_class(scaled, "ggpop_ne_history")
  expect_equal(unique(scaled$method), "PSMC")
  expect_equal(unique(scaled$scale), "relative")
  expect_equal(unique(absolute$time_unit), "years")
  expect_true(all(absolute$time > scaled$time))
})

test_that("Ne history imports MSMC2 final output", {
  data <- import_ne_history(
    extdata_path("ne_history/MSMC2/final.txt"),
    type = "msmc2",
    sample_id = "msmc_a",
    mutation_rate = 1e-8
  )

  expect_s3_class(data, "ggpop_ne_history")
  expect_equal(unique(data$method), "MSMC2")
  expect_equal(unique(data$scale), "absolute")
  expect_true(all(is.finite(data$ne)))
})

test_that("Ne history imports SMC++ and Stairway Plot 2 outputs", {
  smcpp <- import_ne_history(
    extdata_path("ne_history/SMC++/model.csv"),
    type = "smcpp"
  )
  stairway <- import_ne_history(
    extdata_path("ne_history/StairwayPlot2/summary.txt"),
    type = "stairway",
    sample_id = "stairway_a"
  )

  expect_equal(unique(smcpp$method), "SMC++")
  expect_equal(sort(unique(smcpp$sample_id)), c("PopA", "PopB"))
  expect_equal(unique(stairway$method), "Stairway Plot 2")
  expect_true(all(c("ne_lower", "ne_upper") %in% names(stairway)))
})

test_that("Ne history plots build for direct and layered paths", {
  smcpp <- import_ne_history(
    extdata_path("ne_history/SMC++/model.csv"),
    type = "smcpp"
  )
  msmc <- import_ne_history(
    extdata_path("ne_history/MSMC2/final.txt"),
    type = "msmc2",
    sample_id = "msmc_a",
    mutation_rate = 1e-8
  )
  stairway <- import_ne_history(
    extdata_path("ne_history/StairwayPlot2/summary.txt"),
    type = "stairway",
    sample_id = "stairway_a"
  )

  line_plot <- plot_ne_history(smcpp)
  point_plot <- plot_ne_history(smcpp, style = "point", log_x = FALSE)
  ci_plot <- plot_ne_history(stairway, ci = TRUE)
  geom_plot <- ggpop(smcpp) + geom_ne_history()

  expect_s3_class(line_plot, "ggplot")
  expect_s3_class(point_plot, "ggplot")
  expect_s3_class(ci_plot, "ggplot")
  expect_s3_class(geom_plot, "ggplot")
  expect_silent(ggplot2::ggplot_build(line_plot))
  expect_silent(ggplot2::ggplot_build(point_plot))
  expect_silent(ggplot2::ggplot_build(ci_plot))
  expect_silent(ggplot2::ggplot_build(geom_plot))
  expect_equal(line_plot$labels$x, "Time before present (generations)")
  expect_equal(.ne_history_resolve_style(smcpp, "auto"), "line")
  expect_equal(.ne_history_resolve_style(msmc, "auto"), "step")
  expect_equal(.ne_history_resolve_style(stairway, "auto"), "step")
  expect_equal(.ne_history_resolve_style(smcpp, "point"), "point")
})

test_that("Ne history colour_by can override the default sample mapping", {
  data <- .new_ggpop_ne_history(
    data.frame(
      method = rep(c("SMC++", "MSMC2"), each = 3),
      sample_id = rep(c("PopA", "PopB"), each = 3),
      time = rep(c(1000, 5000, 20000), 2),
      ne = c(20000, 28000, 16000, 18000, 24000, 14000),
      stringsAsFactors = FALSE
    ),
    source = "example"
  )

  plot <- plot_ne_history(data, colour_by = "method")
  built <- ggplot2::ggplot_build(plot)

  expect_silent(ggplot2::ggplot_build(plot))
  expect_equal(length(unique(built$data[[1]]$colour)), 2)
})
