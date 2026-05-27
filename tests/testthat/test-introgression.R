test_that("introgression imports Dsuite global trio summaries", {
  bbaa <- import_introgression(
    extdata_path("introgression/Dsuite/dsuite_results_BBAA.txt"),
    type = "dsuite_dtrios"
  )
  dmin <- import_introgression(
    extdata_path("introgression/Dsuite/dsuite_results_Dmin.txt"),
    type = "dsuite_dtrios"
  )

  expect_s3_class(bbaa, "ggpop_introgression")
  expect_equal(unique(bbaa$analysis), "trio")
  expect_equal(unique(bbaa$stat), "D")
  expect_true(all(c("pop1", "pop2", "pop3", "trio", "value", "z_score", "p_value", "f4_ratio") %in% names(bbaa)))
  expect_equal(nrow(bbaa), 12)
  expect_equal(nrow(dmin), 6)
  expect_equal(bbaa$pop1[[1]], "Highland_East")
  expect_equal(bbaa$pop2[[1]], "Highland_West")
  expect_equal(bbaa$pop3[[1]], "Lowland_North")
  expect_gt(abs(bbaa$value[[1]]), 0)
  expect_true(any(bbaa$value < 0))
  expect_true(any(bbaa$p_value < 0.05))
  expect_equal(unique(dmin$analysis), "trio")
})

test_that("introgression imports Dsuite localFstats as ordered window statistics", {
  data <- import_introgression(
    extdata_path("introgression/Dsuite/PopB_PopC_PopA_localFstats_run1_100_50.txt"),
    type = "dsuite_dinvestigate"
  )

  expect_s3_class(data, "ggpop_introgression")
  expect_equal(unique(data$analysis), "window")
  expect_true(all(c("D", "fd", "fdM", "df") %in% unique(data$stat)))
  expect_true(all(c("chr", "start", "end", "pos", "value", ".group") %in% names(data)))
  expect_true(all(is.finite(data$pos)))

  ordered <- .introgression_order_window_data(data)
  expect_equal(unique(ordered$chr)[[1]], "1")
  expect_true(is.unsorted(ordered$pos[ordered$chr == "1"], strictly = FALSE) == FALSE)
})

test_that("introgression imports ADMIXTOOLS statistic outputs as trio summaries", {
  qpdstat <- import_introgression(
    extdata_path("introgression/admixtools/qpdstat_result.csv"),
    type = "admixtools"
  )
  f3 <- import_introgression(
    extdata_path("introgression/admixtools/f3_result.csv"),
    type = "admixtools"
  )
  f4ratio <- import_introgression(
    extdata_path("introgression/admixtools/f4ratio_result.csv"),
    type = "admixtools"
  )

  expect_equal(unique(qpdstat$analysis), "trio")
  expect_equal(unique(qpdstat$stat), "D")
  expect_equal(unique(f3$stat), "f3")
  expect_equal(unique(f4ratio$stat), "f4_ratio")
  expect_equal(nrow(qpdstat), 6)
  expect_equal(nrow(f3), 6)
  expect_equal(nrow(f4ratio), 5)
  expect_true(all(c("se", "z_score", "p_value") %in% names(qpdstat)))
  expect_true(all(c("pop4", "pop5") %in% names(f4ratio)))
  expect_true(any(f3$value < 0))
  expect_false(any(c("from", "to") %in% names(qpdstat)))
})

