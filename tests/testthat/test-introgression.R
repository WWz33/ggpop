test_that("introgression imports Dsuite Dtrios summaries", {
  data <- import_introgression(
    extdata_path("introgression/Dsuite/Dtrios.tsv"),
    type = "dsuite_dtrios"
  )

  expect_s3_class(data, "ggpop_introgression")
  expect_equal(unique(data$analysis), "trio")
  expect_true(all(c("pop1", "pop2", "pop3", "trio", "value", ".group") %in% names(data)))
  expect_equal(data$value[1], 0.18)
  expect_equal(data$z_score[1], 4.2)
})

test_that("introgression imports window statistics from Dsuite and genomics_general", {
  dsuite <- import_introgression(
    extdata_path("introgression/Dsuite/Dinvestigate.tsv"),
    type = "dsuite_dinvestigate"
  )
  genomics <- import_introgression(
    extdata_path("introgression/genomics_general/ABBABABA_window.tsv"),
    type = "genomics_general"
  )

  expect_equal(unique(dsuite$analysis), "window")
  expect_true(all(c("D", "fd", "fdM", "df") %in% unique(dsuite$stat)))
  expect_true(all(c("D", "fd", "fdM") %in% unique(genomics$stat)))
  expect_true(all(is.finite(dsuite$pos)))
  expect_true(all(is.finite(genomics$value)))
})

test_that("introgression imports VCF/pop-derived genomics_general-style example", {
  data <- import_introgression(
    extdata_path("introgression/vcf_pop_example/ABBABABA_window.tsv"),
    type = "genomics_general"
  )

  expect_s3_class(data, "ggpop_introgression")
  expect_equal(unique(data$analysis), "window")
  expect_true(all(c("D", "fd", "fdM") %in% unique(data$stat)))
  expect_equal(unique(data$pop1), "PopA")
  expect_equal(unique(data$pop2), "PopB")
  expect_equal(unique(data$pop3), "PopC")
  expect_true(all(data$sitesused > 0))
})

test_that("introgression imports graph edge lists", {
  treemix <- import_introgression(
    extdata_path("introgression/TreeMix/migration_edges.tsv"),
    type = "treemix"
  )
  qpgraph <- import_introgression(
    extdata_path("introgression/ADMIXTOOLS2/qpgraph_edges.tsv"),
    type = "qpgraph"
  )

  expect_equal(unique(treemix$analysis), "graph")
  expect_equal(unique(qpgraph$analysis), "graph")
  expect_true(all(c("from", "to", "value") %in% names(treemix)))
  expect_true(all(c("lower", "upper") %in% names(qpgraph)))
})

test_that("introgression plots build across data styles", {
  window <- import_introgression(
    extdata_path("introgression/genomics_general/ABBABABA_window.tsv"),
    type = "genomics_general"
  )
  trio <- import_introgression(
    extdata_path("introgression/Dsuite/Dtrios.tsv"),
    type = "dsuite_dtrios"
  )
  graph <- import_introgression(
    extdata_path("introgression/TreeMix/migration_edges.tsv"),
    type = "treemix"
  )

  window_plot <- plot_introgression(window, stat = c("D", "fdM"))
  region_plot <- plot_introgression(window, stat = "D", chr = "1")
  trio_plot <- plot_introgression(trio)
  graph_plot <- plot_introgression(graph)
  geom_plot <- ggpop(window) + geom_introgression(stat = "D")

  expect_s3_class(window_plot, "ggplot")
  expect_s3_class(region_plot, "ggplot")
  expect_s3_class(trio_plot, "ggplot")
  expect_s3_class(graph_plot, "ggplot")
  expect_s3_class(geom_plot, "ggplot")
  expect_silent(ggplot2::ggplot_build(window_plot))
  expect_silent(ggplot2::ggplot_build(region_plot))
  expect_silent(ggplot2::ggplot_build(trio_plot))
  expect_silent(ggplot2::ggplot_build(graph_plot))
  expect_silent(ggplot2::ggplot_build(geom_plot))
  expect_equal(region_plot$labels$x, "Position (Mb)")
  expect_equal(window_plot$labels$x, "Chromosome")

  built_window <- ggplot2::ggplot_build(window_plot)
  built_region <- ggplot2::ggplot_build(region_plot)
  expect_true("size" %in% names(built_window$data[[1]]))
  expect_equal(built_window$data[[1]]$size[1], 1.5)
  expect_true(all(unique(built_window$data[[1]]$colour) %in% c("#4E79A7", "#C4E2F3")))
  expect_true("linewidth" %in% names(built_region$data[[1]]))
  expect_true("size" %in% names(built_region$data[[2]]))
})
