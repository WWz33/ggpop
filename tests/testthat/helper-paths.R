extdata_path <- function(file) {
  installed <- system.file("extdata", file, package = "ggPopi")
  if (nzchar(installed)) return(installed)
  installed_smoke <- system.file("extdata", "smoke", file, package = "ggPopi")
  if (nzchar(installed_smoke)) return(installed_smoke)
  path <- test_path("../../inst/extdata", file)
  if (file.exists(path)) return(path)
  test_path("../../inst/extdata/smoke", file)
}

extdata_dir <- function(dir) {
  installed <- system.file("extdata", dir, package = "ggPopi")
  if (nzchar(installed)) return(installed)
  test_path("../../inst/extdata", dir)
}
