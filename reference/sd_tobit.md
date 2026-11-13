# Calculate the censored standard deviation

Since the standard deviation is almost always desired with the mean, it
is more efficient to use
[`as_sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_sd_tobit.md)
on the mean object instead of calculating the standard deviation
separately.

## Usage

``` r
sd_tobit(...)
```

## Arguments

- ...:

  Arguments passed on to
  [`mean_tobit`](https://humanpred.github.io/tobit.mean/reference/mean_tobit.md)

  `x`

  :   A numeric vector

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

  `na.rm`

  :   A logical value indicating whether `NA` values should be stripped
      from `x` before the computation proceeds.

## Value

A "sd_tobit" class object

## See also

Other Censored Descriptive Statistics:
[`geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/geomean_tobit.md),
[`mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/mean_tobit.md)

## Examples

``` r
sd_tobit(c(2, 2, 3, 5, 6, 8), lower = 2, distribution = "norm")
#> [1] 0.4132036
#> attr(,"mu")
#> [1] 3.682551
#> attr(,"message")
#> [1] "Successful convergence.  message from stats::optim(): CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH"
#> attr(,"class")
#> [1] "sd_tobit"   "mean_tobit"
```
