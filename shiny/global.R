
library(shiny)
library(shinydashboard)
library(shinyjs)
library(leaflet)
library(raster)

library(dplyr)
library(dbplyr)
library(rlang)
library(magrittr)
library(DBI)
library(RPostgreSQL)

library(glue)
library(purrr)
library(formattable)

setwd("..")

source("scripts/funcoes_auxiliares.R")
select = dplyr::select

source("shiny/mapa.R", encoding = "UTF-8")
source("shiny/filtros.R", encoding = "UTF-8")
source("shiny/barra.R", encoding = "UTF-8")
source("shiny/graficos.R", encoding = "UTF-8")

connection = newConnection()

especies = readRDS("data/especies.rds")
taxonBB = readRDS("data/taxonBB.rds")

nomesEspecies = especies %>% 
  arrange(`Nome Atribuido`) %>%
  pull(`Nome Atribuido`) %>%
  unique

taxonIDs = especies %>% 
  filter(!is.na(TaxonID)) %>%
  pull(TaxonID) %>% 
  c(taxonBB$ncbitaxon) %>%
  sort %>%
  unique

tbEstacoes = tbl(connection, "estacoes") %>% collect()
tbEstacoes %<>% 
  mutate(
    data = as.Date(data),
    classificacao = ifelse(total == 190, "Sensível", classificacao)
  )

FONTES = tbEstacoes$fonte %>% unique

r = readRDS("data/raster_seguranca.rds")
pal = colorNumeric(c("orange", "yellow", "green"), values(r), na.color = NA)
