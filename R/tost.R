#' Equivalence test (TOST) from a reported estimate and confidence interval
#'
#' Recovers the standard error from a reported confidence interval and runs
#' the two one-sided tests (TOST) procedure against an equivalence margin.
#' This lets a reader test equivalence for a published trial when only the
#' abstract is available.
#'
#' @param lower,upper Limits of the reported confidence interval.
#' @param sesoi Smallest effect size of interest. A single positive number
#'   gives symmetric bounds (-sesoi, +sesoi); a vector of two numbers gives
#'   asymmetric bounds (lower bound, upper bound).
#' @param estimate Reported point estimate. If `NULL` (default) the midpoint
#'   of the interval is used, which keeps the estimate and the standard error
#'   internally consistent when both were rounded.
#' @param level Confidence level of the reported interval (default 0.95).
#' @param alpha Alpha for each one-sided test. The default, 0.025, corresponds
#'   to a 95% confidence interval, the convention for equivalence and
#'   non-inferiority trials (CONSORT), so every judgment uses the interval a
#'   paper prints. Use 0.05 (a 90% interval) to match bioequivalence or TOSTER
#'   defaults.
#' @param df Degrees of freedom. `Inf` (default) uses the normal distribution;
#'   supply the trial's degrees of freedom for a t-based approximation.
#' When the equivalence interval has the same level as the reported interval
#' (for example `alpha = 0.025` with a 95% CI), the reported limits are used as
#' the equivalence interval, so the conclusion can be read straight off the
#' printed interval even when the reported estimate is not its midpoint.
#' @return An object of class `clinthresh_tost`: a list with the estimate,
#'   standard error, the (1 - 2 * alpha) confidence interval, the
#'   null-hypothesis P value, the two one-sided P values, the TOST P value,
#'   the bounds, and the interval pattern from [classify_ci()].
#' @references
#' Schuirmann DJ (1987). J Pharmacokinet Biopharm 15:657-80.
#' Lakens D (2017). Soc Psychol Personal Sci 8:355-62.
#' @examples
#' # KANON trial: KOOS4 difference 0.2 (95% CI -6.5 to 6.8), margin 8 points
#' tost_ci(lower = -6.5, upper = 6.8, sesoi = 8)
#' @export
tost_ci <- function(lower, upper, sesoi, estimate = NULL, level = 0.95,
                    alpha = 0.025, df = Inf) {
  check_num(lower, "lower"); check_num(upper, "upper")
  if (upper <= lower) stop("`upper` must be greater than `lower`.", call. = FALSE)
  bounds <- make_bounds(sesoi)
  if (!is.numeric(level) || level <= 0 || level >= 1) stop("`level` must be between 0 and 1.", call. = FALSE)
  if (!is.numeric(alpha) || alpha <= 0 || alpha >= 0.5) stop("`alpha` must be between 0 and 0.5.", call. = FALSE)
  crit <- if (is.finite(df)) stats::qt(1 - (1 - level) / 2, df) else stats::qnorm(1 - (1 - level) / 2)
  se <- (upper - lower) / (2 * crit)
  mid <- (lower + upper) / 2
  est <- if (is.null(estimate)) mid else estimate
  tost_core(est, se, bounds, alpha, df, ci_reported = c(lower, upper), level = level,
            ci_eq = if (abs((1 - 2 * alpha) - level) < 1e-9) c(lower, upper) else NULL)
}

#' Equivalence test (TOST) from an estimate and its standard error
#'
#' @inheritParams tost_ci
#' @param estimate Point estimate (for example a between-group difference).
#' @param se Standard error of the estimate.
#' @return An object of class `clinthresh_tost` (see [tost_ci()]).
#' @examples
#' tost_se(estimate = 0.23, se = 0.52, sesoi = 1.57, df = 39)
#' @export
tost_se <- function(estimate, se, sesoi, alpha = 0.025, df = Inf) {
  check_num(estimate, "estimate"); check_num(se, "se")
  if (se <= 0) stop("`se` must be positive.", call. = FALSE)
  bounds <- make_bounds(sesoi)
  crit <- if (is.finite(df)) stats::qt(0.975, df) else stats::qnorm(0.975)
  tost_core(estimate, se, bounds, alpha, df,
            ci_reported = estimate + c(-1, 1) * crit * se, level = 0.95)
}

