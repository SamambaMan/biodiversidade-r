
graficosUI = function(id) {
  ns = NS(id)
  
  tabPanel(title = "Segurança Ambiental",
   formattableOutput(ns("seguranca")),
   value = 2
  )
}

graficos = function(input, output, session, common) {
  output$seguranca = renderFormattable({
    if (is.null(common$react$selecionada))
      return(NULL)
    
    peso_baixo = map_dbl(2:11, ~ pesos(.)[1])
    peso_medio = map_dbl(2:11, ~ pesos(.)[2])
    peso_alto = map_dbl(2:11, ~ pesos(.)[3])
    
    tb = common$row$selecionada
    tb = data.frame(
      "Parâmetro" = c(
        "Índice de Shannon",
        "Presença de baleias",
        "Presença de tartarugas",
        "Presença de corais",
        "Presença de rodolitos",
        "Presença de crustáceos",
        "Presença de poliquetos",
        "Presença de moluscos",
        "Ausência de invasores",
        "Ausência de indicadores de poluição",
        "Total"
      ),
      "Pesos" = c(glue("Alto = {peso_alto}, Médio = {peso_medio}, Baixo = {peso_baixo}"), ""),
      "Valor" = common$react$row %>% 
        select(starts_with("parametro")) %>% 
        as_vector %>% 
        set_names(NULL) %>%
        c(common$react$row$total)
    )
    
    peso_baixo = c(peso_baixo, sum(peso_baixo))
    peso_medio = c(peso_medio, sum(peso_medio))
    peso_alto = c(peso_alto, sum(peso_alto))
    
    formattable(tb, list(
      Valor = formatter("span", 
        style = ~ glue("background-color: {color}; padding: 5px; border-radius: 2px;", color = 
          if_else(Valor == peso_alto, "#ACDC6F", 
            if_else(Valor == peso_baixo, "#FF9594", "#FFCC5D")))
      )
    ))
  })
}