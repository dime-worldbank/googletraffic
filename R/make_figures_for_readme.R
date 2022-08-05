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

mapshot(m, file = "nyc_small.jpeg")

# Point example 2 -----------------------------------------------------------------
r <- gt_make_raster(location    = c(38.744324, -85.511534),
                    height        = 5000,
                    width         = 5000,
                    zoom          = 7,
                    webshot_delay = 20,
                    google_key    = google_key)

jpeg("usa.jpeg",
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
                     maxpixels = 1e8)
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

jpeg("nyc_large.jpeg",
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
                     maxpixels = 1e8)
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

mapshot(m, file = "nyc_grid.jpg")

## Remove part of grid
grid_clean_df <- grid_df[-12,]

m <- leaflet() %>%
  addTiles() %>%
  addPolygons(data =grid_clean_df)

mapshot(m, file = "nyc_grid_clean.jpg")

## Make raster
r <- gt_make_raster_from_grid(grid_param_df = grid_clean_df,
                              webshot_delay = 10,
                              google_key = google_key)

jpeg("nyc_large_from_grid.jpeg",
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
                     maxpixels = 1e8)
dev.off()

# Washington DC Example --------------------------------------------------------
# https://www.google.com/maps/place/38%C2%B054'05.9%22N+77%C2%B002'11.7%22W/@38.9010952,-77.0350844,16.08z/data=!4m6!3m5!1s0x0:0xdfa7b78027c7aac6!7e2!8m2!3d38.9016494!4d-77.0365891!5m1!1e1
r <- gt_make_raster(location = c(40.712989, -74.007226),
                    height = 700,
                    width = 700,
                    zoom = 16,
                    webshot_delay = 5,
                    google_key = google_key)

jpeg("top_example.jpg",
     width = 480*1.5,
     height = 480*1.5)
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



