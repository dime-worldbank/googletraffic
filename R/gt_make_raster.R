# Make Google Traffic Raster

#' Make Google Traffic Raster
#' 
#' Make a raster of [Google traffic data](https://developers.google.com/maps/documentation/javascript/trafficlayer), where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param location Vector of latitude and longitude
#' @param height Height (in pixels; pixel length depends on zoom)
#' @param width Width (in pixels; pixel length depends on zoom)
#' @param zoom Zoom level; integer from 5 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels) and [here](https://developers.google.com/maps/documentation/javascript/overview#zoom-levels).
#' @param google_key Google API key, where the [Maps JavaScript API](https://developers.google.com/maps/documentation/javascript/overview) is enabled. To create a Google API key, follow [these instructions](https://developers.google.com/maps/get-started#create-project).
#' @param traffic_color_dist_thresh Google traffic relies on four main base colors: `#63D668` for no traffic, `#FF974D` for medium traffic, `#F23C32` for high traffic, and `#811F1F` for heavy traffic. Slight variations of these colors can also represent traffic. By default, the base colors and all colors within a 4.6 color distance of each base color are used to define traffic; by default, the `CIEDE2000` metric is used to determine color distance. A value of 2.3 is one threshold used to define a "just noticeable distance" (JND) between colors (by default, 2 X JND is used). This parameter changes the color distance from the base colors used to define colors as traffic. For more information, see [here](https://en.wikipedia.org/wiki/Color_difference#CIEDE2000).
#' @param traffic_color_dist_metric See above; this parameter changes the metric used to calculate distances between colors. By default, `CIEDE2000` is used; `CIE76` and `CIE94` can also be used. For more information, see [here](https://en.wikipedia.org/wiki/Color_difference#CIEDE2000).
#' @param webshot_zoom How many pixels should be created relative to height and width values. If `height` and `width` are set to `100` and `webshot_zoom` is set to `2`, the resulting raster will have dimensions of about `200x200` (default: `1`). 
#' @param webshot_delay How long to wait for Google traffic layer to render. Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#' @param print_progress Whether to print function progress (default: `TRUE`)
#' 
#' @references Markus Hilpert, Jenni A. Shearston, Jemaleddin Cole, Steven N. Chillrud, and Micaela E. Martinez. [Acquisition and analysis of crowd-sourced traffic data](https://arxiv.org/abs/2105.12235). CoRR, abs/2105.12235, 2021.
#' @references Pavel Pokorny. [Determining traffic levels in cities using google maps](https://ieeexplore.ieee.org/abstract/document/8326831). In 2017 Fourth International Conference on Mathematics and Computers in Sciences and in Industry (MCSI), pages 144–147, 2017.
#' 
#' @return Returns a georeferenced raster. Raster pixels can contain the following values: 1 = no traffic; 2 = medium traffic; 3 = high traffic; 4 = heavy traffic.
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
#' @import ColorNameR
#' @import schemr
#' @rawNamespace import(raster, except = c(union, select, intersect))

gt_make_raster <- function(location,
                           height,
                           width,
                           zoom,
                           google_key,
                           traffic_color_dist_thresh = 4.6,
                           traffic_color_dist_metric = "CIEDE2000",
                           webshot_zoom = 1,
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
                         traffic_color_dist_thresh = traffic_color_dist_thresh,
                         traffic_color_dist_metric = traffic_color_dist_metric,
                         webshot_zoom = webshot_zoom,
                         webshot_delay = webshot_delay,
                         print_progress = print_progress)
  
  ## Delete html file
  unlink(filename_html)
  
  return(r)
}