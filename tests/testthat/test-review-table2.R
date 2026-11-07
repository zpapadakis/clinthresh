# Table 2 of Papadakis (Curr Phys Med Rehabil Rep, under review), vs21.
# One rule for every row: reported estimate and 95% limits, normal approximation, and one error rate:
# every judgment uses the 95% CI (alpha = 0.025 per one-sided test, the package default).
z95 <- stats::qnorm(0.975)

test_that("Row 1, Lamo-Espinosa et al. 2025: clinically important at 6 points", {
  r <- tost_ci(6.54, 14.76, sesoi = 6, estimate = 10.65)
  expect_match(r$pattern, "Clinically important")
  expect_equal(r$p_min_effect_above, 0.013295, tolerance = 1e-3)
})

test_that("Row 2, Pringels et al. 2025: real, importance unclear at 10 points", {
  r <- tost_ci(6.2, 19.6, sesoi = 10, estimate = 12.9)
  expect_equal(r$pattern, "Real, importance unclear")
  expect_equal(r$p_min_effect_above, 0.19812, tolerance = 1e-3)
})

test_that("Row 3, Bensa et al. 2026 pain: real but trivial at +/-1, holds for bounds >= 0.74", {
  r <- tost_ci(0.12, 0.74, sesoi = 1, estimate = 0.43)
  expect_equal(r$pattern, "Real but trivial")
  expect_equal(max(abs(r$ci_equivalence)), 0.74)
  expect_lt(r$p_tost, 0.001)
})

test_that("Row 4, KANON: practically equivalent at +/-8, holds for bounds >= 6.8", {
  r <- tost_ci(-6.5, 6.8, sesoi = 8, estimate = 0.2)
  expect_equal(r$pattern, "Practically equivalent")
  expect_equal(max(abs(r$ci_equivalence)), 6.8)
  expect_equal(r$p_tost, 0.010755, tolerance = 1e-3)
  expect_true(r$equivalent)
})

test_that("Row 5, UKSTAR: non-inferior for margins >= 4.9, and equivalence implies non-inferiority", {
  se <- (2.1 - -4.9) / (2 * z95)
  expect_lt(stats::pnorm((-1.38 + 8) / se, lower.tail = FALSE), 0.001)
  expect_false(tost_ci(-4.9, 2.1, sesoi = 4.5, estimate = -1.38)$equivalent)
  expect_true(tost_ci(-4.9, 2.1, sesoi = 5, estimate = -1.38)$equivalent)
})

test_that("Row 6, Hamilton et al. 2015: inconclusive at +/-5 days, holds for bounds >= 7.2", {
  r <- tost_ci(-1.4, 7.2, sesoi = 5, estimate = 2.9)
  expect_equal(r$pattern, "Inconclusive")
  expect_equal(r$p_tost, 0.16924, tolerance = 1e-3)
  expect_equal(max(abs(r$ci_equivalence)), 7.2)
})

test_that("Row 7, Bensa et al. 2026 return to sport: importance unclear at 7 days", {
  r <- tost_ci(4.92, 10.17, sesoi = 7, estimate = 7.54)
  expect_equal(r$pattern, "Real, importance unclear")
  expect_equal(r$p_min_effect_above, 0.34340, tolerance = 1e-3)
})

test_that("With one error rate the five patterns do not overlap", {
  for (i in 1:2000) {
    lo <- stats::runif(1, -3, 3); hi <- lo + stats::runif(1, 0.1, 4)
    p <- classify_ci(lo, hi, sesoi = 1, ci_eq = c(lo, hi))
    trivial <- (lo > 0 || hi < 0) && lo > -1 && hi < 1
    unclear <- (lo > 0 || hi < 0) && !(lo > 1 || hi < -1) && !(lo > -1 && hi < 1)
    expect_false(trivial && unclear)
    if (trivial) expect_equal(p, "Real but trivial")
  }
})
