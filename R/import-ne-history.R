import_ne_history <- function(dir = NULL, ..., type = c("auto", "psmc", "msmc2", "smcpp", "stairway"),
                              sample_id = NULL, mutation_rate = NULL,
                              generation_time = 1, bin_size = 100) {
  type <- match.arg(type)
  files <- .ne_history_collect_files(dir, ...)
  if (length(files) == 0) {
    stop("No Ne history files were provided or discovered.", call. = FALSE)
  }
  if (type == "auto") {
    type <- .guess_ne_history_type(files)
  }
  data <- switch(
    type,
    psmc = .import_ne_history_psmc(files, sample_id, mutation_rate, generation_time, bin_size),
    msmc2 = .import_ne_history_msmc2(files, sample_id, mutation_rate, generation_time),
    smcpp = .import_ne_history_smcpp(files, sample_id, mutation_rate, generation_time),
    stairway = .import_ne_history_stairway(files, sample_id)
  )
  .new_ggpop_ne_history(data, source = type)
}

.ne_history_collect_files <- function(dir = NULL, ...) {
  explicit <- list(...)
  explicit <- explicit[!vapply(explicit, is.null, logical(1))]
  explicit <- unlist(explicit, use.names = TRUE)
  files <- character()
  if (!is.null(dir)) {
    if (file.exists(dir) && !dir.exists(dir)) {
      files <- c(files, dir)
    } else if (!dir.exists(dir)) {
      stop("`dir` must point to an existing directory or file.", call. = FALSE)
    } else {
      files <- c(files, list.files(
        dir,
        pattern = "(\\.psmc$|final\\.txt$|\\.csv$|\\.txt$|\\.tsv$)",
        full.names = TRUE,
        recursive = TRUE,
        ignore.case = TRUE
      ))
    }
  }
  if (length(explicit) > 0) {
    explicit <- ifelse(file.exists(explicit), explicit, file.path(dir %||% ".", explicit))
    files <- c(files, explicit)
  }
  files <- unique(files[file.exists(files)])
  stats::setNames(files, names(files) %||% basename(files))
}

.guess_ne_history_type <- function(files) {
  lower <- tolower(paste(basename(files), collapse = " "))
  if (grepl("\\.psmc$", lower)) return("psmc")
  if (grepl("msmc|final\\.txt", lower)) return("msmc2")
  if (grepl("smc\\+\\+|smcpp|\\.csv$", lower)) return("smcpp")
  if (grepl("stairway", lower)) return("stairway")
  "stairway"
}

.import_ne_history_psmc <- function(files, sample_id, mutation_rate, generation_time, bin_size) {
  rows <- lapply(seq_along(files), function(index) {
    .import_ne_history_psmc_file(
      files[[index]],
      sample_id = .ne_history_sample_id(files, index, sample_id),
      mutation_rate = mutation_rate,
      generation_time = generation_time,
      bin_size = bin_size
    )
  })
  .stats_bind_rows(rows)
}

.import_ne_history_psmc_file <- function(file, sample_id, mutation_rate, generation_time, bin_size) {
  lines <- readLines(file, warn = FALSE)
  tr <- strsplit(lines[grepl("^TR\\s+", lines)][1], "\\s+")[[1]]
  rs <- strsplit(lines[grepl("^RS\\s+", lines)], "\\s+")
  if (length(rs) == 0 || length(tr) < 2) {
    stop("Cannot find PSMC TR/RS records in `", basename(file), "`.", call. = FALSE)
  }
  theta0 <- suppressWarnings(as.numeric(tr[2]))
  epoch <- vapply(rs, function(x) as.integer(x[2]), integer(1))
  t_scaled <- vapply(rs, function(x) as.numeric(x[3]), numeric(1))
  lambda <- vapply(rs, function(x) as.numeric(x[4]), numeric(1))
  if (!is.null(mutation_rate)) {
    n0 <- theta0 / (4 * mutation_rate) / bin_size
    time <- 2 * n0 * t_scaled * generation_time
    ne <- n0 * lambda
    time_unit <- if (generation_time == 1) "generations" else "years"
    scale <- "absolute"
  } else {
    time <- t_scaled
    ne <- lambda
    time_unit <- "scaled"
    scale <- "relative"
  }
  data.frame(
    method = "PSMC",
    sample_id = sample_id,
    epoch = epoch,
    time = time,
    ne = ne,
    time_unit = time_unit,
    scale = scale,
    theta0 = theta0,
    file = basename(file),
    stringsAsFactors = FALSE
  )
}

.import_ne_history_msmc2 <- function(files, sample_id, mutation_rate, generation_time) {
  rows <- lapply(seq_along(files), function(index) {
    .import_ne_history_msmc2_file(
      files[[index]],
      sample_id = .ne_history_sample_id(files, index, sample_id),
      mutation_rate = mutation_rate,
      generation_time = generation_time
    )
  })
  .stats_bind_rows(rows)
}

