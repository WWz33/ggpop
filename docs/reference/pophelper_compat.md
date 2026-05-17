# pophelper compatibility layer

Advanced compatibility wrappers for the full exported \`pophelper\` API.
Regular users should prefer \`import_admix(...) \|\> plot_admix(k =
...)\` or \`import_admix(...) \|\> ggpop() + geom_admix(k = ...)\`.
These helpers directly call original \`pophelper\` functions when full
feature parity is required.

## Usage

``` r
pophelper_functions()
pophelper_call(.fn, ...)
import_pophelper_qlist(qlist, source = "pophelper")
pophelper_as_qlist(qlist, ...)
pophelper_is_qlist(qlist)
read_pophelper_q(files = NULL, filetype = "auto", indlabfromfile = FALSE,
  readci = FALSE, as_ggpop = FALSE)
plot_pophelper_q(data, ..., exportplot = FALSE, returnplot = TRUE,
  theme = "theme_bw", basesize = 8)
plot_pophelper_q_multiline(data, ..., exportplot = FALSE, returnplot = TRUE,
  theme = "theme_bw", basesize = 8)
align_pophelper_k(data, ...)
sort_pophelper_q(data, ...)
split_pophelper_q(data, ...)
merge_pophelper_q(data, ...)
join_pophelper_q(data, ...)
tabulate_pophelper_q(data, ...)
summarise_pophelper_q(data, ...)
analyse_pophelper_q(data, ...)
evanno_pophelper_structure(data, ...)
pophelper_distruct_colours(...)
pophelper_verify_grplab(grplab)
```

## Arguments

- .fn:

  A pophelper exported function name.

- ...:

  Arguments forwarded to the matching \`pophelper\` function.

- qlist:

  A pophelper qlist or qlist-like list.

- source:

  Source label for converted ggpop admixture data.

- files, filetype, indlabfromfile, readci:

  Arguments forwarded to \`pophelper::readQ()\`.

- as_ggpop:

  Convert \`readQ()\` output to \`ggpop_admix\`.

- data:

  A \`ggpop_admix\` object, pophelper qlist, tabulated pophelper data
  frame, or STRUCTURE summary data depending on the wrapped function.

- exportplot, returnplot, theme, basesize:

  Plotting arguments forwarded to pophelper plotting functions.

- grplab:

  Group label data frame passed to \`pophelper::verifyGrplab()\`.

## Details

\`pophelper_functions()\` returns the covered pophelper export list.
\`pophelper_call()\` is a generic escape hatch for any listed original
function. High-level wrappers convert \`ggpop_admix\` long-form data to
pophelper qlists where that is the original function's expected input.
