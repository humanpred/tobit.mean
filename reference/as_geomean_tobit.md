# Create or cast to a geomean_tobit object

Create or cast to a geomean_tobit object

## Usage

``` r
as_geomean_tobit(mu, sd, message = NULL)

# Default S3 method
as_geomean_tobit(mu, sd, message = NULL)

# S3 method for class 'mean_tobit'
as_geomean_tobit(mu, sd, message = NULL)
```

## Arguments

- mu:

  The geometric mean

- sd:

  The geometric standard deviation

- message:

  Additional information about the mean

## Value

A 'geomean_tobit' class object which is a number with attributes for
'sd' and 'message'.

## See also

Other Class creation and coercion:
[`as_cv_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_cv_tobit.md),
[`as_mean_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_mean_tobit.md),
[`as_sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_sd_tobit.md)

## Examples

``` r
as_geomean_tobit(mu=10, sd=2, message="This is just an example")
#> [1] 10
#> attr(,"sd")
#> [1] 2
#> attr(,"message")
#> [1] "This is just an example"
#> attr(,"class")
#> [1] "geomean_tobit" "mean_tobit"   
```
