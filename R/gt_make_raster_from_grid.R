# gt_make_raster_from_grid()

#' Make Google Traffic Raster Based on Grid of Coordinates
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param grid_param_df Grid parameter dataframe produced from \link[gt_make_grid()]{gt_make_grid}
#' @param webshot_delay How long to wait for google traffic layer to render. Larger height/widths require longer delay times.
#' @param google_key Google API key
#' @param print_progress Whether to print function progress
#' @param return_list_of_tiles Instead of merging traffic tiles together into one large tile, return a list of tiles
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_make_raster_from_grid <- function(grid_param_df,
                                     webshot_delay,
                                     google_key,
                                     return_list_of_tiles = F,
                                     print_progress = T){
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(grid_param_df$height[1], 
                                             grid_param_df$width[1],
                                             webshot_delay)
  
  ## Make list of rasters
  r_list <- lapply(1:nrow(grid_param_df), function(i){
    
    if(print_progress){
      print(paste0("Processing tile ",i," out of ",nrow(grid_param_df), 
                   "; pausing for ", webshot_delay, " seconds to allow traffic data to render"))
    } 
    
    param_i <- grid_param_df[i,]
    
    r_i <- gt_make_raster(location       = c(param_i$latitude, param_i$longitude),
                          height         = param_i$height,
                          width          = param_i$width,
                          zoom           = param_i$zoom,
                          webshot_delay  = webshot_delay,
                          google_key     = google_key,
                          print_progress = F)
    
    return(r_i)
  })
  
  if(!return_list_of_tiles){  
    if(length(r_list) > 1){
      ## Mosaic rasters together
      names(r_list)    <- NULL
      #r_list$fun       <- max
      r_list$tolerance <- 9999999
      
      r <- do.call(raster::merge, r_list)
      r[r[] %in% 0] <- NA
    } else{
      r <- r_list[[1]]
    }
  } else{
    r <- r_list
  }
  
  return(r)
}