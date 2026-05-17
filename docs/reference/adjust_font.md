# Adjust ggpop font settings

Apply a consistent text scale to a ggpop/ggplot object.

## 用法

``` r
adjust_font(
  plot,
  base_size = 11,
  base_family = "",
  title_size = NULL,
  subtitle_size = NULL,
  caption_size = NULL,
  axis_title_size = NULL,
  axis_text_size = NULL,
  legend_title_size = NULL,
  legend_text_size = NULL,
  strip_text_size = NULL,
  face = NULL
)
```

## 参数

- plot:

  A ggplot object.

- base_size:

  Base font size in points.

- base_family:

  Base font family.

- title_size, subtitle_size, caption_size:

  Optional sizes for plot title, subtitle, and caption.

- axis_title_size, axis_text_size:

  Optional sizes for axis titles and text.

- legend_title_size, legend_text_size:

  Optional sizes for legend title and text.

- strip_text_size:

  Optional size for facet strip text.

- face:

  Optional font face passed to text elements.

## 值

A ggplot object.
