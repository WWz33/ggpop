\name{import_ne_history}
\alias{import_ne_history}
\alias{import_demographic_history}
\title{Import effective population size history}
\usage{
import_ne_history(
  dir = NULL,
  ...,
  type = c("auto", "psmc", "msmc2", "smcpp", "stairway"),
  sample_id = NULL,
  mutation_rate = NULL,
  generation_time = 1,
  bin_size = 100
)

import_demographic_history(
  dir = NULL,
  ...,
  type = c("auto", "psmc", "msmc2", "smcpp", "stairway"),
  sample_id = NULL,
  mutation_rate = NULL,
  generation_time = 1,
  bin_size = 100
)
}
\arguments{
\item{dir}{Directory containing Ne history result files, or a single file path.}
\item{...}{Optional named file paths. Relative paths are resolved inside \code{dir}.}
\item{type}{Input type. Supports \code{"psmc"}, \code{"msmc2"}, \code{"smcpp"}, and \code{"stairway"}.}
\item{sample_id}{Optional sample or population labels for input files.}
\item{mutation_rate}{Optional per-site mutation rate. Required to convert PSMC/MSMC2 scaled values to absolute time and Ne. For SMC++ outputs, the value is retained as metadata when supplied.}
\item{generation_time}{Generation time multiplier for absolute PSMC/MSMC2 time. For SMC++ CSV files with generation-scale time values, values are multiplied by this number and reported as years. If the input contains a \code{time_unit} column with years, time values are left unchanged.}
\item{bin_size}{PSMC bin size used for theta scaling.}
}
\value{
A \code{ggpop_ne_history} tidy S3 data frame with standardized columns including \code{method}, \code{sample_id}, \code{time}, \code{ne}, \code{time_unit}, and \code{scale}. Common SMC++ columns such as \code{plot_type}, \code{plot_num}, \code{type}, and \code{replicate} are retained, as are supplied SMC++ \code{mutation_rate} and \code{generation_time} assumptions.
}
\description{
Import demographic history outputs from PSMC, MSMC2, SMC++, or Stairway Plot 2 into a typed tidy object for \code{plot_ne_history()} or \code{ggpop() + geom_ne_history()}.
}
\details{
PSMC and MSMC2 outputs are scaled unless \code{mutation_rate} is supplied. SMC++ and Stairway Plot 2 examples are expected to contain absolute effective population size columns. SMC++ time values are treated as generations unless a \code{time_unit} column says they are years. Stairway Plot 2 confidence intervals are retained when lower and upper Ne columns are present.
}
\examples{
smcpp <- import_ne_history(
  system.file("extdata", "ne_history", "SMC++", "model.csv", package = "ggpop"),
  type = "smcpp"
)
smcpp |> plot_ne_history()
}
