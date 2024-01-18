
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