tost_core <- function(est, se, bounds, alpha, df, ci_reported, level, ci_eq = NULL) {
  pfun <- function(q) if (is.finite(df)) stats::pt(q, df, lower.tail = FALSE) else stats::pnorm(q, lower.tail = FALSE)
  qfun <- function(p) if (is.finite(df)) stats::qt(p, df) else stats::qnorm(p)
  p_lower <- pfun((est - bounds[1]) / se)        # H0: effect <= lower bound
  p_upper <- pfun((bounds[2] - est) / se)        # H0: effect >= upper bound
  p_nhst <- 2 * pfun(abs(est / se))
  if (is.null(ci_eq)) ci_eq <- est + c(-1, 1) * qfun(1 - alpha) * se
  out <- list(
    estimate = est, se = se, df = df,
    ci_reported = ci_reported, level = level,
    ci_equivalence = ci_eq, ci_equivalence_level = 1 - 2 * alpha,
    bounds = bounds, p_nhst = p_nhst,
    p_lower = p_lower, p_upper = p_upper, p_tost = max(p_lower, p_upper),
    p_min_effect_above = pfun((est - bounds[2]) / se),  # H0: effect <= upper bound
    p_min_effect_below = pfun((bounds[1] - est) / se),  # H0: effect >= lower bound
    equivalent = ci_eq[1] > bounds[1] && ci_eq[2] < bounds[2],
    pattern = classify_ci(ci_reported[1], ci_reported[2], bounds, ci_eq = ci_eq)
  )
  class(out) <- "clinthresh_tost"
  out
}

#' @export
print.clinthresh_tost <- function(x, digits = 3, ...) {
  f <- function(v) formatC(v, digits = digits, format = "fg", flag = "#")
  cat("Equivalence test (TOST)\n")
  cat(sprintf("  Estimate: %s (%g%% CI %s to %s), P = %s\n", f(x$estimate),
              100 * x$level, f(x$ci_reported[1]), f(x$ci_reported[2]), format_p(x$p_nhst)))
  cat(sprintf("  Bounds: %s to %s\n", f(x$bounds[1]), f(x$bounds[2])))
  cat(sprintf("  %g%% CI: %s to %s; TOST P = %s\n", 100 * x$ci_equivalence_level,
              f(x$ci_equivalence[1]), f(x$ci_equivalence[2]), format_p(x$p_tost)))
  cat(sprintf("  Pattern: %s\n", x$pattern))
  cat(sprintf("  %s\n", report_sentence(x)))
  invisible(x)
}

make_bounds <- function(sesoi) {
  if (!is.numeric(sesoi) || anyNA(sesoi)) stop("`sesoi` must be numeric.", call. = FALSE)
  if (length(sesoi) == 1) {
    if (sesoi <= 0) stop("A single `sesoi` must be positive.", call. = FALSE)
    return(c(-sesoi, sesoi))
  }
  if (length(sesoi) == 2 && sesoi[1] < sesoi[2]) return(sesoi)
  stop("`sesoi` must be one positive number or two increasing numbers.", call. = FALSE)
}

check_num <- function(x, nm) {
  if (!is.numeric(x) || length(x) != 1 || is.na(x)) stop(sprintf("`%s` must be a single number.", nm), call. = FALSE)
}

format_p <- function(p) {
  if (is.na(p)) return("NA")
  if (p < 0.001) return("< 0.001")
  if (p < 0.01) return(sprintf("%.3f", p))
  sprintf("%.2f", p)
}
