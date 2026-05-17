# Create a ggplot object from ggpop data

Creates a ggplot2 object from typed ggpop data so users can add ggpop
geoms with the standard \`+\` syntax.

## Usage

``` r
ggpop(data, mapping = ggplot2::aes(), ..., module = NULL)
```

## Arguments

- data:

  A \`ggpop_gwas\`, \`ggpop_pca\`, or \`ggpop_admix\` object.

- mapping:

  Default ggplot2 aesthetic mapping.

- ...:

  Reserved for future module-specific options.

- module:

  Optional module override.
