# Make Raster from Grid

#' Make Google Traffic Raster Based on Grid of Coordinates
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param grid_param_df Grid parameter dataframe produced from [gt_make_grid()]
#' @param google_key Google API key
#' @param traffic_color_dist_thresh Google traffic relies on four main base colors: `#63D668` for no traffic, `#FF974D` for medium traffic, `#F23C32` for high traffic, and `#811F1F` for heavy traffic. Slight variations of these colors can also represent traffic. By default, the base colors and all colors within a 2.3 color distance of each base color are used to define traffic; by default, the `CIEDE2000` formula is used to determine color distance. A value of 2.3 is one threshold used to define a "just noticeable distance" between colors. This parameter changes the color distance from the base colors used to define colors as traffic.
#' @param traffic_color_dist_metric See above; this parameter changes the formula used to calculate distances between colors. By default, `CIEDE2000` is used; `CIE76` and `CIE94` can also be used.
#' @param webshot_zoom How many pixels should be created relative to height and width values. If `height` and `width` are set to `100` and `webshot_zoom` is set to `2`, the resulting raster will have dimensions of about `200x200` (default: `1`). 
#' @param webshot_delay How long to wait for Google traffic layer to render. Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#' @param return_list_of_rasters Instead of merging traffic rasters produced for each grid together into one large raster, return a list of rasters (default: `FALSE`)
#' @param print_progress Whether to print function progress (default: `TRUE`)
#'
#' @return Returns a georeferenced raster. Raster pixels can contain the following values: 1 = no traffic; 2 = medium traffic; 3 = high traffic; 4 = heavy traffic.
#' @references Sharma, G., Wu, W., & Dalal, E. N. (2005). The CIEDE2000 color-difference formula: Implementation notes, supplementary test data, and mathematical observations. Color Research & Application: Endorsed by Inter-Society Color Council, The Colour Group (Great Britain), Canadian Society for Color, Color Science Association of Japan, Dutch Society for the Study of Color, The Swedish Colour Centre Foundation, Colour Society of Australia, Centre Français de la Couleur, 30(1), 21-30.
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
                                     traffic_color_dist_thresh = 2.3,
                                     traffic_color_dist_metric = "CIEDE2000",
                                     webshot_zoom = 1,
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
                          traffic_color_dist_thresh = traffic_color_dist_thresh,
                          traffic_color_dist_metric = traffic_color_dist_metric,
                          webshot_zoom   = webshot_zoom,
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