# Troubleshooting

# devtools::install_github("dime-worldbank/googletraffic")
#library(googletraffic)

# Setup ------------------------------------------------------------------------
library(dplyr)
library(googleway)
library(htmlwidgets)
library(plotwidgets)
library(png)
library(sf)
library(sp)
library(stringr)
library(webshot2)
library(raster)
library(ColorNameR)
library(schemr)

git_dir <- "~/Documents/Github/googletraffic/R/"
source(file.path(git_dir, "gt_mosaic.R"))
source(file.path(git_dir,"gt_estimate_webshot_delay.R"))
source(file.path(git_dir,"gt_html_to_raster.R"))
source(file.path(git_dir,"gt_load_png_as_traffic_raster.R"))
source(file.path(git_dir,"gt_make_extent.R"))
source(file.path(git_dir,"gt_make_grid.R"))
source(file.path(git_dir,"gt_make_html.R"))
source(file.path(git_dir,"gt_make_png.R"))
source(file.path(git_dir,"gt_make_raster_from_grid.R"))
source(file.path(git_dir,"gt_make_raster_from_polygon.R"))
source(file.path(git_dir,"gt_make_raster.R"))

api_keys_df <- read.csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key_df <- api_keys_df |>
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") 
google_key <- google_key_df$Key

# Make raster ------------------------------------------------------------------
r <- gt_make_raster(location = c(40.712778, -74.006111),
                    height     = 600,
                    width      = 600,
                    zoom       = 15,
                    google_key = google_key)
# r
# 
# # Make png ---------------------------------------------------------------------
# gt_make_png(location     = c(40.712778, -74.006111),
#             height       = 1000,
#             width        = 1000,
#             zoom         = 16,
#             out_filename = "~/Desktop/new_folder/hello/google_traffic.png",
#             google_key   = google_key)
# 
# 
