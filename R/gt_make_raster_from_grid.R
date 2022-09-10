# Make Raster from Grid

#' Make Google Traffic Raster Based on Grid of Coordinates
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param grid_param_df Grid parameter dataframe produced from \link[gt_make_grid()]{`gt_make_grid()`}
#' @param google_key Google API key
#' @param webshot_delay How long to wait for google traffic layer to render. Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#' @param print_progress Whether to print function progress
#' @param return_list_of_tiles Instead of merging traffic tiles together into one large tile, return a list of tiles
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' 
#' @examples
#' \dontrun{
#' ## Grab polygon of Manhattan
#' us_sp <- raster::getData('GADM', country='USA', level=2)
#' ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]
#'
#' ## Make Grid
#' grid_df <- gt_make_grid(polygon = ny_sp,
#'                        height   = 2000,
#'                        width    = 2000,
#'                        zoom     = 16)
#'
#' ## Make raster from grid                        
#' r <- gt_make_raster_from_grid(grid_param_df = grid_clean_df,
#'                               google_key    = "GOOGLE-KEY-HERE")
#'}
#' 
#' @export
gt_make_raster_from_grid <- function(grid_param_df,
                                     google_key,
                                     webshot_delay = NULL,
                                     return_list_of_tiles = F,
                                     print_progress = T){
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(grid_param_df$height[1], 
                                             grid_param_df$width[1],
                                             webshot_delay)
  
  ## Make list of rasters
  r_list <- lapply(1:nrow(grid_param_df), function(i){
    
    if(print_progress){
      message(paste0("Processing tile ",i," out of ",nrow(grid_param_df), 
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
      
      r <- gt_mosaic(r_list)
      
      # ## Make template raster
      # r_list_temp <- r_list
      # 
      # names(r_list_temp)    <- NULL
      # r_list_temp$tolerance <- 9999999
      # 
      # r_temp <- do.call(raster::merge, r_list_temp)
      # r_temp[] <- NA
      # 
      # ## Resample to template
      # for(i in 1:length(r_list)) r_list[[i]] <- raster::resample(r_list[[i]], 
      #                                                            r_temp, 
      #                                                            method = "ngb")
      # 
      # ## Mosaic rasters together
      # names(r_list)    <- NULL
      # r_list$fun       <- max
      # r_list$tolerance <- 999
      # 
      # r <- do.call(raster::mosaic, r_list) 
      
      #r[r[] %in% 0] <- NA
      
    } else{
      r <- r_list[[1]]
    }
  } else{
    r <- r_list
  }
  
  return(r)
}