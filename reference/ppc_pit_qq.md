# LOO probability integral transform Q-Q plot

A quantile-quantile plot comparing LOO-PIT values against the
theoretical Uniform(0, 1) quantiles. Under ideal calibration, points
should fall near the diagonal. A simultaneous pointwise envelope is
shown using the order-statistic Beta distribution.

## Usage

``` r
ppc_pit_qq(pit, prob = 0.95, ...)
```

## Arguments

- pit:

  A numeric vector of LOO-PIT values in \[0, 1\]. Typically obtained
  from `loo::loo_pit()`.

- prob:

  Numeric in (0, 1). Coverage probability for the pointwise Beta
  envelope. Default `0.95`.

- ...:

  Currently unused. Included for future extensibility.

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Details

The \\k\\-th order statistic of \\n\\ Uniform(0, 1) draws follows a
\\\text{Beta}(k,\\ n - k + 1)\\ distribution. The envelope uses
pointwise Beta quantiles evaluated at each sorted empirical rank
position, providing an \\(1-\alpha/2)\\ pointwise band around the
diagonal. This is more accurate than a normal-approximation envelope for
small samples and near the boundaries.

## References

Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., and Gelman, A.
(2019). Visualization in Bayesian workflow. *Journal of the Royal
Statistical Society Series A*, 182(2), 389–402.
[doi:10.1111/rssa.12378](https://doi.org/10.1111/rssa.12378)

## See also

[`ppc_pit_hist()`](https://utkarshpawade.github.io/bayesvis/reference/ppc_pit_hist.md)
for the histogram variant;
[`ppc_coverage()`](https://utkarshpawade.github.io/bayesvis/reference/ppc_coverage.md)
for posterior predictive coverage checks.

## Examples

``` r
set.seed(2024)

# Well-calibrated model
pit_good <- runif(150)
ppc_pit_qq(pit_good)


# Right-skewed PIT: model is over-confident
pit_skewed <- rbeta(150, shape1 = 2, shape2 = 0.8)
ppc_pit_qq(pit_skewed, prob = 0.99)

```
