install.packages("pacman")
library(pacman)
p_load(tidyverse, janitor, bizdays, googlesheets4, anytime)

gs4_auth(
  email = 'levy.nunes@macfor.com.br'
)

url_bi_diagnosticos = 'https://docs.google.com/spreadsheets/d/1TMtZBsiL3h8xV0WRGcwAyhF159VPgv4DEYjrJZDUDps/edit#gid=1061044773'

# extract
bi_diag = googlesheets4::read_sheet(
  url_bi_diagnosticos,
  sheet="Info. Diagnósticos (2023)",
  skip=3,
  )


bi_diag

# transform
bi_diag_clean = bi_diag %>%
  janitor::clean_names() %>%
  filter(!responsavel == 'Responsável')


bi_diag_clean_transformed = bi_diag_clean %>%
  mutate(
    data_solicitacao = anytime::anydate(data_solicitacao %>% unlist()),
    prazo =  anydate(prazo %>% unlist()),
    entrega = anydate(entrega %>% unlist())
    ) %>%
  filter(year(data_solicitacao) > 2022) %>%
  mutate(
    entrega = case_when(
      year(entrega) < 2000 ~ NA,
      TRUE ~ entrega
    ),
    trimestre = quarter(prazo) %>% str_c("T", .),
    tempo_execucao =  bizdays::bizdays(data_solicitacao, entrega, "Brazil/ANBIMA"),
    nivel = nivel %>% str_c("N", .),
    mes = month(entrega, label=F)
  ) %>%
  select(-c(no))



# load
bi_diag_clean_transformed %>%
  googlesheets4::sheet_write(
    'https://docs.google.com/spreadsheets/d/1PcU_8lcbElTOARBAYuWxjjz65auyTLjkysaXMfISsrM/edit#gid=0',
    sheet='Diagnósticos'
  )



