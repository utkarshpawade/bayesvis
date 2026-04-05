# Compute shrinkage factors from posterior and prior draws

A helper that computes the prior-to-posterior shrinkage factor \\\kappa
= 1 - \widehat{\operatorname{Var}}(\theta \mid y) /
\widehat{\operatorname{Var}}(\theta)\\ for each parameter, returning a
named numeric vector. Values are clamped to \[0, 1\].

## Usage

``` r
compute_shrinkage(x, prior_sd = NULL, prior_draws = NULL)
```

## Arguments

- x:

  A numeric matrix of posterior draws with dimensions \[iterations x
  parameters\]. Column names are used as parameter labels. A data frame
  will be coerced to a matrix.

- prior_sd:

  A numeric vector of prior standard deviations, one per parameter.
  Recycled to `ncol(x)` if scalar. Either `prior_sd` or `prior_draws`
  must be supplied.

- prior_draws:

  An optional numeric matrix of prior draws with the same column
  structure as `x`. Use this when closed-form prior SDs are unavailable.
  If both `prior_sd` and `prior_draws` are supplied, `prior_draws` takes
  precedence.

## Value

A named numeric vector of shrinkage factors, one per parameter.

## See also

[`mcmc_shrinkage()`](https://utkarshpawade.github.io/bayesvis/reference/mcmc_shrinkage.md)
for the corresponding diagnostic plot.

## Examples

``` r
set.seed(1)
post <- matrix(rnorm(500 * 4, mean = c(0, 1, 2, 0), sd = 0.3), ncol = 4)
colnames(post) <- paste0("b[", 1:4, "]")

compute_shrinkage(post, prior_sd = 1)
#>      b[1]      b[2]      b[3]      b[4] 
#> 0.2020658 0.2221107 0.1962671 0.2463705 
```
