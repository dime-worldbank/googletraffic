# gt_html_to_raster()

#' Converts Google HTML file to Raster
#' 
#' Converts a Google HTML file into a spatially referenced raster file. 
#'
#' @param filename HTML filename to convert into raster
#' @param location Vector of latitude and longitude
#' @param height Height
#' @param width Width
#' @param zoom Zoom level
#' @param webshot_delay How long to wait for .html file to load. Larger .html files will require more time to fully load. If `NULL`, the following delay time (in seconds) is used: `delay = max(height,width)/200`.
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_html_to_raster <- function(filename,
                              location,
                              height,
                              width,
                              zoom,
                              webshot_delay = NULL){
  
  #### Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(height, width, webshot_delay)
  
  #### Make lat/lon from location vector
  latitude  <- location[1]
  longitude <- location[2]
  
  #### Convert .html to png
  filename_root <- filename %>% str_replace_all(".html$", "")
  filename_only <- basename(filename_root)
  filename_dir <- filename_root %>% str_replace_all(paste0("/", filename_only), "")
  
  # webshot() exports into current directory, so need to set working directory
  # to directory where the html file is located. We grab the current directory
  # so we can switch the directory back.
  current_dir <- getwd()
  
  setwd(filename_dir)
  
  webshot(paste0(filename_only,".html"),
          file = paste0(filename_only,".png"),
          vheight = height,
          vwidth = width,
          cliprect = "viewport",
          delay = webshot_delay,
          zoom = 1)
  
  #### Load as raster and image
  png_filename <- file.path(filename_dir, paste0(filename_only, ".png"))
  
  r <- gt_load_png_as_traffic_raster(png_filename,
                                     latitude,
                                     longitude,
                                     height,
                                     width,
                                     zoom)
  
  ## Delete png from temp file
  unlink(file.path(filename_dir, paste0(filename_only,".png")))
  
  setwd(current_dir)
  
  return(r)
}