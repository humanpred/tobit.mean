# Calculate a censored mean

Calculate a censored mean

## Usage

``` r
mean_tobit(
  x,
  lower = -Inf,
  upper = Inf,
  include_equal = TRUE,
  include_equal_lower = include_equal,
  include_equal_upper = include_equal,
  distribution = c("t", "norm"),
  na.rm = TRUE,
  ...
)
```

## Arguments

- x:

  A numeric vector

- lower, upper:

  The lower and upper bounds for censoring `x`

- include_equal, include_equal_lower, include_equal_upper:

  Should the bounds consider `x <= lower` and `x >= upper` (if `TRUE`)
  or `x < lower` and `x > upper` (if `FALSE`) to be censored?
  (`include_equal` is overridden by setting `include_equal_lower` or
  `include_equal_upper`.)

- distribution:

  What distribution (Student `"t"`, the default, or normal, `"norm"`)
  should be used. If `"t"`, the degrees of freedom are the number of
  non-`NA` values in `x`, and the reported standard deviation is that of
  the fitted t distribution (`scale*sqrt(df/(df - 2))`), which is `NA`
  when there are two or fewer values.

- na.rm:

  A logical value indicating whether `NA` values should be stripped from
  `x` before the computation proceeds.

- ...:

  Arguments passed on to
  [`stats::optim`](https://rdrr.io/r/stats/optim.html)

  `par`

  :   Initial values for the parameters to be optimized over.

  `fn`

  :   A function to be minimized (or maximized), with first argument the
      vector of parameters over which minimization is to take place. It
      should return a scalar result.

  `gr`

  :   A function to return the gradient for the `"BFGS"`, `"CG"` and
      `"L-BFGS-B"` methods. If it is `NULL`, a finite-difference
      approximation will be used.

      For the `"SANN"` method it specifies a function to generate a new
      candidate point. If it is `NULL` a default Gaussian Markov kernel
      is used.

  `method`

  :   The method to be used. See ‘Details’. Can be abbreviated.

  `lower,upper`

  :   Bounds on the variables for the `"L-BFGS-B"` method, or bounds in
      which to *search* for method `"Brent"`.

  `control`

  :   a [`list`](https://rdrr.io/r/base/list.html) of control
      parameters. See ‘Details’.

  `hessian`

  :   Logical. Should a numerically differentiated Hessian matrix be
      returned?

## Value

A 'mean_tobit' object which is a number with attributes for the standard
deviation (sd) and convergence information in the "message" attribute.

## Details

When no values are censored, the ordinary
[`mean()`](https://rdrr.io/r/base/mean.html) and
[`sd()`](https://rdrr.io/r/stats/sd.html) are returned. When there are
no uncensored values, the mean cannot be estimated and `NA` is returned.
When all values are equal (and some, but not all, are censored), the
mean is that value and the standard deviation is `NA`.

Values of `x` must be finite unless they are censored at a finite limit
(for example, `-Inf` with `lower = 0`).

## References

Tobin J. Estimation of Relationships for Limited Dependent Variables.
Econometrica. 1958;26(1):24-36.
[doi:10.2307/1907382](https://doi.org/10.2307/1907382)

Olsen RJ. Note on the Uniqueness of the Maximum Likelihood Estimator for
the Tobit Model. Econometrica. 1978;46(5):1211-1215.
[doi:10.2307/1911445](https://doi.org/10.2307/1911445)

## See also

Other Censored Descriptive Statistics:
[`geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/geomean_tobit.md),
[`sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/sd_tobit.md)

## Examples

``` r
# Values at or below 2 are censored (for example, below a limit of
# quantification)
mean_tobit(c(2, 2, 3, 5, 6, 8), lower = 2, distribution = "norm")
#> [1] 3.682552
#> attr(,"sd")
#> [1] 3.100173
#> attr(,"message")
#> [1] "Successful convergence.  message from stats::optim(): CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH"
#> attr(,"class")
#> [1] "mean_tobit"
```
