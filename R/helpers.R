# ── Input validation ──────────────────────────────────────────────────────────

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

#' @noRd
scheme_color <- function(name) {
  bayesplot::color_scheme_get()[[name]]
}

#' @noRd
bayesplot_chain_colors <- function(n_chains) {
  scheme <- bayesplot::color_scheme_get()
  # bayesplot schemes provide 6 named entries; cycle if more chains needed
  colors <- unname(unlist(scheme))
  colors[((seq_len(n_chains) - 1L) %% length(colors)) + 1L]
}

# ── Statistical helpers ───────────────────────────────────────────────────────

#' DKW inequality: epsilon = sqrt(log(2/alpha) / (2n))
#' @noRd
ecdf_simultaneous_band <- function(n, prob = 0.95) {
  alpha   <- 1 - prob
  sqrt(log(2 / alpha) / (2 * n))
}

# ── Formatting helpers ────────────────────────────────────────────────────────

#' @noRd
scales_label <- function(prob) {
  paste0(round(100 * prob), "%")
}

utils::globalVariables("density")
