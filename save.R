library(rvest)
library(jsonlite)
library(tidyverse)
library(mongolite)


#mendapatkan list crypto
#currencySymbol, name, logo
url <- Sys.getenv("CRYPTO_URL_1")
crypto <- fromJSON(url)
crypto <- crypto$payload

symbol <- crypto['currencySymbol']
for(i in 1:67){
  symbol[i,] <- paste0(tolower(symbol[i,]),"/idr")
}
crypto['pair'] <- symbol

#mendapatkan update harga
url2 <- Sys.getenv("CRYPTO_URL_2")
update <- fromJSON(url2)
update <-update$payload

#menggabungkan crypto dan update
data_crypto <- merge(crypto,update,by="pair")

data_json <- data_crypto %>% select(pair,currencyGroup,name,logo,latestPrice,day,week,month,year)

data_json[,5:9] <- lapply(data_json[,5:9], as.numeric) 

#koneksi ke mongodb
cs = Sys.getenv("CRYPTO_MONGO_CON")
harga_crypto_collection = mongo(collection=Sys.getenv("CRYPTO_MONGO_COL"), db=Sys.getenv("CRYPTO_MONGO_DB"), url=cs)

#insert data_json
if(harga_crypto_collection$count() > 0){
  harga_crypto_collection$remove('{}')
}
harga_crypto_collection$insert(data_json)
