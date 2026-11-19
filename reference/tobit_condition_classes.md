# Classes of the errors and warnings of the censored statistics

Every error and warning the package raises has a class from this table,
so a caller can handle one without matching its message. The classes
follow one pattern: `tobit_mean_error_<what>` for an error and
`tobit_mean_warning_<what>` for a warning, and every error also has the
class `"tobit_mean_error"` (every warning `"tobit_mean_warning"`) before
the classes [`stop()`](https://rdrr.io/r/base/stop.html) and
[`warning()`](https://rdrr.io/r/base/warning.html) gave in 0.1.0:
`"simpleError"`, `"error"`, and `"condition"` (`"simpleWarning"`,
`"warning"`, and `"condition"`). The classes are added in front, and the
messages and calls are unchanged from 0.1.0, so
`tryCatch(..., error = )`, `inherits(e, "simpleError")`, and code that
matches the message keep working. A printed condition shows its first
class, so it begins with the new class name.

## Usage

``` r
tobit_condition_classes
```

## Format

A data.frame with one row per class: `class`, `type` (`"error"` or
`"warning"`), `message` (the message, or `NA` for
`"tobit_mean_error_internal"`, whose message names the check that
failed), and `meaning`

## Classes

- `tobit_mean_error_mu_not_scalar`:

  error: The mean given to a constructor such as as_mean_tobit() is not
  one value. ("'mu' must be a scalar")

- `tobit_mean_error_sd_not_scalar`:

  error: The standard deviation given to a constructor such as
  as_mean_tobit() is not one value. ("'sd' must be a scalar")

- `tobit_mean_error_mu_not_numeric`:

  error: The mean given to a constructor such as as_mean_tobit() is not
  a number. ("'mu' must be numeric")

- `tobit_mean_error_sd_not_numeric`:

  error: The standard deviation given to a constructor such as
  as_mean_tobit() is not a number. ("'sd' must be numeric")

- `tobit_mean_error_sd_without_mu`:

  error: A standard deviation was given with a missing mean. ("'sd' must
  be NA when 'mu' is NA")

- `tobit_mean_error_status_invalid`:

  error: The status given to a constructor such as as_mean_tobit() is
  not one of tobit_status_codes. ("'status' must be NULL or one of
  tobit_status_codes\$status")

- `tobit_mean_error_convert_not_na`:

  error: A mean_tobit with a value was given to as_geomean_tobit().
  ("mean_tobit can only be converted to a geomean_tobit if it is NA")

- `tobit_mean_error_x_is_mean_tobit`:

  error: A result of the package was given as the values. ("'x' may not
  have class 'mean_tobit'")

- `tobit_mean_error_lower_not_numeric`:

  error: The lower limit is not numeric. ("lower must be a numeric")

- `tobit_mean_error_lower_missing`:

  error: The lower limit has a missing value. ("lower may not have
  missing values")

- `tobit_mean_error_lower_length`:

  error: The lower limit is neither one value nor one per value. ("lower
  must be a scalar or the same length as x")

- `tobit_mean_error_upper_not_numeric`:

  error: The upper limit is not numeric. ("upper must be a numeric")

- `tobit_mean_error_upper_missing`:

  error: The upper limit has a missing value. ("upper may not have
  missing values")

- `tobit_mean_error_upper_length`:

  error: The upper limit is neither one value nor one per value. ("upper
  must be a scalar or the same length as x")

- `tobit_mean_error_limits_not_ordered`:

  error: A lower limit is not below its upper limit. ("each lower must
  be less than upper")

- `tobit_mean_error_x_not_finite`:

  error: A value that is not censored, or a limit a censored value
  takes, is not finite. ("'x' must be finite unless it is censored at a
  finite limit")

- `tobit_mean_error_geomean_nonpositive`:

  error: geomean_tobit() has a value and its lower limit both at or
  below zero. ("'x' and 'lower' cannot both be \<= 0 at the same time")

- `tobit_mean_error_geomean_upper_nonpositive`:

  error: geomean_tobit() has an upper limit at or below zero. ("some
  'upper' values were at or below zero")

- `tobit_mean_error_internal`:

  error: A check inside the package failed; its message names the check.
  Please report it as a bug.

- `tobit_mean_warning_sd_ignored`:

  warning: A standard deviation was given to the conversion of a result,
  which keeps its own. ("'sd' is ignored for object conversion (sd is
  taken from the object)")

- `tobit_mean_warning_message_ignored`:

  warning: A message was given to the conversion of a result, which
  keeps its own. ("'message' is ignored for object conversion (message
  is taken from the object)")

- `tobit_mean_warning_status_ignored`:

  warning: A status was given to the conversion of a result, which keeps
  its own. ("'status' is ignored for object conversion (status is taken
  from the object)")

- `tobit_mean_warning_x_negative`:

  warning: geomean_tobit() set values below zero to zero. ("some 'x'
  values were below zero, setting to zero")

- `tobit_mean_warning_lower_negative`:

  warning: geomean_tobit() set lower limits below zero to zero. ("some
  'lower' values were below zero, setting to zero")

## See also

Other Censored Descriptive Statistics:
[`geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/geomean_tobit.md),
[`mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/mean_tobit.md),
[`sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/sd_tobit.md),
[`tobit_status_codes`](https://humanpred.github.io/tobit.mean/reference/tobit_status_codes.md)

## Examples

``` r
tobit_condition_classes
#>                                         class    type
#> 1              tobit_mean_error_mu_not_scalar   error
#> 2              tobit_mean_error_sd_not_scalar   error
#> 3             tobit_mean_error_mu_not_numeric   error
#> 4             tobit_mean_error_sd_not_numeric   error
#> 5              tobit_mean_error_sd_without_mu   error
#> 6             tobit_mean_error_status_invalid   error
#> 7             tobit_mean_error_convert_not_na   error
#> 8            tobit_mean_error_x_is_mean_tobit   error
#> 9          tobit_mean_error_lower_not_numeric   error
#> 10             tobit_mean_error_lower_missing   error
#> 11              tobit_mean_error_lower_length   error
#> 12         tobit_mean_error_upper_not_numeric   error
#> 13             tobit_mean_error_upper_missing   error
#> 14              tobit_mean_error_upper_length   error
#> 15        tobit_mean_error_limits_not_ordered   error
#> 16              tobit_mean_error_x_not_finite   error
#> 17       tobit_mean_error_geomean_nonpositive   error
#> 18 tobit_mean_error_geomean_upper_nonpositive   error
#> 19                  tobit_mean_error_internal   error
#> 20              tobit_mean_warning_sd_ignored warning
#> 21         tobit_mean_warning_message_ignored warning
#> 22          tobit_mean_warning_status_ignored warning
#> 23              tobit_mean_warning_x_negative warning
#> 24          tobit_mean_warning_lower_negative warning
#>                                                                          message
#> 1                                                          'mu' must be a scalar
#> 2                                                          'sd' must be a scalar
#> 3                                                           'mu' must be numeric
#> 4                                                           'sd' must be numeric
#> 5                                                'sd' must be NA when 'mu' is NA
#> 6                      'status' must be NULL or one of tobit_status_codes$status
#> 7                mean_tobit can only be converted to a geomean_tobit if it is NA
#> 8                                            'x' may not have class 'mean_tobit'
#> 9                                                        lower must be a numeric
#> 10                                             lower may not have missing values
#> 11                                lower must be a scalar or the same length as x
#> 12                                                       upper must be a numeric
#> 13                                             upper may not have missing values
#> 14                                upper must be a scalar or the same length as x
#> 15                                            each lower must be less than upper
#> 16                    'x' must be finite unless it is censored at a finite limit
#> 17                          'x' and 'lower' cannot both be <= 0 at the same time
#> 18                                     some 'upper' values were at or below zero
#> 19                                                                          <NA>
#> 20           'sd' is ignored for object conversion (sd is taken from the object)
#> 21 'message' is ignored for object conversion (message is taken from the object)
#> 22   'status' is ignored for object conversion (status is taken from the object)
#> 23                              some 'x' values were below zero, setting to zero
#> 24                          some 'lower' values were below zero, setting to zero
#>                                                                                        meaning
#> 1                    The mean given to a constructor such as as_mean_tobit() is not one value.
#> 2      The standard deviation given to a constructor such as as_mean_tobit() is not one value.
#> 3                     The mean given to a constructor such as as_mean_tobit() is not a number.
#> 4       The standard deviation given to a constructor such as as_mean_tobit() is not a number.
#> 5                                          A standard deviation was given with a missing mean.
#> 6  The status given to a constructor such as as_mean_tobit() is not one of tobit_status_codes.
#> 7                                   A mean_tobit with a value was given to as_geomean_tobit().
#> 8                                             A result of the package was given as the values.
#> 9                                                              The lower limit is not numeric.
#> 10                                                        The lower limit has a missing value.
#> 11                                     The lower limit is neither one value nor one per value.
#> 12                                                             The upper limit is not numeric.
#> 13                                                        The upper limit has a missing value.
#> 14                                     The upper limit is neither one value nor one per value.
#> 15                                                 A lower limit is not below its upper limit.
#> 16             A value that is not censored, or a limit a censored value takes, is not finite.
#> 17                      geomean_tobit() has a value and its lower limit both at or below zero.
#> 18                                        geomean_tobit() has an upper limit at or below zero.
#> 19  A check inside the package failed; its message names the check. Please report it as a bug.
#> 20          A standard deviation was given to the conversion of a result, which keeps its own.
#> 21                     A message was given to the conversion of a result, which keeps its own.
#> 22                      A status was given to the conversion of a result, which keeps its own.
#> 23                                              geomean_tobit() set values below zero to zero.
#> 24                                        geomean_tobit() set lower limits below zero to zero.
tryCatch(
  mean_tobit(1:3, lower = 2, upper = 2),
  tobit_mean_error_limits_not_ordered = function(e) conditionMessage(e)
)
#> [1] "each lower must be less than upper"
```
