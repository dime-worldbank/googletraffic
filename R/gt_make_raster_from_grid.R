#' Make Google Traffic Raster Based on Grid of Coordinates
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param grid_param_df Grid parameter dataframe produced from `gt_make_point_grid`
#' @param webshot_delay How long to wait for google traffic layer to render. Larger height/widths require longer delay times.
#' @param print_progress Show progress for which tile has been processed.
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_make_raster_from_grid <- function(grid_param_df,
                                     webshot_delay,
                                     google_key,
                                     print_progress = T){
  
  ## Make list of rasters
  r_list <- lapply(1:nrow(grid_param_df), function(i){
    
    if(print_progress){
      print(paste0("Processing tile ",i," out of ",nrow(grid_param_df)))
    } 
    
    param_i <- grid_param_df[i,]
    
    r_i <- gt_make_raster(location      = c(param_i$latitude, param_i$longitude),
                          height        = param_i$height,
                          width         = param_i$width,
                          zoom          = param_i$zoom,
                          webshot_delay = webshot_delay,
                          google_key    = google_key)
    
    return(r_i)
  })
  
  ## Mosaic rasters together
  names(r_list)    <- NULL
  r_list$fun       <- max
  r_list$tolerance <- 1
  
  r <- do.call(raster::mosaic, r_list)
  r[r[] %in% 0] <- NA
  
  return(r)
}