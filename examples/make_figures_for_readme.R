# Examples used for readme

if(F){
  
  # Setup ------------------------------------------------------------------------
  library(googletraffic)
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
  library(ggpubr)
  
  #source("https://github.com/dime-worldbank/googletraffic/blob/main/R/main.R")
  
  api_keys_df <- read.csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")
  
  google_key <- api_keys_df %>%
    dplyr::filter(Service == "Google Directions API",
                  Account == "ramarty@email.wm.edu") %>%
    pull(Key)
  
  homepage_images <- "~/Documents/Github/googletraffic/man/figures"
  vignette_images <- "~/Documents/Github/googletraffic/vignettes"
  
  # Example for Top of Package -------------------------------------------------
  r <- gt_make_raster(location = c(38.90723410426802, -77.03655197910766),
                      height = 2000,
                      width = 2000,
                      zoom = 16,
                      google_key = google_key)
  
  r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
  names(r_df) <- c("value", "x", "y")
  
  p <- ggplot() +
    geom_raster(data = r_df, 
                aes(x = x, y = y, 
                    fill = as.factor(value))) +
    labs(fill = "Traffic\nLevel") +
    scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
    coord_quickmap() + 
    theme_void() +
    theme(plot.background = element_rect(fill = "white", color="white"))
  ggsave(p, filename = file.path(vignette_images, "top_example.jpg"), height = 4.5, width = 5)
  
  # Point example 1 -----------------------------------------------------------------
  r <- gt_make_raster(location   = c(40.712778, -74.006111),
                      height     = 2000,
                      width      = 2000,
                      zoom       = 16,
                      google_key = google_key)
  
  r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
  names(r_df) <- c("value", "x", "y")
  
  p <- ggplot() +
    geom_raster(data = r_df, 
                aes(x = x, y = y, 
                    fill = as.factor(value))) +
    labs(fill = "Traffic\nLevel") +
    scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
    coord_quickmap() + 
    theme_void() +
    theme(plot.background = element_rect(fill = "white", color="white"))
  
  ggsave(p, filename = file.path(homepage_images, "nyc_small.jpg"),
         height = 8,
         width = 8)
  
  # Polygon example 2 ----------------------------------------------------------
  us_sp <- getData('GADM', country='USA', level=2)
  ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]
  
  r <- gt_make_raster_from_polygon(polygon       = ny_sp,
                                   height        = 2000,
                                   width         = 2000,
                                   zoom          = 16,
                                   google_key    = google_key)
  
  r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
  names(r_df) <- c("value", "x", "y")
  
  p <- ggplot() +
    geom_raster(data = r_df, 
                aes(x = x, y = y, 
                    fill = as.factor(value))) +
    labs(fill = "Traffic\nLevel") +
    scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
    coord_quickmap() + 
    theme_void() +
    theme(plot.background = element_rect(fill = "white", color="white"))
  
  ggsave(p, filename = file.path(homepage_images, "nyc_large.jpg"),
         height = 20*0.6,
         width = 12*0.5)
  
}

