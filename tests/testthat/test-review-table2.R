# Table 2 of Papadakis (Curr Phys Med Rehabil Rep, under review), vs20.
# One rule for every row: reported estimate and 95% limits, normal approximation.
z95 <- stats::qnorm(0.975)

test_that("Row 1, Lamo-Espinosa et al. 2025: clinically important at 6 points", {
  r <- tost_ci(6.54, 14.76, sesoi = 6, estimate = 10.65)
  expect_match(r$pattern, "Clinically important")
  expect_equal(r$ci_equivalence, c(7.2008, 14.0992), tolerance = 1e-4)
  expect_equal(r$p_min_effect_above, 0.013295, tolerance = 1e-3)
})

test_that("Row 2, Pringels et al. 2025: real, importance unclear at 10 points", {
  r <- tost_ci(6.2, 19.6, sesoi = 10, estimate = 12.9)
  expect_equal(r$pattern, "Real, importance unclear")
  expect_equal(r$p_min_effect_above, 0.19812, tolerance = 1e-3)
})

test_that("Row 3, Bensa et al. 2026 pain: real but trivial at +/-1", {
  r <- tost_ci(0.12, 0.74, sesoi = 1, estimate = 0.43)
  expect_equal(r$pattern, "Real but trivial")
  expect_equal(max(abs(r$ci_equivalence)), 0.6902, tolerance = 1e-3)
  expect_lt(r$p_tost, 0.001)
})

test_that("Row 4, KANON: practically equivalent at +/-8, holds for bounds >= 5.8", {
  r <- tost_ci(-6.5, 6.8, sesoi = 8, estimate = 0.2)
  expect_equal(r$pattern, "Practically equivalent")
  expect_equal(r$ci_equivalence, c(-5.3809, 5.7809), tolerance = 1e-4)
  expect_equal(r$p_tost, 0.010755, tolerance = 1e-3)
})

test_that("Row 5, UKSTAR: non-inferior for margins >= 4.9; equivalent within +/-4.5", {
  se <- (2.1 - -4.9) / (2 * z95)
  expect_lt(stats::pnorm((-1.38 + 8) / se, lower.tail = FALSE), 0.001)
  r <- tost_ci(-4.9, 2.1, sesoi = 4.5, estimate = -1.38)
  expect_true(r$equivalent)
  expect_equal(r$ci_equivalence, c(-4.3173, 1.5573), tolerance = 1e-4)
})

test_that("Row 6, Hamilton et al. 2015: inconclusive at +/-5 days", {
  r <- tost_ci(-1.4, 7.2, sesoi = 5, estimate = 2.9)
  expect_equal(r$pattern, "Inconclusive")
  expect_equal(r$p_tost, 0.16924, tolerance = 1e-3)
  expect_equal(max(abs(r$ci_equivalence)), 6.5087, tolerance = 1e-3)
})

test_that("Row 7, Bensa et al. 2026 return to sport: importance unclear at 7 days", {
  r <- tost_ci(4.92, 10.17, sesoi = 7, estimate = 7.54)
  expect_equal(r$pattern, "Real, importance unclear")
  expect_equal(r$ci_equivalence, c(5.3370, 9.7430), tolerance = 1e-4)
  expect_equal(r$p_min_effect_above, 0.34340, tolerance = 1e-3)
})
