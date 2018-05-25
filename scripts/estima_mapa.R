
library(dplyr)
library(dbplyr)
library(rlang)
library(magrittr)
library(DBI)
library(RPostgreSQL)

source("scripts/funcoes_auxiliares.R")
connection = newConnection()
tbEstacoes = tbl(connection, "estacoes") %>% collect()
dbDisconnect(connection)

library(geosphere)
library(raster)
library(sf)
library(glue)

lngmin = min(tbEstacoes$longitude, na.rm = TRUE) - .01
lngmax = max(tbEstacoes$longitude, na.rm = TRUE) + .01
latmin = min(tbEstacoes$latitude, na.rm = TRUE) - .01
latmax = max(tbEstacoes$latitude, na.rm = TRUE) + .01

DIM = 500

toIJ = function(i) {
  cbind((i-1) %% DIM + 1, (i-1) %/% DIM + 1)
}

toCoord = function(tb) {
  cbind(lngmin + (lngmax - lngmin)*tb[, 1]/DIM, latmax + (latmin - latmax)*tb[, 2]/DIM)
}

if (file.exists(glue("data/dentro_{DIM}.rds"))) {
  dentro_brasil = readRDS(glue("data/dentro_{DIM}.rds"))
} else {
  # calcula os índices do raster que estão dentro do BRASIL
  # eventualmente serão setados como NA
  brasil = readRDS("data/brmap_brasil.rds")
  
  st_pontos = toCoord(toIJ(1:(DIM*DIM))) %>%
    st_multipoint %>% 
    st_sfc %>% 
    st_cast("POINT") %>%
    st_set_crs(4326)
  
  dentro_brasil = st_contains(brasil, st_pontos)[[1]]
  saveRDS(dentro_brasil, glue("data/dentro_{DIM}.rds"))
}

# remove as linhas em que Total é NA
quais = which(!is.na(tbEstacoes$total) & !is.na(tbEstacoes$latitude))
#quais = sample(quais, 100, replace = TRUE)

coords = cbind(tbEstacoes$longitude[quais], tbEstacoes$latitude[quais])
dists = distm(toCoord(toIJ(1:(DIM*DIM))), coords)

# calcula médias de Total[1:n], ponderados pelos inversos dos quadrados
# das distâncias aos pontos
inv = 1 / (dists * dists)
result = inv %*% tbEstacoes$total[quais] / rowSums(inv)

result[dentro_brasil, 1] = NA

r = raster(matrix(result[, 1], DIM, DIM, byrow = TRUE))
extent(r) = c(lngmin, lngmax, latmin, latmax)
projection(r) = CRS("+proj=longlat +datum=WGS84")

saveRDS(r, "data/raster_seguranca.rds")
