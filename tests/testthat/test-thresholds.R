test_that("swc, sem and mdc are correct", {
  expect_equal(swc(sd = 7.85), 1.57)
  expect_equal(swc(c(1, 2, 3, 4)), 0.2 * sd(1:4))
  expect_equal(sem_icc(20, 0.91), 6)
  expect_equal(mdc(sem = 1), qnorm(0.975) * sqrt(2))
  expect_equal(mdc(sd = 20, icc = 0.91), mdc(sem = 6))
  expect_error(sem_icc(20, 1.2))
})

test_that("small_telescope matches the caffeine example", {
  expect_equal(round(small_telescope(25, "paired"), 3), 0.319)
})

test_that("equivalence sample size gives adequate power", {
  n <- n_equivalence(sesoi = 0.5, sd = 1)
  expect_gte(power_equivalence(n, 0.5, 1), 0.80)
  expect_lt(power_equivalence(n - 1, 0.5, 1), 0.80)
  expect_lt(n_equivalence(0.5, 1, design = "paired"), n)
  expect_error(n_equivalence(0.5, 1, true_diff = 0.6))
})

test_that("power agrees with TOSTER when available", {
  skip_if_not_installed("TOSTER")
  p_ours <- power_equivalence(70, sesoi = 0.5, sd = 1)
  p_toster <- TOSTER::power_t_TOST(n = 70, delta = 0, sd = 1, eqb = 0.5, alpha = 0.05, type = "two.sample")$power
  expect_equal(p_ours, p_toster, tolerance = 0.02)
})

test_that("non-inferiority sample size matches the normal formula closely", {
  n <- n_noninferiority(margin = 0.5, sd = 1)
  approx <- ceiling(2 * (qnorm(0.975) + qnorm(0.8))^2 / 0.25)
  expect_true(abs(n - approx) <= 2)
})

test_that("proportion_reaching uses the right direction", {
  expect_equal(proportion_reaching(c(-3, -1, 0, -2), 2, higher_is_better = FALSE)$responders, 2)
  expect_equal(proportion_reaching(c(12, 5, 11.5), 11.5)$responders, 2)
})

test_that("reference table loads", {
  expect_true(all(c("instrument", "value_num", "doi") %in% names(mcid_reference)))
  expect_false(anyNA(mcid_reference$value_num))
})
