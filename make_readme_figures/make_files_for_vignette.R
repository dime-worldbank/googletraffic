# Make Files for Vignettee

vig_dir <- file.path("~/Documents/Github/googletraffic/vignettes")

# Setup ------------------------------------------------------------------------
## Load Google Traffic package
library(googletraffic)

## Load additional packages for working with and visualizing data
library(leaflet)
library(leaflet.extras)
library(leaflet.providers)
library(scales)
library(mapview)
library(raster)
library(tidyverse)

## Set Google API Key
google_key <- "GOOGLE-API-KEY-HERE"

## Define Leaflet Palette and Legend
traffic_pal <- colorNumeric(c("green", "orange", "red", "#660000"), 
                            1:4,
                            na.color = "transparent")

# Load Google API Key ----------------------------------------------------------
api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key <- api_keys_df %>%
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") %>%
  pull(Key)

# Raster Around Point ----------------------------------------------------------
r <- gt_make_raster(location   = c(40.712778, -74.006111),
                    height     = 1000,
                    width      = 1000,
                    zoom       = 16,
                    google_key = google_key)

saveRDS(r, file.path(vig_dir, "raster_point_small.Rds"), version = 2)

## Map raster
#leaflet(width = "100%") %>%
#  addProviderTiles("Esri.WorldGrayCanvas") %>%
#  addRasterImage(r, colors = traffic_pal, opacity = 1) 

# Raster Around Point: Larger --------------------------------------------------
## Make raster
r <- gt_make_raster(location   = c(41.384900, -78.891302),
                    height     = 1000,
                    width      = 1000,
                    zoom       = 7,
                    google_key = google_key)

saveRDS(r, file.path(vig_dir, "raster_point_large.Rds"), version = 2)

## Map raster
#leaflet(width = "100%") %>%
#  addProviderTiles("Esri.WorldGrayCanvas") %>%
#  addRasterImage(r, colors = traffic_pal, opacity = 1) %>%
#  setView(lat = 41.384900, lng = -78.891302, zoom = 6) 

# Raster Around Polygon --------------------------------------------------------
## Grab polygon of Manhattan
us_sp <- getData('GADM', country='USA', level=2)
ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]

## Make raster
r <- gt_make_raster_from_polygon(polygon    = ny_sp,
                                 zoom       = 15,
                                 google_key = google_key)

saveRDS(r, file.path(vig_dir, "raster_polygon.Rds"), version = 2)

## Map raster
#leaflet(width = "100%") %>%
#  addProviderTiles("Esri.WorldGrayCanvas") %>%
#  addRasterImage(r, colors = traffic_pal, opacity = 1) 

# Raster Using Grid ------------------------------------------------------------
#### Grid 1
grid_df <- gt_make_grid(polygon = ny_sp,
                        zoom    = 15)

saveRDS(grid_df, file.path(vig_dir, "raster_grid_1.Rds"), version = 2)

#leaflet(width = "100%") %>%
#  addTiles() %>%
#  addPolygons(data = grid_df, popup = ~as.character(id))

#### Grid 2
#grid_clean_df <- grid_df[-5,]

#saveRDS(grid_clean_df, file.path(vig_dir, "raster_grid_2.png"))

#leaflet(width = "100%") %>%
#  addTiles() %>%
#  addPolygons(data = grid_clean_df)

#### Raster using grid
## Make raster
r <- gt_make_raster_from_grid(grid_param_df = grid_clean_df,
                              google_key    = google_key)

saveRDS(r, file.path(vig_dir, "raster_using_grid.Rds"), version = 2)

## Map raster
#leaflet(width = "100%") %>%
#  addProviderTiles("Esri.WorldGrayCanvas") %>%
#  addRasterImage(r, colors = traffic_pal, opacity = 1) 

# Make PNG then Raster ---------------------------------------------------------

#### Make Grid
#### First, make grid
grid_df <- gt_make_grid(polygon = ny_sp,
                        height  = 2000,
                        width   = 2000,
                        zoom    = 15)

saveRDS(grid_df, file.path(vig_dir, "png_then_raster_grid.Rds"), version = 2)

#print(grid_df)

