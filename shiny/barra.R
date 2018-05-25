
barraUI = function(id) {
  ns = NS(id)  
  
  div(
    valueBoxOutput(ns("indice"), width = NULL) %>% hidden
  )
  
}

barra = function(input, output, session, common) {
  observeEvent(common$react$selecionada, {
    showElement("indice")
    
    runjs(glue("$('#barra-titulo .box-title').html('Estação {common$react$selecionada}')"))
  })
  
  output$indice = renderValueBox({
    row = common$react$row
    
    if (is.null(row))
      return(NULL)
    
    valueBox(
      glue("{row$id}"),
      HTML(glue("<p>Data de Coleta: {if (!is.na(data)) strftime(row$data, '%d/%m/%Y') else 'Não informada'}</p>",
                "<p>Índice H de Shannon: {hshannon = if (is.na(row$hshannon)) \"Não calculado\" else sprintf('<strong>%.1f</strong>', row$hshannon)}<br/>",
                'Índice de Segurança Ambiental: {if (is.na(row$total)) "Não calculado" else sprintf("<strong>%s</strong>", row$total)}<br/>',
                'Classificação: <strong>{row$classificacao}</strong></p>',
                "<p>Coordenadas: {sprintf('%.6f', row$latitude)}, {sprintf('%.6f', row$longitude)}<br/>",
                "Profundidade: {row$profundidade}<br/></p>")),
      color = "blue"
    )
  })
}
