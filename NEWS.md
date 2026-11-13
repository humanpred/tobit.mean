# tobit.mean 0.0.0.9000

* Initial CRAN submission.

## Bug fixes

* `mean_tobit()` reported a wrong standard deviation whenever any value was
  censored (it used `exp(1/p)` instead of `exp(-p)` for the fitted scale).
* Upper-censored values used the lower tail of the distribution in the
  likelihood, so means and standard deviations with an `upper` limit were
  wrong.
* `geomean_tobit()` gave an error for every result that was not `NA`.
* `mean_tobit()` gave an error when `x` had `NA` values, `na.rm = TRUE`, and any
  value was censored.
* `as_sd_tobit()` on a `mean_tobit` object now warns that `message` is ignored,
  as the other conversions do, and `as_sd_tobit.default()` coerces `NA` inputs
  to numeric `NA`.
* `as_cv_tobit()` and `as_sd_tobit()` now work on `sd_tobit` objects.

## Changes

* `distribution` defaults to `"t"`; it was previously required whenever any
  value was censored.
* With `distribution = "t"`, the reported standard deviation is that of the
  fitted t distribution, `scale*sqrt(df/(df - 2))`, and is `NA` when there are
  two or fewer values.
* A single uncensored value, or all values equal with some censored, gives
  the value as the mean and `NA` as the standard deviation.  `mean_tobit`
  objects may now have an `NA` standard deviation with a non-`NA` mean.
* `NA` is returned when no values are between `lower` and `upper` (for
  example, some above `upper` and the rest below `lower`).
* `x` must be finite unless it is censored at a finite limit.
* A zero-length `x` gives `NA` with the message "No values were given".
* The data are centered and scaled before optimization (censored values
  replaced by their limits), so data with a small spread or a large offset
  no longer make `stats::optim()` fail with non-finite likelihood values.
  An error from `stats::optim()` is reported as failed
  convergence.
