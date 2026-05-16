# Import GWAS result files

Imports supported GWAS results into a \`ggpop_gwas\` data frame with
normalized \`chr\`, \`pos\`, \`p\`, and \`snp\` columns.
\`improt_gwas()\` and \`prot_gwas()\` are typo-compatible aliases.

## Usage

``` r
import_gwas(file, type = c("auto", "gcta", "gemma", "emmax"), ...)
improt_gwas(file, type = c("auto", "gcta", "gemma", "emmax"), ...)
prot_gwas(file, type = c("auto", "gcta", "gemma", "emmax"), ...)
```

## Arguments

- file:

  Path to a GWAS result file.

- type:

  Input format: \`gcta\`, \`gemma\`, \`emmax\`, or \`auto\`.

- ...:

  Additional arguments passed to \`read.table()\`.
