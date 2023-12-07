install.packages("pacman")
library(pacman)
p_load(tidyverse, janitor, bizdays, googlesheets4, aws.lambda)

gs4_auth(
  email = 'levy.nunes@macfor.com.br'
)

url_bi_mate = 'https://docs.google.com/spreadsheets/d/1YAsLnEWUmqd7niwTcGL8sCDmXgQWpYXrUvUt71_5Bf0/edit?resourcekey#gid=1219493758'

bi_mate = googlesheets4::read_sheet(
  url_bi_mate,
  sheet="Respostas ao formulário 1"
)

bi_mate_clean = bi_mate %>%
  clean_names() %>%
  select(carimbo_de_data_hora, solicitante, de_qual_area_voce_e, que_tipo_de_material_voce_precisa,
         qual_o_publico_que_sua_estrategia_quer_atingir, por_que_esta_solicitando_uma_pesquisa) %>%
  mutate(
    solicitante = str_split_i(solicitante, "-", 1) %>% str_squish(),
    carimbo_de_data_hora = date(carimbo_de_data_hora),
    nome = NA,
    data_finalizado = NA,
    percepcao = NA,

  ) %>%
  dplyr::rename(
    data_solicitado = carimbo_de_data_hora,
    area_solicitante = de_qual_area_voce_e,
    tipo_material = que_tipo_de_material_voce_precisa,
    publico = qual_o_publico_que_sua_estrategia_quer_atingir,
    objetivo = por_que_esta_solicitando_uma_pesquisa
  )


bi_mate_clean %>%
  googlesheets4::sheet_write(
    'https://docs.google.com/spreadsheets/d/1PcU_8lcbElTOARBAYuWxjjz65auyTLjkysaXMfISsrM/edit#gid=0',
    sheet='Materiais e Estudos Novo'
  )


# union velho + novo

# ler do velho

url_bi = 'https://docs.google.com/spreadsheets/d/1PcU_8lcbElTOARBAYuWxjjz65auyTLjkysaXMfISsrM/edit#gid=0'

bi_mate_velho = read_sheet(
  url_bi,
  sheet = 'Materiais e Estudos Velho',
) %>%
  mutate(data_solicitado = date(data_solicitado))


# union

df_union = union(bi_mate_clean, bi_mate_velho)





df_union %>%
  googlesheets4::sheet_write(
    'https://docs.google.com/spreadsheets/d/1PcU_8lcbElTOARBAYuWxjjz65auyTLjkysaXMfISsrM/edit#gid=0',
    sheet='Materiais e Estudos Junto'
  )


