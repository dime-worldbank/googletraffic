# Troubleshooting

# Setup ------------------------------------------------------------------------
root_dir <- "~/Documents/Github/googletraffic"

source(file.path(root_dir, "R", "gt_estimate_webshot_delay.R"))
source(file.path(root_dir, "R", "gt_html_to_raster.R"))
source(file.path(root_dir, "R", "gt_load_png_as_traffic_raster.R"))
source(file.path(root_dir, "R", "gt_make_extent.R"))
source(file.path(root_dir, "R", "gt_make_grid.R"))
source(file.path(root_dir, "R", "gt_make_html.R"))
source(file.path(root_dir, "R", "gt_make_png.R"))
source(file.path(root_dir, "R", "gt_make_raster_from_grid.R"))
source(file.path(root_dir, "R", "gt_make_raster_from_polygon.R"))
source(file.path(root_dir, "R", "gt_make_raster.R"))
# 
library(tidyverse)
library(googleway)
library(htmlwidgets)
library(webshot)
library(raster)
library(png)
library(plotwidgets)
library(httr)
library(sp)
library(sf)

library(leaflet)
library(leaflet.extras)
library(leaflet.providers)
library(scales)
library(mapview)
library(raster)
library(terra)

api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key <- api_keys_df %>%
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") %>%
  pull(Key)

bing_key <- api_keys_df %>%
  dplyr::filter(Service == "Bing Maps",
                Account == "robmarty3@gmail.com") %>%
  pull(Key)

# Setup ------------------------------------------------------------------------
if(F){
  library(rgeos)
  
  us_adm0_sp <- getData('GADM', country='USA', level=1)
  us_adm0_sp <- us_adm0_sp[!(us_adm0_sp$NAME_1 %in% c("Alaska", "Hawaii")),]
  us_adm0_sp <- gBuffer(us_adm0_sp, width = 0)
  us_adm0_sp$id <- 1
  
  us_adm0_sp_s <- gSimplify(us_adm0_sp, tol = 20/111.21)
  us_adm0_sp_s$id <- 1
  
  r_us <- gt_make_raster_from_polygon(polygon       = us_adm0_sp_s,
                                      height        = 2000,
                                      width         = 2000,
                                      zoom          = 7,
                                      google_key    = google_key,
                                      return_list_of_tiles = F,
                                      webshot_delay = NULL)
  
  saveRDS(r_us, "~/Desktop/gt_data_list_new.Rds")
}

r_list <- readRDS("~/Desktop/gt_data_list_new.Rds")

## Make template raster
r_list_temp <- r_list

names(r_list_temp)    <- NULL
#r_list_temp$fun       <- max
r_list_temp$tolerance <- 9999999

r_temp <- do.call(raster::merge, r_list_temp)
r_temp[] <- NA

## Resample to template
for(i in 1:length(r_list)) r_list[[i]] <- raster::resample(r_list[[i]], r_temp, method = "ngb")

## Mosaic rasters together
names(r_list)    <- NULL
r_list$fun       <- max
#r_list_temp$tolerance <- 9999999

r <- do.call(raster::mosaic, r_list) 

r[][!is.na(r[])]

r_list[[1]][] 

## Check!
leaflet() %>% 
  addTiles() %>%
  addRasterImage(r, opacity = 0.8)

r1_adj <- resample(r1, r_temp, method = "ngb")
r2_adj <- resample(r2, r_temp, method = "ngb")

r12 <- merge(r1_adj, r2_adj)

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r1_adj, opacity = 0.8) %>%
  addRasterImage(r2_adj, opacity = 0.8)  

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r12, opacity = 0.8)


r1 <- r_list[[7]]
leaflet() %>% 
  addTiles() %>%
  addRasterImage(r, opacity = 0.8) 

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r8c, opacity = 0.8) 













r1_poly <- rasterToPolygons(r1, dissolve = T)
r1_poly <- spTransform(r1_poly, CRS("+init=epsg:4326"))

leaflet() %>%
  addTiles() %>%
  addPolygons(data = r1_poly)


r1_poly_p <- spTransform(r1_poly, CRS("+init=epsg:3857"))

crs(r1) <- crs("+init=epsg:3857")

r1_coord <- r1 %>% 
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(longitude = x, latitude = y)
r1_coord$traffic <- r1[]
r1_coord <- r1_coord %>%
  dplyr::filter(!is.na(traffic))

r2_coord <- r2 %>% 
  coordinates() %>%
  as.data.frame() %>%
  dplyr::rename(longitude = x, latitude = y)
r2_coord$traffic <- r2[]
r2_coord <- r2_coord %>%
  dplyr::filter(!is.na(traffic))

r_coord <- bind_rows(r1_coord,
                     r2_coord)

r1_poly <- rasterToPolygons(r1, dissolve = T)
r2_poly <- rasterToPolygons(r2, dissolve = T)

leaflet() %>%
  addTiles() %>%
  addPolygons(data = r1_poly_p)


leaflet() %>%
  addTiles() %>%
  addPolygons(data = a)


## Template raster
r_t <- merge(r1, r2, tolerance = 99999)
r_t[] <- NA

## Add in values
coordinates(r_coord) <- ~longitude+latitude
crs(r_coord) <- CRS("+init=epsg:4326")

r_t_m <- rasterize(r_coord, r_t, field = "traffic", fun = 'max')

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r_t_m, opacity = 0.8, project = F) 

leaflet() %>% 
  addTiles() %>%
  addCircles(dat = r1_coord) 


leaflet() %>%
  addTiles() %>%
  addCircles(data = r_coord)





r1_coord