.import_ne_history_msmc2_file <- function(file, sample_id, mutation_rate, generation_time) {
  raw <- .read_table_auto(file)
  names(raw) <- .standardize_names(names(raw))
  left_col <- .ne_history_required_column(raw, c("left_time_boundary", "left_time", "left"), file, "left time boundary")
  right_col <- .ne_history_required_column(raw, c("right_time_boundary", "right_time", "right"), file, "right time boundary")
  lambda_cols <- grep("^lambda", names(raw), value = TRUE)
  if (length(lambda_cols) == 0) {
    stop("Cannot find MSMC2 lambda columns in `", basename(file), "`.", call. = FALSE)
  }
  rows <- lapply(lambda_cols, function(lambda_col) {
    lambda <- as.numeric(raw[[lambda_col]])
    midpoint <- (as.numeric(raw[[left_col]]) + as.numeric(raw[[right_col]])) / 2
    if (!is.null(mutation_rate)) {
      time <- midpoint / mutation_rate * generation_time
      ne <- (1 / lambda) / (2 * mutation_rate)
      time_unit <- if (generation_time == 1) "generations" else "years"
      scale <- "absolute"
    } else {
      time <- midpoint
      ne <- 1 / lambda
      time_unit <- "scaled"
      scale <- "relative"
    }
    data.frame(
      method = "MSMC2",
      sample_id = if (lambda_col == "lambda") sample_id else paste(sample_id, lambda_col, sep = ":"),
      series = lambda_col,
      time = time,
      ne = ne,
      time_unit = time_unit,
      scale = scale,
      file = basename(file),
      stringsAsFactors = FALSE
    )
  })
  .stats_bind_rows(rows)
}

.import_ne_history_smcpp <- function(files, sample_id, mutation_rate, generation_time) {
  rows <- lapply(seq_along(files), function(index) {
    .import_ne_history_smcpp_file(
      files[[index]],
      sample_id = .ne_history_sample_id(files, index, sample_id),
      mutation_rate = mutation_rate,
      generation_time = generation_time
    )
  })
  .stats_bind_rows(rows)
}

.import_ne_history_smcpp_file <- function(file, sample_id, mutation_rate, generation_time) {
  raw <- utils::read.csv(file, stringsAsFactors = FALSE, check.names = FALSE)
  names(raw) <- .standardize_names(names(raw))
  pop_col <- .first_existing(raw, c("population", "pop", "label", "name", "model"))
  time_col <- .ne_history_required_column(raw, c("time", "generation", "generations", "x"), file, "time")
  ne_col <- .ne_history_required_column(raw, c("ne", "popsize", "population_size", "y"), file, "Ne")
  unit_col <- .first_existing(raw, c("time_unit", "time_units", "unit", "units"))
  raw_unit <- if (is.null(unit_col)) "generations" else tolower(as.character(raw[[unit_col]][1]))
  time_unit <- if (grepl("year", raw_unit)) "years" else "generations"
  time <- as.numeric(raw[[time_col]])
  if (identical(time_unit, "generations") && !is.null(generation_time) && generation_time != 1) {
    time <- time * generation_time
    time_unit <- "years"
  }
  data <- data.frame(
    method = "SMC++",
    sample_id = if (is.null(pop_col)) sample_id else as.character(raw[[pop_col]]),
    time = time,
    ne = raw[[ne_col]],
    time_unit = time_unit,
    scale = "absolute",
    file = basename(file),
    stringsAsFactors = FALSE
  )
  if (!is.null(mutation_rate)) {
    data$mutation_rate <- mutation_rate
  }
  if (!is.null(generation_time)) {
    data$generation_time <- generation_time
  }
  optional <- .ne_history_optional_columns(raw)
  for (column in optional) {
    data[[column]] <- raw[[column]]
  }
  data
}

.ne_history_optional_columns <- function(raw) {
  intersect(
    c("series", "type", "line_type", "plot_type", "plot_num", "replicate", "bootstrap", "bs", "n"),
    names(raw)
  )
}

.import_ne_history_stairway <- function(files, sample_id) {
  rows <- lapply(seq_along(files), function(index) {
    .import_ne_history_stairway_file(files[[index]], sample_id = .ne_history_sample_id(files, index, sample_id))
  })
  .stats_bind_rows(rows)
}

.import_ne_history_stairway_file <- function(file, sample_id) {
  raw <- .read_table_auto(file)
  names(raw) <- .standardize_names(names(raw))
  pop_col <- .first_existing(raw, c("population", "pop", "sample", "sample_id"))
  time_col <- .ne_history_required_column(raw, c("time", "generation", "generations", "year", "years"), file, "time")
  ne_col <- .ne_history_required_column(raw, c("ne", "median", "ne_median", "popsize", "population_size"), file, "Ne")
  lower_col <- .first_existing(raw, c("ne_lower", "lower", "low", "ci_lower", "ne_2_5", "ne_2_5_", "x2_5"))
  upper_col <- .first_existing(raw, c("ne_upper", "upper", "high", "ci_upper", "ne_97_5", "ne_97_5_", "x97_5"))
  data <- data.frame(
    method = "Stairway Plot 2",
    sample_id = if (is.null(pop_col)) sample_id else as.character(raw[[pop_col]]),
    time = raw[[time_col]],
    ne = raw[[ne_col]],
    time_unit = if (grepl("year", time_col)) "years" else "generations",
    scale = "absolute",
    file = basename(file),
    stringsAsFactors = FALSE
  )
  if (!is.null(lower_col)) data$ne_lower <- raw[[lower_col]]
  if (!is.null(upper_col)) data$ne_upper <- raw[[upper_col]]
  data
}

.ne_history_required_column <- function(raw, candidates, file, what) {
  column <- .first_existing(raw, candidates)
  if (is.null(column)) {
    stop(
      "Cannot find ", what, " column in Ne history file `", basename(file),
      "`. Tried: ", paste(candidates, collapse = ", "), ".",
      call. = FALSE
    )
  }
  column
}

.ne_history_sample_id <- function(files, index, sample_id = NULL) {
  if (!is.null(sample_id)) {
    if (length(sample_id) == 1) return(as.character(sample_id))
    return(as.character(sample_id[[index]]))
  }
  file_name <- names(files)[[index]]
  if (!is.null(file_name) && nzchar(file_name)) return(file_name)
  tools::file_path_sans_ext(basename(files[[index]]))
}

import_demographic_history <- import_ne_history
