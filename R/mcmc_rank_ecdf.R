#' Rank-based ECDF plots per chain
#'
#' @description
#' Plots the empirical cumulative distribution function (ECDF) of within-chain
#' rank statistics alongside a simultaneous confidence band consistent with
#' ideal mixing. Under good mixing the ECDFs for all chains should be
#' indistinguishable and lie within the band around the diagonal. Chains that
#' explore different regions of the posterior will show ECDFs that diverge
#' from the diagonal and from each other.
#'
#' This is the ECDF-based companion to `bayesplot::mcmc_rank_overlay()` and
#' implements the diagnostic described by Vehtari et al. (2021).
#'
#' @param x A 3D numeric array of MCMC draws with dimensions
#'   \[iterations × chains × parameters\]. The `dimnames` attribute is used
#'   for chain and parameter labels; missing names are auto-generated.
#' @param pars Optional character vector of parameter names to plot.
#'   Names must match the third dimension of `x`. If `NULL` (default), all
#'   parameters are shown.
#' @param prob Numeric in (0, 1). Coverage probability for the simultaneous
#'   confidence band (DKW inequality). Default `0.99`.
#' @param facet_args A named list of additional arguments forwarded to
#'   [ggplot2::facet_wrap()], such as `ncol` or `scales`. Ignored when only
#'   one parameter is plotted.
#'
#' @return A [ggplot2::ggplot] object. When multiple parameters are shown, the
#'   plot is faceted by parameter.
#'
#' @details
#' For each parameter, draws from all chains are pooled and ranked (average
#' ties). The ECDF of the resulting within-chain ranks is plotted for each
#' chain on the probability scale \eqn{[0, 1]} (ranks divided by the total
#' number of draws \eqn{S = I \times C}).
#'
#' Under ideal mixing the ranks are exchangeable across chains, so each chain's
#' ECDF should track the diagonal. The simultaneous band uses the
#' Dvoretzky-Kiefer-Wolfowitz (DKW) inequality:
#' \deqn{\Pr\!\left(\sup_x |F_I(x) - F(x)| \leq \varepsilon\right) \geq
#'   1 - 2e^{-2 I \varepsilon^2}}
#' where \eqn{I} is the number of iterations per chain, giving:
#' \deqn{\varepsilon = \sqrt{\frac{\log(2/\alpha)}{2I}}}
#'
#' @seealso [bayesplot::mcmc_rank_overlay()] for rank histograms;
#'   [bayesplot::mcmc_trace()] for trace plots.
#'
#' @references
#' Vehtari, A., Gelman, A., Simpson, D., Carpenter, B., and Bürkner, P.-C.
#' (2021). Rank-normalization, folding, and localization: An improved R-hat
#' for assessing convergence of MCMC (with discussion). *Bayesian Analysis*,
#' 16(2), 667--718. \doi{10.1214/20-BA1221}
#'
#' @examples
#' set.seed(7)
#'
#' # Well-mixing chains: ECDFs should stay within the confidence band
#' good <- array(
#'   rnorm(500 * 4 * 2),
#'   dim      = c(500, 4, 2),
#'   dimnames = list(NULL, paste0("chain:", 1:4), c("mu", "sigma"))
#' )
#' mcmc_rank_ecdf(good)
#'
#' # Pathological mixing: first chain stuck in a different region
#' bad <- good
#' bad[, 1, 1] <- rnorm(500, mean = 10, sd = 0.2)
#' mcmc_rank_ecdf(bad, pars = "mu")
#'
#' # Adjust number of facet columns
#' mcmc_rank_ecdf(good, facet_args = list(ncol = 1))
#'
#' @export
mcmc_rank_ecdf <- function(x,
                           pars       = NULL,
                           prob       = 0.99,
                           facet_args = list()) {
  x <- validate_mcmc_array(x)

  n_iter   <- dim(x)[1L]
  n_chains <- dim(x)[2L]
  n_params <- dim(x)[3L]

  if (is.null(dimnames(x)[[2L]])) {
    dimnames(x)[[2L]] <- paste0("chain:", seq_len(n_chains))
  }
  if (is.null(dimnames(x)[[3L]])) {
    dimnames(x)[[3L]] <- paste0("param[", seq_len(n_params), "]")
  }

  chain_names <- dimnames(x)[[2L]]
  param_names <- dimnames(x)[[3L]]

  if (!is.null(pars)) {
    missing_pars <- setdiff(pars, param_names)
    if (length(missing_pars) > 0L) {
      rlang::abort(paste0(
        "Parameters not found in `x`: ",
        paste(missing_pars, collapse = ", ")
      ))
    }
    x           <- x[, , pars, drop = FALSE]
    param_names <- pars
    n_params    <- length(pars)
  }

  if (prob <= 0 || prob >= 1) {
    rlang::abort("`prob` must be in (0, 1).")
  }

  S_total <- n_iter * n_chains

  plot_rows <- vector("list", n_params * n_chains)
  idx <- 0L

  for (p in seq_len(n_params)) {
    draws_p <- x[, , p]
    pooled  <- as.vector(draws_p)
    ranks_p <- matrix(
      rank(pooled, ties.method = "average"),
      nrow = n_iter,
      ncol = n_chains
    )

    for (ch in seq_len(n_chains)) {
      idx <- idx + 1L

      chain_ranks  <- sort(ranks_p[, ch])
      n_ch         <- length(chain_ranks)
      ecdf_y       <- seq_len(n_ch) / n_ch
      theo_x       <- chain_ranks / S_total

      plot_rows[[idx]] <- tibble::tibble(
        parameter   = param_names[p],
        chain       = chain_names[ch],
        theoretical = theo_x,
        ecdf_y      = ecdf_y
      )
    }
  }

  plot_df           <- do.call(rbind, plot_rows)
  plot_df$parameter <- factor(plot_df$parameter, levels = param_names)
  plot_df$chain     <- factor(plot_df$chain,     levels = chain_names)

  epsilon  <- ecdf_simultaneous_band(n_iter, prob = prob)
  theo_seq <- seq(0, 1, length.out = 300)
  band_df  <- tibble::tibble(
    theoretical = theo_seq,
    lower       = pmax(0, theo_seq - epsilon),
    upper       = pmin(1, theo_seq + epsilon)
  )

  scheme       <- bayesplot::color_scheme_get()
  band_fill    <- scheme[["light"]]
  ref_color    <- scheme[["dark"]]
  chain_colors <- bayesplot_chain_colors(n_chains)

  default_facet <- list(ncol = min(3L, n_params))
  facet_args    <- utils::modifyList(default_facet, as.list(facet_args))

  p <- ggplot2::ggplot(
    plot_df,
    ggplot2::aes(
      x     = .data$theoretical,
      y     = .data$ecdf_y,
      color = .data$chain
    )
  ) +
    ggplot2::geom_ribbon(
      data        = band_df,
      ggplot2::aes(
        x    = .data$theoretical,
        ymin = .data$lower,
        ymax = .data$upper
      ),
      fill        = band_fill,
      alpha       = 0.45,
      inherit.aes = FALSE
    ) +
    ggplot2::geom_abline(
      intercept = 0,
      slope     = 1,
      color     = ref_color,
      linetype  = "dashed",
      linewidth = 0.5,
      alpha     = 0.7
    ) +
    ggplot2::geom_step(linewidth = 0.75, alpha = 0.85) +
    ggplot2::scale_color_manual(
      values = chain_colors,
      name   = "Chain"
    ) +
    ggplot2::scale_x_continuous(breaks = seq(0, 1, 0.25)) +
    ggplot2::scale_y_continuous(breaks = seq(0, 1, 0.25)) +
    ggplot2::labs(
      x        = "Theoretical quantile  (pooled uniform rank)",
      y        = "Empirical CDF",
      title    = "Rank ECDF per chain",
      subtitle = paste0(
        n_chains, " chain", if (n_chains != 1L) "s" else "", "  |  ",
        n_iter,   " iterations  |  ",
        scales_label(prob), " simultaneous band"
      )
    ) +
    bayesplot::bayesplot_theme_get()

  if (n_params > 1L) {
    p <- p + do.call(
      ggplot2::facet_wrap,
      c(list(ggplot2::vars(.data$parameter)), facet_args)
    )
  }

  p
}
