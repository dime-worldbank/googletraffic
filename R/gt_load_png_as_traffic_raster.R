# Load .png as Traffic Raster

#' Converts PNG to raster
#'
#' Converts PNG of Google traffic data to raster and translates color values to traffic values
#'
#' @param filename Filename of PNG file
#' @param location Vector of latitude and longitude used to create PNG file using [gt_make_png()]
#' @param height Height (in pixels; pixel length depends on zoom) used to create PNG file using [gt_make_png()]
#' @param width Width (in pixels; pixel length depends on zoom) used to create PNG file using [gt_make_png()]
#' @param zoom Zoom used to PNG png file using [gt_make_png()]
#'
#' @return Returns a raster where each pixel represents traffic level (1 = no traffic, 2 = medium traffic, 3 = traffic delays, 4 = heavy traffic)
#'
#' @examples 
#' \dontrun{
#' ## Make png
#' gt_make_png(location     = c(40.712778, -74.006111),
#'             height       = 1000,
#'             width        = 1000,
#'             zoom         = 16,
#'             out_filename = "google_traffic.png",
#'             google_key   = "GOOGLE-KEY-HERE")
#' 
#' ## Load png as traffic raster
#' r <- gt_load_png_as_traffic_raster(filename = "google_traffic.png",
#'                                    location = c(40.712778, -74.006111),
#'                                    height   = 1000,
#'                                    width    = 1000,
#'                                    zoom     = 16)
#'}                                    
#'
#' @export
gt_load_png_as_traffic_raster <- function(filename,
                                          location,
                                          height,
                                          width,
                                          zoom){
  
  # Code produces some warnings that are not relevant; for example, when initially
  # make a raster, we get a warning that the extent is not defined. This warning
  # can be ignored as the extent is defined later.
  suppressWarnings({
    
    #### Set latitude and longitude
    latitude  <- location[1]
    longitude <- location[2]
    
    #### Load
    r   <- raster::raster(filename,1)
    img <- png::readPNG(filename)
    
    #### Assign traffic colors 
    ## Image to hex
    rimg <- raster::as.raster(img) 
    
    colors_df <- rimg %>% 
      table() %>% 
      as.data.frame() %>%
      dplyr::rename(hex = ".")
    
    colors_df$hex <- colors_df$hex %>% 
      as.character()
    
    ## Assign traffic colors based on hsl
    hsl_df <- colors_df$hex %>% 
      plotwidgets::col2hsl() %>%
      t() %>%
      as.data.frame() 
    
    colors_df <- dplyr::bind_cols(colors_df, hsl_df)
    
    colors_df <- colors_df %>%
      dplyr::mutate(color = case_when(#((H == 0) & (S < 0.2)) ~ "background",
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
    ext_4326 <- gt_make_extent(latitude = latitude,
                               longitude = longitude,
                               height = height,
                               width = width,
                               zoom = zoom)
    
    # Project extent to 3857
    ext_3857 <- ext_4326 %>% 
      sf::st_bbox() %>% 
      sf::st_as_sfc() 
    
    sf::st_crs(ext_3857) <- 4326
    
    ext_3857 <- ext_3857 %>%
      sf::st_transform(3857) %>% 
      sf::st_bbox() %>% 
      raster::extent()
    
    raster::extent(r) <- ext_3857
    
    raster::crs(r) <- sp::CRS("+init=epsg:3857")
    
    ## Convert to EPSG:4326
    r <- raster::projectRaster(r, crs = CRS("+init=epsg:4326"), method = "ngb")
    
  })
  
  return(r)
}
