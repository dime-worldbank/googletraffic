# Make Google Traffic HTML

# Make traffic html from Google
#
# This function returns an html of traffic from Google. The `gt_html_to_raster()` can
# then be used to convert this html into a georeferenced raster file. 
#
# @param location Vector of latitude and longitude
# @param height Height (in pixels; pixel length depends on zoom)
# @param width Width (in pixels; pixel length depends on zoom)
# @param zoom Zoom level; integer from 0 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
# @param filename Path and filename to save file
# @param google_key Google API key
# 
# @return Returns an html file of Google traffic
gt_make_html <- function(location,
                         height,
                         width,
                         zoom,
                         filename,
                         google_key){
  
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
  gmap <- googleway::google_map(key = google_key,
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
    googleway::add_traffic() 
  
  htmlwidgets::saveWidget(gmap, 
                          filename, 
                          selfcontained = T)
  
  #### Also creates folder; delete that
  unlink(filename %>% stringr::str_replace_all(".html$", "_files"), 
         recursive = T)
  
  return(NULL)
}
