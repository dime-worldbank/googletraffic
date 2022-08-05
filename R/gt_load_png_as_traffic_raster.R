#' Converts png to raster
#'
#' Converts PNG to raster and translates color values to traffic values
#'
#' @param img PNG object from `readPNG`
#'
#' @return Returns a raster
gt_load_png_as_traffic_raster <- function(filename,
                                          latitude,
                                          longitude,
                                          height,
                                          width,
                                          zoom){
  
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
    mutate(color = case_when(#((H == 0) & (S < 0.2)) ~ "background",
      ((H == 0) & (S >= 0.28) & (S < 0.7) & (L >= 0.3) & (L <= 0.42)) ~ "dark-red",
      H > 0 & H <= 5 & L <= 0.65 ~ "red", # L <= 0.80
      H >= 20 & H <= 28 & L <= 0.80 ~ "orange", # L <= 0.85
      H >= 120 & H <= 135 & L <= 0.80 ~ "green"))
  
  ## Apply traffic colors to raster
  colors_unique <- colors_df$color %>% unique()
  colors_unique <- colors_unique[!is.na(colors_unique)]
  colors_unique <- colors_unique[!(colors_unique %in% "background")]
  rimg <- matrix(rimg) #%>% raster::t() #%>% base::t()
  for(color_i in colors_unique){
    rimg[rimg %in% colors_df$hex[colors_df$color %in% color_i]] <- color_i
  }
  
  r[] <- NA
  r[rimg %in% "green"]    <- 1
  r[rimg %in% "orange"]   <- 2
  r[rimg %in% "red"]      <- 3
  r[rimg %in% "dark-red"] <- 4
  
  ## Spatially define raster
  extent(r) <- gt_make_extent(latitude,
                              longitude,
                              height,
                              width,
                              zoom)
  
  crs(r) <- CRS("+init=epsg:4326")
  
  return(r)
}