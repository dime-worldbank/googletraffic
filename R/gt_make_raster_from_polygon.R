# Make Raster from Polygon

#' Make Google Traffic Raster Based on Polygon
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param polygon Polygon (`sf` object or `SpatialPolygonsDataframe`) in WGS84 CRS
#' @param zoom Zoom level; integer from 0 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param google_key Google API key
#' @param height_width_max Maximum pixel height and width to check using for each API query (pixel length depends on zoom). If the same number of API queries can be made with a smaller height/width, the function will use a smaller height/width. If `height` and `width` are specified, that height and width will be used and `height_width_max` will be ignored. (Default: `2000`) 
#' @param height Height, in pixels, for each API query (pixel length depends on zoom). Enter a `height` to manually specify the height; otherwise, a height of `height_width_max` or smaller will be used.
#' @param width Pixel, in pixels, for each API query (pixel length depends on zoom). Enter a `width` to manually specify the width; otherwise, a width of `height_width_max` or smaller will be used.
#' @param webshot_delay How long to wait for Google traffic layer to render (in seconds). Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#' @param reduce_hw Number of pixels to reduce height/width by. Doing so creates some overlap between grids to ensure there is not blank space between tiles. (Default: `10`).
#' @param return_list_of_rasters Whether to return a list of raster tiles instead of mosaicing together. (Default: `FALSE`).
#' @param mask_to_polygon Whether to mask raster to `polygon`. (Default: `TRUE`).
#' @param print_progress Show progress for which grid / API query has been processed. (Default: `TRUE`).
#'
#' @return Returns a georeferenced raster. Raster pixels can contain the following values: 1 = no traffic; 2 = medium traffic; 3 = high traffic; 4 = heavy traffic.
#' 
#' @examples
#' \dontrun{
#' ## Grab polygon of Manhattan
#' us_sp <- raster::getData('GADM', country='USA', level=2)
#' ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]
#'
#' ## Make raster
#' r <- gt_make_raster_from_polygon(polygon    = ny_sp,
#'                                  height     = 2000,
#'                                  width      = 2000,
#'                                  zoom       = 16,
#'                                  google_key = "GOOGLE-KEY-HERE")
#'} 
#'
#' @export
gt_make_raster_from_polygon <- function(polygon,
                                        zoom,
                                        google_key,
                                        height_width_max = 2000,
                                        height = NULL,
                                        width = NULL,
                                        webshot_delay = NULL,
                                        reduce_hw = 10,
                                        return_list_of_rasters = FALSE,
                                        mask_to_polygon = TRUE,
                                        print_progress = TRUE){
  
  
  grid_param_df <- gt_make_grid(polygon          = polygon,
                                zoom             = zoom,
                                height_width_max = height_width_max,
                                height           = height,
                                width            = width,
                                reduce_hw        = reduce_hw)
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(grid_param_df$height[1], 
                                             grid_param_df$width[1], 
                                             webshot_delay)
  
  if(print_progress){
    message(paste0("Raster will be created from ",
                   nrow(grid_param_df),
                   " Google traffic tiles."))
  }
  
  r <- gt_make_raster_from_grid(grid_param_df  = grid_param_df,
                                webshot_delay  = webshot_delay,
                                google_key     = google_key,
                                return_list_of_rasters = return_list_of_rasters,
                                print_progress = print_progress)
  
  if(mask_to_polygon & !return_list_of_rasters){
    r <- r %>%
      raster::crop(polygon) %>%
      raster::mask(polygon)
  }
  
  if(mask_to_polygon & return_list_of_rasters){
    
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
