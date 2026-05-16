.optional_fn <- function(.package, .fun, .feature) {
  if (!requireNamespace(.package, quietly = TRUE)) {
    stop(
      "Package `", .package, "` is required for ", .feature,
      ". Install it manually from its upstream repository.",
      call. = FALSE
    )
  }
  utils::getFromNamespace(.fun, .package)
}

.optional_call <- function(.package, .fun, .feature, ...) {
  do.call(.optional_fn(.package, .fun, .feature), list(...))
}
