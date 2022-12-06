# Make Extent

# Helper functions -------------------------------------------------------------
latLngToPoint <- function(mapWidth, mapHeight, lat, lng){
  # Adapted from: https://stackoverflow.com/a/66077896/8729174
  
  x = (lng + 180) * (mapWidth/360)
  y = ((1 - log(tan(lat * pi / 180) + 1 / cos(lat * pi / 180)) / pi) / 2) * mapHeight
  
  return(c(x, y))
}

pointToLatLng <- function(mapWidth, mapHeight, x, y){
  # Adapted from: https://stackoverflow.com/a/66077896/8729174
  lng = x / mapWidth * 360 - 180
  
  n = pi - 2 * pi * y / mapHeight
  lat = (180 / pi *  atan(0.5 * (exp(n) - exp(-n))))
  
  return(c(lat, lng))
}

getImageBounds <- function(mapWidth, mapHeight, xScale, yScale, lat, lng){
  # Adapted from: https://stackoverflow.com/a/66077896/8729174
  
  centreX_Y <- latLngToPoint(mapWidth, mapHeight, lat, lng)
  centreX   <- centreX_Y[1]
  centreY   <- centreX_Y[2]
  
  southWestX  <- centreX - (mapWidth/2)  / xScale
  southWestY  <- centreY + (mapHeight/2) / yScale
  SWlat_SWlng <- pointToLatLng(mapWidth, mapHeight, southWestX, southWestY)
  SWlat       <- SWlat_SWlng[1]
  SWlng       <- SWlat_SWlng[2]
  
  northEastX  <- centreX + (mapWidth/2)/ xScale
  northEastY  <- centreY - (mapHeight/2)/ yScale
  NElat_NElng <- pointToLatLng(mapWidth, mapHeight, northEastX, northEastY)
  NElat       <- NElat_NElng[1]
  NElng       <- NElat_NElng[2]
  
  return(c(SWlat, SWlng, NElat, NElng))
}

# Main function ----------------------------------------------------------------
# Determine the spatial extent of a Google traffic tile
#
# Based on the location, height, width, and zoom, determines the spatial extent of the Google traffic tile
#
# @param latitude Latitude
# @param longitude Longitude
# @param height Height (in pixels; pixel length depends on zoom)
# @param width Width (in pixels; pixel length depends on zoom)
# @param zoom Zoom level
#
# @return Returns an extent object in WGS84 (EPSG:4326)
gt_make_extent <- function(latitude,
                           longitude,
                           height,
                           width,
                           zoom){
  
  mapWidth  <- 256
  mapHeight <- 256
  xScale    <- (2^zoom) / (width/mapWidth)
  yScale    <- (2^zoom) / (height/mapHeight)
  
  corners      <- getImageBounds(mapWidth, mapHeight, xScale, yScale, latitude, longitude)
  point_left   <- corners[2]
  point_right  <- corners[4]
  point_bottom <- corners[1]
  point_top    <- corners[3]
  
  r_extent <- raster::extent(point_left,
                             point_right,
                             point_bottom,
                             point_top)
  
  return(r_extent)
}