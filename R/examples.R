# Examples used for readme

# Setup ------------------------------------------------------------------------
api_keys_df <- read_csv("~/Dropbox/World Bank/Webscraping/Files for Server/api_keys.csv")

google_key <- api_keys_df %>%
  dplyr::filter(Service == "Google Directions API",
                Account == "ramarty@email.wm.edu") %>%
  pull(Key)