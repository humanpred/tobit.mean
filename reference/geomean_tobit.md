# Calculate the censored geometric mean

The geometric mean is calculated as the exponential of the censored mean
of `log(x)`.

## Usage

``` r
geomean_tobit(x, lower = 0, upper = Inf, na.rm = TRUE, ...)
```

## Arguments

- x:

  A numeric vector

- lower, upper:

  The lower and upper bounds for censoring `x`

- na.rm:

  A logical value indicating whether `NA` values should be stripped from
  `x` before the computation proceeds.

- ...:

  Arguments passed on to
  [`mean_tobit`](https://humanpred.github.io/tobit.mean/reference/mean_tobit.md)

  `lower,upper`

  :   The lower and upper bounds for censoring `x`

  `include_equal,include_equal_lower,include_equal_upper`

  :   Should the bounds consider `x <= lower` and `x >= upper` (if
      `TRUE`) or `x < lower` and `x > upper` (if `FALSE`) to be
      censored? (`include_equal` is overridden by setting
      `include_equal_lower` or `include_equal_upper`.)

  `distribution`

  :   What distribution (Student `"t"` or normal, `"norm"`) should be
      used. If `"t"`, the degrees of freedom are the number of non-`NA`
      values in `x`. There is no default; it must be given when any
      value of `x` is censored.

## Value

A "geomean_tobit" class object (which also has the "mean_tobit" class)
which is a number with attributes for the standard deviation of `log(x)`
(sd) and convergence information in the "message" attribute.

## See also

Other Censored Descriptive Statistics:
[`mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/mean_tobit.md),
[`sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/sd_tobit.md)
