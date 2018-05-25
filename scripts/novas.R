
novas = amostras %>% 
  mutate(
    id = Amostra, 
    latitude = `Latitude (graus)`, 
    longitude = `Longitude (graus)`,
    profundidade = ifelse(!is.na(`Profundidade da Aostra ()`), 
                                 `Profundidade da Aostra ()`, 
                                 `Profundidade da Estacao (m)`)
    
  ) %>%
  select(hshannon:profundidade)

tbEstacoes %<>% 
  bind_rows(novas)