# Compatibility and advanced helpers

The recommended user-facing interfaces are:

- [`import_gwas()`](https://wwz33.github.io/ggPopi/reference/import_gwas.md)
  \|\>
  [`plot_manha()`](https://wwz33.github.io/ggPopi/reference/plot_manha.md)
  or [`ggpop()`](https://wwz33.github.io/ggPopi/reference/ggpop.md) +
  [`geom_manha()`](https://wwz33.github.io/ggPopi/reference/geom_manha.md)
- [`import_gwas()`](https://wwz33.github.io/ggPopi/reference/import_gwas.md)
  \|\>
  [`plot_qq()`](https://wwz33.github.io/ggPopi/reference/plot_qq.md) or
  [`ggpop()`](https://wwz33.github.io/ggPopi/reference/ggpop.md) +
  [`ggpop::geom_qq()`](https://rdrr.io/pkg/ggpop/man/geom_qq.html)
- [`plot_admix()`](https://wwz33.github.io/ggPopi/reference/plot_admix.md)
- `ggpop() + geom_admix()`

The package also exports advanced helpers for users who need
original-package compatibility or integration with older code.

## pophelper compatibility

``` r
plot_pophelper_q(import_admix("runs/", type = "admixture"), returnplot = TRUE)
plot_admixture_pophelper(import_admix("runs/", type = "admixture"))
```

These helpers keep the original `pophelper` return structure.

## Importing pophelper qlists

``` r
read_pophelper_q(files = "run1.Q", as_ggpop = TRUE)
```

When `as_ggpop = TRUE`, compatibility input is converted to a typed
`ggpop_admix` object so it can enter the same plotting pipeline as
native imports.
