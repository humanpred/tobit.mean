# Create or cast to a mean_tobit object

Create or cast to a mean_tobit object

## Usage

``` r
as_mean_tobit(mu, sd, message = NULL)

# Default S3 method
as_mean_tobit(mu, sd, message = NULL)
```

## Arguments

- mu:

  The arithmetic mean

- sd:

  The arithmetic standard deviation (`NA` when it cannot be estimated;
  it must be `NA` when `mu` is `NA`)

- message:

  Additional information about the mean

## Value

A 'mean_tobit' class object which is a number with attributes for 'sd'
and 'message'.

## See also

Other Class creation and coercion:
[`as_cv_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_cv_tobit.md),
[`as_geomean_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_geomean_tobit.md),
[`as_sd_tobit()`](https://humanpred.github.io/tobit.mean/reference/as_sd_tobit.md)

## Examples

``` r
as_mean_tobit(mu=10, sd=2, message="This is just an example")
#> [1] 10
#> attr(,"sd")
#> [1] 2
#> attr(,"message")
#> [1] "This is just an example"
#> attr(,"class")
#> [1] "mean_tobit"
```
