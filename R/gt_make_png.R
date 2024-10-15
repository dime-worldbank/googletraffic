#' Make Google Traffic PNG
#' 
#' Make a png file of [Google traffic data](https://developers.google.com/maps/documentation/javascript/trafficlayer). The [gt_load_png_as_traffic_raster()] function can then
#' be used to convert the png into a traffic raster
#' 
#' @param location Vector of latitude and longitude
#' @param height Height (in pixels; pixel length depends on zoom)
#' @param width Width (in pixels; pixel length depends on zoom)
#' @param zoom Zoom level; integer from 5 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels) and [here](https://developers.google.com/maps/documentation/javascript/overview#zoom-levels).
#' @param out_filename Filename of PNG file to make
#' @param google_key Google API key, where the [Maps JavaScript API](https://developers.google.com/maps/documentation/javascript/overview) is enabled. To create a Google API key, follow [these instructions](https://developers.google.com/maps/get-started#create-project).
#' @param webshot_zoom How many pixels should be created relative to height and width values. If `height` and `width` are set to `100` and `webshot_zoom` is set to `2`, the resulting raster will have dimensions of about `200x200` (default: `1`). 
#' @param webshot_delay How long to wait for Google traffic layer to render. Larger height/widths require longer delay times. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`. 
#' @param print_progress Whether to print function progress (default: `TRUE`)
#'
#' @return Returns a PNG file showing traffic levels.
#' 
#' @references Markus Hilpert, Jenni A. Shearston, Jemaleddin Cole, Steven N. Chillrud, and Micaela E. Martinez. [Acquisition and analysis of crowd-sourced traffic data](https://arxiv.org/abs/2105.12235). CoRR, abs/2105.12235, 2021.
#' @references Pavel Pokorny. [Determining traffic levels in cities using google maps](https://ieeexplore.ieee.org/abstract/document/8326831). In 2017 Fourth International Conference on Mathematics and Computers in Sciences and in Industry (MCSI), pages 144–147, 2017.
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
                        webshot_zoom = 1,
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
  #filename_dir  <- tempdir() # filename_root %>% stringr::str_replace_all(paste0("/", filename_only), "")
  filename_dir  <- filename_root %>% 
    stringr::str_replace_all(filename_only, "") %>%
    stringr::str_sub(end = -2)
  
  message("test123")
  
  if(print_progress){
    message(paste0("Pausing for ", webshot_delay, " seconds to allow traffic data to render"))
  }
  
  #### Approach 1
  suppressWarnings({
    webshot2::webshot(url = filename_html,
                      file = file.path(filename_dir, paste0(filename_only,".png")),
                      vheight = height,
                      vwidth = width,
                      cliprect = "viewport",
                      delay = webshot_delay,
                      zoom = webshot_zoom)
  })
  
  #### Approach 2
  ## Check if the PNG is blank
  img <- png::readPNG(file.path(filename_dir, paste0(filename_only,".png")))
  
  if (all(img == 1)) {
    
    chrome_path <- Sys.which("chrome")
    if (chrome_path != "") {
      system2(chrome_path, 
              args = c("--headless", "--disable-gpu", "--screenshot", 
                       paste0("--window-size=", width, ",", height),
                       "--default-background-color=0",
                       filename_html),
              stdout = TRUE,
              stderr = TRUE)
      
      # Move the screenshot to the desired location
      file.rename("screenshot.png", file.path(filename_dir, paste0(filename_only,".png")))
      
    }
  }
  
  ## Read/Write png to file
  img <- png::readPNG(file.path(filename_dir, paste0(filename_only,".png")))
  png::writePNG(img, out_filename)
  
  ## Delete html file
  unlink(filename_html)
  unlink(paste0(filename_only,".png"))
  
  return(NULL)
}