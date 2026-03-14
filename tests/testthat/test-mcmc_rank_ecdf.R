test_that("mcmc_rank_ecdf() returns a ggplot object", {
  p <- mcmc_rank_ecdf(test_array)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_rank_ecdf() subsets parameters with pars", {
  p <- mcmc_rank_ecdf(test_array, pars = "alpha")
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_rank_ecdf() subsets multiple parameters", {
  p <- mcmc_rank_ecdf(test_array, pars = c("alpha", "sigma"))
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_rank_ecdf() accepts custom prob", {
  p <- mcmc_rank_ecdf(test_array, prob = 0.95)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_rank_ecdf() works with single chain", {
  single_chain <- test_array[, 1L, , drop = FALSE]
  p <- mcmc_rank_ecdf(single_chain)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_rank_ecdf() works with single parameter", {
  single_param <- test_array[, , 1L, drop = FALSE]
  p <- mcmc_rank_ecdf(single_param)
  expect_s3_class(p, "ggplot")
  # Single parameter: no facets expected
  geom_types <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_false("FacetWrap" %in% class(p$facet))
})

test_that("mcmc_rank_ecdf() produces facets for multiple parameters", {
  p <- mcmc_rank_ecdf(test_array)
  expect_true(inherits(p$facet, "FacetWrap"))
})

test_that("mcmc_rank_ecdf() works with unnamed dimnames", {
  arr <- array(
    rnorm(50 * 2 * 3),
    dim = c(50L, 2L, 3L)
  )
  p <- mcmc_rank_ecdf(arr)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_rank_ecdf() detects badly mixing chains", {
  # The plot should still build without error on pathological data
  p <- mcmc_rank_ecdf(bad_array)
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_rank_ecdf() accepts facet_args", {
  p <- mcmc_rank_ecdf(test_array, facet_args = list(ncol = 1L))
  expect_s3_class(p, "ggplot")
})

test_that("mcmc_rank_ecdf() errors on non-3D input", {
  expect_error(
    mcmc_rank_ecdf(test_posterior),
    regexp = "3D array"
  )
})

test_that("mcmc_rank_ecdf() errors on non-existent pars", {
  expect_error(
    mcmc_rank_ecdf(test_array, pars = "nonexistent"),
    regexp = "Parameters not found"
  )
})

test_that("mcmc_rank_ecdf() errors when prob outside (0, 1)", {
  expect_error(
    mcmc_rank_ecdf(test_array, prob = 0),
    regexp = "\\(0, 1\\)"
  )
})

test_that("mcmc_rank_ecdf() errors on non-numeric array", {
  char_arr <- array(as.character(1:24), dim = c(4, 3, 2))
  expect_error(mcmc_rank_ecdf(char_arr), regexp = "numeric")
})
