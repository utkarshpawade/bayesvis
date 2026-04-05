# bayesvis: Extended Bayesian Visualization Diagnostics

A companion/extension prototype for the bayesplot package. Provides
advanced visualization tools for diagnosing Bayesian models:

- [`mcmc_shrinkage()`](https://utkarshpawade.github.io/bayesvis/reference/mcmc_shrinkage.md):
  Prior-to-posterior shrinkage diagnostic scatter plot

- [`compute_shrinkage()`](https://utkarshpawade.github.io/bayesvis/reference/compute_shrinkage.md):
  Helper to compute shrinkage factors from draws

- [`ppc_pit_hist()`](https://utkarshpawade.github.io/bayesvis/reference/ppc_pit_hist.md):
  LOO probability integral transform histogram

- [`ppc_pit_qq()`](https://utkarshpawade.github.io/bayesvis/reference/ppc_pit_qq.md):
  LOO-PIT quantile-quantile plot with envelope

- [`mcmc_rank_ecdf()`](https://utkarshpawade.github.io/bayesvis/reference/mcmc_rank_ecdf.md):
  Rank-based ECDF plots per chain with simultaneous bands

- [`ppc_coverage()`](https://utkarshpawade.github.io/bayesvis/reference/ppc_coverage.md):
  Posterior predictive coverage plot

## Conventions

All plot functions follow bayesplot conventions:

- Function names are prefixed by plot category: `mcmc_*` for MCMC
  diagnostics, `ppc_*` for posterior predictive checks.

- All functions return
  [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
  objects that can be further customized with standard ggplot2 layers.

- Plots use
  [`bayesplot::bayesplot_theme_get()`](https://mc-stan.org/bayesplot/reference/bayesplot_theme_get.html)
  and
  [`bayesplot::color_scheme_get()`](https://mc-stan.org/bayesplot/reference/bayesplot-colors.html)
  for visual consistency. Change the color scheme globally with
  [`bayesplot::color_scheme_set()`](https://mc-stan.org/bayesplot/reference/bayesplot-colors.html).

## References

Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., and Gelman, A.
(2019). Visualization in Bayesian workflow. *Journal of the Royal
Statistical Society Series A*, 182(2), 389–402.
[doi:10.1111/rssa.12378](https://doi.org/10.1111/rssa.12378)

Vehtari, A., Gelman, A., Simpson, D., Carpenter, B., and Bürkner, P.-C.
(2021). Rank-normalization, folding, and localization: An improved R-hat
for assessing convergence of MCMC (with discussion). *Bayesian
Analysis*, 16(2), 667–718.
[doi:10.1214/20-BA1221](https://doi.org/10.1214/20-BA1221)
