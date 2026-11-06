#' Classify a confidence interval against zero and a clinical threshold
#'
#' Places an interval into one of the five patterns described in Papadakis
#' (Figure 1): clinically important, real but importance unclear, real but
#' trivial, practically equivalent, or inconclusive.
#'
#' Zero is judged with the interval supplied (usually the 95% CI). The
#' equivalence bounds are judged with `ci_eq` when supplied (usually the 90%
#' CI, which matches a TOST at alpha = 0.05); otherwise with the same interval.
#'
#' @param lower,upper Limits of the confidence interval.
#' @param sesoi One positive number (symmetric bounds) or two increasing
#'   numbers (lower and upper bound).
#' @param ci_eq Optional interval of length two used for the bounds.
#' @return A character string naming the pattern. For clinically important
#'   effects the direction is added ("above the upper bound" or "below the
#'   lower bound").
#' @examples
#' classify_ci(-0.9, 0.2, sesoi = 1.8)   # RESTORE: practically equivalent
#' classify_ci(-0.18, -0.04, sesoi = 0.5) # significant but trivial
#' classify_ci(-12.4, 10.6, sesoi = 12)  # crosses a bound: inconclusive
#' @export
classify_ci <- function(lower, upper, sesoi, ci_eq = NULL) {
  check_num(lower, "lower"); check_num(upper, "upper")
  b <- make_bounds(sesoi)
  eq <- if (is.null(ci_eq)) c(lower, upper) else ci_eq
  if (lower > b[2]) return("Clinically important (above the upper bound)")
  if (upper < b[1]) return("Clinically important (below the lower bound)")
  excludes_zero <- lower > 0 || upper < 0
  inside <- eq[1] > b[1] && eq[2] < b[2]
  if (excludes_zero && inside) return("Real but trivial")
  if (excludes_zero) return("Real, importance unclear")
  if (inside) return("Practically equivalent")
  "Inconclusive"
}

#' One-sentence interpretation of an equivalence test
#'
#' Writes a plain-language sentence that can be pasted into a results or
#' discussion section.
#'
#' @param x An object returned by [tost_ci()] or [tost_se()].
#' @param units Optional units appended to numbers (for example "points").
#' @param digits Number of decimals.
#' @return A character string.
#' @examples
#' report_sentence(tost_ci(-6.5, 6.8, sesoi = 8), units = "points")
#' @export
report_sentence <- function(x, units = "", digits = 2) {
  stopifnot(inherits(x, "clinthresh_tost"))
  u <- if (nzchar(units)) paste0(" ", units) else ""
  n <- function(v) formatC(v, digits = digits, format = "f")
  lead <- sprintf("The difference was %s%s (%g%% CI %s to %s; P = %s).",
                  n(x$estimate), u, 100 * x$level, n(x$ci_reported[1]), n(x$ci_reported[2]),
                  format_p(x$p_nhst))
  eq <- sprintf("Against equivalence bounds of %s to %s%s, the %g%% CI (%s to %s) %s the bounds (TOST P = %s)",
                n(x$bounds[1]), n(x$bounds[2]), u, 100 * x$ci_equivalence_level,
                n(x$ci_equivalence[1]), n(x$ci_equivalence[2]),
                if (x$equivalent) "lies inside" else "is not inside", format_p(x$p_tost))
  tail <- switch(sub(" \\(.*", "", x$pattern),
    "Clinically important" = "the whole interval lies beyond the threshold, so the effect is both real and clinically important.",
    "Real, importance unclear" = "the effect is probably real, but the data cannot tell whether it is large enough to matter.",
    "Real but trivial" = "the effect is probably real but smaller than the threshold of clinical importance.",
    "Practically equivalent" = "the data support the absence of a clinically important difference.",
    "Inconclusive" = "the data are compatible with no effect and with a clinically important one, so no conclusion is possible.")
  paste0(lead, " ", eq, "; ", tail)
}
