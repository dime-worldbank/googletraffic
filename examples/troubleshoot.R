# Troubleshooting

# Setup ------------------------------------------------------------------------
root_dir <- "~/Documents/Github/googletraffic"

source(file.path(root_dir, "R", "gt_estimate_webshot_delay.R"))
source(file.path(root_dir, "R", "gt_html_to_raster.R"))
source(file.path(root_dir, "R", "gt_load_png_as_traffic_raster.R"))
source(file.path(root_dir, "R", "gt_make_extent.R"))
source(file.path(root_dir, "R", "gt_make_grid.R"))
source(file.path(root_dir, "R", "gt_make_html.R"))
source(file.path(root_dir, "R", "gt_make_png.R"))
source(file.path(root_dir, "R", "gt_make_raster_from_grid.R"))
source(file.path(root_dir, "R", "gt_make_raster_from_polygon.R"))
source(file.path(root_dir, "R", "gt_make_raster.R"))

library(tidyverse)
library(googleway)
library(htmlwidgets)
library(webshot)
library(raster)
library(png)
library(plotwidgets)
library(httr)
library(sp)
library(sf)

library(plyr)

api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key <- api_keys_df %>%
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") %>%
  pull(Key)

# Setup ------------------------------------------------------------------------
us_sp <- getData('GADM', country='USA', level=2)
dc_sp <- us_sp[us_sp$NAME_1 %in% "District of Columbia",]

r <- gt_make_raster_from_polygon(polygon = dc_sp,
                                 height = 2000,
                                 width = 2000,
                                 zoom = 15,
                                 webshot_delay = 20,
                                 google_key = google_key)

## Mosaic rasters together
r_list <- r_list_out

names(r_list)    <- NULL
r_list$fun       <- max
r_list$tolerance <- 2

r <- do.call(raster::merge, r_list)
r[r[] %in% 0] <- NA

r <- raster::merge(r_list[[1]], r_list[[4]], tolerance = 1)