a <- resample(r1, r_t)

leaflet() %>%
  addTiles() %>%
  addRasterImage(a)





r_t[] <- NA









xmin <- min(bbox(r1)[1,1], bbox(r2)[1,1])
xmax <- max(bbox(r1)[1,2], bbox(r2)[1,2])  
ymin <- min(bbox(r1)[2,1], bbox(r2)[2,1])  
ymax <- max(bbox(r1)[2,2], bbox(r2)[2,2])  
newextent=c(xmin, xmax, ymin, ymax)
newextent <- extent(newextent)





r1_ext <- terra::extend(r1, newextent, snap = "out")

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r1_ext, opacity = 0.8, project = F) 

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r1, opacity = 0.8, project = F) 


extent(r1) <- newextent
r1 <- setExtent(r1, newextent, keepres=TRUE)
r1

r1_ext <- setExtent(r1, newextent, keepres=T, snap=F)
#r2_ext <- setExtent(r2, newextent, keepres=T, snap=T)

r1_new <- r1
extent(r1_new) <- r1_ext

r1
r1_new



#r1_ext = extend(r1, newextent)
#r2_ext = extend(r2, newextent)

## WAY 1
r1_ext_adj <- projectRaster(from = r1_ext, to = r2_ext, method = "ngb")
r_m        <- merge(r1_ext_adj, r2_ext)

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r_m, opacity = 0.8, project = T) 

# WAY 2
s123 = stack(r1_ext, r2_ext)


leaflet() %>% 
  addTiles() %>%
  addRasterImage(r1_ext, opacity = 0.8, project = T)  %>%
  addRasterImage(r2_ext, opacity = 0.8, project = T) 



a <- mean_narm
s123.mean = calc(s123, fun=max, na.rm=T)

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r1, opacity = 0.8, project = F) 

a <- crop(r_list[[1]], r_template)

#### After same resolution, still need to merge together
#r_list$fun <- max
r_list_m <- do.call(raster::merge, list(r_list[[5]], r_list[[8]]))

#### CHECK
leaflet() %>% 
  addTiles() %>%
  addRasterImage(s123.mean, opacity = 0.8, project = F) 

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r_list_m, opacity = 0.8, project = F) 

leaflet() %>% 
  addTiles() %>%
  addRasterImage(r_list[[5]], opacity = 0.5, project = F) %>%
  addRasterImage(r_list[[8]], opacity = 0.5, project = F)  

r_list_m
r_list[[5]]
r_list[[8]]



r_list[[5]]
r_list[[8]]

res(r_list[[5]])[1] == res(r_list[[8]])[1]
res(r_list[[5]])[2] == res(r_list[[8]])[2]

res(r_list[[5]])[1] - res(r_list[[8]])[1]
res(r_list[[5]])[2] - res(r_list[[8]])[2]


# IDEAS
# -Make same extent, padded with NAs

r_template_f <- r_template
r_template_f[] <- 1
leaflet() %>% 
  addTiles() %>%
  addRasterImage(r_template_f, opacity = 0.8, project = F) 

# Create Rasters ---------------------------------------------------------------
library(raster)
library(leaflet)
library(rgeos)

## US data and simplify for faster processing
us_sp <- getData('GADM', country='USA', level=1)
us_sp <- gSimplify(us_sp, tol = 1/111)
us_sp$id <- 1:length(us_sp)

## Make rasters
r1 <- raster(ncol=2000, nrow=2000)
extent(r1) <- c(-102.9243, -80.95162, 33.88336, 50.0742)
crs(r1) <- "+proj=longlat +datum=WGS84 +no_defs"
r1[,seq(from = 1, to = 2000, by = 5)] = 1:10

r2 <- raster(ncol=2000, nrow=2000)
extent(r2) <- c(-102.9243, -80.95162, 18.20463, 37.48908)
crs(r2) <- "+proj=longlat +datum=WGS84 +no_defs"
r2[,seq(from = 1, to = 2000, by = 5)] = 1:10

## Mask to US
r1 <- mask(r1, us_sp)
r2 <- mask(r2, us_sp)

## Plot Separately
leaflet() %>% 
  addTiles() %>%
  addRasterImage(r1, opacity = 0.8, project = F) %>%
  addRasterImage(r2, opacity = 0.8, project = F)  

# Attempt 1 at merging ---------------------------------------------------------
# Set high tolerance so don't get "different resolution" error

## Merge
r_a1 <- merge(r1, r2, fun = max, tolerance = 1)

## Plot (raster look shifted)
leaflet() %>% 
  addTiles() %>%
  addRasterImage(r_a1, project = F)

# Attempt 2 at merging ---------------------------------------------------------
# Set high tolerance so don't get "different resolution" error

## Make resolutions similar
r_template <- merge(r1, r2, fun = max, tolerance = 1)

r1_adj_temp <- projectRaster(from = r1, to = r_template, alignOnly = TRUE) 
r1_adj      <- projectRaster(from = r1, to = r1_adj_temp, method = "ngb")

r2_adj_temp <- projectRaster(from = r2, to = r_template, alignOnly = TRUE) 
r2_adj      <- projectRaster(from = r2, to = r2_adj_temp, method = "ngb")

## Merge
r_a2 <- merge(r1_adj, r2_adj, fun = max)

## Plot separately (looks correct)
leaflet() %>% 
  addTiles() %>%
  addRasterImage(r1_adj, project = F) %>%
  addRasterImage(r2_adj, project = F)

## Plot merged (rasters look shifted)
leaflet() %>% 
  addTiles() %>%
  addRasterImage(r_a2, project = F)

