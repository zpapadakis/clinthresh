#' Smallest worthwhile change
#'
#' The smallest worthwhile change (SWC) is a distribution-based threshold
#' equal to a fraction (by default 0.2) of the between-subject standard
#' deviation. It is mostly used for performance tests in athletes.
#'
#' @param x Numeric vector of scores (one per athlete, for example baseline
#'   values). Ignored when `sd` is supplied.
#' @param sd Between-subject standard deviation, if already known.
#' @param factor Fraction of the standard deviation (default 0.2).
#' @return The smallest worthwhile change in the units of `x`.
#' @references Hopkins WG (2000). Sports Med 30:1-15.
#' @examples
#' swc(sd = 7.85)          # 1.57
#' swc(c(30, 34, 41, 38, 29, 45))
#' @export
swc <- function(x = NULL, sd = NULL, factor = 0.2) {
  if (is.null(sd)) {
    if (is.null(x) || length(stats::na.omit(x)) < 2) stop("Supply `x` (at least two values) or `sd`.", call. = FALSE)
    sd <- stats::sd(x, na.rm = TRUE)
  }
  check_num(sd, "sd"); check_num(factor, "factor")
  factor * sd
}

#' Standard error of measurement
#'
#' @param sd Between-subject standard deviation.
#' @param icc Test-retest intraclass correlation coefficient (0 to 1).
#' @return The standard error of measurement, `sd * sqrt(1 - icc)`.
#' @examples
#' sem_icc(sd = 20, icc = 0.90)
#' @export
sem_icc <- function(sd, icc) {
  check_num(sd, "sd"); check_num(icc, "icc")
  if (icc < 0 || icc > 1) stop("`icc` must be between 0 and 1.", call. = FALSE)
  sd * sqrt(1 - icc)
}

#' Minimal detectable change
#'
#' The smallest change in an individual that exceeds measurement error with
#' the stated confidence: `z * sqrt(2) * SEM`.
#'
#' @param sem Standard error of measurement (see [sem_icc()]). Alternatively
#'   supply `sd` and `icc`.
#' @param sd,icc Between-subject SD and test-retest ICC, used when `sem` is
#'   not given.
#' @param level Confidence level (default 0.95; 0.90 is also common).
#' @return The minimal detectable change in the units of the outcome.
#' @references de Vet HC et al. (2006). Health Qual Life Outcomes 4:54.
#' @examples
#' mdc(sem = 6.7, level = 0.90)   # about 15.6
#' mdc(sd = 20, icc = 0.90)
#' @export
mdc <- function(sem = NULL, sd = NULL, icc = NULL, level = 0.95) {
  if (is.null(sem)) {
    if (is.null(sd) || is.null(icc)) stop("Supply `sem`, or both `sd` and `icc`.", call. = FALSE)
    sem <- sem_icc(sd, icc)
  }
  check_num(sem, "sem")
  stats::qnorm(1 - (1 - level) / 2) * sqrt(2) * sem
}

#' Small-telescopes equivalence bound
#'
#' The standardized effect an original study had 33% power to detect
#' (Simonsohn 2015). It is a principled bound for testing whether a
#' replication result is too small to have been detected by the original
#' study.
#'
#' @param n Sample size of the original study (per group for two-sample
#'   designs; number of pairs for paired designs).
#' @param type `"two.sample"` (default), `"paired"` or `"one.sample"`.
#' @param alpha Two-sided alpha of the original study (default 0.05).
#' @param sd Optional standard deviation to convert the bound into raw units
#'   (for paired designs, the SD of the differences).
#' @return The standardized bound d33, or the raw bound when `sd` is given.
#' @references Simonsohn U (2015). Psychol Sci 26:559-69.
#' @examples
#' small_telescope(25, type = "paired")   # about 0.32
#' @export
small_telescope <- function(n, type = c("two.sample", "paired", "one.sample"), alpha = 0.05, sd = NULL) {
  type <- match.arg(type)
  d33 <- stats::power.t.test(n = n, sig.level = alpha, power = 1 / 3, type = type, sd = 1)$delta
  if (is.null(sd)) d33 else d33 * sd
}

