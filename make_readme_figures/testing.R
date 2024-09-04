# Testing Package

# TODO:
# Use 4.6

# Setup ------------------------------------------------------------------------
# devtools::install_github("dime-worldbank/googletraffic")
library(googletraffic)
library(dplyr)
library(ggplot2)
library(leaflet)
library(raster)

if(F){
  library(dplyr)
  library(googleway)
  library(htmlwidgets)
  library(plotwidgets)
  library(png)
  library(sf)
  library(sp)
  library(stringr)
  library(webshot2)
  library(raster)
  library(ColorNameR)
  library(schemr)
}

api_keys_df <- read.csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key_df <- api_keys_df |>
  dplyr::filter(Service == "Google Javascript API",
                Account == "robmarty3@gmail.com")
google_key <- google_key_df$Key

# Test -------------------------------------------------------------------------
gt_make_png(location = c(40.717437418183884, -73.99145764250052),
            height = 200,
            width = 200,
            zoom = 16,
            out_filename = paste0("~/Desktop/test123.png"),
            google_key = google_key)

r <- gt_make_raster(location = c(40.717437418183884, -73.99145764250052),
            height = 200,
            width = 200,
            zoom = 16,
            google_key = google_key)

## Plot
r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
names(r_df) <- c("value", "x", "y")

ggplot() +
  geom_raster(data = r_df, 
              aes(x = x, y = y, 
                  fill = as.factor(value))) +
  labs(fill = "Traffic\nLevel") +
  scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
  coord_quickmap() + 
  theme_void() +
  theme(plot.background = element_rect(fill = "white", color="white"))


# Make PNGs --------------------------------------------------------------------
dir.create("~/Desktop/gt_pngs")

for(zoom in 5:20){
  gt_make_png(location = c(40.717437418183884, -73.99145764250052),
              height = 2000,
              width = 2000,
              zoom = zoom,
              out_filename = paste0("~/Desktop/gt_pngs/gt",zoom,".png"),
              google_key = google_key)
}

# Make Traffic Figures ---------------------------------------------------------
dir.create("~/Desktop/gt_raster_images")

for(zoom in 5:20){
  r <- gt_load_png_as_traffic_raster(filename = paste0("~/Desktop/gt_pngs/gt",zoom,".png"),
                                     location = c(40.717437418183884, -73.99145764250052),
                                     height = 2000,
                                     width = 2000,
                                     zoom = zoom)

  r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
  names(r_df) <- c("value", "x", "y")

  p <- ggplot() +
    geom_raster(data = r_df,
                aes(x = x, y = y,
                    fill = as.factor(value))) +
    labs(fill = "Traffic\nLevel") +
    scale_fill_manual(values = c("#63D668", "#FF974D", "#F23C32", "#811F1F")) +
    coord_quickmap() +
    theme_void() +
    theme(plot.background = element_rect(fill = "white", color="white"))

  ggsave(p, filename = paste0("~/Desktop/gt_raster_images/r",zoom,".png"),
         height = 6, width = 6)
}

# Test Leaflet -----------------------------------------------------------------
zoom=16
traffic_pal <- colorNumeric(c("#63D668", "#FF974D", "#F23C32", "#811F1F"),
                            1:4,
                            na.color = "transparent")

r <- gt_load_png_as_traffic_raster(filename = paste0("~/Desktop/gt_pngs/gt",zoom,".png"),
                                   location = c(40.717437418183884, -73.99145764250052),
                                   height = 2000,
                                   width = 2000,
                                   traffic_color_dist_thresh = 4.6,
                                   zoom = zoom)

## Map raster
leaflet() %>%
  #addTiles() %>%
  addRasterImage(r, colors = traffic_pal, opacity = 1, method = "ngb")

# Test Grid --------------------------------------------------------------------
grid_df <- gt_make_grid(polygon = ny_sp,
                        zoom    = 15)

leaflet() %>%
  addTiles() %>%
  addPolygons(data = grid_df)

r <- gt_make_raster_from_grid(grid_param_df = grid_df,
                              google_key    = google_key)

## Plot
r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
names(r_df) <- c("value", "x", "y")

p <- ggplot() +
  geom_raster(data = r_df,
              aes(x = x, y = y,
                  fill = as.factor(value))) +
  labs(fill = "Traffic\nLevel") +
  scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
  coord_quickmap() +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", color="white"))

ggsave(p, filename = "~/Desktop/nyc_grid.png",
       height = 7*1.6,
       width = 4.2*1.6)


leaflet() %>%
  addTiles() %>%
  addRasterImage(r, colors = traffic_pal, opacity = 1, method = "ngb")

# Test Polygon -----------------------------------------------------------------

## Grab shapefile of Manhattan
us_sp <- getData('GADM', country='USA', level=2)
ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]

## Make raster
r <- gt_make_raster_from_polygon(polygon    = ny_sp,
                                 zoom       = 16,
                                 google_key = google_key)

## Plot
r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
names(r_df) <- c("value", "x", "y")

p <- ggplot() +
  geom_raster(data = r_df,
              aes(x = x, y = y,
                  fill = as.factor(value))) +
  labs(fill = "Traffic\nLevel") +
  scale_fill_manual(values = c("green2", "orange", "red", "#660000")) +
  coord_quickmap() +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", color="white"))

ggsave(p, filename = "~/Desktop/nyc_polygon.png",
       height = 7*2,
       width = 4.2*2)

leaflet() %>%
  addTiles() %>%
  addRasterImage(r, colors = traffic_pal, opacity = 1, method = "ngb")
