#' LOO probability integral transform histogram
#'
#' @description
#' Plots the distribution of LOO probability integral transform (LOO-PIT)
#' values as a density histogram, overlaid with the expected Uniform(0, 1)
#' density and a simultaneous confidence band. Under ideal calibration the
#' LOO-PIT values are approximately Uniform(0, 1); departures indicate
#' over-dispersion (U-shaped histogram) or under-dispersion (hump-shaped).
#'
#' @param pit A numeric vector of LOO-PIT values in \[0, 1\]. Typically
#'   obtained from `loo::loo_pit()`.
#' @param bins Integer. Number of histogram bins. Default `10`.
#' @param prob Numeric in (0, 1). Coverage probability for the confidence
#'   band around the uniform density. Default `0.95`.
#' @param ... Currently unused. Included for future extensibility.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @details
#' Each bin count follows a \eqn{\text{Binomial}(n, 1/K)} distribution under
#' the null hypothesis that PIT values are Uniform(0, 1), where \eqn{n} is
#' the number of observations and \eqn{K} = `bins`. The confidence band is
#' derived from the normal approximation to the binomial, converted to the
#' density scale (\eqn{K/n} × count).
#'
#' The histogram bars display density, not counts, so the theoretical
#' uniform reference is the horizontal line at \eqn{y = 1}.
#'
#' @references
#' Vehtari, A., Gelman, A., and Gabry, J. (2017). Practical Bayesian model
#' evaluation using leave-one-out cross-validation and WAIC. *Statistics and
#' Computing*, 27(5), 1413--1432. \doi{10.1007/s11222-016-9696-4}
#'
#' Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., and Gelman, A. (2019).
#' Visualization in Bayesian workflow. *Journal of the Royal Statistical
#' Society Series A*, 182(2), 389--402. \doi{10.1111/rssa.12378}
#'
#' @examples
#' set.seed(2024)
#'
#' # Well-calibrated model: PIT values near Uniform(0,1)
#' pit_good <- runif(200)
#' ppc_loo_pit(pit_good)
#'
#' # Over-dispersed model: PIT values concentrated near 0 and 1
#' pit_over <- rbeta(200, shape1 = 0.4, shape2 = 0.4)
#' ppc_loo_pit(pit_over)
#'
#' # Under-dispersed model: PIT values concentrated near 0.5
#' pit_under <- rbeta(200, shape1 = 4, shape2 = 4)
#' ppc_loo_pit(pit_under)
#'
#' @export
ppc_loo_pit <- function(pit, bins = 10L, prob = 0.95, ...) {
  pit <- validate_pit(pit)
  n   <- length(pit)
  K   <- as.integer(bins)

  if (K < 2L || K > n) {
    rlang::abort(
      paste0("`bins` must be between 2 and length(pit) = ", n, ".")
    )
  }
  if (prob <= 0 || prob >= 1) {
    rlang::abort("`prob` must be in (0, 1).")
  }

  # Under H0 (uniform): each bin count ~ Binomial(n, 1/K)
  # Expected density = 1 (uniform density on [0,1])
  # SD of density = sqrt(n * p * (1-p)) / (n * (1/K))
  #               = sqrt((1-1/K) / (n/K))
  bin_prob   <- 1 / K
  density_sd <- sqrt(bin_prob * (1 - bin_prob) * K^2 / n)  # simplifies to sqrt(K*(K-1)/n)
  z_crit     <- stats::qnorm((1 + prob) / 2)

  band_lower <- max(0, 1 - z_crit * density_sd)
  band_upper <- 1 + z_crit * density_sd

  # Color scheme
  scheme   <- bayesplot::color_scheme_get()
  fill_col <- scheme[["light"]]
  line_col <- scheme[["dark"]]
  band_col <- scheme[["mid"]]

  # Band spans the full [0,1] x range
  band_df <- data.frame(
    xmin = 0, xmax = 1,
    ymin = band_lower, ymax = band_upper
  )

  ggplot2::ggplot(data.frame(pit = pit), ggplot2::aes(x = .data$pit)) +
    # Confidence band (behind histogram)
    ggplot2::geom_rect(
      data        = band_df,
      ggplot2::aes(
        xmin = .data$xmin, xmax = .data$xmax,
        ymin = .data$ymin, ymax = .data$ymax
      ),
      fill        = band_col,
      alpha       = 0.25,
      inherit.aes = FALSE
    ) +
    # Density histogram
    ggplot2::geom_histogram(
      ggplot2::aes(y = ggplot2::after_stat(density)),
      bins      = K,
      fill      = fill_col,
      color     = line_col,
      linewidth = 0.35,
      alpha     = 0.85
    ) +
    # Expected uniform density
    ggplot2::geom_hline(
      yintercept = 1,
      color      = line_col,
      linetype   = "dashed",
      linewidth  = 0.7
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0, 1),
      breaks = seq(0, 1, by = 0.25),
      expand = c(0, 0)
    ) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.06))
    ) +
    ggplot2::labs(
      x        = "LOO-PIT value",
      y        = "Density",
      title    = "LOO-PIT distribution",
      subtitle = paste0(
        "n = ", n, "  |  ",
        scales_label(prob), " confidence band  |  ",
        K, " bins"
      )
    ) +
    bayesplot::bayesplot_theme_get()
}


