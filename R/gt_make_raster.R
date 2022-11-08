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
#' @param webshot_delay How long to wait for Google traffic layer to render. Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#' @param print_progress Whether to print function progress (default: `TRUE`)
#'
#' @return Returns a georeferenced raster. Raster pixels can contain the following values: 1 = no traffic; 2 = medium traffic; 3 = high traffic; 4 = heavy traffic.
#' 
#' @examples
#' \dontrun{
#' r <- gt_make_raster(location   = c(40.712778, -74.006111),
#'                     height     = 1000,
#'                     width      = 1000,
#'                     zoom       = 16,
#'                     google_key = "GOOGLE-KEY-HERE")
#'}
#' 
#' @export
#' @import dplyr
#' @import googleway
#' @import htmlwidgets
#' @import plotwidgets
#' @import png
#' @import sf
#' @import sp
#' @import stringr
#' @import webshot
#' @rawNamespace import(raster, except = c(union, select, intersect))

gt_make_raster <- function(location,
                           height,
                           width,
                           zoom,
                           google_key,
                           webshot_delay = NULL,
                           print_progress = TRUE){
  
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