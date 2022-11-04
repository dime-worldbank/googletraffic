pkgname <- "googletraffic"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
base::assign(".ExTimings", "googletraffic-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('googletraffic')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("gt_load_png_as_traffic_raster")
### * gt_load_png_as_traffic_raster

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gt_load_png_as_traffic_raster
### Title: Converts PNG to raster
### Aliases: gt_load_png_as_traffic_raster

### ** Examples

## Not run: 
##D ## Make png
##D gt_make_png(location     = c(40.712778, -74.006111),
##D             height       = 1000,
##D             width        = 1000,
##D             zoom         = 16,
##D             out_filename = "google_traffic.png",
##D             google_key   = "GOOGLE-KEY-HERE")
##D 
##D ## Load png as traffic raster
##D r <- gt_load_png_as_traffic_raster(filename = "google_traffic.png",
##D                                    location = c(40.712778, -74.006111),
##D                                    height   = 1000,
##D                                    width    = 1000,
##D                                    zoom     = 16)
## End(Not run)                                    




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gt_load_png_as_traffic_raster", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gt_make_grid")
### * gt_make_grid

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gt_make_grid
### Title: Creates Grid to Query Google Traffic
### Aliases: gt_make_grid

### ** Examples

## Make polygon
poly_sf <- c(xmin = -74.02426,
             xmax = -73.91048,
             ymin = 40.70042,
             ymax = 40.87858) |>
  sf::st_bbox() |>
  sf::st_as_sfc() |>
  sf::st_as_sf()

sf::st_crs(poly_sf) <- 4326

## Make grid using polygon
grid_sf <- gt_make_grid(polygon = poly_sf,
                        height  = 2000,
                        width   = 2000,
                        zoom    = 16)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gt_make_grid", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gt_make_png")
### * gt_make_png

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gt_make_png
### Title: Make Google Traffic PNG
### Aliases: gt_make_png

### ** Examples

## Not run: 
##D gt_make_png(location     = c(40.712778, -74.006111),
##D             height       = 1000,
##D             width        = 1000,
##D             zoom         = 16,
##D             out_filename = "google_traffic.png",
##D             google_key   = "GOOGLE-KEY-HERE")
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gt_make_png", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gt_make_raster")
### * gt_make_raster

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gt_make_raster
### Title: Make Google Traffic Raster
### Aliases: gt_make_raster

### ** Examples

## Not run: 
##D r <- gt_make_raster(location   = c(40.712778, -74.006111),
##D                     height     = 1000,
##D                     width      = 1000,
##D                     zoom       = 16,
##D                     google_key = "GOOGLE-KEY-HERE")
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gt_make_raster", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gt_make_raster_from_grid")
### * gt_make_raster_from_grid

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gt_make_raster_from_grid
### Title: Make Google Traffic Raster Based on Grid of Coordinates
### Aliases: gt_make_raster_from_grid

### ** Examples

## Not run: 
##D ## Grab polygon of Manhattan
##D us_sp <- raster::getData('GADM', country='USA', level=2)
##D ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]
##D 
##D ## Make Grid
##D grid_df <- gt_make_grid(polygon = ny_sp,
##D                        height   = 2000,
##D                        width    = 2000,
##D                        zoom     = 16)
##D 
##D ## Make raster from grid                        
##D r <- gt_make_raster_from_grid(grid_param_df = grid_clean_df,
##D                               google_key    = "GOOGLE-KEY-HERE")
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gt_make_raster_from_grid", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gt_make_raster_from_polygon")
### * gt_make_raster_from_polygon

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gt_make_raster_from_polygon
### Title: Make Google Traffic Raster Based on Polygon
### Aliases: gt_make_raster_from_polygon

### ** Examples

## Not run: 
##D ## Grab polygon of Manhattan
##D us_sp <- raster::getData('GADM', country='USA', level=2)
##D ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]
##D 
##D ## Make raster
##D r <- gt_make_raster_from_polygon(polygon    = ny_sp,
##D                                  height     = 2000,
##D                                  width      = 2000,
##D                                  zoom       = 16,
##D                                  google_key = "GOOGLE-KEY-HERE")
## End(Not run) 




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gt_make_raster_from_polygon", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gt_mosaic")
### * gt_mosaic

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gt_mosaic
### Title: Mosaic rasters with different origins and resolutions
### Aliases: gt_mosaic

### ** Examples

r1 <- raster::raster(ncol=10, nrow=10, xmn = -10, xmx = 1,  ymn = -10, ymx = 1)
r2 <- raster::raster(ncol=10, nrow=10, xmn = 0,   xmx = 10, ymn = 0,   ymx = 10)
r3 <- raster::raster(ncol=10, nrow=10, xmn = 9,   xmx = 20, ymn = 9,   ymx = 20)

r123 <- list(r1, r2, r3)

r <- gt_mosaic(r123)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gt_mosaic", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
