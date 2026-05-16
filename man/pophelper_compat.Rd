\name{pophelper_compat}
\alias{pophelper_functions}
\alias{pophelper_call}
\alias{import_pophelper_qlist}
\alias{pophelper_as_qlist}
\alias{pophelper_is_qlist}
\alias{read_pophelper_q}
\alias{plot_pophelper_q}
\alias{plot_pophelper_q_multiline}
\alias{align_pophelper_k}
\alias{sort_pophelper_q}
\alias{split_pophelper_q}
\alias{merge_pophelper_q}
\alias{join_pophelper_q}
\alias{tabulate_pophelper_q}
\alias{summarise_pophelper_q}
\alias{analyse_pophelper_q}
\alias{evanno_pophelper_structure}
\alias{pophelper_distruct_colours}
\alias{pophelper_verify_grplab}
\title{pophelper compatibility layer}
\usage{
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
}
\arguments{
\item{.fn}{A pophelper exported function name.}
\item{...}{Arguments forwarded to the matching `pophelper` function.}
\item{qlist}{A pophelper qlist or qlist-like list.}
\item{source}{Source label for converted ggpop admixture data.}
\item{files, filetype, indlabfromfile, readci}{Arguments forwarded to `pophelper::readQ()`.}
\item{as_ggpop}{Convert `readQ()` output to `ggpop_admix`.}
\item{data}{A `ggpop_admix` object, pophelper qlist, tabulated pophelper data frame, or STRUCTURE summary data depending on the wrapped function.}
\item{exportplot, returnplot, theme, basesize}{Plotting arguments forwarded to pophelper plotting functions.}
\item{grplab}{Group label data frame passed to `pophelper::verifyGrplab()`.}
}
\description{
Advanced compatibility wrappers for the full exported `pophelper` API. Regular users should prefer `import_admix(...) |> plot_admix(k = ...)` or `import_admix(...) |> ggpop() + geom_admix(k = ...)`. These helpers directly call original `pophelper` functions when full feature parity is required.
}
\details{
`pophelper_functions()` returns the covered pophelper export list. `pophelper_call()` is a generic escape hatch for any listed original function. High-level wrappers convert `ggpop_admix` long-form data to pophelper qlists where that is the original function's expected input.
}
