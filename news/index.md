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

## tobit.mean 0.1.0

- Initial CRAN submission.
