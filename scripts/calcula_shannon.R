
library(magrittr)
library(dplyr)
library(dbplyr)
library(DBI)
library(RPostgreSQL)

# calcula o índice shannon a nível de família

source("scripts/funcoes_auxiliares.R")

printf("Conectando ao banco de dados...\n")

connection = newConnection()

printf("Conectado com sucesso!\n")

tb = tbl(connection, "listagens_biodiversidade") %>% 
  select(ncbitaxon, station) %>% 
  filter(!is.na(ncbitaxon), !is.na(station)) %>%
  collect()

arvore = readRDS("data/arvore.rds")

printf("Recuperando famílias dos fragmentos...\n")

## shannon digial

tb %<>% 
  mutate(
    family = upTo(ncbitaxon, "family", arvore)
  )

printf("Computando índice de Shannon...\n")

shannon = tb %>%
  filter(!is.na(family)) %>%
  group_by(station, family) %>% 
  summarise(contagem = n()) %>%
  group_by(station) %>%
  summarise(hshannon = DiversitySampler::Hs(contagem)) 

shannon %>% 
  glue_data("UPDATE estacoes SET hshannon = {hshannon} WHERE id = '{station}';") %>%
  walk(dbSendStatement, conn = connection)

## shannon analógico



dbDisconnect(connection)

printf("Finalizado!\n")
