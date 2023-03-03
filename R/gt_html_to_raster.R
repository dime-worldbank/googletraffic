# HTML to Raster

# Converts Google HTML file to Raster
# 
# Converts a Google HTML file into a spatially referenced raster file. 
#
# @param filename HTML filename to convert into raster
# @param location Vector of latitude and longitude
# @param height Height (in pixels; pixel length depends on zoom)
# @param width Width (in pixels; pixel length depends on zoom)
# @param zoom Zoom level; integer from 5 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels) and [here](https://developers.google.com/maps/documentation/javascript/overview#zoom-levels).
# @param traffic_color_dist_thresh Google traffic relies on four main base colors: `#63D668` for no traffic, `#FF974D` for medium traffic, `#F23C32` for high traffic, and `#811F1F` for heavy traffic. Slight variations of these colors can also represent traffic. By default, the base colors and all colors within a 2.3 color distance of each base color are used; by default, the `CIEDE2000` formula is used to determine color distance. A value of 2.3 is one threshold used to define a "just noticeable distance" between colors. This parameter changes the color distance from the base colors used to define colors as traffic.
# @param traffic_color_dist_metric See above; this parameter changes the formula used to calculate distances between colors. By default, `CIEDE2000` is used; `CIE76` and `CIE94` can also be used.
# @param webshot_zoom How many pixels should be created relative to height and width values. If `height` and `width` are set to `100` and `webshot_zoom` is set to `2`, the resulting raster will have dimensions of about `200x200` (default: `1`). 
# @param webshot_delay How long to wait for .html file to load. Larger .html files (large height/widths) will require more time to fully load. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
# @param print_progress Whether to print function progress
#
# @return Returns a georeferenced raster. Raster pixels can contain the following values: 1 = no traffic; 2 = medium traffic; 3 = high traffic; 4 = heavy traffic.
# @references Sharma, G., Wu, W., & Dalal, E. N. (2005). The CIEDE2000 color-difference formula: Implementation notes, supplementary test data, and mathematical observations. Color Research & Application: Endorsed by Inter-Society Color Council, The Colour Group (Great Britain), Canadian Society for Color, Color Science Association of Japan, Dutch Society for the Study of Color, The Swedish Colour Centre Foundation, Colour Society of Australia, Centre Français de la Couleur, 30(1), 21-30.
gt_html_to_raster <- function(filename,
                              location,
                              height,
                              width,
                              zoom,
                              traffic_color_dist_thresh = 2.3,
                              traffic_color_dist_metric = "CIEDE2000",
                              webshot_zoom = 1,
                              webshot_delay = NULL,
                              print_progress = TRUE){
  
  #### Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(height, width, webshot_delay)
  
  #### Make lat/lon from location vector
  latitude  <- location[1]
  longitude <- location[2]
  
  #### Convert .html to png
  filename_root <- filename %>% str_replace_all(".html$", "")
  filename_only <- basename(filename_root)
  filename_dir  <- filename_root %>% 
    stringr::str_replace_all(paste0("/", filename_only), "")
  
  if(print_progress){
    cat(paste0("Pausing for ", webshot_delay, " seconds to allow traffic data to render"))
  }
  
  # Gives a warning referencing lengths/logical that can be ignored
  # In is.null(x) || is.na(x) : 'length(x) = 4 > 1' in coercion to 'logical(1)'
  suppressWarnings({
    webshot2::webshot(url = filename,
                     file = file.path(filename_dir, paste0(filename_only,".png")),
                     vheight = height,
                     vwidth = width,
                     cliprect = "viewport",
                     delay = webshot_delay,
                     zoom = webshot_zoom) # change
  })
  
  #### Load as raster and image
  png_filename <- file.path(filename_dir, paste0(filename_only, ".png"))
  
  r <- gt_load_png_as_traffic_raster(filename = png_filename,
                                     location = c(latitude, longitude),
                                     height   = height,
                                     width    = width,
                                     zoom     = zoom,
                                     traffic_color_dist_thresh = traffic_color_dist_thresh,
                                     traffic_color_dist_metric = traffic_color_dist_metric)
  
  ## Delete png from temp file
  unlink(file.path(filename_dir, paste0(filename_only,".png")))
  
  return(r)
}