# Testing Package

# Setup ------------------------------------------------------------------------
library(googletraffic)

api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key <- api_keys_df %>%
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") %>%
  pull(Key)

# Make PNGs --------------------------------------------------------------------
for(zoom in 10:15){
  gt_make_png(location = c(40.717437418183884, -73.99145764250052),
              height = 2000,
              width = 2000,
              zoom = zoom,
              out_filename = paste0("~/Desktop/gt_pngs/gt",zoom,".png"),
              google_key = google_key)
}

# Make Traffic Figures ---------------------------------------------------------
for(zoom in 10:15){
  r <- gt_load_png_as_traffic_raster(filename = paste0("~/Desktop/gt_pngs/gt",zoom,".png"),
                                     location = c(40.717437418183884, -73.99145764250052),
                                     height = 2000,
                                     width = 2000,
                                     zoom = zoom)
  
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
  
  ggsave(p, filename = paste0("~/Desktop/gt_raster_images/r",zoom,".png"),
         height = 6, width = 6)
}

