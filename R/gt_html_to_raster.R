#' Converts Google HTML file to Raster
#' 
#' Converts a Google HTML file into a spatially referenced raster file. 
#'
#' @param polygon `SpatialPolygonsDataframe` the defines region to be queried.
#'
#' ## If `save_params` is set to `FALSE` in `` or `gt_make_htmls_from_grid`, then the following must be specified
#' @param height Height
#' @param width Width
#' @param zoom Zoom level
#'
#' ## Other parameters
#' @param webshot_delay How long to wait for .html file to load. Larger .html files will require more time to fully load.
#' @param save_png The function creates a .png file as an intermediate step. Specify whether the .png file should be kept (default: `FALSE`)
#'
#' @return Returns a georeferenced raster file. The file can contain the following values: 1 = no traffic; 2 = light traffic; 3 = moderate traffic; 4 = heavy traffic.
#' @export
gt_html_to_raster <- function(filename,
                              location = NULL,
                              height = NULL,
                              width = NULL,
                              zoom = NULL,
                              webshot_delay = NULL,
                              save_png = F){
  
  ## Set webshot_delay if null
  webshot_delay <- gt_estimate_webshot_delay(height, width, webshot_delay)
  
  ## Grab parameters from dataframe
  if(is.null(location) | is.null(height) | is.null(width) | is.null(zoom)){
    param_df_filename <- filename %>% str_replace_all(".html$", "_params.Rds")
    
    if(file.exists(param_df_filename)){
      param_df <- readRDS(param_df_filename)
      
      location = param_df$location
      height   = param_df$height
      width    = param_df$width
      zoom     = param_df$zoom
      
    } else{
      stop("location, height, width, or zoom not specified and parameter dataframe doesn't exist")
    }
    
  }
  
  #### Make lat/lon
  latitude = location[1]
  longitude = location[2]
  
  #### Convert .html to png
  filename_root <- filename %>% str_replace_all(".html$", "")
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
  
  #### Load as raster and image
  png_filename <- file.path(filename_dir, paste0(filename_only, ".png"))
  
  r <- gt_load_png_as_traffic_raster(png_filename,
                                     latitude,
                                     longitude,
                                     height,
                                     width,
                                     zoom)
  
  ## Save PNG
  #img <- readPNG(file.path(filename_dir, paste0(filename_only, ".png")))
  
  ## Delete png from temp file
  unlink(file.path(filename_dir, paste0(filename_only,".png")))
  
  setwd(current_dir)
  return(r)
}