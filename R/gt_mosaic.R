# Mosaic Rasters

#' Mosaic rasters with different origins and resolutions
#' 
#' The [raster::mosaic()] function requires rasters to have the same origin and resolution.
#' However, when producing multiple rasters to query traffic data across a large study area, the
#' rasters will not have the same origins and may not have the same resolutions (in cases where rasters 
#' at different latitudes are queried). `gt_mosaic()` allows for mosaicing rasters with different
#' origins and resolutions.
#' 
#' @param r_list List of rasters
#'
#' @return Returns a raster.
#' 
#' @examples
#' r1 <- raster::raster(ncol=10, nrow=10, xmn = -10, xmx = 1,  ymn = -10, ymx = 1)
#' r2 <- raster::raster(ncol=10, nrow=10, xmn = 0,   xmx = 10, ymn = 0,   ymx = 10)
#' r3 <- raster::raster(ncol=10, nrow=10, xmn = 9,   xmx = 20, ymn = 9,   ymx = 20)
#' 
#' r123 <- list(r1, r2, r3)
#' 
#' r <- gt_mosaic(r123)
#' 
#' @export
gt_mosaic <- function(r_list){
  
  ## Make template raster
  r_list_temp <- r_list
  
  names(r_list_temp)    <- NULL
  r_list_temp$tolerance <- 9999999
  
  r_temp <- do.call(raster::merge, r_list_temp)
  r_temp[] <- NA
  
  ## Resample to template
  for(i in 1:length(r_list)) r_list[[i]] <- raster::resample(r_list[[i]], 
                                                             r_temp, 
                                                             method = "ngb")
  
  ## Mosaic rasters together
  names(r_list)    <- NULL
  r_list$fun       <- max
  r_list$tolerance <- 999
  
  r <- do.call(raster::mosaic, r_list) 
  
  return(r)
}





