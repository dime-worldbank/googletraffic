#' Make Google Traffic PNG
#' 
#' Make a png file of Google traffic data. The [gt_load_png_as_traffic_raster()] function can then
#' be used to convert the png into a traffic raster
#' 
#' @param location Vector of latitude and longitude
#' @param height Height (in pixels; pixel length depends on zoom)
#' @param width Width (in pixels; pixel length depends on zoom)
#' @param zoom Zoom level; integer from 0 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param out_filename Filename of PNG file to make
#' @param google_key Google API key
#' @param webshot_delay How long to wait for Google traffic layer to render. Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`. 
#' @param print_progress Whether to print function progress (default: `TRUE`)
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#'
#' @examples
#' \dontrun{
#' gt_make_png(location     = c(40.712778, -74.006111),
#'             height       = 1000,
#'             width        = 1000,
#'             zoom         = 16,
#'             out_filename = "google_traffic.png",
#'             google_key   = "GOOGLE-KEY-HERE")
#'}
#'
#' @export
gt_make_png <- function(location,
                        height,
                        width,
                        zoom,
                        out_filename,
                        google_key,
                        webshot_delay = NULL,
                        print_progress = TRUE){
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(height, width, webshot_delay)
  
  #### Filename; as html
  filename_html <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = ".html")
  
  #### Make html
  gt_make_html(location = location,
               height = height,
               width = width,
               zoom = zoom,
               filename = filename_html,
               google_key = google_key)
  
  #### Webshot; save png
  ## Make lat/lon
  latitude  <- location[1]
  longitude <- location[2]
  
  ## Convert .html to png
  filename_root <- filename_html %>% stringr::str_replace_all(".html$", "")
  filename_only <- basename(filename_root)
  filename_dir  <- filename_root %>% stringr::str_replace_all(paste0("/", filename_only), "")
  
  if(print_progress){
    message(paste0("Pausing for ", webshot_delay, " seconds to allow traffic data to render"))
  }
  
  webshot::webshot(url = filename_html,
                   file = file.path(filename_dir, paste0(filename_only,".png")),
                   vheight = height,
                   vwidth = width,
                   cliprect = "viewport",
                   delay = webshot_delay,
                   zoom = 1)
  
  ## Read/Write png to file
  img <- png::readPNG(file.path(filename_dir, paste0(filename_only,".png")))
  png::writePNG(img, out_filename)
  
  ## Delete html file
  unlink(filename_html)
  unlink(paste0(filename_only,".png"))

  return(NULL)
}