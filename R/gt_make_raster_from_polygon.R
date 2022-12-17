# Make Raster from Polygon

#' Make Google Traffic Raster Based on Polygon
#' 
#' Make a raster of [Google traffic data](https://developers.google.com/maps/documentation/javascript/trafficlayer), where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param polygon Polygon (`sf` object or `SpatialPolygonsDataframe`) in WGS84 CRS
#' @param zoom Zoom level; integer from 5 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels) and [here](https://developers.google.com/maps/documentation/javascript/overview#zoom-levels).
#' @param google_key Google API key, where the [Maps JavaScript API](https://developers.google.com/maps/documentation/javascript/overview) is enabled. To create a Google API key, follow [these instructions](https://developers.google.com/maps/get-started#create-project).
#' @param height_width_max Maximum pixel height and width to check using for each API query (pixel length depends on zoom). If the same number of API queries can be made with a smaller height/width, the function will use a smaller height/width. If `height` and `width` are specified, that height and width will be used and `height_width_max` will be ignored. (Default: `2000`) 
#' @param height Height, in pixels, for each API query (pixel length depends on zoom). Enter a `height` to manually specify the height; otherwise, a height of `height_width_max` or smaller will be used.
#' @param width Pixel, in pixels, for each API query (pixel length depends on zoom). Enter a `width` to manually specify the width; otherwise, a width of `height_width_max` or smaller will be used.
#' @param traffic_color_dist_thresh Google traffic relies on four main base colors: `#63D668` for no traffic, `#FF974D` for medium traffic, `#F23C32` for high traffic, and `#811F1F` for heavy traffic. Slight variations of these colors can also represent traffic. By default, the base colors and all colors within a 4.6 color distance of each base color are used to define traffic; by default, the `CIEDE2000` metric is used to determine color distance. A value of 2.3 is one threshold used to define a "just noticeable distance" (JND) between colors (by default, 2 X JND is used). This parameter changes the color distance from the base colors used to define colors as traffic. For more information, see [here](https://en.wikipedia.org/wiki/Color_difference#CIEDE2000).
#' @param traffic_color_dist_metric See above; this parameter changes the metric used to calculate distances between colors. By default, `CIEDE2000` is used; `CIE76` and `CIE94` can also be used. For more information, see [here](https://en.wikipedia.org/wiki/Color_difference#CIEDE2000).
#' @param webshot_zoom How many pixels should be created relative to height and width values. If `height` and `width` are set to `100` and `webshot_zoom` is set to `2`, the resulting raster will have dimensions of about `200x200` (default: `1`). 
#' @param webshot_delay How long to wait for Google traffic layer to render (in seconds). Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#' @param reduce_hw Number of pixels to reduce height/width by. Doing so creates some overlap between grids to ensure there is not blank space between tiles. (Default: `10`).
#' @param return_list_of_rasters Whether to return a list of raster tiles instead of mosaicing together. (Default: `FALSE`).
#' @param mask_to_polygon Whether to mask raster to `polygon`. (Default: `TRUE`).
#' @param print_progress Show progress for which grid / API query has been processed. (Default: `TRUE`).
#'
#' @references Markus Hilpert, Jenni A. Shearston, Jemaleddin Cole, Steven N. Chillrud, and Micaela E. Martinez. [Acquisition and analysis of crowd-sourced traffic data](https://arxiv.org/abs/2105.12235). CoRR, abs/2105.12235, 2021.
#' @references Pavel Pokorny. [Determining traffic levels in cities using google maps](https://ieeexplore.ieee.org/abstract/document/8326831). In 2017 Fourth International Conference on Mathematics and Computers in Sciences and in Industry (MCSI), pages 144–147, 2017.
#'
#' @return Returns a georeferenced raster. Raster pixels can contain the following values: 1 = no traffic; 2 = medium traffic; 3 = high traffic; 4 = heavy traffic.
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
                                        traffic_color_dist_thresh = 4.6,
                                        traffic_color_dist_metric = "CIEDE2000",
                                        webshot_zoom = 1,
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
                                traffic_color_dist_thresh = traffic_color_dist_thresh,
                                traffic_color_dist_metric = traffic_color_dist_metric,
                                webshot_zoom   = webshot_zoom,
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
