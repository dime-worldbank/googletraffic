# HTML to Raster

# Converts Google HTML file to Raster
# 
# Converts a Google HTML file into a spatially referenced raster file. 
#
# @param filename HTML filename to convert into raster
# @param location Vector of latitude and longitude
# @param height Height (in pixels; pixel length depends on zoom)
# @param width Width (in pixels; pixel length depends on zoom)
# @param zoom Zoom level
# @param webshot_zoom How many pixels should be created relative to height and width values. If `height` and `width` are set to `100` and `webshot_zoom` is set to `2`, the resulting raster will have dimensions of about `200x200` (default: `1`). 
# @param webshot_delay How long to wait for .html file to load. Larger .html files (large height/widths) will require more time to fully load. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
# @param print_progress Whether to print function progress
#
# @return Returns a georeferenced raster. Raster pixels can contain the following values: 1 = no traffic; 2 = medium traffic; 3 = high traffic; 4 = heavy traffic.
gt_html_to_raster <- function(filename,
                              location,
                              height,
                              width,
                              zoom,
                              traffic_color_dist_thresh = 4.6,
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
    webshot::webshot(url = filename,
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