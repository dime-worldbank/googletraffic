# googletraffic
Create data from Google Maps Traffic

# Overview

Google Maps Traffic provides valuable information about traffic conditions across an area. This package provides functions to produce georeferenced rasters from live Google Maps traffic information. Providing Google Traffic information in a georeferenced data format facilitates analysis of traffic information (e.g., merging traffic information with other data sources, observing trends over time, etc).

The below image shows an example raster produced using the package showing [traffic in lower Manhattan.](https://www.google.com/maps/place/40%C2%B042'46.8%22N+74%C2%B000'26.0%22W/@40.712993,-74.00942,17z/data=!3m1!4b1!4m6!3m5!1s0x0:0x7f21802cb308cc80!7e2!8m2!3d40.7129887!4d-74.0072258!5m1!1e1)

<p align="center">
<img src="images/top_example.jpg" alt="Example" width="500"/>
</p>

Pixel values in rasters can be one of four values, as described in the below table:

| Google Traffic Color | Description | Raster Value |
| -------------------- | ----------- | ------------ |
| Green                | No traffic       | 1       |
| Orange               | Light traffic    | 2       |
| Red                  | Moderate traffic | 3       |
| Dark Red             | Heavy traffic    | 4       |

# Installation

```r  
# install.packages("devtools")
devtools::install_github("dime-worldbank/googletraffic")
```

# Google API Key

Querying Google traffic information requires a Google API key with the [Maps Javascript API](https://developers.google.com/maps/documentation/javascript/overview) enabled.

```r
# The functions that query Google traffic information require a Google API key.
google_key <- "GOOGLE-KEY-HERE"
```

# Quickstart

The package enables querying Google traffic information around a specific location and for specific or larger spatial extents. In this section, key parameters relevant across functions are defined; then examples are shown querying traffic around a point, polygon, and grid.

* [Key parameters]
* [Query Traffic Around a Specific Location]
* [Query Granular Traffic Information for Large Spatial Extent]
  - [Query Traffic From a Polygon]
  - [Query Traffic From a Grid]

To run the below examples, the following packages should be also be loaded for visualizing the rasters.
```r
library(googletraffic)
library(leaflet)
library(leaflet.extras)
library(leaflet.providers)
library(scales)
library(mapview)
```

## Key parameters

The following are key parameters used when querying Google Traffic data.

* __zoom:__ The [zoom level](https://wiki.openstreetmap.org/wiki/Zoom_levels) defines the resolution of the traffic image. Values can range from 0 to 20. At the equator, with a zoom level 10, each will be about 150 meters; with a zoom level 20, each pixel will be about 0.15 meters. Consequently, smaller zoom levels can be used if only larger roads are of interest (e.g., highways), while larger zoom levels will be needed for capturing smaller roads.
* __height/width:__ The height and width defines the height and width of the raster in terms of pixels. The spatial extent of pixels depends on the `zoom` level and latitude.
* __webshot_delay:__ Google maps information is originally rendered on an interactive map. For large values of `height` and `width`, traffic information can take some time to render on a map. Consequently, a delay (specified using `webshot_delay`) is introduced to ensure traffic information is fully rendered on the map before traffic data is extracted. For example, when using a `height` and `width` of 500, a delay time of 2 seconds works well. For a `height` and `width` of 5000, a delay of up to 20 seconds may be needed. Traffic information cannot be rendered for very large `height` and `width` values, no matter the `webshot_delay` specified.

## Raster Around a Specific Location

The `gt_make_raster` function produces a raster, using a centroid location and height/width to specify the location where data is queried. The below example queries traffic for lower Manhattan, NYC.

```r  
## Make raster
r <- gt_make_raster(location      = c(-1.286389, 36.817222),
                    height        = 1000,
                    width         = 1000,
                    zoom          = 16,
                    webshot_delay = 4,
                    google_key    = google_key)

## Map raster
pal <- colorNumeric(c("green", "orange", "red", "#660000"), values(r),
                        na.color = "transparent")

leaflet() %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addRasterImage(r, colors = pal, opacity = 1,project=F)
```

![NYC Example 1](images/nyc_small.jpg)

By using a smaller `zoom`, we can capture a larger area.
```r  
## Make raster
r <- gt_make_raster(location    = c(38.744324, -85.511534),
                  height        = 1000,
                  width         = 1000,
                  zoom          = 7,
                  webshot_delay = 4,
                  google_key    = google_key)

## Map raster
rasterVis::levelplot(r,
                     col.regions = c("green", "orange", "red", "#660000"),
                     par.settings = list(axis.line = list(col = "transparent")),
                     scales = list(col = "black"),
                     colorkey = F,
                     xlab = NULL,
                     ylab = NULL,
                     margin = F)
```

![USA Example](images/usa.jpg)

## Query Granular Traffic Information for Large Spatial Extent

The above example illustrates a trade off between resolution and spatial extent. For small `zoom` levels, we can capture a large areas, but the pixels values are also large --- so we may only be able to detect overall traffic for large roads or cities. For large `zoom` levels, we can detect traffic on specific roads, but can only capture traffic for a smaller area. We could set a large `zoom` and a large `height` and `width`, but Google traffic information will fail to render if we set the `height` and `width` values too large (no matter the `webshot_delay` we specify).

The package provides functions that allow querying granular traffic information for large spatial extents. Here, we simply make multiple queries to obtain traffic information for multiple areas, then the information is merged together into one raster file. The `gt_make_raster_from_polygon()` and `gt_make_raster_from_grid()` provide two different approaches for querying granular traffic information for spatial extents where multiple Google queries are needed.

### Raster from Polygon

The above example showed querying traffic information for lower Manhattan. Here, we show querying traffic information for all of Manhattan using the same resolution (a `zoom` level of 16, where each pixel is 2-3 meters long). Using the `gt_make_raster_from_polygon()`, we input a polygon of Manhattan. We still specify the `height` and `width`. Large `height` and `width` values will result in fewer Google queries, while smaller `height` and `width` values will require more queries to cover the same spatial area.

In the below example, we use a `height` and `width` of 2000, which results in needing to make 14 Google API queries to cover all of Manhattan. Given a `height` and `width` of 2000 is still a bit large, we use a `webshot_delay` of 10 seconds.

```r  
## Grab polygon of Manhattan
us_sp <- getData('GADM', country='USA', level=2)
ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]

## Make raster
r <- gt_make_raster_from_polygon(polygon       = ny_sp,
                                 height        = 2000,
                                 width         = 2000,
                                 zoom          = 16,
                                 webshot_delay = 10,
                                 google_key    = google_key)

## Plot raster
rasterVis::levelplot(r,
                     col.regions = c("green", "orange", "red", "#660000"),
                     par.settings = list(axis.line = list(col = "transparent")),
                     scales = list(col = "black"),
                     colorkey = F,
                     xlab = NULL,
                     ylab = NULL,
                     margin = F)
```

![NYC Example 2](images/nyc_large.jpg)

### Raster from Grid

`gt_make_raster_from_polygon()` creates a grid that covers a polygon, creates a traffic raster for each grid, and mosaics them together. Some may prefer to first create and see the grid, then create a traffic raster using this grid. For example, one could (1) create a grid that covers a polygon then (2) remove certain grid tiles that cover areas that may not be of interest. The `gt_make_point_grid()` and `gt_make_raster_from_grid()` functions facilitate this process; `gt_make_point_grid()` creates a grid, then `gt_make_raster_from_grid()` uses a grid as an input to create a traffic raster.

Here, we create a grid.
```r
grid_df <- gt_make_point_grid(polygon = ny_sp,
                              height  = 2000,
                              width   = 2000,
                              zoom    = 16)

leaflet() %>%
  addTiles() %>%
  addPolygons(data = grid_df)
```

![NYC Grid](images/nyc_grid.jpg)


We notice that the tile in the bottom left corner just covers water and some land outside of Manhattan. To reduce the number of API queries we need to make, we can remove this tile.

```r
grid_clean_df <- grid_df[-12,]

leaflet() %>%
  addTiles() %>%
  addPolygons(data = grid_clean_df)
```

![NYC Grid Clean](images/nyc_grid_clean.jpg)

We can then use the grid to make a traffic raster.
```r
r <- gt_make_raster_from_grid(grid_param_df = grid_clean_df,
                              webshot_delay = 10,
                              google_key = google_key)

rasterVis::levelplot(r,
                     col.regions = c("green", "orange", "red", "#660000"),
                     par.settings = list(axis.line = list(col = "transparent")),
                     scales = list(col = "black"),
                     colorkey = F,
                     xlab = NULL,
                     ylab = NULL,
                     margin = F)
```

![NYC Example 3](images/nyc_large_from_grid.jpg)

Note that the above raster includes traffic in areas outside of Manhattan; the image is not cropped or masked to just the Manhattan polygon. This result can also be achieved when using the `gt_make_raster_from_polygon()` function by setting `crop_to_polygon` to `FALSE`.
