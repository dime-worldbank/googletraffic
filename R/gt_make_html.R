#' Make traffic html from Google
#'
#' This function returns an html of traffic from Google. The `gt_html_to_raster()` can
#' then be used to convert this html into a georeferenced raster file. 
#'
#' @param location Vector of latitude and longitude
#' @param height Height
#' @param width Width
#' @param zoom Zoom; integer from 0 to 20. For more information, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param filename Path and filename to save file
#' @param google_key Google API key
#' @param save_params Save an .Rds file that contains the parameters (location, height, width and zoom). This file can then be used by the `gt_html_to_raster()` function.
#' 
#' @return Returns an html file of Google traffic
#' @export
gt_make_html <- function(location,
                         height,
                         width,
                         zoom,
                         filename,
                         google_key,
                         save_params = F){
  
  #### Define style; all white background
  # Adapted from: https://snazzymaps.com/style/95/roadie
  style <- '[
    {
        "elementType": "labels",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "elementType": "geometry",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
            {
                "visibility": "on"
            },
            {
                "color": "#ffffff"
            }
        ]
    },
    {
        "featureType": "landscape",
        "stylers": [
            {
                "color": "#ffffff"
            },
            {
                "visibility": "on"
            }
        ]
    },
    {}
]'
  
  #### Create map
  gmap <- google_map(key = google_key,
                     location = location,
                     zoom = zoom,
                     height = height,
                     width = width,
                     styles = style,
                     zoom_control = F,
                     map_type_control = F,
                     scale_control = F,
                     fullscreen_control = F,
                     rotate_control = F,
                     street_view_control = F) %>%
    add_traffic() 
  
  
  saveWidget(gmap, 
             filename, 
             selfcontained = T)
  
  #### Also creates folder; delete that
  unlink(filename %>% str_replace_all(".html$", "_files"), 
         recursive = T)
  
  return(NULL)
}