# Test Function

if(F){
  
  library(tidyverse)
  library(googletraffic)
  library(leaflet)
  library(scales)
  devtools::install_github("ramarty/googletraffic")
  if(F){
    remove.packages("googletraffic")
  }
  
  library(dehex)
  # remotes::install_github("matt-dray/dehex")
  # https://www.rostrum.blog/2021/08/10/dehex/
  
  api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")
  
  google_key <- api_keys_df %>%
    dplyr::filter(Service == "Google Directions API",
                  Account == "ramarty@email.wm.edu") %>%
    pull(Key)
  
  bing_key <- api_keys_df %>%
    dplyr::filter(Service == "Bing Maps",
                  Account == "robmarty3@gmail.com") %>%
    pull(Key)
  
  # Check colors ---------------------------------------------------------------
  file_i <- "~/Desktop/googletraffic_nairobi_utc1659096004_id8.png"
  nbo_grid   <- readRDS("~/Desktop/nairobi_grid.Rds")
  nbo_grid_i <- nbo_grid[nbo_grid$id %in% 8,]
  
  #### FUNCTION
  filename <- file_i
  latitude <- nbo_grid_i$latitude
  longitude <- nbo_grid_i$longitude
  height <- nbo_grid_i$height
  width <- nbo_grid_i$width
  zoom <- nbo_grid_i$zoom
  
  #### Load
  r   <- raster(filename,1)
  img <- readPNG(filename)
  
  #### Assign traffic colors 
  ## Image to hex
  rimg <- as.raster(img) 
  colors_df <- rimg %>% table() %>% as.data.frame() %>%
    dplyr::rename(hex = ".")
  colors_df$hex <- colors_df$hex %>% as.character()
  
  ## Assign traffic colors based on hsl
  hsl_df <- colors_df$hex %>% 
    col2hsl() %>%
    t() %>%
    as.data.frame() 
  
  colors_df <- bind_cols(colors_df, hsl_df)
  
  colors_df <- colors_df %>%
    dplyr::mutate(hex = hex %>% substring(1,7))
  
  colors_df <- colors_df %>%
    mutate(color = case_when(#((H == 0) & (S < 0.2)) ~ "background",
      ((H == 0) & (S >= 0.28) & (S < 0.7) & (L >= 0.3) & (L <= 0.42)) ~ "dark-red",
      H > 0 & H <= 5 & L <= 0.65 ~ "red", # L <= 0.80
      H >= 20 & H <= 28 & L <= 0.80 ~ "orange", # L <= 0.85
      H >= 120 & H <= 135 & L <= 0.80 ~ "green"))
  
  colors_df <- colors_df %>%
    arrange(-L)
  
  colors_df_i <- colors_df[colors_df$color %in% "dark-red",]
#  colors_df_i <- colors_df[is.na(colors_df$color),]
  colors_df_i <- colors_df_i %>%
    mutate(id = 1:n())
  head(colors_df_i)
  

  
  show_col(colors_df_i$hex)
  
  for(i in 1:nrow(colors_df_i)){
    print(i)
    colors_df_i[i,] %>% print()
    dh_solve(colors_df_i$hex[i], swatch = TRUE, crayon=T)
    Sys.sleep(1)
    print("----")
  }
  
  ## Apply traffic colors to raster
  colors_unique <- colors_df$color %>% unique()
  colors_unique <- colors_unique[!is.na(colors_unique)]
  colors_unique <- colors_unique[!(colors_unique %in% "background")]
  rimg <- matrix(rimg) #%>% raster::t() #%>% base::t()
  for(color_i in colors_unique){
    rimg[rimg %in% colors_df$hex[colors_df$color %in% color_i]] <- color_i
  }
  
  dh_solve("#D6DBAB", swatch = TRUE, crayon=T)
  
  # Test Function --------------------------------------------------------------
  file_i <- "~/Desktop/googletraffic_nairobi_utc1659096004_id8.png"
  nbo_grid   <- readRDS("~/Desktop/nairobi_grid.Rds")
  nbo_grid_i <- nbo_grid[nbo_grid$id %in% 8,]
  
  r <- gt_load_png_as_traffic_raster(filename = file_i,
                                     nbo_grid_i$latitude,
                                     nbo_grid_i$longitude,
                                     nbo_grid_i$height,
                                     nbo_grid_i$width,
                                     nbo_grid_i$zoom)

  pal_all <- colorNumeric(c("green", "orange", "red", "#660000"), values(r),
                          na.color = "transparent")
  
  leaflet() %>% 
    addTiles() %>%
    addRasterImage(r, colors = pal_all, opacity = 1,project=F) %>%
    addLegend(pal = pal_gr, values = values(r),
              title = "Traffic")
  
  # Test on random location ----------------------------------------------------
  r <- gt_make_raster(location = c(38.904722, -77.016389),
                      height = 5000,
                      width = 5000,
                      zoom = 8,
                      webshot_delay = 20,
                      google_key = google_key)
  
  pal_all <- colorNumeric(c("green", "orange", "red", "#660000"), values(r),
                          na.color = "transparent")
  
  leaflet() %>% 
    addTiles() %>%
    addRasterImage(r, colors = pal_all, opacity = 1,project=F) %>%
    addLegend(pal = pal_gr, values = values(r),
              title = "Traffic")
  
  # Next -----------------------------------------------------------------------
  latitude = 59.915717
  longitude = 10.755022
  zoom = 16
  height = 500
  width = 500
  
  gt_make_png(c(latitude, longitude),
              height,
              width,
              zoom,
              5,
              google_key,
              out_filename = "~/Desktop/t123.png")
  
  gr <- gt_make_raster(c(latitude, longitude),
                       height,
                       width,
                       zoom,
                       5,
                       google_key)
  
  library(leaflet)
  pal_gr <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), values(gr),
                         na.color = "transparent")
  
  leaflet() %>% 
    addTiles() %>%
    addRasterImage(gr, colors = pal_gr, opacity = 0.5) %>%
    addLegend(pal = pal_gr, values = values(gr),
              title = "Traffic")
  
  
  # GET EXTENT -----------------------------------------------------------------
  library(jsonlite)
  library(httr)
  latitude = 59.915717
  longitude = 10.755022
  
  #latitude = 0
  #longitude = 0
  zoom = 16
  height = 6000
  width = 6000
  
  bing_metadata_url <- paste0("https://dev.virtualearth.net/REST/v1/Imagery/Map/Road/",
                              latitude,",",longitude,"/",zoom,
                              "?mapSize=",height,",",width,
                              #"&style=",style,
                              "&mmd=1",
                              "&mapLayer=TrafficFlow&format=png&key=",bing_key)
  
  md <- bing_metadata_url %>% GET() %>% content(as="text") %>% fromJSON 
  bbox <- md$resourceSets$resources[[1]]$bbox[[1]]
  bbox
  gt_make_extent(latitude,
                 longitude,
                 height,
                 width,
                 zoom)
  
  br <- bing_traffic(latitude,
                     longitude,
                     height,
                     width,
                     zoom,
                     bing_key)
  
  gr <- gt_make_raster(c(latitude, longitude),
                       height,
                       width,
                       zoom,
                       20,
                       google_key)
  
  pal_gr <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), values(gr),
                         na.color = "transparent")
  
  pal_br <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), values(br),
                         na.color = "transparent")
  
  leaflet() %>% 
    addTiles() %>%
    addRasterImage(br, colors = pal, opacity = 0.5) %>%
    addLegend(pal = pal_br, values = values(br),
              title = "Traffic")
  
  leaflet() %>% 
    addTiles() %>%
    addRasterImage(gr, colors = pal, opacity = 0.5) %>%
    addLegend(pal = pal_gr, values = values(gr),
              title = "Traffic")
  
  # Test functions -------------------------------------------------------------
  style <- '[
    {
        "elementType": "labels",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "elementType": "geometry",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "color": "#ffffff"
            }
        ]
    },
    {
        "featureType": "landscape",
        "stylers": [
            {
                "color": "#ffffff"
            },
            {
                "visibility": "on"
            }
        ]
    },
    {}
]'
  
  # NEW STUFF HERE =============================================================
  # NOTE: RELIES ON DEVELOPMENT VERSION OF GOOGLEWAY!!!
  library(googleway)
  help(google_map)
  
  gmap <- google_map(key = google_key,
                     #location = location,
                     zoom = 14,
                     map_bounds = c(36.6414, -1.45354, 37.063969, -1.45354),
                     #height = height,
                     #width = width,
                     styles = style,
                     zoom_control = F,
                     map_type_control = F,
                     scale_control = F,
                     fullscreen_control = F,
                     rotate_control = F,
                     street_view_control = F) %>%
    add_traffic() 
  
  library(htmlwidgets)
  saveWidget(gmap, 
             file = "~/Desktop/map.html", 
             selfcontained = T)
  
  library(webshot)
  webshot_delay <- 10
  setwd("~/Desktop")
  webshot(paste0("map",".html"),
          file = paste0("map",".png"),
          vheight = "100p",
          vwidth = "100p",
          cliprect = "viewport",
          delay = webshot_delay,
          zoom = 1)
  
  gmap
  
  
  #### From Lat/Long
  r <- gt_make_raster(location = c(-1.286389, 36.817222),
                      height = 500,
                      width = 500,
                      zoom = 16,
                      webshot_delay = 2)
  
  #### From Grid
  nbo <- getData('GADM', country='KEN', level=1, path = "~/Desktop")
  nbo <- nbo[nbo$NAME_1 %in% "Nairobi",]
  
  grid_param_df <- gt_make_point_grid(polygon = nbo,
                                      height = 500,
                                      width = 500,
                                      zoom = 12,
                                      reduce_hw = 100)
  
  head(grid_param_df)
  
  r <- gt_make_raster_from_grid(grid_param_df = grid_param_df,
                                webshot_delay = 2)
  
  #### From polygon
  nbo <- getData('GADM', country='KEN', level=1, path = "~/Desktop")
  nbo <- nbo[nbo$NAME_1 %in% "Nairobi",]
  
  r <- gt_make_raster_from_polygon(polygon = nbo,
                                   height = 500,
                                   width = 500,
                                   zoom = 12,
                                   webshot_delay = 5,
                                   reduce_hw = 100,
                                   print_progress = T)
  
  # One raster, one time period --------------------------------------------------
  ## Option 1
  gt_make_html(location = c(-1.286389, 36.817222),
               height = 5000,
               width = 5000,
               zoom = 15,
               filename = "~/Desktop/nbo.html", 
               google_key = google_key)
  
  r <- gt_html_to_raster(filename = "~/Desktop/gtt/html/nbo.html",
                         webshot_delay = 10)
  
  ## Option 2
  gt_make_html(location = c(-1.286389, 36.817222),
               height = 5000,
               width = 5000,
               zoom = 16,
               filename = "~/Desktop/gtt/html/nbo.html", 
               google_key = google_key,
               save_params = F)
  
  r <- gt_html_to_raster(filename = "~/Desktop/gtt/html/nbo.html",
                         location = c(-1.286389, 36.817222),
                         height = 5000,
                         width = 5000,
                         zoom = 16,
                         webshot_delay = 10)
  
  # Multiple rasters, one time period --------------------------------------------
  ## Make grid dataframe
  nbo <- getData('GADM', country ='KEN', level=1, download = F)
  nbo <- nbo[nbo$NAME_1 %in% "Nairobi",]
  
  grid_param_df <- gt_make_point_grid(polygon = nbo,
                                      height = 6000,
                                      width = 6000,
                                      zoom = 16,
                                      reduce_hw = 100)
  
  ## Option 1
  make_htmls_from_grid(grid_param_df = grid_param_df,
                       filename_suffix = "nbo_gtt",
                       out_dir = "~/Desktop/gtt/html",
                       google_key = google_key)
  
  html_files <- list.files("~/Desktop/gtt/html", pattern = ".html$", full.names = T)
  
  r <- gt_htmls_to_raster(html_files = html_files,
                          webshot_delay = 22)
  
  ## Option 2
  make_htmls_from_grid(grid_param_df = grid_param_df,
                       filename_suffix = "nbo_gtt",
                       out_dir = "~/Desktop/gtt/html",
                       google_key = google_key,
                       save_params = F)
  
  html_files <- list.files("~/Desktop/gtt/html", pattern = ".html$", full.names = T)
  
  r <- gt_htmls_to_raster(html_files = html_files,
                          grid_param_df = grid_param_df,
                          webshot_delay = 22)
  
  # Multiple rasters, multiple time periods --------------------------------------
  ## Make grid dataframe
  nbo <- getData('GADM', country ='KEN', level=1)
  nbo <- nbo[nbo$NAME_1 %in% "Nairobi",]
  
  grid_param_df <- gt_make_point_grid(polygon = nbo,
                                      height = 6000,
                                      width = 6000,
                                      zoom = 16,
                                      reduce_hw = 100)
  
  ## Make HTMLs
  library(lubridate)
  for(i in 1:3){
    
    time <- Sys.time() %>% 
      with_tz(tzone = "UTC") %>%
      as.numeric() %>% 
      as.character() %>% 
      str_replace_all("[[:punct:]]", "")
    
    make_htmls_from_grid(grid_param_df = grid_param_df,
                         filename_suffix = paste0("nbo_gt_utc",time),
                         out_dir = "~/Desktop/gtt/html",
                         google_key = google_key,
                         save_params = F)
    
    Sys.sleep(5)
  }
  
  ## Make rasters
  html_files <- "~/Desktop/gtt/html" %>%
    list.files(pattern = ".html$",
               full.names = T) 
  
  time_stamps <- html_files %>% 
    str_replace_all(".html", "") %>%
    str_replace_all(".*_utc", "") %>%
    unique()
  
  for(time_i in time_stamps){
    html_files_time_i <- html_files %>%
      str_subset(time_i)
    
    r <- gt_htmls_to_raster(html_files = html_files_time_i,
                            grid_param_df = grid_param_df,
                            webshot_delay = 22)
    
    saveRDS(r, file.path("~/Desktop", paste0("nbo_gt_utc",time_i,".Rds")))
  }
  
  
  
  
  
  writeRaster(r_all, "~/Desktop/test.tiff",overwrite=TRUE)
  
  
  r_test <- mosaic(r_list[[1]],
                   #r_list[[2]],
                   #r_list[[3]],
                   r_list[[4]],
                   #r_list[[5]],
                   #r_list[[6]],
                   fun = max,
                   tolerance = 1)
  
  
  #r_test <- r_list[[2]]
  library(leaflet)
  pal <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), values(r_test),
                      na.color = "transparent")
  
  leaflet() %>% addTiles() %>%
    addRasterImage(r_test, colors = pal, opacity = 0.7) %>%
    addLegend(pal = pal, values = values(r_test),
              title = "Traffic")
  
}