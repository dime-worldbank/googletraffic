#' Make Google Traffic PNG
#' 
#' Make a raster from Google traffic data, where each pixel has one of four values
#' indicating traffic volume (no traffic, light, moderate, and heavy).
#' 
#' @param location Vector of latitude and longitude
#' @param height Height
#' @param width Width
#' @param zoom Zoom level; integer from 0 to 20. For more information, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param webshot_delay How long to wait for google traffic layer to render. Larger height/widths require longer delay times.
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_make_png <- function(location,
                        height,
                        width,
                        zoom,
                        webshot_delay,
                        google_key,
                        out_filename){
  
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
  latitude = location[1]
  longitude = location[2]
  
  ## Convert .html to png
  filename_root <- filename_html %>% str_replace_all(".html$", "")
  filename_only <- basename(filename_root)
  filename_dir <- filename_root %>% str_replace_all(paste0("/", filename_only), "")
  
  current_dir <- getwd()
  
  setwd(filename_dir)
  webshot(paste0(filename_only,".html"),
          file = paste0(filename_only,".png"),
          vheight = height,
          vwidth = width,
          cliprect = "viewport",
          delay = webshot_delay,
          zoom = 1)
  
  ## Read/Write png to file
  img <- readPNG(file.path(paste0(filename_only,".png")))
  writePNG(img, out_filename)
  
  ## Delete html file
  unlink(filename_html)
  unlink(paste0(filename_only,".html"))
  unlink(paste0(filename_only,".png"))
  unlink(paste0(filename_only,".Rds"))
  
  setwd(current_dir)
  
  return(NULL)
}