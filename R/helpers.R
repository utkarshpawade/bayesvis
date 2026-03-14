# Internal helper functions shared across bayesvis
# None of these are exported.

# ── Input validation ──────────────────────────────────────────────────────────

#' Validate and coerce a posterior draws matrix
#'
#' Accepts a numeric matrix or a data frame that can be coerced to one.
#' Errors informatively on wrong type, wrong dimensions, or non-numeric input.
#'
#' @param x Object to validate.
#' @param call Calling environment for error messages.
#' @return A numeric matrix.
#' @noRd
validate_draws_matrix <- function(x, call = rlang::caller_env()) {
  if (is.data.frame(x)) {
    x <- as.matrix(x)
  }
  if (!is.matrix(x)) {
    rlang::abort(
      paste0("`x` must be a numeric matrix of posterior draws, not a ",
             class(x)[1L], "."),
      call = call
    )
  }
  if (!is.numeric(x)) {
    rlang::abort("`x` must be a numeric matrix.", call = call)
  }
  if (nrow(x) < 2L) {
    rlang::abort("`x` must have at least 2 rows (MCMC draws).", call = call)
  }
  x
}

#' Validate a 3D MCMC array (iterations x chains x parameters)
#'
#' @param x Object to validate.
#' @param call Calling environment for error messages.
#' @return A validated 3D numeric array.
#' @noRd
validate_mcmc_array <- function(x, call = rlang::caller_env()) {
  if (!is.array(x) || length(dim(x)) != 3L) {
    rlang::abort(
      paste0(
        "`x` must be a 3D array with dimensions ",
        "[iterations, chains, parameters], not a ", class(x)[1L], "."
      ),
      call = call
    )
  }
  if (!is.numeric(x)) {
    rlang::abort("`x` must be a numeric array.", call = call)
  }
  if (dim(x)[1L] < 2L) {
    rlang::abort("`x` must have at least 2 iterations.", call = call)
  }
  if (dim(x)[2L] < 1L) {
    rlang::abort("`x` must have at least 1 chain.", call = call)
  }
  x
}

#' Validate observed data vector y
#' @noRd
validate_y <- function(y, call = rlang::caller_env()) {
  if (!is.numeric(y)) {
    rlang::abort("`y` must be a numeric vector.", call = call)
  }
  y <- as.numeric(y)
  if (anyNA(y)) {
    rlang::warn("`y` contains NA values; they will be removed.")
    y <- y[!is.na(y)]
  }
  if (length(y) < 2L) {
    rlang::abort(
      "`y` must contain at least 2 non-missing observations.",
      call = call
    )
  }
  y
}

#' Validate posterior predictive draws matrix yrep
#' @noRd
validate_yrep <- function(yrep, y, call = rlang::caller_env()) {
  if (!is.matrix(yrep) || !is.numeric(yrep)) {
    rlang::abort("`yrep` must be a numeric matrix.", call = call)
  }
  if (ncol(yrep) != length(y)) {
    rlang::abort(
      paste0("`yrep` must have ncol == length(y) == ", length(y), "."),
      call = call
    )
  }
  if (nrow(yrep) < 2L) {
    rlang::abort("`yrep` must have at least 2 rows (draws).", call = call)
  }
  yrep
}

#' Validate LOO-PIT values
#' @noRd
validate_pit <- function(pit, call = rlang::caller_env()) {
  if (!is.numeric(pit)) {
    rlang::abort("`pit` must be a numeric vector.", call = call)
  }
  pit <- as.numeric(pit)
  if (anyNA(pit)) {
    rlang::warn("`pit` contains NA values; they will be removed.")
    pit <- pit[!is.na(pit)]
  }
  if (any(pit < 0 | pit > 1)) {
    rlang::abort("`pit` values must all be in [0, 1].", call = call)
  }
  if (length(pit) < 3L) {
    rlang::abort(
      "`pit` must contain at least 3 non-missing values.",
      call = call
    )
  }
  pit
}

# ── Color helpers ─────────────────────────────────────────────────────────────

#' Get a named color from the current bayesplot color scheme
#' @noRd
scheme_color <- function(name) {
  bayesplot::color_scheme_get()[[name]]
}

#' Build a set of chain colors cycling through the current scheme
#'
#' Returns `n` colors cycling through the bayesplot color scheme palette,
#' so chain colors remain consistent with the user's chosen scheme.
#'
#' @param n_chains Integer. Number of chains.
#' @return Character vector of hex colors of length `n_chains`.
#' @noRd
bayesplot_chain_colors <- function(n_chains) {
  scheme <- bayesplot::color_scheme_get()
  # bayesplot schemes provide 6 named entries; cycle if more chains needed
  colors <- unname(unlist(scheme))
  colors[((seq_len(n_chains) - 1L) %% length(colors)) + 1L]
}

# ── Statistical helpers ───────────────────────────────────────────────────────

#' Compute DKW simultaneous confidence band half-width
#'
#' Uses the Dvoretzky-Kiefer-Wolfowitz inequality:
#' P(sup|F_n(x) - F(x)| > epsilon) <= 2 * exp(-2 * n * epsilon^2)
#' Solved for epsilon at a given coverage probability.
#'
#' @param n Integer. Number of observations.
#' @param prob Numeric. Coverage probability.
#' @return Scalar epsilon (half-width of the simultaneous band).
#' @noRd
ecdf_simultaneous_band <- function(n, prob = 0.95) {
  alpha   <- 1 - prob
  sqrt(log(2 / alpha) / (2 * n))
}

# ── Formatting helpers ────────────────────────────────────────────────────────

#' Format a probability as a percentage label
#' @noRd
scales_label <- function(prob) {
  paste0(round(100 * prob), "%")
}

# Suppress R CMD check NOTE for ggplot2 computed aesthetics used inside
# after_stat() — these are not regular R objects.
utils::globalVariables("density")
