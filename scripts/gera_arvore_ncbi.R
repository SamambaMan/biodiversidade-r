
# gera_arvore_rcbi.R
# 
# Baixa o arquivo contendo os taxon ids do NCBI e gera uma árvore adequada
# 

library(readr)
library(purrr)

download.file("ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdmp.zip", 
              destfile = "data/download.zip")

unzip("data/download.zip", exdir = "data/download")

nodes = read_delim("data/download/nodes.dmp", 
                   "\t", escape_double = FALSE, col_names = FALSE, 
                   trim_ws = TRUE) %>% 
  select(id = X1, parent = X3, rank = X5) %>%
  mutate(id = as.character(id), parent = as.character(parent))

named_vector = 1:nrow(nodes)
names(named_vector) = nodes$id
arvore = map(named_vector, ~ list(parent = nodes$parent[.], rank = nodes$rank[.]))

saveRDS(arvore, "data/arvore.rds")

file.remove("data/download.zip")
unlink("data/download", recursive = TRUE)