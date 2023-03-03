# Data for Mapbox Examples

library(dplyr)
library(mapboxapi)
library(sf)
library(raster)
library(ggplot2)
library(leaflet)

# Setup ------------------------------------------------------------------------
## Keys
api_keys_df <- read.csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

key_df <- api_keys_df %>%
  dplyr::filter(Service == "Mapbox",
                Account == "ramarty@email.wm.edu") 
key <- key_df$Key

## Grab shapefile of Manhattan
us_sp <- getData('GADM', country='USA', level=2)
ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]
ny_sf <- ny_sp %>% st_as_sf()

# Download data ----------------------------------------------------------------
nyc_cong_point <- get_vector_tiles(
  tileset_id = "mapbox.mapbox-traffic-v1",
  location = c(-74.006111, 40.712778), # c(longitude, latitude)
  zoom = 14,
  access_token = key
)$traffic$lines

saveRDS(nyc_cong_point, "~/Documents/Github/googletraffic/vignettes/mapbox_nyc_z14_point.Rds")

nyc_cong_poly <- get_vector_tiles(
  tileset_id = "mapbox.mapbox-traffic-v1",
  location = ny_sf,
  zoom = 14,
  access_token = key
)$traffic

saveRDS(nyc_cong_poly, "~/Documents/Github/googletraffic/vignettes/mapbox_nyc_z14_polygon.Rds")

# Maps -------------------------------------------------------------------------
#### Point
nyc_cong_point %>%
  mutate(congestion = congestion %>% 
           tools::toTitleCase() %>%
           factor(levels = c("Low", "Moderate", "Heavy", "Severe"))) %>%
  ggplot() +
  geom_sf(aes(color = congestion)) +
  scale_color_manual(values = c("green2", "orange", "red", "#660000")) +
  labs(color = "Congestion") +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", color="white"))

ggsave(filename = file.path("~/Documents/Github/googletraffic/man/figures/mapbox_nyc_point.jpg"),
       height = 4, width = 4)

#### Polygon
nyc_cong_poly %>%
  mutate(congestion = congestion %>% 
           tools::toTitleCase() %>%
           factor(levels = c("Low", "Moderate", "Heavy", "Severe"))) %>%
  ggplot() +
  geom_sf(aes(color = congestion),
          size = 0.1) +
  scale_color_manual(values = c("green2", "orange", "red", "#660000")) +
  labs(color = "Congestion") +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", color="white"))

ggsave(filename = file.path("~/Documents/Github/googletraffic/man/figures/mapbox_nyc_polygon.jpg"),
       height = 4, width = 4)

# Leaflet ----------------------------------------------------------------------
#### Point
mapbox_pal <- colorFactor(palette = c("green", "orange", "red", "#660000"), 
                            domain = c("low", "moderate", "heavy", "severe"),
                          ordered = T)

leaflet(width = "100%") %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addPolylines(data = nyc_cong_point, color = ~mapbox_pal(congestion), popup = ~as.character(congestion), opacity = 1) %>%
  setView(lat = 40.705, lng = -74.01, zoom = 14) 

#### Polygon
leaflet(width = "100%") %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%
  addPolylines(data = nyc_cong_poly, color = ~mapbox_pal(congestion), opacity = 1, weight = 1) %>%
  setView(lat = 40.7773729, lng = -73.968252, zoom = 12) 

