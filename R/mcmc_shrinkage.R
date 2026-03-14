#' Prior-to-posterior shrinkage diagnostic plot
#'
#' @description
#' Plots the shrinkage factor against the posterior z-score for each parameter.
#' Shrinkage quantifies how much the posterior has contracted relative to the
#' prior: \eqn{\kappa \approx 1} means the data are highly informative for that
#' parameter; \eqn{\kappa \approx 0} means the posterior barely updated from
#' the prior.
#'
#' This diagnostic is especially useful in regularized regression and
#' hierarchical models where some parameters may be weakly identified, and
#' as part of simulation-based calibration (SBC) workflows.
#'
#' @param x A numeric matrix of posterior draws with dimensions
#'   \[iterations × parameters\]. Column names are used as parameter labels.
#'   A data frame will be coerced to a matrix.
#' @param prior_sd A numeric vector of prior standard deviations, one per
#'   parameter. Recycled to `ncol(x)` if scalar. Either `prior_sd` or
#'   `prior_draws` must be supplied.
#' @param prior_draws An optional numeric matrix of prior draws with the same
#'   column structure as `x`. Use this when closed-form prior SDs are
#'   unavailable. If both `prior_sd` and `prior_draws` are supplied,
#'   `prior_draws` takes precedence.
#' @param pars Optional character vector of parameter names to display.
#'   Names must match column names of `x`. If `NULL` (default), all
#'   parameters are shown.
#' @param point_size Numeric. Size of plotted points. Default `3`.
#' @param label_size Numeric. Text size for parameter labels (in mm).
#'   Default `3`. Set to `0` to suppress labels.
#'
#' @return A [ggplot2::ggplot] object. The plot can be further customized
#'   with standard **ggplot2** layers and
#'   [bayesplot::bayesplot_theme_set()].
#'
#' @details
#' The shrinkage factor for parameter \eqn{\theta} is defined as:
#' \deqn{\kappa_\theta = 1 - \frac{\widehat{\operatorname{Var}}(\theta \mid y)}
#'   {\widehat{\operatorname{Var}}(\theta)}}
#' where the numerator is the sample variance of the posterior draws and the
#' denominator is the prior variance (supplied via `prior_sd` or estimated from
#' `prior_draws`). Values are clamped to \[0, 1\].
#'
#' The z-score is the ratio of the posterior mean to the posterior SD:
#' \deqn{z_\theta = \frac{\bar{\theta}_{\text{post}}}
#'   {\widehat{\operatorname{SD}}(\theta \mid y)}}
#' serving as a signal-to-noise measure. Parameters with
#' \eqn{|z| > 2} and high \eqn{\kappa} are well-identified. Parameters with
#' low \eqn{\kappa} regardless of z-score suggest weak identifiability or
#' near-prior posteriors.
#'
#' Reference lines are drawn at \eqn{\kappa \in \{0, 0.5, 1\}} and at
#' \eqn{z = 0}.
#'
#' @references
#' Piironen, J. and Vehtari, A. (2017). Comparison of Bayesian predictive
#' methods for model selection. *Statistics and Computing*, 27(3), 711--735.
#' \doi{10.1007/s11222-016-9649-y}
#'
#' Betancourt, M. and Girolami, M. (2015). Hamiltonian Monte Carlo for
#' hierarchical models. *Current Trends in Bayesian Methodology with
#' Applications*, 79(30), 2--4.
#'
#' @examples
#' set.seed(42)
#' n_iter <- 1000
#'
#' # Six parameters: first three have high shrinkage (informative data),
#' # last three have low shrinkage (weakly identified / near-prior)
#' posterior <- matrix(
#'   c(rnorm(n_iter * 3, mean = 1.5, sd = 0.15),  # high shrinkage
#'     rnorm(n_iter * 3, mean = 0.0, sd = 0.95)),  # low shrinkage
#'   ncol = 6
#' )
#' colnames(posterior) <- paste0("beta[", 1:6, "]")
#'
#' mcmc_shrinkage(posterior, prior_sd = 1)
#'
#' # Using prior draws instead of closed-form prior SDs
#' prior_draws <- matrix(rnorm(n_iter * 6, sd = 1), ncol = 6)
#' colnames(prior_draws) <- colnames(posterior)
#' mcmc_shrinkage(posterior, prior_draws = prior_draws)
#'
#' # Select a subset of parameters
#' mcmc_shrinkage(posterior, prior_sd = 1, pars = paste0("beta[", 4:6, "]"))
#'
#' @export
mcmc_shrinkage <- function(x,
                           prior_sd    = NULL,
                           prior_draws = NULL,
                           pars        = NULL,
                           point_size  = 3,
                           label_size  = 3) {
  x <- validate_draws_matrix(x)

  if (is.null(prior_sd) && is.null(prior_draws)) {
    rlang::abort("One of `prior_sd` or `prior_draws` must be supplied.")
  }

  # Assign default column names if missing
  if (is.null(colnames(x))) {
    colnames(x) <- paste0("param[", seq_len(ncol(x)), "]")
  }

  # Subset parameters
  if (!is.null(pars)) {
    missing_pars <- setdiff(pars, colnames(x))
    if (length(missing_pars) > 0L) {
      rlang::abort(paste0(
        "Parameters not found in `x`: ",
        paste(missing_pars, collapse = ", ")
      ))
    }
    x <- x[, pars, drop = FALSE]
  }

  n_params    <- ncol(x)
  param_names <- colnames(x)

  # Posterior statistics
  post_mean <- colMeans(x)
  post_var  <- apply(x, 2, stats::var)
  post_sd   <- sqrt(post_var)

  # Prior variance — from prior_draws if supplied, else from prior_sd
  if (!is.null(prior_draws)) {
    prior_draws <- validate_draws_matrix(prior_draws)
    if (!is.null(pars)) {
      # Match columns; allow prior_draws to have more columns than x
      pars_avail <- intersect(pars, colnames(prior_draws))
      if (length(pars_avail) < length(pars)) {
        rlang::abort(
          "Some `pars` not found as column names in `prior_draws`."
        )
      }
      prior_draws <- prior_draws[, pars, drop = FALSE]
    }
    if (ncol(prior_draws) != n_params) {
      rlang::abort(
        "`prior_draws` must have the same number of columns as `x`."
      )
    }
    prior_var <- apply(prior_draws, 2, stats::var)
  } else {
    if (length(prior_sd) == 1L) {
      prior_sd <- rep(prior_sd, n_params)
    }
    if (length(prior_sd) != n_params) {
      rlang::abort(paste0(
        "`prior_sd` must be length 1 or ", n_params,
        " (one per parameter)."
      ))
    }
    prior_var <- prior_sd^2
  }

  # Compute shrinkage (clamped to [0,1]) and z-scores
  shrinkage <- pmax(0, pmin(1, 1 - post_var / prior_var))
  z_score   <- post_mean / post_sd

  plot_df <- tibble::tibble(
    parameter = factor(param_names, levels = param_names),
    z_score   = z_score,
    shrinkage = shrinkage
  )

  # Color scheme from bayesplot
  scheme    <- bayesplot::color_scheme_get()
  clr_pt    <- scheme[["mid"]]
  clr_fill  <- scheme[["light"]]
  clr_dark  <- scheme[["dark"]]
  clr_label <- scheme[["dark_highlight"]]

  p <- ggplot2::ggplot(
    plot_df,
    ggplot2::aes(x = .data$z_score, y = .data$shrinkage)
  ) +
    # Horizontal reference lines at kappa = 0, 0.5, 1
    ggplot2::geom_hline(
      yintercept = c(0, 1),
      color      = clr_dark,
      linetype   = "dashed",
      linewidth  = 0.5,
      alpha      = 0.7
    ) +
    ggplot2::geom_hline(
      yintercept = 0.5,
      color      = clr_dark,
      linetype   = "dotted",
      linewidth  = 0.4,
      alpha      = 0.45
    ) +
    # Vertical reference at z = 0
    ggplot2::geom_vline(
      xintercept = 0,
      color      = clr_dark,
      linetype   = "dashed",
      linewidth  = 0.5,
      alpha      = 0.7
    ) +
    # Scatter points
    ggplot2::geom_point(
      size  = point_size,
      shape = 21,
      color = clr_pt,
      fill  = clr_fill,
      alpha = 0.9
    ) +
    ggplot2::scale_y_continuous(
      limits = c(-0.07, 1.07),
      breaks = c(0, 0.25, 0.5, 0.75, 1),
      labels = c(
        "0\n(no shrinkage)", "0.25", "0.5", "0.75",
        "1\n(full shrinkage)"
      )
    ) +
    ggplot2::labs(
      x        = "Posterior z-score  (mean / SD)",
      y        = expression("Shrinkage factor  " * kappa),
      title    = "Prior-to-posterior shrinkage",
      subtitle = paste0(n_params, " parameter", if (n_params != 1L) "s" else "")
    ) +
    bayesplot::bayesplot_theme_get()

  # Parameter labels (suppressed when label_size == 0)
  if (label_size > 0) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = .data$parameter),
      size     = label_size,
      vjust    = -1,
      color    = clr_label,
      fontface = "italic"
    )
  }

  p
}