#' Power of an equivalence test (TOST)
#'
#' Approximate power of the two one-sided tests procedure for a two-group or
#' paired comparison of means, using central t distributions.
#'
#' @param n Sample size per group (two-sample) or number of pairs (paired).
#' @param sesoi Equivalence margin (one positive number; symmetric bounds).
#' @param sd Standard deviation of the outcome (two-sample) or of the
#'   within-pair differences (paired).
#' @param true_diff Assumed true difference (default 0).
#' @param alpha Alpha for each one-sided test (default 0.05).
#' @param design `"two.sample"` or `"paired"`.
#' @return Power (0 to 1).
#' @export
power_equivalence <- function(n, sesoi, sd, true_diff = 0, alpha = 0.05,
                              design = c("two.sample", "paired")) {
  design <- match.arg(design)
  se <- if (design == "two.sample") sd * sqrt(2 / n) else sd / sqrt(n)
  df <- if (design == "two.sample") 2 * n - 2 else n - 1
  tc <- stats::qt(1 - alpha, df)
  p <- stats::pt((sesoi - true_diff) / se - tc, df) + stats::pt((sesoi + true_diff) / se - tc, df) - 1
  max(0, p)
}

#' Sample size for an equivalence trial
#'
#' Smallest sample size that gives the target power for a TOST against
#' symmetric bounds. Plan around the smallest effect size of interest, not
#' around an effect reported in an earlier small study.
#'
#' @inheritParams power_equivalence
#' @param power Target power (default 0.80; 0.90 is often preferred).
#' @return Sample size per group (two-sample) or number of pairs (paired).
#' @references Lakens D (2017). Soc Psychol Personal Sci 8:355-62.
#' @examples
#' n_equivalence(sesoi = 8, sd = 20)                 # KOOS-type outcome
#' n_equivalence(sesoi = 1.57, sd = 3.3, design = "paired")
#' @export
n_equivalence <- function(sesoi, sd, true_diff = 0, alpha = 0.05, power = 0.80,
                          design = c("two.sample", "paired")) {
  design <- match.arg(design)
  if (abs(true_diff) >= sesoi) stop("`true_diff` must be smaller than `sesoi` in absolute value.", call. = FALSE)
  for (n in 3:1e5) if (power_equivalence(n, sesoi, sd, true_diff, alpha, design) >= power) return(n)
  NA_integer_
}

#' Sample size for a non-inferiority trial
#'
#' @param margin Non-inferiority margin (positive number, in outcome units).
#'   The new treatment is non-inferior if the lower confidence limit of
#'   (new - control) lies above `-margin`, for an outcome where higher is
#'   better.
#' @param sd Standard deviation of the outcome (two-sample) or of the
#'   within-pair differences (paired).
#' @param true_diff Assumed true difference, new minus control (default 0).
#' @param alpha One-sided alpha (default 0.025, which matches a two-sided 95%
#'   confidence interval).
#' @param power Target power (default 0.80).
#' @param design `"two.sample"` or `"paired"`.
#' @return Sample size per group, or number of pairs.
#' @references Piaggio G et al. (2012). JAMA 308:2594-604.
#' @examples
#' n_noninferiority(margin = 8, sd = 20)
#' @export
n_noninferiority <- function(margin, sd, true_diff = 0, alpha = 0.025, power = 0.80,
                             design = c("two.sample", "paired")) {
  design <- match.arg(design)
  if (margin <= 0) stop("`margin` must be positive.", call. = FALSE)
  for (n in 3:1e5) {
    se <- if (design == "two.sample") sd * sqrt(2 / n) else sd / sqrt(n)
    df <- if (design == "two.sample") 2 * n - 2 else n - 1
    if (stats::pt((margin + true_diff) / se - stats::qt(1 - alpha, df), df) >= power) return(n)
  }
  NA_integer_
}

#' Proportion of patients reaching an individual threshold
#'
#' Individual thresholds such as the MCID or PASS should be reported as the
#' proportion of patients who reach them, not compared with a group mean.
#'
#' @param change Numeric vector of individual change scores (or final scores
#'   for PASS).
#' @param threshold The threshold.
#' @param higher_is_better Logical; if `FALSE`, a reduction counts as
#'   improvement (for example pain scores).
#' @param level Confidence level for the Wilson interval (default 0.95).
#' @return A data frame with n, number of responders, proportion and Wilson
#'   confidence interval.
#' @examples
#' set.seed(1); proportion_reaching(rnorm(60, 10, 12), threshold = 11.5)
#' @export
proportion_reaching <- function(change, threshold, higher_is_better = TRUE, level = 0.95) {
  change <- stats::na.omit(change)
  hit <- if (higher_is_better) change >= threshold else change <= -abs(threshold)
  n <- length(change); k <- sum(hit); p <- k / n
  z <- stats::qnorm(1 - (1 - level) / 2)
  centre <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / (1 + z^2 / n)
  data.frame(n = n, responders = k, proportion = p,
             lower = max(0, centre - half), upper = min(1, centre + half))
}
