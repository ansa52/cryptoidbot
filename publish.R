#library
library(rtweet)
library(tidyverse)
library(mongolite)
library(gt)
library(gtExtras)
library(webshot2)


#koneksi ke mongodb
cs = Sys.getenv("CRYPTO_MONGO_CON")
harga_crypto_collection = mongo(collection=Sys.getenv("CRYPTO_MONGO_COL"), db=Sys.getenv("CRYPTO_MONGO_DB"), url=cs)

#insert data_json
crypto <- harga_crypto_collection$find('{}')

# 5 crypto dengan harga tertinggi
high_price <- crypto[order(crypto$latestPrice, decreasing = TRUE),]
high <- high_price[1:5,3:9]

# 5 crypto dengan harga terendah
low_price <- crypto[order(crypto$latestPrice, decreasing = FALSE),]
low <- low_price[1:5,3:9]


tabel <- high %>%
  mutate(logo = map(logo, gt::html)) %>% gt() %>%
  tab_header(title = md("5 Crypto Harga Tertinggi")) %>% 
  tab_spanner(label = "Perubahan Harga", columns = matches("day|week|month|year")) %>%
  fmt_currency(columns = latestPrice, currency = "IDR", sep_mark = ".", dec_mark = ",") %>%
  gt_img_rows(columns = logo, img_source = "web", height = 30) %>%
  tab_options(data_row.padding = px(1))

tabel2 <- low %>%
  mutate(logo = map(logo, gt::html)) %>% gt() %>%
  tab_header(title = md("5 Crypto Harga Terendah")) %>% 
  tab_spanner(label = "Perubahan Harga", columns = matches("day|week|month|year")) %>%
  fmt_currency(columns = latestPrice, currency = "IDR", sep_mark = ".", dec_mark = ",") %>%
  gt_img_rows(columns = logo, img_source = "web", height = 30) %>%
  tab_options(data_row.padding = px(1))

tmp <- tempfile(fileext = '.png') #path to temp .png file
gtsave_extra(tabel,tmp) #save gt table as png

tmp2 <- tempfile(fileext = '.png') #path to temp .png file
gtsave_extra(tabel,tmp2) #save gt table as png


## Create Twitter token
crypto_token <- rtweet::create_token(
  app = Sys.getenv("CRYPTO_APP"), 
  consumer_key =    Sys.getenv("CRYPTO_TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("CRYPTO_TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("CRYPTO_TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("CRYPTO_TWITTER_ACCESS_TOKEN_SECRET")
)

status_details <- paste0(
  "Update Harga Crypto", data$name, "\n\n"
)

## Post the image to Twitter
rtweet::post_tweet(
  status = status_details,
  media = tmp,
  token = crypto_token
)

rtweet::post_tweet(
  status = status_details,
  media = tmp2,
  token = crypto_token
)

