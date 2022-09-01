# Make Grid

#' Creates grid to query Google Traffic 
#'
#' Querying too large of a location may be unfeasible; consequently, it may be necessary to query multiple smaller locations to cover a large location. Based on the location to be queried and the height, width and zoom parameters, determines the points that should be queried.
#'
#' @param polygon Polygon (`sf` object or `SpatialPolygonsDataframe`) in WGS84 CRS the defines region to be queried.
#' @param height Height (in pixels; pixel length depends on zoom)
#' @param width Width (in pixels; pixel length depends on zoom)
#' @param zoom Zoom level
#' @param reduce_hw Number of pixels to reduce height/width by. Doing so creates some overlap between tiles to ensure there is not blank space between tiles (default = 10 pixels).
#'
#' @return Returns a dataframe with the locations to query and parameters.
#' @export
gt_make_grid <- function(polygon,
                         height,
                         width,
                         zoom,
                         reduce_hw = 10){
  
  ## Polygon should be sf object
  if(class(polygon)[1] %in% "SpatialPolygonsDataFrame"){
    polygon <- polygon %>% sf::st_as_sf()
  }
  
  ## If polygon is more than one row, make one polygon
  if(nrow(polygon) > 1){
    polygon$id <- 1
    polygon <- polygon %>%
      dplyr::group_by(id) %>%
      dplyr::summarize(geometry = st_union(geometry))
  }
  
  ## Reduce height/width
  # Extents may not perfectly connect. Reducing the height and width aims to create
  # some overlap in the extents, so all the tiles will connect.
  height_use <- height - reduce_hw
  width_use  <- width  - reduce_hw
  
  ## Decimal degree distance of pixel
  # Use most extreme latitude location
  most_extreme_lat_point <- sf::st_coordinates(polygon) %>%
    as.data.frame() %>%
    dplyr::mutate(Y_abs = abs(Y)) %>%
    dplyr::arrange(-Y_abs) %>%
    head(1)
  
  most_extreme_lat_ext <- gt_make_extent(latitude = most_extreme_lat_point$Y,
                                         longitude = most_extreme_lat_point$X,
                                         height = height,
                                         width = width,
                                         zoom = zoom)
  
  pixel_dist_deg <- min(
    (most_extreme_lat_ext@xmax - most_extreme_lat_ext@xmin) / width,
    (most_extreme_lat_ext@ymax - most_extreme_lat_ext@ymin) / height
  )
  
  x_degree <- (most_extreme_lat_ext@xmax - most_extreme_lat_ext@xmin) / width
  y_degree <- (most_extreme_lat_ext@ymax - most_extreme_lat_ext@ymin) / height
  
  ## Make raster and convert to polygon
  poly_ext <- raster::extent(polygon)
  
  r <- raster::raster(ext = poly_ext, res=c(width_use*x_degree,
                                            height_use*y_degree))
  r <- raster::extend(r, c(1,1)) #Expand by one cell, to ensure covers all study area
  
  p <- r %>% raster::rasterToPolygons() %>% sf::st_as_sf()
  
  ## Only keep polygons that intersect with original polygon
  p_inter_tf <- sf::st_intersects(p, polygon, sparse=F) %>% as.vector()
  p_inter <- p[p_inter_tf,]
  
  ## Grab points
  points_df <- p_inter %>% 
    sf::st_centroid() %>%
    sf::st_coordinates() %>%
    as.data.frame() %>%
    dplyr::rename(longitude = X,
                  latitude = Y) %>%
    dplyr::mutate(id = 1:n(),
                  height = height,
                  width = width,
                  zoom = zoom) 
  
  geom <- lapply(1:nrow(points_df), function(i){
    param <- points_df[i,]
    
    ext <- gt_make_extent(param$latitude,
                          param$longitude,
                          param$height,
                          param$width,
                          param$zoom)
    
    ext %>% 
      sf::st_bbox() %>% 
      sf::st_as_sfc() %>% 
      sf::st_as_sf(crs = CRS("+init=epsg:4326"))
    #as(ext, "SpatialPolygons") %>% st_as_sf()
  }) %>%
    dplyr::bind_rows()
  
  points_sf <- sf::st_sf(points_df, geometry = geom$x)
  
  return(points_sf)
}
