# googletraffic
Create data from Google Maps Traffic data

# Overview

# Installation

```r  
# install.packages("devtools")
devtools::install_github("ramarty/googletraffic")
```

# Examples

## Raster from lat/lon
```r  
r <- gt_make_raster(location      = c(-1.286389, 36.817222),
                    height        = 500,
                    width         = 500,
                    zoom          = 16,
                    webshot_delay = 2,
                    google_key    = google_key)
```

## Raster from grid
```r  
nbo <- getData('GADM', country='KEN', level=1, path = "~/Desktop")
nbo <- nbo[nbo$NAME_1 %in% "Nairobi",]

grid_param_df <- gt_make_point_grid(polygon   = nbo,
                                    height    = 500,
                                    width     = 500,
                                    zoom      = 12,
                                    reduce_hw = 100)

r <- gt_make_raster_from_grid(grid_param_df = grid_param_df,
                              webshot_delay = 5,
                              google_key    = google_key)
```

## Raster from polygon
```r  
r <- gt_make_raster(location      = c(-1.286389, 36.817222),
                    height        = 500,
                    width         = 500,
                    zoom          = 16,
                    webshot_delay = 2)

nbo <- getData('GADM', country='KEN', level=1, path = "~/Desktop")
nbo <- nbo[nbo$NAME_1 %in% "Nairobi",]

r <- gt_make_raster_from_polygon(polygon       = nbo,
                                 height        = 500,
                                 width         = 500,
                                 zoom          = 12,
                                 webshot_delay = 5,
                                 reduce_hw     = 100,
                                 google_key    = google_key)
```
