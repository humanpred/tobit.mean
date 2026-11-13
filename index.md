# tobit.mean

The goal of tobit.mean is to calculate descriptive statistics of
censored vectors (for example, concentrations below a limit of
quantification). The arithmetic mean, geometric mean, standard
deviation, and coefficient of variation are estimated by maximum
likelihood with the Tobit model, so censored values are accounted for
rather than dropped or replaced.

## Installation

You can install the development version of tobit.mean from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("humanpred/tobit.mean")
```

## Example

Calculate the mean of a vector where values at or below 0.5 are
censored:

``` r

library(tobit.mean)
tobit.mean::mean_tobit(c(0, 1, 4, 10), lower = 0.5, distribution = "t")
```
