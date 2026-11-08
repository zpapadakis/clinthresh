#' Read a published confidence interval without testing a post hoc threshold
#'
#' Reading mode for clinicians and reviewers who appraise a trial they did not
#' design. Tests against a threshold keep their error rate only when the
#' threshold was fixed before the data were seen; a reader sees the result
#' first. `read_ci()` therefore reports no P value against a threshold. It
#' returns the range of thresholds for which each conclusion holds (Papadakis,
#' under review; Neuhauser 2010) and, if a threshold from outside the data is
#' supplied, the pattern of the interval against it (see [classify_ci()]).
#'
#' With the reported 95% CI (one-sided alpha = 0.025 per test):
#' equivalence holds for any symmetric bound at least as wide as the larger
#' absolute limit; clinical importance holds for any threshold up to the limit
#' nearest zero (only when the interval excludes zero); and non-inferiority
#' holds for any margin beyond the unfavorable limit.
#'
#' @param lower,upper Limits of the reported confidence interval.
#' @param estimate Optional point estimate (defaults to the midpoint).
#' @param threshold Optional threshold set outside the data (a published
#'   MCID or smallest worthwhile effect, the trialists' pre-specified value or
#'   a value the reader wrote down before reading the result).
#' @param higher_is_better For the non-inferiority range: `TRUE` if the
#'   difference is new minus standard and higher values favor the new option.
#' @param level Level of the reported interval (default 0.95).
#' @return An object of class `clinthresh_read` with the elements `estimate`,
#'   `ci`, `level`, `equivalence_holds_for`, `importance_holds_for` (`NA` when
#'   the interval includes zero), `noninferiority_holds_for`, `threshold` and
#'   `pattern` (`NA` without a threshold).
#' @examples
#' # KANON (early minus optional ACL reconstruction), KOOS4 at 2 years
#' read_ci(-6.8, 6.5, estimate = -0.2, threshold = 8)
#' # UKSTAR (brace minus cast), ATRS at 9 months
#' read_ci(-4.9, 2.1, estimate = -1.38)$noninferiority_holds_for
#' @export
read_ci <- function(lower, upper, estimate = NULL, threshold = NULL,
                    higher_is_better = TRUE, level = 0.95) {
  check_num(lower, "lower"); check_num(upper, "upper")
  if (!(upper > lower)) stop("`upper` must be larger than `lower`.", call. = FALSE)
  est <- if (is.null(estimate)) (lower + upper) / 2 else estimate
  imp <- if (lower > 0) lower else if (upper < 0) -upper else NA_real_
  ni <- if (higher_is_better) max(0, -lower) else max(0, upper)
  pat <- if (is.null(threshold)) NA_character_ else classify_ci(lower, upper, threshold)
  structure(list(estimate = est, ci = c(lower, upper), level = level,
                 equivalence_holds_for = max(abs(c(lower, upper))),
                 importance_holds_for = imp, noninferiority_holds_for = ni,
                 threshold = if (is.null(threshold)) NA_real_ else threshold,
                 pattern = pat), class = "clinthresh_read")
}

#' @export
print.clinthresh_read <- function(x, digits = 2, ...) {
  n <- function(v) formatC(v, digits = digits, format = "f")
  cat("Reading a published result (no test against a post hoc threshold)\n")
  cat(sprintf("  Estimate %s (%g%% CI %s to %s)\n", n(x$estimate), 100 * x$level, n(x$ci[1]), n(x$ci[2])))
  cat(sprintf("  Equivalence holds for symmetric bounds >= %s\n", n(x$equivalence_holds_for)))
  cat(sprintf("  Importance holds for thresholds <= %s\n",
              if (is.na(x$importance_holds_for)) "none (interval includes zero)" else n(x$importance_holds_for)))
  cat(sprintf("  Non-inferiority holds for margins >= %s\n", n(x$noninferiority_holds_for)))
  if (!is.na(x$pattern)) cat(sprintf("  Against a threshold of %s: %s\n", n(x$threshold), x$pattern))
  invisible(x)
}