test_that("introgression imports TreeMix internal outputs as lightweight graph summaries", {
  edges <- import_introgression(
    extdata_path("introgression/treemix/treemix.M1.edges.gz"),
    type = "treemix"
  )
  treeout <- import_introgression(
    extdata_path("introgression/treemix/treemix.M1.treeout.gz"),
    type = "treemix"
  )

  expect_s3_class(edges, "ggpop_introgression")
  expect_equal(unique(edges$analysis), "graph")
  expect_true(all(c("tree", "migration") %in% unique(edges$stat)))
  expect_true(all(c("from", "to", "value", "drift") %in% names(edges)))
  expect_true(all(c("x", "y", "xend", "yend", "layout") %in% names(edges)))
  expect_equal(unique(edges$layout), "treemix")
  expect_true(all(stats::complete.cases(edges[, c("x", "y", "xend", "yend")])))
  expect_gt(max(edges$xend, na.rm = TRUE), max(edges$x, na.rm = TRUE))
  expect_equal(unique(treeout$stat), "migration")
  expect_equal(unique(treeout$format), "treemix_treeout")

  layout <- .introgression_graph_layout(edges)
  expect_true(any(!layout$nodes$is_tip))
  expect_false(any(grepl("^node_", layout$nodes$.label[layout$nodes$is_tip])))

  migration_edges <- layout$edges[layout$edges$stat == "migration", , drop = FALSE]
  label_nodes <- .introgression_graph_label_nodes(
    layout$nodes[layout$nodes$is_tip, , drop = FALSE],
    migration_edges,
    nudge_x = 0.002,
    nudge_y = 0.045
  )
  migration_target <- label_nodes[label_nodes$node == migration_edges$to[[1]], , drop = FALSE]
  right_tip <- label_nodes[label_nodes$node == "PopB", , drop = FALSE]
  expect_lt(migration_target$.label_x, migration_target$x)
  expect_gt(migration_target$.label_y, migration_target$y)
  expect_equal(migration_target$.label_hjust, 1)
  expect_gt(right_tip$.label_x, right_tip$x)
  expect_equal(right_tip$.label_hjust, 0)
})

test_that("introgression auto import filters mixed real output directories by detected type", {
  dsuite <- import_introgression(extdata_dir("introgression/Dsuite"))
  admixtools <- import_introgression(extdata_dir("introgression/admixtools"))
  treemix <- import_introgression(extdata_dir("introgression/treemix"))

  expect_s3_class(dsuite, "ggpop_introgression")
  expect_equal(unique(dsuite$analysis), "trio")
  expect_equal(unique(admixtools$analysis), "trio")
  expect_true(all(c("D", "f3", "f4_ratio") %in% unique(admixtools$stat)))
  expect_equal(unique(treemix$analysis), "graph")
})

test_that("introgression plots build across real data styles", {
  window <- import_introgression(
    extdata_path("introgression/Dsuite/PopB_PopC_PopA_localFstats_run1_100_50.txt"),
    type = "dsuite_dinvestigate"
  )
  trio <- import_introgression(
    extdata_path("introgression/Dsuite/dsuite_results_BBAA.txt"),
    type = "dsuite_dtrios"
  )
  qpdstat <- import_introgression(
    extdata_path("introgression/admixtools/qpdstat_result.csv"),
    type = "admixtools"
  )
  graph <- import_introgression(
    extdata_path("introgression/treemix/treemix.M1.edges.gz"),
    type = "treemix"
  )

  window_plot <- plot_introgression(window, stat = c("D", "fdM"))
  region_plot <- plot_introgression(window, stat = "D", chr = "1")
  trio_plot <- plot_introgression(trio)
  matrix_plot <- plot_introgression(trio, style = "matrix")
  qpdstat_plot <- plot_introgression(qpdstat)
  graph_plot <- plot_introgression(graph)
  geom_plot <- ggpop(window) + geom_introgression(stat = "D")

  expect_s3_class(window_plot, "ggplot")
  expect_s3_class(region_plot, "ggplot")
  expect_s3_class(trio_plot, "ggplot")
  expect_s3_class(matrix_plot, "ggplot")
  expect_s3_class(qpdstat_plot, "ggplot")
  expect_s3_class(graph_plot, "ggplot")
  expect_s3_class(geom_plot, "ggplot")
  expect_true(any(vapply(trio_plot$layers, function(layer) inherits(layer$geom, "GeomTile"), logical(1))))
  expect_true(any(vapply(matrix_plot$layers, function(layer) inherits(layer$geom, "GeomTile"), logical(1))))
  expect_true(any(vapply(qpdstat_plot$layers, function(layer) inherits(layer$geom, "GeomErrorbar"), logical(1))))
  expect_false(any(vapply(qpdstat_plot$layers, function(layer) inherits(layer$geom, "GeomTile"), logical(1))))
  expect_s3_class(ggplot2::ggplot_build(window_plot), "ggplot_built")
  expect_s3_class(ggplot2::ggplot_build(region_plot), "ggplot_built")
  expect_s3_class(ggplot2::ggplot_build(trio_plot), "ggplot_built")
  expect_s3_class(ggplot2::ggplot_build(matrix_plot), "ggplot_built")
  expect_s3_class(ggplot2::ggplot_build(qpdstat_plot), "ggplot_built")
  expect_s3_class(ggplot2::ggplot_build(graph_plot), "ggplot_built")
  expect_s3_class(ggplot2::ggplot_build(geom_plot), "ggplot_built")
  expect_equal(region_plot$labels$x, "Position (Mb)")
  expect_equal(window_plot$labels$x, "Chromosome")
  expect_equal(graph_plot$labels$x, "Drift parameter")
  expect_equal(.introgression_pretty_label(c("Highland_East", "Hybrid_North / Lowland_South")), c("Highland East", "Hybrid North / Lowland South"))
})

