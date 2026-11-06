#' Plot one or more intervals against equivalence bounds
#'
#' Draws each estimate with its reported confidence interval (thin line) and
#' its equivalence confidence interval (thick line), the equivalence region
#' (shaded) and zero.
#'
#' @param ... One or more objects from [tost_ci()] or [tost_se()], optionally
#'   named (names are used as row labels).
#' @param xlab Label for the horizontal axis.
#' @return A ggplot object.
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   plot_equivalence(KANON = tost_ci(-6.5, 6.8, 8),
#'                    RESTORE = tost_ci(-0.9, 0.2, 1.8))
#' }
#' @export
plot_equivalence <- function(..., xlab = "Difference (outcome units)") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Install ggplot2 to draw plots.", call. = FALSE)
  xs <- list(...)
  if (length(xs) == 1 && is.list(xs[[1]]) && !inherits(xs[[1]], "clinthresh_tost")) xs <- xs[[1]]
  if (!all(vapply(xs, inherits, logical(1), "clinthresh_tost"))) stop("All inputs must come from tost_ci() or tost_se().", call. = FALSE)
  nm <- names(xs); if (is.null(nm)) nm <- rep("", length(xs))
  nm[nm == ""] <- paste("Result", which(nm == ""))
  d <- data.frame(
    label = factor(nm, levels = rev(nm)),
    est = vapply(xs, `[[`, numeric(1), "estimate"),
    lo = vapply(xs, function(x) x$ci_reported[1], numeric(1)),
    hi = vapply(xs, function(x) x$ci_reported[2], numeric(1)),
    elo = vapply(xs, function(x) x$ci_equivalence[1], numeric(1)),
    ehi = vapply(xs, function(x) x$ci_equivalence[2], numeric(1)),
    blo = vapply(xs, function(x) x$bounds[1], numeric(1)),
    bhi = vapply(xs, function(x) x$bounds[2], numeric(1)),
    pattern = vapply(xs, `[[`, character(1), "pattern"),
    ptost = vapply(xs, function(x) format_p(x$p_tost), character(1)))
  d$y <- as.numeric(d$label)
  d$txt <- paste0(d$pattern, "; TOST P = ", d$ptost)
  ggplot2::ggplot(d) +
    ggplot2::geom_rect(ggplot2::aes(xmin = blo, xmax = bhi, ymin = y - 0.35, ymax = y + 0.35),
                       fill = "grey88") +
    ggplot2::geom_vline(xintercept = 0, colour = "grey45") +
    ggplot2::geom_segment(ggplot2::aes(x = lo, xend = hi, y = y, yend = y), linewidth = 0.5) +
    ggplot2::geom_segment(ggplot2::aes(x = elo, xend = ehi, y = y, yend = y), linewidth = 1.8) +
    ggplot2::geom_point(ggplot2::aes(x = est, y = y), size = 2.6) +
    ggplot2::geom_text(ggplot2::aes(x = est, y = y + 0.48, label = txt), size = 3.2) +
    ggplot2::scale_y_continuous(breaks = d$y, labels = as.character(d$label),
                                limits = c(0.5, max(d$y) + 0.75)) +
    ggplot2::labs(x = xlab, y = NULL,
                  caption = "Shaded: equivalence region. Thin line: reported CI. Thick line: equivalence CI.") +
    ggplot2::theme_classic(base_size = 12)
}

#' Launch the clinthresh web app
#'
#' Opens an interactive app for clinicians and authors: interpret a published
#' result against a threshold, plan the sample size of an equivalence or
#' non-inferiority trial, compute SWC and MDC, and browse a reference table of
#' minimal important differences.
#'
#' @param ... Passed to [shiny::runApp()].
#' @return Called for its side effect.
#' @export
run_app <- function(...) {
  for (p in c("shiny", "ggplot2")) if (!requireNamespace(p, quietly = TRUE)) stop(sprintf("Install the '%s' package to run the app.", p), call. = FALSE)
  shiny::runApp(system.file("app", package = "clinthresh"), ...)
}

#' Reference table of thresholds of clinical importance
#'
#' Published minimal important differences, trial-specific margins and
#' distribution-based defaults for outcomes common in sports medicine
#' rehabilitation. Each row gives its source; thresholds depend on
#' population, anchor and method, so check the source before use.
#'
#' @format A data frame with one row per threshold and columns:
#' \describe{
#'   \item{instrument, subscale}{Outcome measure.}
#'   \item{scale_range, higher_is}{Score range and direction.}
#'   \item{population}{Population in which the threshold was derived.}
#'   \item{threshold_type}{MCID, MIC, trial SESOI, SWC or distribution-based.}
#'   \item{value, unit}{Threshold as reported (text; may be a range).}
#'   \item{value_num}{First number of `value`, for calculations.}
#'   \item{method, level}{Derivation method and whether the threshold applies
#'     to individuals or to between-group differences.}
#'   \item{source, doi, notes}{Citation, DOI and caveats.}
#' }
#' @source See the `source` and `doi` columns. Contributions welcome via the
#'   GitHub repository.
"mcid_reference"

utils::globalVariables(c("blo", "bhi", "y", "lo", "hi", "elo", "ehi", "est", "txt"))
