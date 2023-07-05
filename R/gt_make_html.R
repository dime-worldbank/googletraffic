# Make Google Traffic HTML

# Make traffic html from Google
#
# This function returns an html of traffic from Google. The `gt_html_to_raster()` can
# then be used to convert this html into a georeferenced raster file.
#
# @param location Vector of latitude and longitude
# @param height Height (in pixels; pixel length depends on zoom)
# @param width Width (in pixels; pixel length depends on zoom)
# @param zoom Zoom level; integer from 5 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
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


  html_code <- paste0('
  <!DOCTYPE html>
  <html>
  <head>
      <title>Google Maps Traffic Layer</title>
      <style>
          html,
          body {
              height: 100%;
              margin: 0;
              padding: 0;
          }

          #map {
              height: ',height,'px;
              width: ',width,'px;
          }
      </style>
      <script src="https://maps.googleapis.com/maps/api/js?key=',google_key,'&libraries=visualization"></script>
      <script>
          function initMap() {
              var map = new google.maps.Map(document.getElementById("map"), {
                  center: { lat: ',location[1],', lng: ',location[2],' },
                  zoom: ',zoom,',
                  disableDefaultUI: true,
                  styles: [
                      {
                          "elementType": "labels",
                          "stylers": [
                              { "visibility": "off" }
                          ]
                      },
                      {
                          "elementType": "geometry",
                          "stylers": [
                              { "visibility": "off" }
                          ]
                      },
                      {
                          "featureType": "road",
                          "elementType": "geometry",
                          "stylers": [
                              { "visibility": "on" },
                              { "color": "#ffffff" }
                          ]
                      },
                      {
                          "featureType": "landscape",
                          "stylers": [
                              { "color": "#ffffff" },
                              { "visibility": "on" }
                          ]
                      }
                  ]
              });

              var trafficLayer = new google.maps.TrafficLayer();
              trafficLayer.setMap(map);
          }
      </script>
  </head>
  <body>
      <div id="map"></div>

      <script>
          window.onload = function () {
              initMap();
          };
      </script>
  </body>
  </html>
  ')

  sink(filename)
  cat(html_code)
  sink()

  return(NULL)
}