test_that("introgression matrix style aggregates repeated Dsuite trio summaries", {
  matrix_data <- data.frame(
    analysis = "trio",
    stat = "D",
    pop1 = c("Out1", "Out2", "Out3", "Out4", "Out5"),
    pop2 = c("PopB", "PopB", "PopD", "PopD", "PopD"),
    pop3 = c("PopC", "PopC", "PopC", "PopA", "PopA"),
    value = c(0.18, 0.22, -0.11, 0.06, -0.19),
    p_value = c(0.010, 0.001, 0.200, 0.050, 0.004),
    f4_ratio = c(0.24, 0.26, 0.15, 0.08, 0.23),
    stringsAsFactors = FALSE
  )
  class(matrix_data) <- unique(c("ggpop_introgression", class(matrix_data)))

  layout <- .introgression_matrix_layout(matrix_data)
  plot <- plot_introgression(matrix_data, style = "matrix")
  built <- ggplot2::ggplot_build(plot)

  expect_equal(nrow(layout$data), 3)
  expect_equal(nrow(layout$grid), 4)
  expect_true(layout$has_significance)
  expect_equal(levels(layout$data$pop2), c("PopB", "PopD"))
  expect_equal(levels(layout$data$pop3), c("PopC", "PopA"))
  expect_equal(layout$data$value[layout$data$pop2 == "PopB" & layout$data$pop3 == "PopC"], 0.22)
  expect_equal(layout$data$value[layout$data$pop2 == "PopD" & layout$data$pop3 == "PopA"], -0.19)
  expect_true(layout$data$.significant[layout$data$pop2 == "PopB" & layout$data$pop3 == "PopC"])
  expect_true(layout$data$.significant[layout$data$pop2 == "PopD" & layout$data$pop3 == "PopA"])
  expect_equal(layout$data$.label[layout$data$pop2 == "PopB" & layout$data$pop3 == "PopC"], "0.22")
  expect_equal(layout$data$.label[layout$data$pop2 == "PopD" & layout$data$pop3 == "PopA"], "-0.19")
  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(built$data[[1]]), 4)
  expect_equal(nrow(built$data[[2]]), 3)
})

test_that("introgression trio plots facet mixed statistic families", {
  admixtools <- import_introgression(
    extdata_dir("introgression/admixtools"),
    type = "admixtools"
  )

  plot <- plot_introgression(admixtools)
  built <- ggplot2::ggplot_build(plot)

  expect_s3_class(plot$facet, "FacetGrid")
  expect_gt(length(unique(built$data[[1]]$PANEL)), 1)
})
