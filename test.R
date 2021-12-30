library(tidyverse)
library(rtweet)

# Creación Twitter Token
test_ghactions_twitter_r_token <- rtweet::create_token(
  app = "test_ghactions_twitter_r",
  consumer_key =    Sys.getenv("TWITTER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_API_KEY_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

#Lectura del CSV


#Manipulación ligera de datos sobre el CSV


#Visualización de datos


#Generación de PNG


#Publicación del tweet
rtweet::post_tweet(
  status=paste0('Iniciación a TWITTER API + R + GITHUB ACTIONS. Actualización en la fecha ', Sys.time()),
  token=test_ghactions_twitter_r_token
)
