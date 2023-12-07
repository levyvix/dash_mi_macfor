install.packages("pacman")
library(pacman)
p_load(tidyverse, janitor, bizdays, googlesheets4, aws.lambda)

gs4_auth(
  email = "levy.nunes@macfor.com.br"
)

url_udpi <- "https://docs.google.com/spreadsheets/d/1KgHSTmlLiEcDrDGGawua0l2R2ZYMZFi9rbBOsSvRGTk/edit#gid=91549763"

# extract
udpi <- googlesheets4::read_sheet(
  url_udpi,
  sheet = "Respostas ao formulário 1",
  skip = 0,
)


udpi_clean <- udpi %>%
  clean_names() %>%
  mutate(
    solicitante = str_to_title(solicitante),
    trimestre = quarter(carimbo_de_data_hora) %>% str_c("T", .),
    mes = month(carimbo_de_data_hora, label = FALSE),
  )

udpi_clean %>%
  googlesheets4::sheet_write(
    "https://docs.google.com/spreadsheets/d/1PcU_8lcbElTOARBAYuWxjjz65auyTLjkysaXMfISsrM/edit#gid=0",
    sheet = "UDPI"
  )
