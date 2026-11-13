# Estimate the log-likelihood for the gamma/delta transformed convex parameters for tobit regression

Estimate the log-likelihood for the gamma/delta transformed convex
parameters for tobit regression

## Usage

``` r
negLogLik_tobit(
  param,
  x,
  lower_limit,
  upper_limit,
  mask_lower,
  mask_between,
  mask_upper,
  distribution = c("t", "norm")
)
```

## Arguments

- param:

  c(gamma, delta) see details

- x:

  The vector of values

- lower_limit, upper_limit:

  The vector lower and upper limits for censoring

- mask_lower, mask_between, mask_upper:

  Boolean masks indicating if the value is below the lower limit, a
  point value, or above the upper limit

- distribution:

  The distribution to use

## Value

The negative log-likelihood as a numeric scalar

## Details

`beta = delta/gamma` and `sigma^2 = gamma^-2`. The estimation is based
on the convex reformulation of the likelihood function described in
Olsen 1978.

## References

Olsen RJ. Note on the Uniqueness of the Maximum Likelihood Estimator for
the Tobit Model. Econometrica. 1978;46(5):1211-1215.
[doi:10.2307/1911445](https://doi.org/10.2307/1911445)
