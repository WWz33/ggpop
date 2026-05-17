.pophelper_exports <- c(
  "alignK", "analyseQ", "as.qlist", "clumppExport", "collectClumppOutput",
  "collectRunsTess", "distructColours", "distructExport", "evannoMethodStructure",
  "is.qlist", "joinQ", "mergeQ", "plotQ", "plotQMultiline", "readQ",
  "readQBaps", "readQBasic", "readQClumpp", "readQStructure", "readQTess",
  "readQTess3", "sortQ", "splitQ", "summariseQ", "tabulateQ", "verifyGrplab"
)

pophelper_functions <- function() {
  .pophelper_exports
}

pophelper_call <- function(.fn, ...) {
  .require_pophelper()
  .fn <- match.arg(.fn, .pophelper_exports)
  do.call(utils::getFromNamespace(.fn, "pophelper"), list(...))
}

import_pophelper_qlist <- function(qlist, source = "pophelper") {
  qlist <- pophelper_as_qlist(qlist)
  out <- do.call(rbind, Map(.pophelper_run_to_long, qlist, names(qlist)))
  rownames(out) <- NULL
  .new_ggpop_admix(out, source = source)
}

pophelper_as_qlist <- function(qlist, ...) {
  .require_pophelper()
  if (inherits(qlist, "ggpop_admix") || (is.data.frame(qlist) && all(c("sample_id", "run_id", "cluster", "proportion") %in% names(qlist)))) {
    return(as_pophelper_qlist(qlist))
  }
  .pophelper_get("as.qlist")(qlist, ...)
}

pophelper_is_qlist <- function(qlist) {
  .require_pophelper()
  invisible(.pophelper_get("is.qlist")(qlist))
  TRUE
}

as_pophelper_qlist <- function(data) {
  if (is.list(data) && !is.data.frame(data)) {
    .require_pophelper()
    invisible(.pophelper_get("is.qlist")(data))
    return(data)
  }
  .require_columns(data, c("sample_id", "run_id", "cluster", "proportion"), "admixture data")
  runs <- split(data, data$run_id)
  qlist <- lapply(runs, function(run_data) {
    clusters <- sort(unique(as.character(run_data$cluster)))
    samples <- unique(as.character(run_data$sample_id))
    matrix_data <- stats::xtabs(proportion ~ sample_id + cluster, run_data)
    matrix_data <- matrix_data[samples, clusters, drop = FALSE]
    out <- as.data.frame.matrix(matrix_data, stringsAsFactors = FALSE)
    names(out) <- paste0("Cluster", seq_along(out))
    attr(out, "ind") <- nrow(out)
    attr(out, "k") <- ncol(out)
    out
  })
  names(qlist) <- names(runs)
  qlist
}

read_pophelper_q <- function(files = NULL, filetype = "auto", indlabfromfile = FALSE,
                             readci = FALSE, as_ggpop = FALSE) {
  .require_pophelper()
  qlist <- .pophelper_get("readQ")(
    files = files,
    filetype = filetype,
    indlabfromfile = indlabfromfile,
    readci = readci
  )
  if (as_ggpop) {
    import_pophelper_qlist(qlist)
  } else {
    qlist
  }
}

plot_pophelper_q <- function(data, ..., exportplot = FALSE, returnplot = TRUE,
                             theme = "theme_bw", basesize = 8) {
  .require_pophelper()
  .pophelper_get("plotQ")(
    qlist = as_pophelper_qlist(data),
    ...,
    exportplot = exportplot,
    returnplot = returnplot,
    theme = theme,
    basesize = basesize
  )
}

plot_pophelper_q_multiline <- function(data, ..., exportplot = FALSE, returnplot = TRUE,
                                       theme = "theme_bw", basesize = 8) {
  .require_pophelper()
  .pophelper_get("plotQMultiline")(
    qlist = as_pophelper_qlist(data),
    ...,
    exportplot = exportplot,
    returnplot = returnplot,
    theme = theme,
    basesize = basesize
  )
}

plot_admixture_pophelper <- function(data, ..., exportplot = FALSE, returnplot = TRUE,
                                     theme = "theme_bw", basesize = 8) {
  plot_pophelper_q(
    data,
    ...,
    exportplot = exportplot,
    returnplot = returnplot,
    theme = theme,
    basesize = basesize
  )
}

align_pophelper_k <- function(data, ...) {
  .require_pophelper()
  .pophelper_get("alignK")(as_pophelper_qlist(data), ...)
}

sort_pophelper_q <- function(data, ...) {
  .require_pophelper()
  .pophelper_get("sortQ")(as_pophelper_qlist(data), ...)
}

split_pophelper_q <- function(data, ...) {
  .require_pophelper()
  .pophelper_get("splitQ")(as_pophelper_qlist(data), ...)
}

merge_pophelper_q <- function(data, ...) {
  .require_pophelper()
  .pophelper_get("mergeQ")(as_pophelper_qlist(data), ...)
}

join_pophelper_q <- function(data, ...) {
  .require_pophelper()
  .pophelper_get("joinQ")(as_pophelper_qlist(data), ...)
}

tabulate_pophelper_q <- function(data, ...) {
  .require_pophelper()
  .pophelper_get("tabulateQ")(as_pophelper_qlist(data), ...)
}

summarise_pophelper_q <- function(data, ...) {
  .require_pophelper()
  if (is.data.frame(data) && all(c("k", "ind") %in% names(data))) {
    .pophelper_get("summariseQ")(data, ...)
  } else {
    .pophelper_get("summariseQ")(.pophelper_get("tabulateQ")(as_pophelper_qlist(data)), ...)
  }
}

analyse_pophelper_q <- function(data, ...) {
  .require_pophelper()
  .pophelper_get("analyseQ")(as_pophelper_qlist(data), ...)
}

evanno_pophelper_structure <- function(data, ...) {
  .require_pophelper()
  .pophelper_get("evannoMethodStructure")(data, ...)
}

pophelper_distruct_colours <- function(...) {
  .require_pophelper()
  .pophelper_get("distructColours")(...)
}

pophelper_verify_grplab <- function(grplab) {
  .require_pophelper()
  invisible(.pophelper_get("verifyGrplab")(grplab))
  TRUE
}

.require_pophelper <- function() {
  if (!requireNamespace("pophelper", quietly = TRUE)) {
    stop("Package `pophelper` is required for this compatibility function.", call. = FALSE)
  }
}

.pophelper_get <- function(fun) {
  .optional_fn("pophelper", fun, "pophelper compatibility functions")
}

.pophelper_run_to_long <- function(run, run_id) {
  clusters <- names(run)
  sample_id <- rownames(run)
  if (is.null(sample_id) || any(!nzchar(sample_id))) {
    sample_id <- paste0("ind", seq_len(nrow(run)))
  }
  out <- do.call(rbind, lapply(seq_along(clusters), function(i) {
    data.frame(
      sample_id = sample_id,
      run_id = run_id,
      k = length(clusters),
      cluster = paste0("K", i),
      proportion = as.numeric(run[[i]]),
      stringsAsFactors = FALSE
    )
  }))
  rownames(out) <- NULL
  out
}
