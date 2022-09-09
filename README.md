# googletraffic  <img src="man/figures/hex.png" align="right" width="200" />
Create traffic data from the [Google Maps Javascript API](https://developers.google.com/maps/documentation/javascript/trafficlayer) Traffic Layer

## Overview <a name="overview"></a>

Google Maps provides information about traffic conditions across an area. This package provides functions to produce georeferenced rasters from live Google Maps traffic information. Providing Google traffic information in a georeferenced data format facilitates analysis of traffic information (e.g., spatially merging traffic information with other data sources).

The below image shows an example raster produced using the package showing [traffic within Washington, DC.](https://www.google.com/maps/@38.9065495,-77.0368202,16z/data=!5m1!1e1)

<p align="center">
<img src="man/figures/top_example.jpg" alt="Example" width="800"/>
</p>

Pixel values in rasters are derived from Google [traffic colors](https://support.google.com/maps/answer/3092439?hl=en&co=GENIE.Platform%3DDesktop#zippy=%2Ctraffic) and can be one of four values:

| Google Traffic Color | Description | Raster Value |
| -------------------- | ----------- | ------------ |
| Green                | No traffic delays | 1      |
| Orange               | Medium traffic    | 2      |
| Red                  | High traffic    | 3      |
| Dark Red             | Heavy traffic     | 4      |

## Installation <a name="installation"></a>

The package is available via github and can be installed using `devtools`.

```r  
# install.packages("devtools")
devtools::install_github("dime-worldbank/googletraffic")
```

## Usage <a name="usage"></a>

See the [this vignette](https://dime-worldbank.github.io/googletraffic/articles/googletraffic-vignette.html) for additional information and examples illustrating how to use the package.


