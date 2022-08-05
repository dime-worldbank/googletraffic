# Examples used for readme

# Setup ------------------------------------------------------------------------
library(tidyverse)
library(googleway)
library(htmlwidgets)
library(webshot)
library(raster)
library(png)
library(plotwidgets)
library(httr)
library(sf)

library(leaflet)
library(leaflet.extras)
library(leaflet.providers)
library(scales)
library(mapview)

#source("https://github.com/dime-worldbank/googletraffic/blob/main/R/main.R")

api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key <- api_keys_df %>%
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") %>%
  pull(Key)

setwd("~/Documents/Github/googletraffic/images")

# Point example 1 -----------------------------------------------------------------
r <- gt_make_raster(location = c(40.712778, -74.006111),
                    height = 1000,
                    width = 1000,
                    zoom = 15,
                    webshot_delay = 5,
                    google_key = google_key)

pal <- colorNumeric(c("green", "orange", "red", "#660000"), values(r),
                    na.color = "transparent")

m <- leaflet() %>% 
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addRasterImage(r, colors = pal, opacity = 1,project=F)

mapshot(m, file = "nyc_small.png")

# Point example 2 -----------------------------------------------------------------
r <- gt_make_raster(location    = c(38.744324, -85.511534),
                    height        = 5000,
                    width         = 5000,
                    zoom          = 9,
                    webshot_delay = 20,
                    google_key    = google_key)

png("usa.png",
    width = 480*4,
    height = 480*4)
rasterVis::levelplot(r, 
                     col.regions = c("green", "orange", "red", "#660000"),
                     par.settings = list(axis.line = list(col = "transparent")), 
                     scales = list(col = "black"),
                     colorkey = F,
                     xlab = NULL,
                     ylab = NULL,
                     margin = F,
                     maxpixels = 1e10)
dev.off()

# Polygon example -----------------------------------------------------------------
us_sp <- getData('GADM', country='USA', level=2)
ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]

r <- gt_make_raster_from_polygon(polygon       = ny_sp,
                                 height        = 2000,
                                 width         = 2000,
                                 zoom          = 16,
                                 webshot_delay = 10,
                                 google_key    = google_key)

png("nyc_large.png",
    width = 480*4,
    height = 480*4)
rasterVis::levelplot(r, 
                     col.regions = c("green", "orange", "red", "#660000"),
                     par.settings = list(axis.line = list(col = "transparent")), 
                     scales = list(col = "black"),
                     colorkey = F,
                     xlab = NULL,
                     ylab = NULL,
                     margin = F,
                     maxpixels = 1e10)
dev.off()

# Grid example -----------------------------------------------------------------
## Make initial grid
grid_df <- gt_make_point_grid(polygon = ny_sp,
                              height = 2000,
                              width = 2000,
                              zoom = 16)

m <- leaflet() %>%
  addTiles() %>%
  addPolygons(data =grid_df)

mapshot(m, file = "nyc_grid.png")

## Remove part of grid
grid_clean_df <- grid_df[-12,]

m <- leaflet() %>%
  addTiles() %>%
  addPolygons(data =grid_clean_df)

mapshot(m, file = "nyc_grid_clean.png")

## Make raster
r <- gt_make_raster_from_grid(grid_param_df = grid_clean_df,
                              webshot_delay = 10,
                              google_key = google_key)

png("nyc_large_from_grid.png",
    width = 480*4,
    height = 480*4)
rasterVis::levelplot(r, 
                     col.regions = c("green", "orange", "red", "#660000"),
                     par.settings = list(axis.line = list(col = "transparent")), 
                     scales = list(col = "black"),
                     colorkey = F,
                     xlab = NULL,
                     ylab = NULL,
                     margin = F,
                     maxpixels = 1e10)
dev.off()

