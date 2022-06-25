library(rtweet)
library(tidyverse)
library(mongolite)


#koneksi ke mongodb
cs = Sys.getenv("CRYPTO_MONGO_CON")
harga_crypto_collection = mongo(collection=Sys.getenv("CRYPTO_MONGO_COL"), db=Sys.getenv("CRYPTO_MONGO_DB"), url=cs)

#insert data_json
crypto <- harga_crypto_collection$find('{}')
glimpse(crypto)
high_price <- crypto[order(crypto$latestPrice, decreasing = TRUE),]
high <- high_price[1:5,3:7]

low_price <- crypto[order(crypto$latestPrice, decreasing = FALSE),]
low <- low_price[1:5,3:7]


tabel <- high %>%
  mutate(logo = map(logo, gt::html)) %>% gt() %>%
  tab_spanner(label = "Perubahan Harga", columns = matches("day|week|month|year")) %>%
  tab_header(title = md("5 Crypto Harga Tertinggi")) %>% 
  fmt_currency(columns = latestPrice, currency = "IDR", sep_mark = ".", dec_mark = ",") %>%
  gt_img_rows(columns = logo, img_source = "web", height = 30) %>%
  tab_options(data_row.padding = px(1))


## Create Twitter token
crypto_token <- rtweet::create_token(
  app = Sys.getenv("CRYPTO_APP"), 
  consumer_key =    Sys.getenv("CRYPTO_TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("CRYPTO_TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("CRYPTO_TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("CRYPTO_TWITTER_ACCESS_TOKEN_SECRET")
)

#data <- high[1,]

install.packages("gt")
library(gt)

status_details <- paste0(
  "Name: ", data$name, "\n",
  "Harga(Rp): ", data$latestPrice, " \n"
)


## Post the image to Twitter
rtweet::post_tweet(
  status = status_details,
  token = crypto_token
)

