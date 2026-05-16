.is_hex_colour <- function(x) {
  grepl("^#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$", x)
}

new_pop_palette <- function(x, name = "ggpop palette", reverse = FALSE) {
  if (!is.character(x) || !all(.is_hex_colour(x))) {
    stop("`x` must be a character vector of hex colours.", call. = FALSE)
  }
  if (reverse) {
    x <- rev(x)
  }
  structure(x, class = c("ggpop_palette_scheme", "character"), ggpop_palette_name = name)
}

print.ggpop_palette_scheme <- function(x, ...) {
  cat(attr(x, "ggpop_palette_name") %||% "ggpop palette", "\n", sep = "")
  print(unclass(x))
  invisible(x)
}

c.ggpop_palette_scheme <- function(...) {
  new_pop_palette(NextMethod(), name = "combined ggpop palette")
}

`[.ggpop_palette_scheme` <- function(x, i) {
  new_pop_palette(NextMethod(), name = attr(x, "ggpop_palette_name") %||% "ggpop palette")
}

`[[.ggpop_palette_scheme` <- function(x, i) {
  new_pop_palette(NextMethod(), name = attr(x, "ggpop_palette_name") %||% "ggpop palette")
}

colors_pop_okabeito <- new_pop_palette(
  c("#0072B2", "#56B4E9", "#009E73", "#F5C710", "#E69F00", "#D55E00", "#CC79A7"),
  "colors_pop_okabeito"
)

colors_pop_distinct <- new_pop_palette(
  c(
    "#4E79A7", "#F28E2B", "#59A14F", "#E15759", "#76B7B2", "#B07AA1",
    "#EDC948", "#9C755F", "#BAB0AC", "#2F4B7C", "#A05195", "#FF7C43"
  ),
  "colors_pop_distinct"
)

colors_pop_paper <- new_pop_palette(
  c("#4E79A7", "#F28E2B", "#59A14F", "#E15759", "#76B7B2", "#B07AA1", "#EDC948", "#9C755F", "#BAB0AC"),
  "colors_pop_paper"
)

colors_pop_manhattan <- new_pop_palette(
  c("#D95319", "#E4A100", "#7E2F8E", "#5EA500", "#0095D4", "#A2142F", "#0C53AA"),
  "colors_pop_manhattan"
)

ggpop_palette <- function(n = NULL, palette = c("population", "admixture", "manhattan", "publication"),
                          downsample = c("evenly", "first", "last", "middle"),
                          reverse = FALSE, saturation = 1) {
  downsample <- match.arg(downsample)
  palette <- .resolve_pop_palette(palette)
  if (reverse) {
    palette <- rev(palette)
  }
  palette <- .apply_saturation(palette, saturation = saturation)
  if (is.null(n)) {
    return(palette)
  }
  if (n < 1) {
    return(character())
  }
  .palette_n(palette, n, downsample = downsample)
}

scale_colour_ggpop <- function(palette = c("population", "admixture", "manhattan", "publication"),
                               n = NULL, saturation = 1, reverse = FALSE,
                               downsample = c("evenly", "first", "last", "middle"), ...) {
  if (is.numeric(palette) && length(palette) == 1 && is.character(n) && length(n) == 1) {
    old_n <- palette
    palette <- n
    n <- old_n
  }
  if (is.numeric(palette) && length(palette) == 1 && is.null(n)) {
    n <- palette
    palette <- "manhattan"
  }
  values <- ggpop_palette(n = n, palette = palette, saturation = saturation, reverse = reverse, downsample = downsample)
  ggplot2::discrete_scale("colour", palette = function(n) .palette_n(values, n, downsample = downsample), ...)
}

scale_color_ggpop <- scale_colour_ggpop

scale_fill_ggpop <- function(palette = c("admixture", "population", "publication", "manhattan"),
                             n = NULL, saturation = 1, reverse = FALSE,
                             downsample = c("evenly", "first", "last", "middle"), ...) {
  if (is.numeric(palette) && length(palette) == 1 && is.character(n) && length(n) == 1) {
    old_n <- palette
    palette <- n
    n <- old_n
  }
  if (is.numeric(palette) && length(palette) == 1 && is.null(n)) {
    n <- palette
    palette <- "admixture"
  }
  values <- ggpop_palette(n = n, palette = palette, saturation = saturation, reverse = reverse, downsample = downsample)
  ggplot2::discrete_scale("fill", palette = function(n) .palette_n(values, n, downsample = downsample), ...)
}

.resolve_pop_palette <- function(palette) {
  if (is.character(palette) && length(palette) == 1 && !.is_hex_colour(palette)) {
    palette <- match.arg(palette, c("population", "admixture", "manhattan", "publication"))
    return(switch(
      palette,
      population = colors_pop_okabeito,
      admixture = colors_pop_distinct,
      manhattan = colors_pop_manhattan,
      publication = colors_pop_paper
    ))
  }
  if (!is.character(palette) || !all(.is_hex_colour(palette))) {
    stop("`palette` must be a palette name or a character vector of hex colours.", call. = FALSE)
  }
  palette
}

.palette_n <- function(palette, n, downsample = c("evenly", "first", "last", "middle")) {
  downsample <- match.arg(downsample)
  palette <- unclass(palette)
  if (!is.null(names(palette))) {
    return(palette)
  }
  if (length(palette) == n) {
    return(palette)
  }
  if (n == 1) {
    return(palette[1])
  }
  if (length(palette) > n) {
    return(.downsample_vector(palette, n, downsample = downsample))
  }
  grDevices::colorRampPalette(palette)(n)
}

.downsample_vector <- function(x, n, downsample = c("evenly", "first", "last", "middle")) {
  if (length(x) <= n) {
    return(x)
  }
  downsample <- match.arg(downsample)
  if (downsample == "evenly") {
    by <- (length(x) / (n - 1)) - (1 / (n - 1))
    i <- floor(cumsum(c(1, rep(by, n - 1))))
    return(x[i])
  }
  if (downsample == "first") {
    return(x[seq_len(n)])
  }
  if (downsample == "last") {
    return(x[(length(x) - n + 1):length(x)])
  }
  start_index <- ceiling((length(x) - n) / 2) + 1
  x[start_index:(start_index + n - 1)]
}

.apply_saturation <- function(colors, saturation, background_color = "#FFFFFF") {
  if (saturation == 1) {
    return(colors)
  }
  vapply(colors, function(color) {
    rgb_color <- grDevices::col2rgb(color)
    rgb_background <- grDevices::col2rgb(background_color)
    mixed <- (1 - saturation) * rgb_background + saturation * rgb_color
    grDevices::rgb(t(mixed), maxColorValue = 255)
  }, character(1))
}
