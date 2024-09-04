
### Packages
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
library(ggplot2)
library(geodata)

files <- file.path("~", "Documents", "Github", "googletraffic", "R") |>
  list.files(full.names = T,
             pattern = "*.R")
for(file_i in files) source(file_i)

api_keys_df <- read.csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key_df <- api_keys_df |>
  dplyr::filter(Service == "Google Javascript API",
                Account == "robmarty3@gmail.com")
google_key <- google_key_df$Key

# Test -------------------------------------------------------------------------
gt_make_png(location = c(40.717437418183884, -73.99145764250052),
            height = 500,
            width = 500,
            zoom = 16,
            out_filename = paste0("~/Desktop/test123.png"),
            google_key = google_key)

r <- gt_make_raster(location = c(40.717437418183884, -73.99145764250052),
                    height = 500,
                    width = 500,
                    zoom = 16,
                    google_key = google_key)

nbo <- gadm(country = "KEN", level = 1, path = tempdir())
nbo <- nbo[nbo$NAME_1 == "Nairobi",] %>% st_as_sf()

# Make raster
r <- gt_make_raster_from_polygon(polygon = nbo,
                                 zoom       = 14,
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

ggsave(p, filename = "~/Desktop/nbo_traffic.png",
       height = 4, width = 5)

