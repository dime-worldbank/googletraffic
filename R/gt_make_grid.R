# Make Grid

#' Creates Grid to Query Google Traffic 
#'
#' Creates a grid of sf polygons, where traffic data for each polygon can then be queried using [gt_make_raster_from_grid()]. 
#'
#' @param polygon Polygon (`sf` object or `SpatialPolygonsDataframe`) in WGS84 CRS the defines region to be queried.
#' @param zoom Zoom level; integer from 0 to 20. For more information about how zoom levels correspond to pixel size, see [here](https://wiki.openstreetmap.org/wiki/Zoom_levels)
#' @param height_width_max Maximum pixel height and width to check using for each grid (pixel length depends on zoom). If the same number of grids can be made with a smaller height/width, the function will use a smaller height/width. If `height` and `width` are specified, that height and width will be used and `height_width_max` will be ignored. (Default: `2000`) 
#' @param height Height, in pixels, for each grid (pixel length depends on zoom). Enter a `height` to manually specify the height; otherwise, a height of `height_width_max` or smaller will be used.
#' @param width Pixel, in pixels, for each grid (pixel length depends on zoom). Enter a `width` to manually specify the width; otherwise, a width of `height_width_max` or smaller will be used.
#' @param reduce_hw Number of pixels to reduce height/width by. Doing so creates some overlap between grids to ensure there is not blank space between grids. (Default: 10).
#'
#' @return Returns an sf dataframe with the locations to query, including parameters needed for [gt_make_raster_from_grid()]
#' 
#' @examples
#' ## Make polygon
#' poly_sf <- c(xmin = -74.02426,
#'              xmax = -73.91048,
#'              ymin = 40.70042,
#'              ymax = 40.87858) |>
#'   sf::st_bbox() |>
#'   sf::st_as_sfc() |>
#'   sf::st_as_sf()
#' 
#' sf::st_crs(poly_sf) <- 4326
#' 
#' ## Make grid using polygon
#' grid_sf <- gt_make_grid(polygon = poly_sf,
#'                         height  = 2000,
#'                         width   = 2000,
#'                         zoom    = 16)
#' 
#' @export
gt_make_grid <- function(polygon,
                         zoom,
                         height_width_max = 2000,
                         height = NULL,
                         width = NULL,
                         reduce_hw = 10){
  
  ## Polygon should be sf object
  if(class(polygon)[1] %in% "SpatialPolygonsDataFrame"){
    polygon <- polygon %>% sf::st_as_sf()
  }
  
  ## Check CRS
  if(sf::st_crs(polygon) != sf::st_crs(4326)){
    warning("Transforming polygon to EPSG:4236 CRS")
    polygon <- polygon %>% sf::st_transform(4326)
  }
  
  ## If polygon is more than one row, make one polygon
  if(nrow(polygon) > 1){
    polygon$id <- 1
    polygon <- polygon %>%
      dplyr::group_by(id) %>%
      dplyr::summarize(geometry = st_union(geometry))
  }
  
  #### Checks
  if(is.null(height) & !is.null(width)){
    stop('"width" specified but not "height"; if specify "width", must also specify "height." If don\'t specify either "height" or "width", the function will choose a "height" and "width" based on the extent of the polygon.')
  }
  
  if(!is.null(height) & is.null(width)){
    stop('"height" specified but not "width"; if specify "height", must also specify "width" If don\'t specify either "height" or "width", the function will choose a "height" and "width" based on the extent of the polygon.')
  }
  
  if(!is.null(height) & !is.null(width) & !is.null(height_width_max)){
    warning('"height_width_max" ignored; if "height", "width", and "height_width_max" are all specified, "height_width_max" will be ignored.')
  }
  
  #### Make height/width
  
  # If height and width are both specified, use those; 
  # if not, optimize height/width up to height_width_max
  if(!(!is.null(height) & !is.null(width))){
    
    ## Set min to check
    height_width_min = min(c(250, round(height_width_max/2)))
    
    ## Height/widths to try
    hw_vec <- seq(from = height_width_min,
                  to = height_width_max,
                  by = (height_width_max - height_width_min)/4) %>%
      ceiling() %>%
      rev()
    
    ## Don't consider maximum; we initialize with maximum
    hw_vec <- hw_vec[-1]
    
    ## Set initial height/width to use
    hw_use <- height_width_max
    
    ## Check initial rows
    grid_param_df <- gt_make_grid(polygon   = polygon,
                                  height    = height_width_max,
                                  width     = height_width_max,
                                  zoom      = zoom,
                                  reduce_hw = 0)
    n_grid_initial <- nrow(grid_param_df)
    
    ## Check if can use smaller height/width
    for(hw in hw_vec){
      grid_param_df <- gt_make_grid(polygon   = polygon,
                                    height    = hw,
                                    width     = hw,
                                    zoom      = zoom,
                                    reduce_hw = 0)
      
      # If initial number of grids can be achieved with using a small height/width,
      # then use the smaller height/width
      if(nrow(grid_param_df) == n_grid_initial) hw_use <- hw
    }
    
    height <- hw_use
    width  <- hw_use
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
    dplyr::mutate(Y_abs = abs(.data$Y)) %>%
    dplyr::arrange(-.data$Y_abs) %>%
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
    dplyr::rename(longitude = .data$X,
                  latitude = .data$Y) %>%
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
  }) %>%
    dplyr::bind_rows()
  
  points_sf <- sf::st_sf(points_df, geometry = geom$x)
  
  return(points_sf)
}
