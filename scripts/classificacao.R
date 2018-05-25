
library(magrittr)
library(dplyr)
library(dbplyr)
library(DBI)
library(RPostgreSQL)
library(purrr)
library(glue)

source("scripts/funcoes_auxiliares.R")

parametros = readRDS("data/parametros.rds")
arvore = readRDS("data/arvore.rds")

familia_parametros = map(parametros, upTo, "family", arvore)

connection = newConnection()

tb = tbl(connection, "listagens_biodiversidade") %>% 
  select(ncbitaxon, station) %>% 
  filter(!is.na(ncbitaxon), !is.na(station)) %>%
  collect()

tb %<>% mutate(
  family = upTo(ncbitaxon, "family", arvore),
  genus = upTo(ncbitaxon, "genus", arvore),
  species = upTo(ncbitaxon, "species", arvore)
)

contaAparicoes = function(df, ids) {
  map_int(ids, ~ any(df$family == .) %>% as.integer) %>% 
    sum(na.rm = TRUE)
}

tbEstacoes = tbl(connection, "estacoes") %>% 
  collect()

shannon = tbEstacoes$hshannon %>% 
  set_names(tbEstacoes$id)

# analogico
shannon = amostras %>% 
  filter(!is.na(hshannon) & !is.null(hshannon))

shannon = shannon$hshannon %>%
  set_names(shannon$Amostra)

classifica = function(tb) {
  #station = tb$station[1]
  station = tb$Amostras[1]
  print(station)
  if (!(station %in% names(shannon)))
    return(data.frame())
  
  indices = map_int(as.character(3:11), ~ contaAparicoes(tb, familia_parametros[[.]])) %>%
    map2_int(c(rep(TRUE, 7), FALSE, FALSE), function(conta, presenca) {
      if (!presenca) 
        conta = 3L - conta
      
      if (conta == 3L) 
        3L 
      else if (conta == 1L) 
        2L 
      else 
        1L
    })
  
  indices = c(if (shannon[station] >= 5)
      3L
    else if (shannon[station] >= 3)
      2L
    else
      1L, indices)
  
  X = map_dbl(2:11, ~ pesos(.)[1]) %>% sum
  Y = map_dbl(2:11, ~ pesos(.)[3]) %>% sum
  
  pontos = map_dbl(1:length(indices), ~ pesos(.+1)[indices[.]])
  
  params = data.frame(cod_amostra = station)
  
  for (i in 1:10) {
    params[[glue("parametro_{i+1}")]] = pontos[i]
  }
  
  params$total = sum(pontos)
  
  params$classificacao = if (sum(pontos) == Y) 
    "Sensível"
  else if (sum(pontos) > X) 
    "Natural"
  else 
    "Impactado"
  
  params
}

res = especies %>%
  group_by(Amostras) %>%
  do(classifica(.))

# res = tb %>%
#   group_by(station) %>%
#   do(classifica(.))

dbDisconnect(connection)
