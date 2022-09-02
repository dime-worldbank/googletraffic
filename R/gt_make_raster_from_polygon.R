# Make Raster from Polygon

#' Make Google Traffic Raster Based on Polygon
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param polygon Polygon (`sf` object or `SpatialPolygonsDataframe`) in WGS84 CRS
#' @param height Height (in pixels; pixel length depends on zoom)
#' @param width Width (in pixels; pixel length depends on zoom)
#' @param zoom Zoom level; integer from 0 to 20. For more information, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param google_key Google API key
#' @param webshot_delay How long to wait for google traffic layer to render. Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#' @param reduce_hw Number of pixels to reduce height/width by. Doing so creates some overlap between tiles to ensure there is not blank space between tiles (default: 10).
#' @param return_list_of_tiles Whether to return a list of raster tiles instead of mosaicing together (default: `FALSE`).
#' @param mask_to_polygon Whether to mask raster to `polygon` (default: `TRUE`).
#' @param print_progress Show progress for which tile has been processed (default: `TRUE`).
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_make_raster_from_polygon <- function(polygon,
                                        height,
                                        width,
                                        zoom,
                                        google_key,
                                        webshot_delay = NULL,
                                        reduce_hw = 10,
                                        return_list_of_tiles = F,
                                        mask_to_polygon = T,
                                        print_progress = T){
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(height, width, webshot_delay)
  
  grid_param_df <- gt_make_grid(polygon   = polygon,
                                height    = height,
                                width     = width,
                                zoom      = zoom,
                                reduce_hw = reduce_hw)
  
  if(print_progress){
    message(paste0("Raster will be created from ",
                   nrow(grid_param_df),
                   " Google traffic tiles."))
  }
  
  r <- gt_make_raster_from_grid(grid_param_df  = grid_param_df,
                                webshot_delay  = webshot_delay,
                                google_key     = google_key,
                                return_list_of_tiles = return_list_of_tiles,
                                print_progress = print_progress)
  
  if(mask_to_polygon & !return_list_of_tiles){
    r <- r %>%
      raster::crop(polygon) %>%
      raster::mask(polygon)
  }
  
  if(mask_to_polygon & return_list_of_tiles){
    
    if("SpatialPolygonsDataFrame" %in% class(polygon)){
      polygon <- polygon %>% sf::st_as_sf()
    }
    
    for(i in 1:length(r)){
      if(print_progress){
        message(paste0("Cropping tile ", i, " of ", length(r)))
      }
      
      ## Check intersection using planar geometry
      sf_use_s2_default <- sf::sf_use_s2()
      
      sf::sf_use_s2(FALSE)
      inter_df <- sf::st_intersects(r[[i]] %>% sf::st_bbox() %>% sf::st_as_sfc(),
                                    polygon %>% sf::st_bbox() %>% sf::st_as_sfc(),
                                    sparse = F)[1]
      sf::sf_use_s2(sf_use_s2_default)
      
      ## Could also use rgeos approach
      # inter_df <- gIntersects(r[[i]] %>% st_bbox() %>% st_as_sfc() %>% as("Spatial"), 
      #                         polygon %>% st_bbox() %>% st_as_sfc() %>% as("Spatial"))
      
      if(inter_df){
        
        r[[i]] <- r[[i]] %>% 
          raster::crop(polygon) %>% 
          raster::mask(polygon)
        
      } else{
        r[[i]] <- NA
      }
    }
    
    r <- r[!is.na(r)]
  }
  
  return(r)
}
