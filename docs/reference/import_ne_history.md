# Import effective population size history

Import demographic history outputs from PSMC, MSMC2, SMC++, or Stairway
Plot 2 into a typed tidy object for
[`plot_ne_history()`](https://wwz33.github.io/ggPopi/reference/geom_ne_history.md)
or `ggpop() + geom_ne_history()`.

## Usage

``` r
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
```

## Arguments

- dir:

  Directory containing Ne history result files, or a single file path.

- ...:

  Optional named file paths. Relative paths are resolved inside `dir`.

- type:

  Input type. Supports `"psmc"`, `"msmc2"`, `"smcpp"`, and `"stairway"`.

- sample_id:

  Optional sample or population labels for input files.

- mutation_rate:

  Optional per-site mutation rate. Required to convert PSMC/MSMC2 scaled
  values to absolute time and Ne. For SMC++ outputs, the value is
  retained as metadata when supplied.

- generation_time:

  Generation time multiplier for absolute PSMC/MSMC2 time. For SMC++ CSV
  files with generation-scale time values, values are multiplied by this
  number and reported as years. If the input contains a `time_unit`
  column with years, time values are left unchanged.

- bin_size:

  PSMC bin size used for theta scaling.

## Value

A `ggpop_ne_history` tidy S3 data frame with standardized columns
including `method`, `sample_id`, `time`, `ne`, `time_unit`, and `scale`.
Common SMC++ columns such as `plot_type`, `plot_num`, `type`, and
`replicate` are retained, as are supplied SMC++ `mutation_rate` and
`generation_time` assumptions.

## Details

PSMC and MSMC2 outputs are scaled unless `mutation_rate` is supplied.
SMC++ and Stairway Plot 2 examples are expected to contain absolute
effective population size columns. SMC++ time values are treated as
generations unless a `time_unit` column says they are years. Stairway
Plot 2 confidence intervals are retained when lower and upper Ne columns
are present.

## Examples

``` r
smcpp <- import_ne_history(
  system.file("extdata", "ne_history", "SMC++", "model.csv", package = "ggpop"),
  type = "smcpp"
)
#> Error: `dir` must point to an existing directory or file.
smcpp |> plot_ne_history()
#> Error: object 'smcpp' not found
```
