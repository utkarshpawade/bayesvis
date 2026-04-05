#' bayesvis: Extended Bayesian Visualization Diagnostics
#'
#' @description
#' A companion/extension prototype for the \pkg{bayesplot} package. Provides
#' advanced visualization tools for diagnosing Bayesian models:
#'
#' - `mcmc_shrinkage()`: Prior-to-posterior shrinkage diagnostic scatter plot
#' - `compute_shrinkage()`: Helper to compute shrinkage factors from draws
#' - `ppc_pit_hist()`: LOO probability integral transform histogram
#' - `ppc_pit_qq()`: LOO-PIT quantile-quantile plot with envelope
#' - `mcmc_rank_ecdf()`: Rank-based ECDF plots per chain with simultaneous bands
#' - `ppc_coverage()`: Posterior predictive coverage plot
#'
#' @section Conventions:
#' All plot functions follow \pkg{bayesplot} conventions:
#' \itemize{
#'   \item Function names are prefixed by plot category: `mcmc_*` for MCMC
#'     diagnostics, `ppc_*` for posterior predictive checks.
#'   \item All functions return [ggplot2::ggplot] objects that can be further
#'     customized with standard \pkg{ggplot2} layers.
#'   \item Plots use [bayesplot::bayesplot_theme_get()] and
#'     [bayesplot::color_scheme_get()] for visual consistency. Change the color
#'     scheme globally with [bayesplot::color_scheme_set()].
#' }
#'
#' @section References:
#' Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., and Gelman, A. (2019).
#' Visualization in Bayesian workflow. *Journal of the Royal Statistical
#' Society Series A*, 182(2), 389--402. \doi{10.1111/rssa.12378}
#'
#' Vehtari, A., Gelman, A., Simpson, D., Carpenter, B., and Bürkner, P.-C.
#' (2021). Rank-normalization, folding, and localization: An improved R-hat
#' for assessing convergence of MCMC (with discussion). *Bayesian Analysis*,
#' 16(2), 667--718. \doi{10.1214/20-BA1221}
#'
#' @name bayesvis-package
#' @aliases bayesvis
#' @importFrom rlang .data
"_PACKAGE"