#' LOO probability integral transform Q-Q plot
#'
#' @description
#' A quantile-quantile plot comparing LOO-PIT values against the theoretical
#' Uniform(0, 1) quantiles. Under ideal calibration, points should fall
#' near the diagonal. A simultaneous pointwise envelope is shown using the
#' order-statistic Beta distribution.
#'
#' @param pit A numeric vector of LOO-PIT values in \[0, 1\]. Typically
#'   obtained from `loo::loo_pit()`.
#' @param prob Numeric in (0, 1). Coverage probability for the pointwise
#'   Beta envelope. Default `0.95`.
#' @param ... Currently unused. Included for future extensibility.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @details
#' The \eqn{k}-th order statistic of \eqn{n} Uniform(0, 1) draws follows a
#' \eqn{\text{Beta}(k,\, n - k + 1)} distribution. The envelope uses
#' pointwise Beta quantiles evaluated at each sorted empirical rank position,
#' providing an \eqn{(1-\alpha/2)} pointwise band around the diagonal.
#' This is more accurate than a normal-approximation envelope for small
#' samples and near the boundaries.
#'
#' @references
#' Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., and Gelman, A. (2019).
#' Visualization in Bayesian workflow. *Journal of the Royal Statistical
#' Society Series A*, 182(2), 389--402. \doi{10.1111/rssa.12378}
#'
#' @examples
#' set.seed(2024)
#'
#' # Well-calibrated model
#' pit_good <- runif(150)
#' ppc_loo_pit_qq(pit_good)
#'
#' # Right-skewed PIT: model is over-confident
#' pit_skewed <- rbeta(150, shape1 = 2, shape2 = 0.8)
#' ppc_loo_pit_qq(pit_skewed, prob = 0.99)
#'
#' @export
ppc_loo_pit_qq <- function(pit, prob = 0.95, ...) {
  pit <- validate_pit(pit)
  n   <- length(pit)

  if (prob <= 0 || prob >= 1) {
    rlang::abort("`prob` must be in (0, 1).")
  }

  # Sorted empirical PIT values
  emp   <- sort(pit)
  alpha <- (1 - prob) / 2

  # Theoretical uniform quantiles (mean of k-th order statistic)
  ranks <- seq_len(n)
  theo  <- ranks / (n + 1)

  # Pointwise envelope via Beta order-statistic distribution
  lower <- stats::qbeta(alpha,     shape1 = ranks, shape2 = n - ranks + 1)
  upper <- stats::qbeta(1 - alpha, shape1 = ranks, shape2 = n - ranks + 1)

  qq_df <- tibble::tibble(
    theoretical = theo,
    empirical   = emp,
    lower       = lower,
    upper       = upper
  )

  # Color scheme
  scheme   <- bayesplot::color_scheme_get()
  pt_color <- scheme[["mid"]]
  pt_fill  <- scheme[["light"]]
  env_col  <- scheme[["mid"]]
  ref_col  <- scheme[["dark"]]

  ggplot2::ggplot(
    qq_df,
    ggplot2::aes(x = .data$theoretical, y = .data$empirical)
  ) +
    # Confidence envelope
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data$lower, ymax = .data$upper),
      fill  = env_col,
      alpha = 0.30
    ) +
    # Reference diagonal
    ggplot2::geom_abline(
      intercept = 0,
      slope     = 1,
      color     = ref_col,
      linetype  = "dashed",
      linewidth = 0.6
    ) +
    # Q-Q points
    ggplot2::geom_point(
      size  = 2,
      shape = 21,
      color = pt_color,
      fill  = pt_fill,
      alpha = 0.85
    ) +
    ggplot2::scale_x_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25)) +
    ggplot2::coord_equal() +
    ggplot2::labs(
      x        = "Theoretical Uniform(0,1) quantiles",
      y        = "Empirical LOO-PIT quantiles",
      title    = "LOO-PIT Q-Q plot",
      subtitle = paste0(
        "n = ", n, "  |  ",
        scales_label(prob), " pointwise envelope"
      )
    ) +
    bayesplot::bayesplot_theme_get()
}
