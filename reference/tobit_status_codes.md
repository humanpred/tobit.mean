# Status codes of a censored mean

The `"status"` attribute of the results of
[`mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/mean_tobit.md),
[`geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/geomean_tobit.md),
and
[`sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/sd_tobit.md)
is one of these codes. It says how the result was reached, so a caller
can act on it without reading the `"message"` attribute, whose text may
change.

## Usage

``` r
tobit_status_codes
```

## Format

A data.frame with one row per code: `status` (the code) and `meaning`

## Details

Arithmetic on a result keeps its attributes, as it kept `"sd"` and
`"message"` in 0.1.0: after `m + 1`, the `"status"` still describes the
fit that gave `m`, not the new value.

## Codes

- `"no_values"`:

  No values were given; the mean is NA.

- `"all_na"`:

  All values were NA; the mean is NA.

- `"na_not_removed"`:

  Some values were NA and na.rm is FALSE; the mean is NA.

- `"uncensored"`:

  No value was censored; the mean and standard deviation are the
  ordinary ones.

- `"all_above_upper"`:

  Every value was censored at the upper limit; the mean is NA.

- `"all_below_lower"`:

  Every value was censored at the lower limit; the mean is NA.

- `"none_between"`:

  Every value was censored, some at the lower limit and some at the
  upper; the mean is NA.

- `"single_value"`:

  Some values were censored and all values were equal; the mean is that
  value and the standard deviation is NA.

- `"converged"`:

  The censored model was fit and stats::optim() converged.

- `"not_converged"`:

  stats::optim() did not converge; the mean is NA.

- `"optim_error"`:

  stats::optim() stopped with an error; the mean is NA.

## See also

Other Censored Descriptive Statistics:
[`geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/geomean_tobit.md),
[`mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/mean_tobit.md),
[`sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/sd_tobit.md),
[`tobit_condition_classes`](https://humanpred.github.io/tobit.mean/reference/tobit_condition_classes.md)

## Examples

``` r
tobit_status_codes
#>             status
#> 1        no_values
#> 2           all_na
#> 3   na_not_removed
#> 4       uncensored
#> 5  all_above_upper
#> 6  all_below_lower
#> 7     none_between
#> 8     single_value
#> 9        converged
#> 10   not_converged
#> 11     optim_error
#>                                                                                                          meaning
#> 1                                                                          No values were given; the mean is NA.
#> 2                                                                            All values were NA; the mean is NA.
#> 3                                                        Some values were NA and na.rm is FALSE; the mean is NA.
#> 4                                  No value was censored; the mean and standard deviation are the ordinary ones.
#> 5                                                   Every value was censored at the upper limit; the mean is NA.
#> 6                                                   Every value was censored at the lower limit; the mean is NA.
#> 7                       Every value was censored, some at the lower limit and some at the upper; the mean is NA.
#> 8  Some values were censored and all values were equal; the mean is that value and the standard deviation is NA.
#> 9                                                       The censored model was fit and stats::optim() converged.
#> 10                                                              stats::optim() did not converge; the mean is NA.
#> 11                                                         stats::optim() stopped with an error; the mean is NA.
attr(mean_tobit(c(2, 2, 3, 5, 6, 8), lower = 2, distribution = "norm"), "status")
#> [1] "converged"
```
