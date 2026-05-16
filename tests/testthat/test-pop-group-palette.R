test_that("population group files import and join to PCA/admixture", {
  groups <- import_pop_group(extdata_path("pop_group.txt"))
  expect_named(groups, c("sample_id", "pop"))
  expect_equal(nrow(groups), 304)

  pca <- import_pca(
    extdata_path("pca/gcta.eigenvec"),
    type = "gcta",
    pop_group = extdata_path("pop_group.txt")
  )
  expect_true("pop" %in% names(pca))
  expect_false(anyNA(pca$pop))

  admix <- import_admix(
    extdata_dir("admixture"),
    type = "admixture",
    ind = extdata_path("snp/finalsnp_ld.fam"),
    pop_group = extdata_path("pop_group.txt")
  )
  expect_true("pop" %in% names(admix))
  expect_false(anyNA(admix$pop))
})

test_that("discrete population palettes downsample and interpolate", {
  expect_s3_class(colors_pop_okabeito, "ggpop_palette_scheme")
  expect_length(ggpop_palette(3, "population"), 3)
  expect_length(ggpop_palette(20, "population"), 20)
  expect_s3_class(scale_colour_ggpop("population"), "ScaleDiscrete")
  expect_s3_class(scale_fill_ggpop("admixture"), "ScaleDiscrete")
})

test_that("PCA defaults to population colour when pop is present", {
  pca <- import_pca(
    extdata_path("pca/gcta.eigenvec"),
    type = "gcta",
    pop_group = extdata_path("pop_group.txt")
  )

  plot <- plot_pca(pca)
  built <- ggplot2::ggplot_build(plot)

  expect_s3_class(plot, "ggplot")
  expect_silent(ggplot2::ggplot_build(plot))
  expect_equal(length(unique(built$data[[1]]$colour)), length(unique(pca$pop)))
})

test_that("admixture implements pophelper-style group labels and sorting", {
  admix <- import_admix(
    extdata_dir("admixture"),
    type = "admixture",
    ind = extdata_path("snp/finalsnp_ld.fam"),
    pop_group = extdata_path("pop_group.txt")
  )

  grouped <- plot_admix(
    admix,
    k = 3,
    sort = "all",
    order_group = TRUE,
    show_group_labels = TRUE,
    show_sample_labels = TRUE
  )
  built <- ggplot2::ggplot_build(grouped)
  layout <- built$layout$layout

  expect_s3_class(grouped, "ggplot")
  expect_true(".facet_group" %in% names(layout))
  expect_equal(sort(unique(as.character(layout$.facet_group))), sort(unique(admix$pop)))
  expect_false(is.null(built$plot$theme$axis.text.x))
})
