# googletraffic  <img src="man/figures/hex.png" align="right" width="200" />
Create Georeferenced Traffic Data from the [Google Maps Javascript API](https://developers.google.com/maps/documentation/javascript/trafficlayer)

## Overview <a name="overview"></a>

Google Maps provides information about traffic conditions across an area. This package provides functions to produce georeferenced rasters from live Google Maps traffic information. Providing Google traffic information in a georeferenced data format facilitates analysis of traffic information (e.g., spatially merging traffic information with other data sources).

<!--- The below image shows an example raster produced using the package showing [traffic within Washington, DC.](https://www.google.com/maps/@38.9098813,-77.0406205,15.01z/data=!5m1!1e1)

<p align="center">
<img src="man/figures/top_example.jpg" alt="Example" width="800"/>
</p>
--->

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

## Quickstart <a name="quickstart"></a>

### Setup
```r  
library(googletraffic)

google_key <- "GOOGLE-KEY-HERE"
```

### Raster around point
To create a raster around a point, we set the centroid coordinate, the [zoom](https://wiki.openstreetmap.org/wiki/Zoom_levels) level, and the height/width around the centroid coordinate (height/width are in terms of pixels, and kilometer distance of a pixel is determined primarily by the zoom level).

```r  
## Make raster
r <- gt_make_raster(location   = c(40.712778, -74.006111),
                    height     = 2000,
                    width      = 2000,
                    zoom       = 16,
                    google_key = google_key)

## Plot
r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
names(r_df) <- c("value", "x", "y")

ggplot() +
  geom_raster(data = r_df, 
              aes(x = x, y = y, 
                  fill = as.factor(value))) +
  labs(fill = "Traffic\nLevel") +
  scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
  coord_quickmap() + 
  theme_void() +
  theme(plot.background = element_rect(fill = "white", color="white"))
```

<p align="center">
<img src="man/figures/nyc_small.jpg" alt="Example" width="800"/>
</p>

### Raster around polygon
We can also create a raster using a polygon to define the location. We still define the zoom, height, and width. If needed, the function will make multiple API calls to cover the area within the polygon; the height/width parameters determine the height/width for a single API call (larger height/width mean less API calls are needed, but traffic data will fail to render if too large of a height/width are set.)

```r
## Grab shapefile of Manhattan
us_sp <- getData('GADM', country='USA', level=2)
ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]

## Make raster
r <- gt_make_raster_from_polygon(polygon       = ny_sp,
                                 height        = 2000,
                                 width         = 2000,
                                 zoom          = 16,
                                 google_key    = google_key)

## Plot
r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
names(r_df) <- c("value", "x", "y")

ggplot() +
  geom_raster(data = r_df, 
              aes(x = x, y = y, 
                  fill = as.factor(value))) +
  labs(fill = "Traffic\nLevel") +
  scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
  coord_quickmap() + 
  theme_void() +
  theme(plot.background = element_rect(fill = "white", color="white"))
```

<p align="center">
<img src="man/figures/nyc_large.jpg" alt="Example" width="800"/>
</p>

## Usage <a name="usage"></a>

See [this vignette](https://dime-worldbank.github.io/googletraffic/articles/googletraffic-vignette.html) for additional information and examples illustrating how to use the package.