#' Compute shrinkage factors from posterior and prior draws
#'
#' @description
#' A helper that computes the prior-to-posterior shrinkage factor
#' \eqn{\kappa = 1 - \widehat{\operatorname{Var}}(\theta \mid y) /
#' \widehat{\operatorname{Var}}(\theta)} for each parameter, returning a
#' named numeric vector. Values are clamped to \[0, 1\].
#'
#' @inheritParams mcmc_shrinkage
#'
#' @return A named numeric vector of shrinkage factors, one per parameter.
#'
#' @examples
#' set.seed(1)
#' post <- matrix(rnorm(500 * 4, mean = c(0, 1, 2, 0), sd = 0.3), ncol = 4)
#' colnames(post) <- paste0("b[", 1:4, "]")
#'
#' compute_shrinkage(post, prior_sd = 1)
#'
#' @export
compute_shrinkage <- function(x, prior_sd = NULL, prior_draws = NULL) {
  x <- validate_draws_matrix(x)

  if (is.null(prior_sd) && is.null(prior_draws)) {
    rlang::abort("One of `prior_sd` or `prior_draws` must be supplied.")
  }

  if (is.null(colnames(x))) {
    colnames(x) <- paste0("param[", seq_len(ncol(x)), "]")
  }

  n_params <- ncol(x)
  post_var <- apply(x, 2, stats::var)

  if (!is.null(prior_draws)) {
    prior_draws <- validate_draws_matrix(prior_draws)
    prior_var   <- apply(prior_draws, 2, stats::var)
  } else {
    if (length(prior_sd) == 1L) prior_sd <- rep(prior_sd, n_params)
    prior_var <- prior_sd^2
  }

  kappa <- pmax(0, pmin(1, 1 - post_var / prior_var))
  stats::setNames(kappa, colnames(x))
}
