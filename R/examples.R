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

source("https://github.com/dime-worldbank/googletraffic/blob/main/R/main.R")


api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key <- api_keys_df %>%
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") %>%
  pull(Key)

setwd("~/Documents/Github/googletraffic")

# Base example -----------------------------------------------------------------
r <- gt_make_raster(location = c(40.712778, -74.006111),
                    height = 1000,
                    width = 1000,
                    zoom = 16,
                    webshot_delay = 5,
                    google_key = google_key)

print(r)
png("nyc_small.png",
    width = 480*2,
    height = 480*2)
rasterVis::levelplot(r, 
                     col.regions = c("green", "orange", "red", "#660000"),
                     par.settings = list(axis.line = list(col = "transparent")), 
                     scales = list(col = "black"),
                     colorkey = F,
                     xlab = NULL,
                     ylab = NULL,
                     margin = F,
                     maxpixels = 1e7)
dev.off()

pal <- colorNumeric(c("green", "orange", "red", "#660000"), values(r),
                        na.color = "transparent")

m <- leaflet() %>% 
  #addProviderTiles(providers$Stadia.AlidadeSmoothDark) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addRasterImage(r, colors = pal_all, opacity = 1,project=F)

mapshot(m, file = "nyc_small_leaflet.png")

# Base example -----------------------------------------------------------------








