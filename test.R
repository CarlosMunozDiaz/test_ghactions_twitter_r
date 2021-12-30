library(tidyverse)
library(rtweet)

# Creación Twitter Token
test_ghactions_twitter_r_token <- rtweet::create_token(
  app = "test_ghactions_rtweet",
  consumer_key =    Sys.getenv("TWITTER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_API_KEY_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

#Lectura del CSV > Prueba siempre con la fecha menos un día > Hasta ver patrones de publicación, hacemos prueba con string directamente
#date <- Sys.Date() - 1
uci_data <- read.csv2(paste0('https://www.mscbs.gob.es/profesionales/saludPublica/ccayes/alertasActual/nCov/documentos/Datos_Capacidad_Asistencial_Historico_', '29122021' ,'.csv'))

#Manipulación ligera de datos sobre el CSV > Nos quedamos con los datos de España
uci_data <- uci_data %>%
  filter(Unidad != 'Hospitalización convencional') %>%
  group_by(Fecha) %>%
  summarise(
    total_camas = sum(TOTAL_CAMAS),
    ocupadas_covid = sum(OCUPADAS_COVID19),
    ocupadas_nocovid = sum(OCUPADAS_NO_COVID19)
  ) %>%
  mutate(
    porc_ocupacion_covid = (ocupadas_covid * 100) / total_camas,
    porc_ocupacion_nocovid = (ocupadas_nocovid * 100) / total_camas,
    porc_ocupacion_total = porc_ocupacion_covid + porc_ocupacion_nocovid
  )
uci_data$Fecha <- as.Date(uci_data$Fecha, format = "%d/%m/%Y")
uci_data <- uci_data %>%
  arrange(Fecha)

#Visualización de datos
uci_data_wider <- uci_data %>% select(Fecha, porc_ocupacion_covid, porc_ocupacion_nocovid)
uci_data_longer <- pivot_longer(uci_data_wider, cols = starts_with("porc"), names_to = 'tipo', values_to = 'valor')
uci_data_longer$tipo_2 <- factor(uci_data_longer$tipo, sort(unique(uci_data_longer$tipo), decreasing = TRUE))

png <- ggplot(uci_data_longer, aes(x=Fecha, y=valor, fill=tipo_2)) + 
  geom_area() +
  geom_hline(yintercept = 25) +
  ylim(0,100) +
  ylab('% de ocupación') +
  labs(
    title = 'Evolución de la ocupación de UCI en España',
    subtitle = 'Del 1 de agosto de 2020 al 28 de diciembre de 2021'
  ) +
  theme_minimal() +
  theme(
    legend.position = 'top',
    legend.title = element_blank()
  )

#Generación de PNG
ggsave(plot = png, filename = './test_ghactions_uci_data.png', units = 'in', width = 7.5, height = 4.5, dpi = 300)


#Publicación del tweet
rtweet::post_tweet(
  status=paste0('Nuevo test básico TWITTER API + R(DPLYR+GGPLOT2) + GITHUB ACTIONS con imagen. Ocupación de UCIs en España'),
  media='./test_ghactions_uci_data.png',
  token=test_ghactions_twitter_r_token
)
