# Import population group labels

Imports a two-column population group file for PCA colours and admixture
group labels. The default format is \`sample pop\`.

## Usage

``` r
import_pop_group(file, sample_col = "sample", pop_col = "pop", ...)
```

## Arguments

- file:

  Path to a delimited text file.

- sample_col:

  Sample ID column name. Defaults to \`sample\`.

- pop_col:

  Population group column name. Defaults to \`pop\`.

- ...:

  Additional arguments passed to \`read.table()\`.

## Examples

``` r
groups <- import_pop_group(system.file("extdata", "pop_group.txt", package = "ggpop"))
```
