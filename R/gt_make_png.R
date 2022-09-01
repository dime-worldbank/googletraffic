#' Make Google Traffic PNG
#' 
#' Make a png file of Google traffic data. The `gt_load_png_as_traffic_raster()` function can then
#' be used to convert the png into a traffic raster
#' 
#' @param location Vector of latitude and longitude
#' @param height Height (in pixels; pixel length depends on zoom)
#' @param width Width (in pixels; pixel length depends on zoom)
#' @param zoom Zoom level; integer from 0 to 20. For more information, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param webshot_delay How long to wait for google traffic layer to render. Larger height/widths require longer delay times.
#' @param google_key Google API key
#' @param out_filename Filename/path of png file to make
#' @param print_progress Whether to print function progress
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_make_png <- function(location,
                        height,
                        width,
                        zoom,
                        webshot_delay,
                        google_key,
                        out_filename,
                        print_progress = T){
  
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
  
  current_dir <- getwd()
  
  setwd(filename_dir)
  
  if(print_progress){
    cat(paste0("Pausing for ", webshot_delay, " seconds to allow traffic data to render"))
  }
  
  webshot::webshot(paste0(filename_only,".html"),
                   file = paste0(filename_only,".png"),
                   vheight = height,
                   vwidth = width,
                   cliprect = "viewport",
                   delay = webshot_delay,
                   zoom = 1)
  
  ## Read/Write png to file
  img <- png::readPNG(file.path(paste0(filename_only,".png")))
  png::writePNG(img, out_filename)
  
  ## Delete html file
  unlink(filename_html)
  unlink(paste0(filename_only,".html"))
  unlink(paste0(filename_only,".png"))
  unlink(paste0(filename_only,".Rds"))
  
  setwd(current_dir)
  
  return(NULL)
}