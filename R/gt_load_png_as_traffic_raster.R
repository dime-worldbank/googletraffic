# Load .png as Traffic Raster

#' Converts PNG to raster
#'
#' Converts PNG of [Google traffic data](https://developers.google.com/maps/documentation/javascript/trafficlayer) to raster and translates color values to traffic values
#'
#' @param filename Filename of PNG file
#' @param location Vector of latitude and longitude used to create PNG file using [gt_make_png()]
#' @param height Height (in pixels; pixel length depends on zoom) used to create PNG file using [gt_make_png()]
#' @param width Width (in pixels; pixel length depends on zoom) used to create PNG file using [gt_make_png()]
#' @param zoom Zoom level used to create PNG file using [gt_make_png()]
#' @param traffic_color_dist_thresh Google traffic relies on four main base colors: `#63D668` for no traffic, `#FF974D` for medium traffic, `#F23C32` for high traffic, and `#811F1F` for heavy traffic. Slight variations of these colors can also represent traffic. By default, the base colors and all colors within a 4.6 color distance of each base color are used to define traffic; by default, the `CIEDE2000` metric is used to determine color distance. A value of 2.3 is one threshold used to define a "just noticeable distance" (JND) between colors (by default, 2 X JND is used). This parameter changes the color distance from the base colors used to define colors as traffic. For more information, see [here](https://en.wikipedia.org/wiki/Color_difference#CIEDE2000).
#' @param traffic_color_dist_metric See above; this parameter changes the metric used to calculate distances between colors. By default, `CIEDE2000` is used; `CIE76` and `CIE94` can also be used. For more information, see [here](https://en.wikipedia.org/wiki/Color_difference#CIEDE2000).
#' @return Returns a raster where each pixel represents traffic level (1 = no traffic, 2 = medium traffic, 3 = traffic delays, 4 = heavy traffic)
#'
#' @references Markus Hilpert, Jenni A. Shearston, Jemaleddin Cole, Steven N. Chillrud, and Micaela E. Martinez. [Acquisition and analysis of crowd-sourced traffic data](https://arxiv.org/abs/2105.12235). CoRR, abs/2105.12235, 2021.
#' @references Pavel Pokorny. [Determining traffic levels in cities using google maps](https://ieeexplore.ieee.org/abstract/document/8326831). In 2017 Fourth International Conference on Mathematics and Computers in Sciences and in Industry (MCSI), pages 144–147, 2017.
#'
#' @examples 
#' \dontrun{
#' ## Make png
#' gt_make_png(location     = c(40.712778, -74.006111),
#'             height       = 1000,
#'             width        = 1000,
#'             zoom         = 16,
#'             out_filename = "google_traffic.png",
#'             google_key   = "GOOGLE-KEY-HERE")
#' 
#' ## Load png as traffic raster
#' r <- gt_load_png_as_traffic_raster(filename = "google_traffic.png",
#'                                    location = c(40.712778, -74.006111),
#'                                    height   = 1000,
#'                                    width    = 1000,
#'                                    zoom     = 16)
#'}                                    
#'
#' @export
gt_load_png_as_traffic_raster <- function(filename,
                                          location,
                                          height,
                                          width,
                                          zoom,
                                          traffic_color_dist_thresh = 4.6,
                                          traffic_color_dist_metric = "CIEDE2000"){
  
  # Code produces some warnings that are not relevant; for example, when initially
  # make a raster, we get a warning that the extent is not defined. This warning
  # can be ignored as the extent is defined later.
  suppressWarnings({
    
    #### Set latitude and longitude
    latitude  <- location[1]
    longitude <- location[2]
    
    #### Load
    r   <- raster::raster(filename,1)
    img <- png::readPNG(filename)
    
    #### Assign traffic colors 
    ## Image to hex
    rimg <- raster::as.raster(img) 

    #google_colours = c("#63D668", "#FF974D", "#F23C32", "#811F1F")
    google_colours = c("#11D68F", "#FFCF43", "#F24E42", "#A92727")
    google_colours_ff <- paste0(google_colours, "FF")
    
    if(traffic_color_dist_thresh == 0){
      
      r[] <- NA
      r[rimg %in% google_colours_ff[1]] <- 1
      r[rimg %in% google_colours_ff[2]] <- 2
      r[rimg %in% google_colours_ff[3]] <- 3
      r[rimg %in% google_colours_ff[4]] <- 4
      
    } else {
      
      ## Color Values
      color_df <- rimg[] %>% 
        unique() %>% 
        as.data.frame() %>%
        dplyr::rename(hex = ".") %>%
        dplyr::mutate(hex_noff = str_replace_all(.data$hex, "FF$", "FF"))
      
      lab_df <- color_df$hex_noff %>% 
        schemr::hex_to_lab()
      
      color_df <- bind_cols(color_df,
                            lab_df)
      
      ## Distance
      color_df$dist_1 <- ColorNameR::colordiff(color_df[,c("l", "a", "b")],
                                               as.matrix(schemr::hex_to_lab(google_colours[1])),
                                               metric = traffic_color_dist_metric)
      
      color_df$dist_2 <- ColorNameR::colordiff(color_df[,c("l", "a", "b")],
                                               as.matrix(schemr::hex_to_lab(google_colours[2])),
                                               metric = traffic_color_dist_metric)
      
      color_df$dist_3 <- ColorNameR::colordiff(color_df[,c("l", "a", "b")],
                                               as.matrix(schemr::hex_to_lab(google_colours[3])),
                                               metric = traffic_color_dist_metric)
      
      color_df$dist_4 <- ColorNameR::colordiff(color_df[,c("l", "a", "b")],
                                               as.matrix(schemr::hex_to_lab(google_colours[4])),
                                               metric = traffic_color_dist_metric)
      
      ## Assign traffic levels
      color_df <- color_df %>%
        dplyr::mutate(traffic = case_when(
          dist_1 <= traffic_color_dist_thresh ~ 1,
          dist_2 <= traffic_color_dist_thresh ~ 2,
          dist_3 <= traffic_color_dist_thresh ~ 3,
          dist_4 <= traffic_color_dist_thresh ~ 4
        )) 
      
      r[] <- NA
      r[rimg %in% color_df$hex[color_df$traffic %in% 1]] <- 1
      r[rimg %in% color_df$hex[color_df$traffic %in% 2]] <- 2
      r[rimg %in% color_df$hex[color_df$traffic %in% 3]] <- 3
      r[rimg %in% color_df$hex[color_df$traffic %in% 4]] <- 4
    }
    
    #### Spatially define raster
    ext_4326 <- gt_make_extent(latitude = latitude,
                               longitude = longitude,
                               height = height,
                               width = width,
                               zoom = zoom)
    
    # Project extent to 3857
    ext_3857 <- ext_4326 %>% 
      sf::st_bbox() %>% 
      sf::st_as_sfc() 
    
    sf::st_crs(ext_3857) <- 4326
    
    ext_3857 <- ext_3857 %>%
      sf::st_transform(3857) %>% 
      sf::st_bbox() %>% 
      raster::extent()
    
    raster::extent(r) <- ext_3857
    
    raster::crs(r) <- sp::CRS("+init=epsg:3857")
    
    ## Convert to EPSG:4326
    r <- raster::projectRaster(r, crs = CRS("+init=epsg:4326"), method = "ngb")
    
  })
  
  return(r)
}
