#' @import dplyr
#' @import googleway
#' @import htmlwidgets
#' @import webshot
#' @import raster
#' @import png
#' @import plotwidgets
#' @import httr
#' @import sp
#' @import sf
#' @import stringr

if(F){
  roxygen2::roxygenise("~/Documents/Github/googletraffic")
}

# Make Google Traffic Raster

#' Make Google Traffic Raster
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param location Vector of latitude and longitude
#' @param height Height (in pixels; pixel length depends on zoom)
#' @param width Width (in pixels; pixel length depends on zoom)
#' @param zoom Zoom level; integer from 0 to 20. For more information, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param google_key Google API key
#' @param webshot_delay How long to wait for google traffic layer to render. Larger height/widths require longer delay times.
#' @param print_progress Whether to print function progress
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_make_raster <- function(location,
                           height,
                           width,
                           zoom,
                           google_key,
                           webshot_delay = NULL,
                           print_progress = T){
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(height, width, webshot_delay)
  
  ## Filename; as html
  filename_html <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = ".html")
  
  ## Make html
  gt_make_html(location = location,
               height = height,
               width = width,
               zoom = zoom,
               filename = filename_html,
               google_key = google_key)
  
  ## Make raster
  r <- gt_html_to_raster(filename = filename_html,
                         location = location,
                         height = height,
                         width = width,
                         zoom = zoom,
                         webshot_delay = webshot_delay,
                         print_progress = print_progress)
  
  ## Delete html file
  unlink(filename_html)
  
  return(r)
}