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
  values to absolute time and Ne.

- generation_time:

  Generation time multiplier for absolute PSMC/MSMC2 time.

- bin_size:

  PSMC bin size used for theta scaling.

## Value

A `ggpop_ne_history` tidy S3 data frame with standardized columns
including `method`, `sample_id`, `time`, `ne`, `time_unit`, and `scale`.

## Details

PSMC and MSMC2 outputs are scaled unless `mutation_rate` is supplied.
SMC++ and Stairway Plot 2 examples are expected to already contain
absolute time and effective population size columns. Stairway Plot 2
confidence intervals are retained when lower and upper Ne columns are
present.

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
