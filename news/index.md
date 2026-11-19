# Changelog

## tobit.mean 0.1.0.9000

- [`mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/mean_tobit.md),
  [`geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/geomean_tobit.md),
  and
  [`sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/sd_tobit.md)
  results have a `"status"` attribute saying how the result was reached,
  one of the codes in the new exported `tobit_status_codes` (for example
  `"converged"`, `"not_converged"`, `"all_below_lower"`). The
  `"message"` attribute is unchanged.
- [`as_mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_mean_tobit.md),
  [`as_geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_geomean_tobit.md),
  and
  [`as_sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_sd_tobit.md)
  take a `status` argument (`NULL` by default, giving no attribute, as
  before).
- Every error and warning has a class, listed in the new exported
  `tobit_condition_classes` (`tobit_mean_error_<what>` or
  `tobit_mean_warning_<what>`, with the parent class `tobit_mean_error`
  or `tobit_mean_warning`), so it can be handled without matching its
  message. The classes are added in front of those
  [`stop()`](https://rdrr.io/r/base/stop.html) and
  [`warning()`](https://rdrr.io/r/base/warning.html) gave (`simpleError`
  or `simpleWarning`, then `error` or `warning`, and `condition`), so
  code that tests for those keeps working; a printed condition now
  begins with its new class name. The messages are unchanged.

## tobit.mean 0.1.0

- Initial CRAN submission.
