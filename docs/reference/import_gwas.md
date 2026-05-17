# Import GWAS result files

Imports supported GWAS results into a \`ggpop_gwas\` data frame with
normalized \`chr\`, \`pos\`, \`p\`, and \`snp\` columns.

## Usage

``` r
import_gwas(file, type = c("auto", "gcta", "gemma", "emmax"), ...)
```

## Arguments

- file:

  Path to a GWAS result file.

- type:

  Input format: \`gcta\`, \`gemma\`, \`emmax\`, or \`auto\`.

- ...:

  Additional arguments passed to \`read.table()\`.
