
library(readxl)
library(magrittr)
library(dplyr)
library(purrr)
library(stringr)

source("scripts/funcoes_auxiliares.R", encoding = "UTF-8")

arvore = readRDS("data/arvore.rds")

amostras = read_excel("~/Downloads/Amostras_Especies2lurodrigo-V2.xlsx")
especies = read_excel("~/Downloads/Amostras_Especies2lurodrigo-V2.xlsx", sheet = "EspeciesAll") %>%
  mutate(TaxonID = as.character(TaxonID))

especies %<>% 
  mutate(
    species = upTo(TaxonID, "species", arvore),
    genus = upTo(TaxonID, "genus", arvore),
    family = upTo(TaxonID, "family", arvore)
  )

# faz_relacional = function(tb) {
#   data.frame(
#     cod_amostra = str_split(tb$Amostras, ";")[[1]] %>% str_trim(),
#     cod_especie = tb$COD
#   )  
# }
# 
# amostras_x_especies = especies %>%
#   group_by(COD) %>%
#   do(faz_relacional(.)) %>%
#   ungroup %>%
#   select(starts_with("cod_"))

# tbJoined = inner_join(amostras_x_especies, especies%>% select(COD, species:family), by = c("cod_especie" = "COD"))

shannon = especies %>%
  filter(!is.na(family)) %>%
  group_by(Amostras, family) %>% 
  summarise(contagem = n()) %>%
  group_by(Amostras) %>%
  summarise(hshannon = DiversitySampler::Hs(contagem)) %>%
  select(Amostras, hshannon)

amostras = left_join(amostras, shannon, by = c("Amostra" = "Amostras"))
