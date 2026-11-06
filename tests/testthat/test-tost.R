test_that("tost_ci reproduces the worked examples in the review", {
  k <- tost_ci(-6.5, 6.8, sesoi = 8)                 # KANON
  expect_equal(round(k$ci_equivalence, 1), c(-5.4, 5.7))
  expect_equal(round(k$p_tost, 2), 0.01)
  expect_true(k$equivalent)
  r <- tost_ci(-0.9, 0.2, sesoi = 1.8)               # RESTORE
  expect_lt(r$p_tost, 0.001)
  expect_equal(r$pattern, "Practically equivalent")
  h <- tost_ci(-0.18, -0.04, sesoi = 0.5)            # Rutjes, large trials
  expect_equal(h$pattern, "Real but trivial")
  v <- tost_ci(-12.4, 10.6, sesoi = 12)              # de Vos
  expect_equal(round(v$p_tost, 2), 0.03)
})

test_that("tost_ci and tost_se agree", {
  a <- tost_ci(-1, 3, sesoi = 4)
  b <- tost_se(a$estimate, a$se, sesoi = 4)
  expect_equal(a$p_tost, b$p_tost)
})

test_that("asymmetric bounds and input checks work", {
  x <- tost_ci(-1, 1, sesoi = c(-2, 3))
  expect_equal(x$bounds, c(-2, 3))
  expect_error(tost_ci(1, -1, 2))
  expect_error(tost_ci(-1, 1, -2))
  expect_error(tost_ci(-1, 1, c(3, 1)))
})

test_that("t-based version is more conservative than normal", {
  expect_gt(tost_ci(-1, 1, 1.5, df = 10)$p_tost, tost_ci(-1, 1, 1.5)$p_tost)
})

test_that("classify_ci returns each pattern", {
  expect_match(classify_ci(1.3, 2.5, 1), "above the upper bound")
  expect_match(classify_ci(-2.5, -1.3, 1), "below the lower bound")
  expect_equal(classify_ci(0.3, 2.0, 1), "Real, importance unclear")
  expect_equal(classify_ci(0.2, 0.8, 1), "Real but trivial")
  expect_equal(classify_ci(-0.5, 0.55, 1), "Practically equivalent")
  expect_equal(classify_ci(-1.5, 2.2, 1), "Inconclusive")
})

test_that("report_sentence and print produce text", {
  x <- tost_ci(-6.5, 6.8, sesoi = 8)
  expect_match(report_sentence(x, "points"), "lies inside")
  expect_output(print(x), "Equivalence test")
})

test_that("summary-statistic TOST matches TOSTER 0.8.6", {
  w <- tost_means(10, 5, 30, 8, 7, 25, sesoi = 5)
  expect_equal(w$df, 42.40304, tolerance = 1e-6)
  expect_equal(w$p_upper, 0.03989339, tolerance = 1e-6)
  p <- tost_means(0.23, 3.26, 40, sesoi = 1.57, paired = TRUE)
  expect_equal(p$p_tost, 0.0065547, tolerance = 1e-4)
  r <- tost_prop(13, 274, 17, 266, sesoi = 5)
  expect_equal(r$p_tost, 0.04471023, tolerance = 1e-6)
})
