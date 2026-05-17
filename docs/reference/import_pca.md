# Import or compute PCA results

Imports PCA coordinates into \`ggpop_pca\`, or computes PCA using the
optional \`flashpcaR\` backend. When \`pop_group\` is supplied, PCA
plots map population groups to ggpop's unified discrete colour scale by
default.

## 用法

``` r
import_pca(file, type = c("auto", "plink", "gcta"), eigenval = NULL,
  pop_group = NULL, ...)
compute_pca(genotype, method = c("flashpca"), pop_group = NULL, ...)
```

## 参数

- file:

  Path to a PLINK or GCTA eigenvector file.

- type:

  Input format: \`plink\`, \`gcta\`, or \`auto\`.

- eigenval:

  Optional eigenvalue file.

- pop_group:

  Optional path or data frame with two columns, \`sample\` and \`pop\`,
  used for population colors.

- genotype:

  Genotype matrix or flashpcaR-supported input.

- method:

  PCA method. Currently \`flashpca\`, backed by \`flashpcaR\`.

- ...:

  Additional arguments.
