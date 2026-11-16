# tobit.mean 0.1.0.9000

* `mean_tobit()`, `geomean_tobit()`, and `sd_tobit()` results have a `"status"`
  attribute saying how the result was reached, one of the codes in the new
  exported `tobit_status_codes` (for example `"converged"`, `"not_converged"`,
  `"all_below_lower"`). The `"message"` attribute is unchanged.
* `as_mean_tobit()`, `as_geomean_tobit()`, and `as_sd_tobit()` take a `status`
  argument (`NULL` by default, giving no attribute, as before).

# tobit.mean 0.1.0

* Initial CRAN submission.
