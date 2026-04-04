#' Posterior predictive coverage plot
#'
#' @description
#' For each observed data point, computes a credible interval from the
#' posterior predictive draws and marks whether the observation is covered.
#' Observations are displayed sorted on the x-axis, with intervals colored
#' by coverage status and the empirical coverage rate annotated.
#'
#' Departures from the nominal `prob` coverage indicate model
#' mis-specification:
#' \itemize{
#'   \item **Empirical coverage < nominal**: the model is over-confident
#'     (intervals too narrow).
#'   \item **Empirical coverage > nominal**: the model is under-confident
#'     (intervals too wide).
#' }
#'
#' @param y A numeric vector of observed data values (length \eqn{n}).
#' @param yrep A numeric matrix of posterior predictive draws (\eqn{S \times n}),
#'   where \eqn{S} is the number of draws and \eqn{n = \text{length}(y)}.
#' @param prob Numeric in (0, 1). Nominal coverage probability for the
#'   predictive intervals. Default `0.90`.
#' @param sort_by Character string. How to order observations on the x-axis:
#'   \describe{
#'     \item{`"y"`}{Sort by observed value (default). Makes coverage gaps
#'       near the tails easy to spot.}
#'     \item{`"mean"`}{Sort by posterior predictive mean.}
#'     \item{`"index"`}{Preserve original observation order.}
#'   }
#' @param point_size Numeric. Size of observed-value points. Default `1.5`.
#' @param interval_linewidth Numeric. Width of the interval line segments.
#'   Default `0.4`.
#'
#' @return A [ggplot2::ggplot] object.
#'
#' @details
#' The predictive interval bounds for observation \eqn{i} are the
#' \eqn{(1 - \text{prob})/2} and \eqn{(1 + \text{prob})/2} empirical
#' quantiles of the column \eqn{\text{yrep}[, i]}. Coverage is defined as
#' \eqn{y_i \in [\text{lower}_i,\, \text{upper}_i]}.
#'
#' @references
#' Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., and Gelman, A. (2019).
#' Visualization in Bayesian workflow. *Journal of the Royal Statistical
#' Society Series A*, 182(2), 389--402. \doi{10.1111/rssa.12378}
#'
#' Gelman, A., Meng, X.-L., and Stern, H. (1996). Posterior predictive
#' assessment of model fitness via realized discrepancies. *Statistica Sinica*,
#' 6(4), 733--760.
#'
#' @examples
#' set.seed(99)
#' n    <- 60
#' y    <- rnorm(n, mean = 2, sd = 1)
#' yrep <- matrix(rnorm(500 * n, mean = 2, sd = 1), nrow = 500)
#'
#' # Well-calibrated model: empirical coverage ≈ nominal 90%
#' ppc_coverage(y, yrep, prob = 0.90)
#'
#' # Over-confident model: intervals are too narrow
#' yrep_narrow <- matrix(rnorm(500 * n, mean = 2, sd = 0.25), nrow = 500)
#' ppc_coverage(y, yrep_narrow, prob = 0.90)
#'
#' # Sort by posterior predictive mean instead of observed value
#' ppc_coverage(y, yrep, sort_by = "mean")
#'
#' @export
ppc_coverage <- function(y,
                         yrep,
                         prob               = 0.90,
                         sort_by            = c("y", "mean", "index"),
                         point_size         = 1.5,
                         interval_linewidth = 0.4) {
  y       <- validate_y(y)
  yrep    <- validate_yrep(yrep, y)
  sort_by <- match.arg(sort_by)

  if (prob <= 0 || prob >= 1) {
    rlang::abort("`prob` must be in (0, 1).")
  }

  n        <- length(y)
  alpha_lo <- (1 - prob) / 2
  alpha_hi <- 1 - alpha_lo

  lower   <- apply(yrep, 2, stats::quantile, probs = alpha_lo, names = FALSE)
  upper   <- apply(yrep, 2, stats::quantile, probs = alpha_hi, names = FALSE)
  pm      <- colMeans(yrep)
  covered <- (y >= lower) & (y <= upper)
  emp_cov <- mean(covered)

  df <- tibble::tibble(
    obs_index = seq_len(n),
    y         = y,
    lower     = lower,
    upper     = upper,
    pm        = pm,
    covered   = covered
  )

  df <- switch(
    sort_by,
    y     = df[order(df$y),  ],
    mean  = df[order(df$pm), ],
    index = df
  )
  df$x_pos <- seq_len(n)

  scheme     <- bayesplot::color_scheme_get()
  col_cover  <- scheme[["mid"]]
  col_miss   <- scheme[["dark_highlight"]]
  fill_cover <- scheme[["light"]]
  fill_miss  <- scheme[["dark"]]

  ann_label <- sprintf(
    "Empirical: %.1f%%  (nominal: %.0f%%)",
    100 * emp_cov, 100 * prob
  )
  ann_color <- if (abs(emp_cov - prob) < 0.05) "grey30" else col_miss

  ggplot2::ggplot(df, ggplot2::aes(x = .data$x_pos)) +
    ggplot2::geom_linerange(
      ggplot2::aes(
        ymin  = .data$lower,
        ymax  = .data$upper,
        color = .data$covered
      ),
      linewidth = interval_linewidth,
      alpha     = 0.65
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        y     = .data$y,
        color = .data$covered,
        fill  = .data$covered
      ),
      size  = point_size,
      shape = 21,
      alpha = 0.9
    ) +
    ggplot2::scale_color_manual(
      values = c("TRUE"  = col_cover,  "FALSE" = col_miss),
      labels = c("TRUE"  = "Covered",  "FALSE" = "Not covered"),
      name   = NULL
    ) +
    ggplot2::scale_fill_manual(
      values = c("TRUE"  = fill_cover, "FALSE" = fill_miss),
      labels = c("TRUE"  = "Covered",  "FALSE" = "Not covered"),
      name   = NULL
    ) +
    ggplot2::annotate(
      "text",
      x        = 1,
      y        = Inf,
      label    = ann_label,
      hjust    = 0,
      vjust    = 1.6,
      size     = 3.5,
      color    = ann_color,
      fontface = "bold"
    ) +
    ggplot2::labs(
      x        = paste0("Observation index (sorted by ", sort_by, ")"),
      y        = "Value",
      title    = paste0(
        scales_label(prob), " posterior predictive coverage"
      ),
      subtitle = paste0(
        n, " observations  |  ",
        sum(!covered), " not covered  |  ",
        nrow(yrep), " posterior predictive draws"
      )
    ) +
    ggplot2::theme(legend.position = "bottom") +
    bayesplot::bayesplot_theme_get()
}
