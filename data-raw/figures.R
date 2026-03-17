## Script to regenerate README figures with a light theme.
## Run from the package root: source("data-raw/figures.R")

library(ggplot2)
library(bayesplot)
library(bayesvis)

out_dir <- "man/figures"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# Use the blue color scheme but with a light ggplot2 theme so figures
# are readable on white GitHub backgrounds.
color_scheme_set("blue")
bayesplot_theme_set(theme_light(base_size = 12))

save_fig <- function(p, name, width = 7, height = 4.5) {
  ggsave(
    filename = file.path(out_dir, paste0(name, ".png")),
    plot     = p,
    width    = width,
    height   = height,
    dpi      = 150,
    bg       = "white"
  )
  message("Saved: ", name, ".png")
}

set.seed(42)

# ── shrinkage ──────────────────────────────────────────────────────────────────
posterior <- matrix(
  c(
    rnorm(1000 * 3, mean = 1.5, sd = 0.15),  # well-identified
    rnorm(1000 * 3, mean = 0.0, sd = 0.95)   # near-prior
  ),
  ncol = 6
)
colnames(posterior) <- paste0("beta[", 1:6, "]")

save_fig(
  mcmc_shrinkage(posterior, prior_sd = 1),
  "shrinkage",
  width = 6, height = 5
)

# ── rank_ecdf ─────────────────────────────────────────────────────────────────
arr <- array(
  rnorm(500 * 4 * 2),
  dim      = c(500, 4, 2),
  dimnames = list(NULL, paste0("chain:", 1:4), c("mu", "sigma"))
)
arr[, 1, 1] <- rnorm(500, mean = 8, sd = 0.2)  # chain 1 stuck

save_fig(
  mcmc_rank_ecdf(arr),
  "rank_ecdf",
  width = 8, height = 4.5
)

# ── pit_hist ──────────────────────────────────────────────────────────────────
save_fig(ppc_pit_hist(runif(200)), "pit_hist")

# ── pit_qq ────────────────────────────────────────────────────────────────────
save_fig(ppc_pit_qq(rbeta(200, 0.35, 0.35)), "pit_qq")

# ── coverage ──────────────────────────────────────────────────────────────────
y    <- rnorm(60, mean = 2, sd = 1)
yrep <- matrix(rnorm(500 * 60, mean = 2, sd = 1), nrow = 500)

save_fig(ppc_coverage(y, yrep, prob = 0.90), "coverage")

message("Done. All figures written to ", out_dir, "/")
