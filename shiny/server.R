
function(input, output, session) {
  common = new.env()
  common$react = reactiveValues(
    selecionada = NULL,
    row = NULL,
    tbEstacoes = tbEstacoes,
    modoPeriodo = FALSE
  )
  
  callModule(mapa, "mapa", common)
  callModule(graficos, "graficos", common)
  callModule(filtros, "filtros", common)
  callModule(barra, "barra", common)
  
  session$onSessionEnded(function() {
    dbDisconnect(connection)
  })
}