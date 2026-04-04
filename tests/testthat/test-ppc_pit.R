test_that("ppc_pit_hist() returns a ggplot object", {
  p <- ppc_pit_hist(test_pit)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_pit_hist() accepts custom bins", {
  p <- ppc_pit_hist(test_pit, bins = 20L)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_pit_hist() accepts custom prob", {
  p <- ppc_pit_hist(test_pit, prob = 0.80)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_pit_hist() handles boundary values 0 and 1", {
  # Some LOO-PIT implementations can produce exact 0s or 1s
  pit_boundary <- c(0, test_pit, 1)
  p <- ppc_pit_hist(pit_boundary, bins = 5L)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_pit_hist() errors on non-numeric input", {
  expect_error(ppc_pit_hist(c("a", "b", "c")), regexp = "numeric")
})

test_that("ppc_pit_hist() errors when values outside [0, 1]", {
  expect_error(
    ppc_pit_hist(c(0.1, 0.5, 1.5)),
    regexp = "\\[0, 1\\]"
  )
})

test_that("ppc_pit_hist() errors when prob outside (0, 1)", {
  expect_error(ppc_pit_hist(test_pit, prob = 0),   regexp = "\\(0, 1\\)")
  expect_error(ppc_pit_hist(test_pit, prob = 1.2),  regexp = "\\(0, 1\\)")
})

test_that("ppc_pit_hist() errors when bins out of range", {
  expect_error(ppc_pit_hist(test_pit, bins = 1L),   regexp = "bins")
  expect_error(ppc_pit_hist(test_pit, bins = 1000L), regexp = "bins")
})

test_that("ppc_pit_hist() warns and drops NAs", {
  pit_with_na <- c(test_pit, NA, NA)
  expect_warning(
    p <- ppc_pit_hist(pit_with_na),
    regexp = "NA"
  )
  expect_s3_class(p, "ggplot")
})

test_that("ppc_pit_hist() minimum valid input (3 values)", {
  p <- ppc_pit_hist(c(0.1, 0.5, 0.9), bins = 2L)
  expect_s3_class(p, "ggplot")
})


test_that("ppc_pit_qq() returns a ggplot object", {
  p <- ppc_pit_qq(test_pit)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_pit_qq() accepts custom prob", {
  p <- ppc_pit_qq(test_pit, prob = 0.99)
  expect_s3_class(p, "ggplot")
})

test_that("ppc_pit_qq() errors on non-numeric input", {
  expect_error(ppc_pit_qq(c("a", "b", "c")), regexp = "numeric")
})

test_that("ppc_pit_qq() errors when prob outside (0, 1)", {
  expect_error(ppc_pit_qq(test_pit, prob = 1), regexp = "\\(0, 1\\)")
})

test_that("ppc_pit_qq() handles boundary values", {
  p <- ppc_pit_qq(c(0, 0.5, 1))
  expect_s3_class(p, "ggplot")
})

test_that("ppc_pit_qq() produces a fixed/equal aspect ratio coordinate", {
  p     <- ppc_pit_qq(test_pit)
  coord <- p$coordinates
  # ggplot2 >= 4.0 merged CoordEqual into CoordCartesian; check ratio = 1
  is_coord_equal <- inherits(coord, "CoordFixed") ||
                    inherits(coord, "CoordEqual")  ||
                    (inherits(coord, "CoordCartesian") &&
                       isTRUE(all.equal(coord$ratio, 1)))
  expect_true(is_coord_equal)
})
