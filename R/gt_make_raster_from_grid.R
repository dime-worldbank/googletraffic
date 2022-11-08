# Make Raster from Grid

#' Make Google Traffic Raster Based on Grid of Coordinates
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param grid_param_df Grid parameter dataframe produced from [gt_make_grid()]
#' @param google_key Google API key
#' @param webshot_delay How long to wait for Google traffic layer to render. Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#' @param return_list_of_rasters Instead of merging traffic rasters produced for each grid together into one large raster, return a list of rasters (default: `FALSE`)
#' @param print_progress Whether to print function progress (default: `TRUE`)
#'
#' @return Returns a georeferenced raster. Raster pixels can contain the following values: 1 = no traffic; 2 = medium traffic; 3 = high traffic; 4 = heavy traffic.
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
                                     return_list_of_rasters = FALSE,
                                     print_progress = TRUE){
  
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(grid_param_df$height[1], 
                                             grid_param_df$width[1],
                                             webshot_delay)
  
  ## Make list of rasters
  r_list <- lapply(1:nrow(grid_param_df), function(i){
    
    if(print_progress){
      message(paste0("Processing grid / API query ",i," out of ",nrow(grid_param_df), 
                     "; pausing for ", webshot_delay, " seconds to allow traffic data to render"))
    } 
    
    param_i <- grid_param_df[i,]
    
    r_i <- gt_make_raster(location       = c(param_i$latitude, param_i$longitude),
                          height         = param_i$height,
                          width          = param_i$width,
                          zoom           = param_i$zoom,
                          webshot_delay  = webshot_delay,
                          google_key     = google_key,
                          print_progress = FALSE)
    
    return(r_i)
  })
  
  if(!return_list_of_rasters){  
    if(length(r_list) > 1){
      
      r <- gt_mosaic(r_list)
      
    } else{
      r <- r_list[[1]]
    }
  } else{
    r <- r_list
  }
  
  return(r)
}