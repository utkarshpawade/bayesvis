# ── Shared test fixtures ──────────────────────────────────────────────────────
# This file is sourced automatically by testthat before any test file.

set.seed(12345)

# Dimensions
n_iter   <- 120L
n_chains <- 3L
n_params <- 4L
n_obs    <- 40L

# 2D posterior draws matrix (iterations × parameters)
test_posterior <- matrix(
  c(
    rnorm(n_iter, mean =  0.8, sd = 0.20),  # alpha  – high shrinkage
    rnorm(n_iter, mean = -1.2, sd = 0.25),  # beta[1]
    rnorm(n_iter, mean =  2.0, sd = 0.30),  # beta[2]
    rnorm(n_iter, mean =  0.0, sd = 0.92)   # sigma  – low shrinkage
  ),
  nrow = n_iter,
  ncol = n_params
)
colnames(test_posterior) <- c("alpha", "beta[1]", "beta[2]", "sigma")

# 3D MCMC array (iterations × chains × parameters)
test_array <- array(
  rnorm(n_iter * n_chains * n_params),
  dim      = c(n_iter, n_chains, n_params),
  dimnames = list(
    iteration = NULL,
    chain     = paste0("chain:", seq_len(n_chains)),
    parameter = colnames(test_posterior)
  )
)

# 3D array with one badly mixing chain (chain 1 shifted for "alpha")
bad_array         <- test_array
bad_array[, 1, 1] <- rnorm(n_iter, mean = 8, sd = 0.1)

# Observed data and posterior predictive matrix
test_y    <- rnorm(n_obs, mean = 1, sd = 1)
test_yrep <- matrix(
  rnorm(n_iter * n_obs, mean = 1, sd = 1),
  nrow = n_iter,
  ncol = n_obs
)

# LOO-PIT values (well-calibrated: ~ Uniform(0,1))
test_pit <- runif(60)
