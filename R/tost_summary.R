#' Equivalence test (TOST) from group means and SDs
#'
#' Two independent groups (group 1 minus group 2) with Welch or pooled
#' standard error, or a paired design from the mean and SD of the
#' within-person differences.
#'
#' @inheritParams tost_ci
#' @param m1,sd1,n1 Mean, SD and size of group 1 (or, with `paired = TRUE`,
#'   the mean and SD of the differences and the number of pairs).
#' @param m2,sd2,n2 Mean, SD and size of group 2 (ignored when `paired = TRUE`).
#' @param welch Use the Welch (unequal variance) standard error and df.
#' @param paired Paired or crossover design.
#' @return An object of class `clinthresh_tost` (see [tost_ci()]).
#' @examples
#' tost_means(10, 5, 30, 8, 7, 25, sesoi = 5)
#' tost_means(0.23, 3.26, 40, sesoi = 1.57, paired = TRUE)
#' @export
tost_means <- function(m1, sd1, n1, m2 = NULL, sd2 = NULL, n2 = NULL, sesoi,
                       alpha = 0.025, welch = TRUE, paired = FALSE) {
  if (paired) {
    return(tost_se(m1, sd1 / sqrt(n1), sesoi, alpha = alpha, df = n1 - 1))
  }
  if (is.null(m2) || is.null(sd2) || is.null(n2))
    stop("Give `m2`, `sd2` and `n2`, or set `paired = TRUE`.", call. = FALSE)
  v1 <- sd1^2 / n1; v2 <- sd2^2 / n2
  if (welch) {
    se <- sqrt(v1 + v2); df <- (v1 + v2)^2 / (v1^2 / (n1 - 1) + v2^2 / (n2 - 1))
  } else {
    sp2 <- ((n1 - 1) * sd1^2 + (n2 - 1) * sd2^2) / (n1 + n2 - 2)
    se <- sqrt(sp2 * (1 / n1 + 1 / n2)); df <- n1 + n2 - 2
  }
  tost_se(m1 - m2, se, sesoi, alpha = alpha, df = df)
}

#' Equivalence test (TOST) for a risk difference
#'
#' Risk difference (group 1 minus group 2) in percentage points with a Wald
#' (unpooled) standard error. The Wald interval is unreliable with few events.
#'
#' @inheritParams tost_ci
#' @param x1,n1 Events and sample size in group 1.
#' @param x2,n2 Events and sample size in group 2.
#' @param sesoi Threshold in percentage points (a single positive value for
#'   symmetric bounds, or two values).
#' @return An object of class `clinthresh_tost` (see [tost_ci()]).
#' @examples
#' tost_prop(13, 274, 17, 266, sesoi = 5)
#' @export
tost_prop <- function(x1, n1, x2, n2, sesoi, alpha = 0.025) {
  p1 <- x1 / n1; p2 <- x2 / n2
  se <- 100 * sqrt(p1 * (1 - p1) / n1 + p2 * (1 - p2) / n2)
  if (se == 0) stop("Standard error is zero; the Wald method cannot be used.", call. = FALSE)
  tost_se(100 * (p1 - p2), se, sesoi, alpha = alpha, df = Inf)
}
