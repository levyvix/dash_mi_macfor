install.packages("pacman")
library(pacman)
p_load(tidyverse, janitor, bizdays, googlesheets4, aws.lambda)

gs4_auth(
  email = "levy.nunes@macfor.com.br"
)

url_conc_diagnosticos <- "https://docs.google.com/spreadsheets/d/1JsUuyXgi0KPYbpnxmpyQyO4PRjCoEGkWbnAylTdQKMA/edit#gid=0"

# extract
conc_diag <- googlesheets4::read_sheet(
  url_conc_diagnosticos,
  sheet = "2023",
  skip = 1,
) %>% select(Marca:Resultado)



mapa_meses <- tibble(
  Mês = c(
    "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
    "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
  ),
  numero = 1:12
)

conc_diag_clean <- conc_diag %>%
  select(Marca, Mês, Tipo, Origem, Resultado) %>%
  drop_na() %>%
  left_join(mapa_meses, by = "Mês") %>%
  mutate(data = as.Date(paste0("2023-", sprintf("%02d", numero), "-01"))) %>%
  mutate(
    mes = month(data),
    trimestre = quarter(data)
  ) %>%
  select(-c(numero, Mês))


conc_diag_clean %>%
  googlesheets4::sheet_write(
    "https://docs.google.com/spreadsheets/d/1PcU_8lcbElTOARBAYuWxjjz65auyTLjkysaXMfISsrM/edit#gid=0",
    sheet = "Concorrencias"
  )
