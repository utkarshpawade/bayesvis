# ppc_loo_pit() tests --------------------------------------------------------

test_that("ppc_loo_pit() returns a ggplot object", {
  p <- ppc_loo_pit(test_pit)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_loo_pit() accepts custom bins", {
  p <- ppc_loo_pit(test_pit, bins = 20L)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_loo_pit() accepts custom prob", {
  p <- ppc_loo_pit(test_pit, prob = 0.80)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_loo_pit() handles boundary values 0 and 1", {
  # Some LOO-PIT implementations can produce exact 0s or 1s
  pit_boundary <- c(0, test_pit, 1)
  p <- ppc_loo_pit(pit_boundary, bins = 5L)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_loo_pit() errors on non-numeric input", {
  expect_error(ppc_loo_pit(c("a", "b", "c")), regexp = "numeric")
})

test_that("ppc_loo_pit() errors when values outside [0, 1]", {
  expect_error(
    ppc_loo_pit(c(0.1, 0.5, 1.5)),
    regexp = "\\[0, 1\\]"
  )
})

test_that("ppc_loo_pit() errors when prob outside (0, 1)", {
  expect_error(ppc_loo_pit(test_pit, prob = 0),   regexp = "\\(0, 1\\)")
  expect_error(ppc_loo_pit(test_pit, prob = 1.2),  regexp = "\\(0, 1\\)")
})

test_that("ppc_loo_pit() errors when bins out of range", {
  expect_error(ppc_loo_pit(test_pit, bins = 1L),   regexp = "bins")
  expect_error(ppc_loo_pit(test_pit, bins = 1000L), regexp = "bins")
})

test_that("ppc_loo_pit() warns and drops NAs", {
  pit_with_na <- c(test_pit, NA, NA)
  expect_warning(
    p <- ppc_loo_pit(pit_with_na),
    regexp = "NA"
  )
  expect_s3_class(p, "ggplot")
})

test_that("ppc_loo_pit() minimum valid input (3 values)", {
  p <- ppc_loo_pit(c(0.1, 0.5, 0.9), bins = 2L)
  expect_s3_class(p, "ggplot")
})


# ppc_loo_pit_qq() tests -----------------------------------------------------

test_that("ppc_loo_pit_qq() returns a ggplot object", {
  p <- ppc_loo_pit_qq(test_pit)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_loo_pit_qq() accepts custom prob", {
  p <- ppc_loo_pit_qq(test_pit, prob = 0.99)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_loo_pit_qq() errors on non-numeric input", {
  expect_error(ppc_loo_pit_qq(c("a", "b", "c")), regexp = "numeric")
})

test_that("ppc_loo_pit_qq() errors when prob outside (0, 1)", {
  expect_error(ppc_loo_pit_qq(test_pit, prob = 1), regexp = "\\(0, 1\\)")
})

test_that("ppc_loo_pit_qq() handles boundary values", {
  p <- ppc_loo_pit_qq(c(0, 0.5, 1))
  expect_s3_class(p, "ggplot")
})

test_that("ppc_loo_pit_qq() produces a fixed/equal aspect ratio coordinate", {
  p     <- ppc_loo_pit_qq(test_pit)
  coord <- p$coordinates
  # ggplot2 >= 4.0 merged CoordEqual into CoordCartesian; check ratio = 1
  is_coord_equal <- inherits(coord, "CoordFixed") ||
                    inherits(coord, "CoordEqual")  ||
                    (inherits(coord, "CoordCartesian") &&
                       isTRUE(all.equal(coord$ratio, 1)))
  expect_true(is_coord_equal)
})
