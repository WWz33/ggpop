test_that("pophelper compatibility layer lists all exported pophelper functions", {
  expected <- c(
    "alignK", "analyseQ", "as.qlist", "clumppExport", "collectClumppOutput",
    "collectRunsTess", "distructColours", "distructExport", "evannoMethodStructure",
    "is.qlist", "joinQ", "mergeQ", "plotQ", "plotQMultiline", "readQ",
    "readQBaps", "readQBasic", "readQClumpp", "readQStructure", "readQTess",
    "readQTess3", "sortQ", "splitQ", "summariseQ", "tabulateQ", "verifyGrplab"
  )

  expect_setequal(pophelper_functions(), expected)
})

test_that("ggpop admixture data round-trips through pophelper qlist", {
  skip_if_not_installed("pophelper")
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")

  qlist <- pophelper_as_qlist(admix)
  expect_true(pophelper_is_qlist(qlist))

  roundtrip <- import_pophelper_qlist(qlist)
  expect_s3_class(roundtrip, "ggpop_admix")
  expect_equal(nrow(roundtrip), nrow(admix))
  expect_equal(sort(unique(roundtrip$cluster)), sort(unique(admix$cluster)))
})

test_that("pophelper plotting wrappers call plotQ and plotQMultiline", {
  skip_if_not_installed("pophelper")
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")

  expect_type(suppressWarnings(plot_pophelper_q(admix)), "list")
  expect_type(suppressWarnings(plot_admixture_pophelper(admix)), "list")
  expect_type(suppressWarnings(plot_pophelper_q_multiline(admix)), "list")
})

test_that("pophelper plotQ join interface works with native qlist input", {
  skip_if_not_installed("pophelper")
  admix_dir <- system.file("extdata", "admixture", package = "ggPopi")
  q2 <- pophelper::readQ(file.path(admix_dir, "finalsnp_ld.2.Q"))
  q3 <- pophelper::readQ(file.path(admix_dir, "finalsnp_ld.3.Q"))
  slist1 <- c(q2, q3)

  plot <- suppressWarnings(
    plot_pophelper_q(
      slist1[c(1, 2)],
      imgoutput = "join",
      returnplot = TRUE,
      exportplot = FALSE,
      basesize = 11
    )
  )

  expect_type(plot, "list")
  expect_equal(length(plot), 2)
})

test_that("pophelper generic and analysis wrappers dispatch to original package", {
  skip_if_not_installed("pophelper")
  admix <- import_admix(extdata_path("small_admixture.Q"), type = "admixture")

  expect_true(pophelper_call("is.qlist", pophelper_as_qlist(admix)) |> is.null())
  expect_s3_class(tabulate_pophelper_q(admix), "data.frame")
  expect_s3_class(summarise_pophelper_q(admix), "data.frame")
  expect_type(pophelper_distruct_colours(), "character")
})
