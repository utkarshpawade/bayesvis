set.seed(12345)

n_iter   <- 120L
n_chains <- 3L
n_params <- 4L
n_obs    <- 40L

test_posterior <- matrix(
  c(
    rnorm(n_iter, mean =  0.8, sd = 0.20),
    rnorm(n_iter, mean = -1.2, sd = 0.25),
    rnorm(n_iter, mean =  2.0, sd = 0.30),
    rnorm(n_iter, mean =  0.0, sd = 0.92)
  ),
  nrow = n_iter,
  ncol = n_params
)
colnames(test_posterior) <- c("alpha", "beta[1]", "beta[2]", "sigma")

test_array <- array(
  rnorm(n_iter * n_chains * n_params),
  dim      = c(n_iter, n_chains, n_params),
  dimnames = list(
    iteration = NULL,
    chain     = paste0("chain:", seq_len(n_chains)),
    parameter = colnames(test_posterior)
  )
)

bad_array         <- test_array
bad_array[, 1, 1] <- rnorm(n_iter, mean = 8, sd = 0.1)

test_y    <- rnorm(n_obs, mean = 1, sd = 1)
test_yrep <- matrix(
  rnorm(n_iter * n_obs, mean = 1, sd = 1),
  nrow = n_iter,
  ncol = n_obs
)

test_pit <- runif(60)
