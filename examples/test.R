
library(googletraffic)

api_keys_df <- readr::read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key <- api_keys_df |>
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") |>
  dplyr::pull(Key)

#### From Point
r <- gt_make_raster(location   = c(40.712778, -74.006111),
                    height     = 1000,
                    width      = 1000,
                    zoom       = 16,
                    google_key = google_key)

#### From Polygon
us_sp <- raster::getData('GADM', country='USA', level=2)
ny_sp <- us_sp[us_sp$NAME_2 %in% "New York",]
aa <- ny_sp |> sf::st_as_sf()

aap <- sf::st_transform(aa, 4326)


sf::st_crs(aa) == 9122

st_crs()

st_crs(sfc) = 4326


r <- gt_make_raster_from_polygon(polygon    = ny_sp,
                                 height     = 2000,
                                 width      = 2000,
                                 zoom       = 10,
                                 google_key = google_key)

r <- gt_make_raster_from_polygon(polygon    = ny_sp,
                                 height     = 2000,
                                 width      = 2000,
                                 zoom       = 10,
                                 google_key = google_key,
                                 return_list_of_tiles = T)

#### From Grid
grid_df <- gt_make_grid(polygon = ny_sp,
                        height  = 500,
                        width   = 500,
                        zoom    = 16)

grid_clean_df <- grid_df[1:2,]

r <- gt_make_raster_from_grid(grid_param_df = grid_clean_df,
                              google_key    = google_key)
