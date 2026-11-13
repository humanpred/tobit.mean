# Create or extract the standard deviation from a mean_tobit object

Create or extract the standard deviation from a mean_tobit object

## Usage

``` r
as_sd_tobit(mu, sd, message = NULL)

# Default S3 method
as_sd_tobit(mu, sd, message = NULL)

# S3 method for class 'mean_tobit'
as_sd_tobit(mu, sd, message = NULL)

# S3 method for class 'geomean_tobit'
as_sd_tobit(mu, sd, message = NULL)
```

## Arguments

- mu:

  The arithmetic mean

- sd:

  The arithmetic standard deviation

- message:

  Additional information about the mean

## Value

A 'sd_tobit' class object which is a number with attributes of 'mu' (the
mean) and 'message'.

## Methods (by class)

- `as_sd_tobit(mean_tobit)`: Convert a 'mean_tobit' object to a
  'sd_tobit' object

- `as_sd_tobit(geomean_tobit)`: Convert a 'geomean_tobit' object to a
  'sd_tobit' object

## See also

Other Class creation and coercion:
[`as_cv_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_cv_tobit.md),
[`as_geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_geomean_tobit.md),
[`as_mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_mean_tobit.md)

## Examples

``` r
as_sd_tobit(mu = 10, sd = 2)
#> [1] 2
#> attr(,"mu")
#> [1] 10
#> attr(,"class")
#> [1] "sd_tobit"
as_sd_tobit(as_mean_tobit(mu = 10, sd = 2))
#> [1] 2
#> attr(,"mu")
#> [1] 10
#> attr(,"class")
#> [1] "sd_tobit"   "mean_tobit"
```
