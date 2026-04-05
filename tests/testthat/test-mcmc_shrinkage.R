test_that("mcmc_shrinkage() returns a ggplot object", {
  p <- mcmc_shrinkage(test_posterior, prior_sd = 1)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_shrinkage() works with per-parameter prior_sd", {
  p <- mcmc_shrinkage(test_posterior, prior_sd = rep(1, n_params))
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_shrinkage() works with prior_draws", {
  prior <- matrix(rnorm(n_iter * n_params), nrow = n_iter)
  colnames(prior) <- colnames(test_posterior)
  p <- mcmc_shrinkage(test_posterior, prior_draws = prior)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_shrinkage() prior_draws takes precedence over prior_sd", {
  prior <- matrix(rnorm(n_iter * n_params), nrow = n_iter)
  colnames(prior) <- colnames(test_posterior)
  p <- mcmc_shrinkage(test_posterior, prior_sd = 1, prior_draws = prior)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_shrinkage() subsets parameters with pars", {
  p <- mcmc_shrinkage(
    test_posterior,
    prior_sd = 1,
    pars = c("alpha", "sigma")
  )
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_shrinkage() works with a single parameter", {
  single <- test_posterior[, "alpha", drop = FALSE]
  p <- mcmc_shrinkage(single, prior_sd = 1)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_shrinkage() works with unnamed matrix columns", {
  unnamed <- unname(test_posterior)
  p <- mcmc_shrinkage(unnamed, prior_sd = 1)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_shrinkage() accepts data frame input", {
  df <- as.data.frame(test_posterior)
  p  <- mcmc_shrinkage(df, prior_sd = 1)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_shrinkage() errors when neither prior_sd nor prior_draws given", {
  expect_error(
    mcmc_shrinkage(test_posterior),
    regexp = "prior_sd|prior_draws"
  )
})

test_that("mcmc_shrinkage() errors on wrong prior_sd length", {
  expect_error(
    mcmc_shrinkage(test_posterior, prior_sd = c(1, 2)),  # 2 != 4
    regexp = "length 1 or"
  )
})

test_that("mcmc_shrinkage() errors on non-existent pars", {
  expect_error(
    mcmc_shrinkage(test_posterior, prior_sd = 1, pars = "nonexistent"),
    regexp = "Parameters not found"
  )
})

test_that("mcmc_shrinkage() label_size = 0 suppresses labels", {
  p <- mcmc_shrinkage(test_posterior, prior_sd = 1, label_size = 0)
  expect_s3_class(p, "ggplot")
  geom_types <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_false("GeomText" %in% geom_types)
})


test_that("compute_shrinkage() returns named numeric vector", {
  kappa <- compute_shrinkage(test_posterior, prior_sd = 1)
  expect_type(kappa, "double")
  expect_named(kappa)
  expect_length(kappa, n_params)
})

test_that("compute_shrinkage() values are in [0, 1]", {
  kappa <- compute_shrinkage(test_posterior, prior_sd = 1)
  expect_true(all(kappa >= 0 & kappa <= 1))
})

test_that("compute_shrinkage() high-shrinkage parameters near 1", {
  kappa <- compute_shrinkage(test_posterior, prior_sd = 1)
  expect_gt(kappa["alpha"],   0.9)
  expect_gt(kappa["beta[1]"], 0.9)
})

test_that("compute_shrinkage() low-shrinkage parameters near 0", {
  kappa <- compute_shrinkage(test_posterior, prior_sd = 1)
  expect_lt(kappa["sigma"], 0.3)
})

test_that("compute_shrinkage() works with prior_draws", {
  prior <- matrix(rnorm(n_iter * n_params), nrow = n_iter)
  kappa <- compute_shrinkage(test_posterior, prior_draws = prior)
  expect_length(kappa, n_params)
})

test_that("compute_shrinkage() errors without prior specification", {
  expect_error(
    compute_shrinkage(test_posterior),
    regexp = "prior_sd|prior_draws"
  )
})

test_that("compute_shrinkage() errors on mismatched prior_draws columns", {
  wrong_cols <- matrix(rnorm(n_iter * 2L), nrow = n_iter)
  expect_error(
    compute_shrinkage(test_posterior, prior_draws = wrong_cols),
    regexp = "same number of columns"
  )
})

test_that("compute_shrinkage() errors on wrong prior_sd length", {
  expect_error(
    compute_shrinkage(test_posterior, prior_sd = c(1, 2)),
    regexp = "length 1 or"
  )
})

test_that("mcmc_shrinkage() plot data has correct structure", {
  p <- mcmc_shrinkage(test_posterior, prior_sd = 1)
  expect_equal(nrow(p$data), n_params)
  expect_true(all(c("z_score", "shrinkage", "parameter") %in% names(p$data)))
  expect_true(all(p$data$shrinkage >= 0 & p$data$shrinkage <= 1))
})

test_that("mcmc_shrinkage() errors on non-numeric point_size", {
  expect_error(
    mcmc_shrinkage(test_posterior, prior_sd = 1, point_size = "big"),
    regexp = "point_size"
  )
})

test_that("validate_draws_matrix() rejects 1-row matrix", {
  expect_error(
    bayesvis:::validate_draws_matrix(matrix(1:3, nrow = 1)),
    regexp = "at least 2"
  )
})

test_that("validate_draws_matrix() coerces data.frame", {
  df <- data.frame(a = 1:5, b = 6:10)
  result <- bayesvis:::validate_draws_matrix(df)
  expect_true(is.matrix(result))
})
