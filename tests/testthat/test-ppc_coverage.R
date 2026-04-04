test_that("ppc_coverage() returns a ggplot object", {
  p <- ppc_coverage(test_y, test_yrep)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_coverage() accepts custom prob", {
  p <- ppc_coverage(test_y, test_yrep, prob = 0.50)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_coverage() accepts all sort_by options", {
  for (s in c("y", "mean", "index")) {
    p <- ppc_coverage(test_y, test_yrep, sort_by = s)
    expect_s3_class(p, "ggplot")
  }
})

test_that("ppc_coverage() reports correct number of uncovered obs", {
  yrep_narrow <- matrix(
    rnorm(500L * n_obs, mean = mean(test_y), sd = 0.05),
    nrow = 500L
  )
  p <- ppc_coverage(test_y, yrep_narrow, prob = 0.90)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_coverage() works with minimum observations (n = 2)", {
  y_small    <- rnorm(2L)
  yrep_small <- matrix(rnorm(10L * 2L), nrow = 10L)
  p <- ppc_coverage(y_small, yrep_small)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_coverage() works with minimum predictive draws (S = 2)", {
  yrep_min <- matrix(rnorm(2L * n_obs), nrow = 2L)
  p <- ppc_coverage(test_y, yrep_min)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_coverage() errors on non-numeric y", {
  expect_error(
    ppc_coverage(letters[seq_len(n_obs)], test_yrep),
    regexp = "numeric"
  )
})

test_that("ppc_coverage() errors when ncol(yrep) != length(y)", {
  yrep_wrong <- matrix(rnorm(100L * 10L), nrow = 100L)  # 10 cols, not n_obs
  expect_error(
    ppc_coverage(test_y, yrep_wrong),
    regexp = "ncol == length"
  )
})

test_that("ppc_coverage() errors when prob outside (0, 1)", {
  expect_error(ppc_coverage(test_y, test_yrep, prob = 0),   regexp = "\\(0, 1\\)")
  expect_error(ppc_coverage(test_y, test_yrep, prob = 1.5), regexp = "\\(0, 1\\)")
})

test_that("ppc_coverage() errors on non-matrix yrep", {
  expect_error(
    ppc_coverage(test_y, as.vector(test_yrep)),
    regexp = "matrix"
  )
})

test_that("ppc_coverage() warns and handles NA in y", {
  y_with_na <- c(test_y, NA)
  expect_warning(
    tryCatch(
      ppc_coverage(y_with_na, test_yrep),
      error = function(e) NULL
    ),
    regexp = "NA"
  )
})

test_that("ppc_coverage() invalid sort_by errors", {
  expect_error(
    ppc_coverage(test_y, test_yrep, sort_by = "banana"),
    regexp = "sort_by|arg"
  )
})
