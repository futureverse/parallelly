# Calculate the size of an R object when it is serialized

This function goes through all the motions of serializing an object, but
does nothing with the bytes other than to tally the total length.

## Usage

``` r
serializedSize(obj)
```

## Arguments

- obj:

  An R object.

## Value

(double) Number of bytes needed to serialize this object.

## Author

Mike FC

## Examples

``` r
object.size(mtcars)
#> 7208 bytes
serializedSize(mtcars)
#> [1] 3807
```
