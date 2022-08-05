#' Make Google Traffic Raster Based on Polygon
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param polygon `SpatialPolygonsDataframe` in WGS84 CRS.
#' @param height Height
#' @param width Width
#' @param zoom Zoom level; integer from 0 to 20. For more information, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param webshot_delay How long to wait for google traffic layer to render. Larger height/widths require longer delay times.
#' @param reduce_hw Number of pixels to reduce height/width by. The tiles produced by the function may not exactly overlap. Reducing the height and width ensures overlap to eventually remove any blank space.
#' @param print_progress Show progress for which tile has been processed.
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_make_raster_from_polygon <- function(polygon,
                                        height,
                                        width,
                                        zoom,
                                        webshot_delay,
                                        google_key,
                                        reduce_hw = 10,
                                        crop_to_polygon = T,
                                        print_progress = T){
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(height, width, webshot_delay)
  
  grid_param_df <- gt_make_point_grid(polygon   = polygon,
                                      height    = height,
                                      width     = width,
                                      zoom      = zoom,
                                      reduce_hw = reduce_hw)
  
  if(print_progress){
    print(paste0("Raster will be created from ",
                 nrow(grid_param_df),
                 " Google traffic tiles."))
  }
  
  r <- gt_make_raster_from_grid(grid_param_df = grid_param_df,
                                webshot_delay = webshot_delay,
                                google_key    = google_key)
  
  if(crop_to_polygon){
    r <- r %>%
      crop(polygon) %>%
      mask(polygon)
  }
  
  return(r)
}