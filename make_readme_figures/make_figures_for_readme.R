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
  
  google_key <- "GOOGLE-KEY-HERE"

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
         height = 4*1.8,
         width = 5*1.8)

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
         height = 7*1.6,
         width = 4.2*1.6)
}

