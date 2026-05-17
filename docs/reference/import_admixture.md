# Import admixture proportion files

Imports admixture proportions into long-format \`ggpop_admix\` S3 data
for \`plot_admix()\` and \`geom_admix()\`. Directories are read as full
multi-K ADMIXTURE result sets. \`import_admix()\` is the shorter
user-facing alias. When \`pop_group\` is supplied, population labels are
joined by \`sample_id\` and drive pophelper-style group facets and
sorting.

## 用法

``` r
import_admixture(file, type = c("auto", "structure", "admixture"), ind = NULL,
  pattern = "\\.Q$", recursive = FALSE, pop_group = NULL, ...)
import_admix(file, type = c("auto", "structure", "admixture"), ind = NULL,
  pattern = "\\.Q$", recursive = FALSE, pop_group = NULL, ...)
```

## 参数

- file:

  Path to one or more ADMIXTURE \`.Q\` files, a directory containing
  \`.Q\` files, or a limited STRUCTURE-like numeric matrix.

- type:

  Input format: \`admixture\`, \`structure\`, or \`auto\`.

- ind:

  Optional sample label file or data frame.

- pattern:

  File pattern used when \`file\` is a directory.

- recursive:

  Search directories recursively.

- pop_group:

  Optional path or data frame with two columns, \`sample\` and \`pop\`,
  used for population group labels, sorting, and facets.

- ...:

  Additional arguments passed to \`read.table()\`.
