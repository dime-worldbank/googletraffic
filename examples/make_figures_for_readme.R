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
  
  api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")
  
  google_key <- api_keys_df %>%
    dplyr::filter(Service == "Google Directions API",
                  Account == "ramarty@email.wm.edu") %>%
    pull(Key)
  
  readme_images <- "~/Documents/Github/googletraffic/images"
  homepage_images <- "~/Documents/Github/googletraffic/man/figures"
  
  # Point example 1 -----------------------------------------------------------------
  r <- gt_make_raster(location = c(40.712778, -74.006111),
                      height = 1000,
                      width = 1000,
                      zoom = 16,
                      google_key = google_key)
  
  pal <- colorNumeric(c("green", "orange", "red", "#660000"), values(r),
                      na.color = "transparent")
  
  m <- leaflet() %>% 
    addProviderTiles("Esri.WorldGrayCanvas") %>%
    addRasterImage(r, colors = pal, opacity = 1,project=F)
  
  mapshot(m, file = file.path(readme_images, "nyc_small.jpg"))
  mapshot(m, file = file.path(homepage_images, "nyc_small.jpg"))
  
  # Point example 2 -----------------------------------------------------------------
  r <- gt_make_raster(location    = c(41.384900, -78.891302),
                      height        = 1000,
                      width         = 1000,
                      zoom          = 7,
                      google_key    = google_key)
  
  pal <- colorNumeric(c("green", "orange", "red", "#660000"), values(r),
                      na.color = "transparent")
  
  m <- leaflet() %>% 
    addProviderTiles("Esri.WorldGrayCanvas") %>%
    addRasterImage(r, colors = pal, opacity = 1,project=F)
  
  mapshot(m, file = file.path(readme_images, "usa.jpg"))
  mapshot(m, file = file.path(homepage_images, "usa.jpg"))
  
  # Polygon example -----------------------------------------------------------------
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
    theme(legend.key.size = unit(1, 'cm'),
          legend.title = element_text(size=20),
          legend.text = element_text(size=20),
          plot.background = element_rect(fill = "white", color="white"))
  ggsave(p, filename = file.path(readme_images, "nyc_large.jpg"),
         height = 20*0.8,
         width = 12*0.8)
  
  ggsave(p, filename = file.path(homepage_images, "nyc_large.jpg"),
         height = 20*0.8,
         width = 12*0.8)
  
  # jpeg("nyc_large.jpg",
  #      width = 480*4,
  #      height = 480*4)
  # rasterVis::levelplot(r, 
  #                      col.regions = c("green", "orange", "red", "#660000"),
  #                      par.settings = list(axis.line = list(col = "transparent")), 
  #                      scales = list(col = "black"),
  #                      colorkey = F,
  #                      xlab = NULL,
  #                      ylab = NULL,
  #                      margin = F,
  #                      maxpixels = 1e8)
  # dev.off()
  
  # Grid example -----------------------------------------------------------------
  ## Make initial grid
  grid_df <- gt_make_grid(polygon = ny_sp,
                          height = 2000,
                          width = 2000,
                          zoom = 16)
  
  m <- leaflet() %>%
    addTiles() %>%
    addPolygons(data = grid_df)
  
  mapshot(m, file = file.path(readme_images, "nyc_grid.jpg"))
  mapshot(m, file = file.path(homepage_images, "nyc_grid.jpg"))
  
  ## Remove part of grid
  grid_clean_df <- grid_df[-12,]
  
  m <- leaflet() %>%
    addTiles() %>%
    addPolygons(data =grid_clean_df)
  
  mapshot(m, file = file.path(readme_images, "nyc_grid_clean.jpg"))
  mapshot(m, file = file.path(homepage_images, "nyc_grid_clean.jpg"))
  
  ## Make raster
  r <- gt_make_raster_from_grid(grid_param_df = grid_clean_df,
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
    theme(legend.key.size = unit(1, 'cm'),
          legend.title = element_text(size=20),
          legend.text = element_text(size=20),
          plot.background = element_rect(fill = "white", color="white"))
  ggsave(p, filename = file.path(readme_images, "nyc_large_from_grid.jpg"),
         height = 20*0.8,
         width = 12*0.8)
  
  ggsave(p, filename = file.path(homepage_images, "nyc_large_from_grid.jpg"),
         height = 20*0.8,
         width = 12*0.8)
  
  # jpeg("nyc_large_from_grid.jpg",
  #      width = 480*4,
  #      height = 480*4)
  # rasterVis::levelplot(r, 
  #                      col.regions = c("green", "orange", "red", "#660000"),
  #                      par.settings = list(axis.line = list(col = "transparent")), 
  #                      scales = list(col = "black"),
  #                      colorkey = F,
  #                      xlab = NULL,
  #                      ylab = NULL,
  #                      margin = F,
  #                      maxpixels = 1e8)
  # dev.off()
  
  # Example for Top of Package -------------------------------------------------
  # https://www.google.com/maps/place/38%C2%B054'05.9%22N+77%C2%B002'11.7%22W/@38.9010952,-77.0350844,16.08z/data=!4m6!3m5!1s0x0:0xdfa7b78027c7aac6!7e2!8m2!3d38.9016494!4d-77.0365891!5m1!1e1
  r <- gt_make_raster(location = c(38.897761687363925, -77.03651747528248),
                      height = 700,
                      width = 700,
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
  ggsave(p, filename = file.path(readme_images, "top_example.jpg"), height = 5, width = 5)
  ggsave(p, filename = file.path(homepage_images, "top_example.jpg"), height = 5, width = 5)
  
  # jpeg("top_example.jpg",
  #      width = 480*1.5,
  #      height = 480*1.5)
  # rasterVis::levelplot(r, 
  #                      col.regions = c("green", "orange", "red", "#660000"),
  #                      par.settings = list(axis.line = list(col = "transparent")), 
  #                      scales = list(col = "black"),
  #                      colorkey = F,
  #                      xlab = NULL,
  #                      ylab = NULL,
  #                      margin = F,
  #                      maxpixels = 1e10)
  # dev.off()
  
}

