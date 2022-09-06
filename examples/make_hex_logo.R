# Make Hexagon Logo

if(F){
  
  library(hexSticker)
  library(ggplot2)
  library(googletraffic)
  library(tidyverse)
  library(raster)
  
  api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")
  
  google_key <- api_keys_df %>%
    dplyr::filter(Service == "Google Directions API",
                  Account == "ramarty@email.wm.edu") %>%
    pull(Key)
  
  r <- gt_make_raster(location = c(39.099749, -84.514448),
                      height = 1200,
                      width = 1200,
                      zoom = 16,
                      webshot_delay = 5,
                      google_key = google_key)
  
  r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
  names(r_df) <- c("value", "x", "y")
  
  p <- ggplot() +
    geom_raster(data = r_df, 
                aes(x = x, y = y, 
                    fill = as.factor(value))) +
    scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
    coord_quickmap() + 
    theme_void() + 
    theme_transparent() +
    theme(legend.position = "none")

  sticker(p, 
          package="googletraffic", 
          p_size=21.5, #7 
          p_y = 1.4,
          p_family = "sans",
          p_fontface = "italic",
          s_x=1, 
          s_y=0.9, 
          s_width=2.3, 
          s_height=2.3,
          p_color = "white",
          h_fill = "gray10",
          h_color = "gray10",
          white_around_sticker = T,
          spotlight = T,
          l_alpha = 0.15,
          l_y = 1.4,
          l_x = 0.93,
          l_width = 3,
          l_height = 3,
          filename="~/Documents/Github/googletraffic/images/hex.png")

 }