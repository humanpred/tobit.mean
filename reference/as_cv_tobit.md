# Calculate the percent coefficient of variation (CV)

Calculate the percent coefficient of variation (CV)

## Usage

``` r
as_cv_tobit(x)

# S3 method for class 'mean_tobit'
as_cv_tobit(x)

# S3 method for class 'geomean_tobit'
as_cv_tobit(x)

# S3 method for class 'sd_tobit'
as_cv_tobit(x)
```

## Arguments

- x:

  The object to use for CV calculation

## Value

The percent coefficient of variation as a numeric scalar

## Methods (by class)

- `as_cv_tobit(mean_tobit)`: CV for the arithmetic mean: `100*sd/mu`

- `as_cv_tobit(geomean_tobit)`: CV for the geometric mean:
  `100*sqrt(exp(sd^2)-1)`

- `as_cv_tobit(sd_tobit)`: CV from a 'sd_tobit' object, using the
  geometric formula when it came from a 'geomean_tobit' object and the
  arithmetic formula otherwise

## See also

Other Class creation and coercion:
[`as_geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_geomean_tobit.md),
[`as_mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_mean_tobit.md),
[`as_sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_sd_tobit.md)

## Examples

``` r
as_cv_tobit(as_mean_tobit(mu = 10, sd = 2))
#> [1] 20
as_cv_tobit(as_geomean_tobit(mu = 10, sd = 0.2))
#> [1] 20.20168
```
