## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse    = TRUE,
  comment     = "#>",
  fig.width   = 7,
  fig.height  = 4.5,
  fig.align   = "center",
  out.width   = "95%"
)
set.seed(42)


## ----load---------------------------------------------------------------------
library(bayesvis)
library(bayesplot)

# Use a muted color scheme throughout
color_scheme_set("blue")


## ----sim-data-----------------------------------------------------------------
n_iter   <- 1000L   # MCMC iterations per chain
n_chains <- 4L      # number of chains
n_obs    <- 80L     # observations

# ── Posterior draws ──────────────────────────────────────────────────────────
# Six parameters, varying degrees of identifiability.
# beta[1]–beta[3]: well identified (posterior SD << prior SD of 1)
# beta[4]–beta[6]: weakly identified (posterior SD ≈ prior SD of 1)
posterior_2d <- matrix(
  c(
    rnorm(n_iter, mean =  1.5, sd = 0.12),   # beta[1]
    rnorm(n_iter, mean = -0.8, sd = 0.18),   # beta[2]
    rnorm(n_iter, mean =  2.1, sd = 0.22),   # beta[3]
    rnorm(n_iter, mean =  0.1, sd = 0.94),   # beta[4]
    rnorm(n_iter, mean = -0.2, sd = 0.98),   # beta[5]
    rnorm(n_iter, mean =  0.3, sd = 0.91)    # beta[6]
  ),
  ncol = 6L
)
colnames(posterior_2d) <- paste0("beta[", 1:6, "]")
prior_sd <- rep(1, 6)

# ── Well-mixing 3D array ─────────────────────────────────────────────────────
# Four chains, two parameters: draws are i.i.d. so mixing is perfect.
good_array <- array(
  rnorm(n_iter * n_chains * 2),
  dim      = c(n_iter, n_chains, 2L),
  dimnames = list(NULL, paste0("chain:", 1:4), c("mu", "sigma"))
)

# ── Badly-mixing 3D array ────────────────────────────────────────────────────
# Chain 1 for "mu" is stuck in a completely different region.
bad_array         <- good_array
bad_array[, 1, 1] <- rnorm(n_iter, mean = 8, sd = 0.15)

# ── Observed data and posterior predictive draws ─────────────────────────────
y_true <- 2
y      <- rnorm(n_obs, mean = y_true, sd = 1)

# Well-calibrated model: yrep drawn from the same distribution as y
yrep_good   <- matrix(rnorm(500L * n_obs, mean = y_true, sd = 1), nrow = 500L)

# Over-confident model: posterior predictive intervals too narrow
yrep_narrow <- matrix(rnorm(500L * n_obs, mean = y_true, sd = 0.25), nrow = 500L)

# ── LOO-PIT values ────────────────────────────────────────────────────────────
# Well-calibrated ≈ Uniform(0,1)
pit_good  <- runif(n_obs)
# Over-dispersed: PIT concentrated near 0 and 1
pit_over  <- rbeta(n_obs, shape1 = 0.35, shape2 = 0.35)
# Under-dispersed: PIT concentrated near 0.5
pit_under <- rbeta(n_obs, shape1 = 5, shape2 = 5)


## ----shrinkage-good, fig.height = 5-------------------------------------------
mcmc_shrinkage(posterior_2d, prior_sd = prior_sd)


## ----shrinkage-prior-draws, fig.height = 5------------------------------------
prior_draws <- matrix(rnorm(n_iter * 6, sd = 1), ncol = 6)
colnames(prior_draws) <- colnames(posterior_2d)

mcmc_shrinkage(posterior_2d, prior_draws = prior_draws)


## ----compute-shrinkage--------------------------------------------------------
kappa <- compute_shrinkage(posterior_2d, prior_sd = prior_sd)
round(kappa, 3)


## ----pit-good-----------------------------------------------------------------
ppc_loo_pit(pit_good)


## ----pit-over-----------------------------------------------------------------
ppc_loo_pit(pit_over, bins = 12L)


## ----pit-under----------------------------------------------------------------
ppc_loo_pit(pit_under, bins = 12L)


## ----pit-qq-good--------------------------------------------------------------
ppc_loo_pit_qq(pit_good)


## ----pit-qq-over--------------------------------------------------------------
ppc_loo_pit_qq(pit_over)


## ----rank-good----------------------------------------------------------------
mcmc_rank_ecdf(good_array, prob = 0.99)


## ----rank-bad, fig.height = 5-------------------------------------------------
mcmc_rank_ecdf(bad_array, prob = 0.99)


## ----rank-single--------------------------------------------------------------
mcmc_rank_ecdf(bad_array, pars = "sigma")


## ----coverage-good------------------------------------------------------------
ppc_coverage(y, yrep_good, prob = 0.90)


## ----coverage-narrow----------------------------------------------------------
ppc_coverage(y, yrep_narrow, prob = 0.90)


## ----coverage-by-mean, fig.height = 4-----------------------------------------
ppc_coverage(y, yrep_good, sort_by = "mean")


## ----color-schemes, fig.width = 7, fig.height = 3.5---------------------------
color_scheme_set("red")
ppc_loo_pit(pit_under)


## ----reset-scheme, include = FALSE--------------------------------------------
color_scheme_set("blue")

