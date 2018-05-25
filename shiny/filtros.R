
filtrosUI = function(id) {
  ns = NS(id)
  
  box(title = "Filtros", 
    checkboxGroupInput(ns("filtros"),
      label = "Fontes",
      choices = FONTES,
      selected = FONTES
    ),
    selectInput(ns("especie"), "Busca por espécie", 
                choices = c("", nomesEspecies), selectize = TRUE),
    selectInput(ns("taxonid"), "Busca por Taxonomy ID (NCBI)", 
                choices = c("", taxonIDs), selectize = TRUE),
    checkboxInput(ns("modoPeriodo"), "Ativar busca por período?", value = FALSE),
    dateRangeInput(ns("periodo"), "Período das coletas", language = "pt-BR", 
                   min = min(tbEstacoes$data, na.rm = TRUE),
                   start = min(tbEstacoes$data, na.rm = TRUE),
                   max = max(tbEstacoes$data, na.rm = TRUE),
                   end = max(tbEstacoes$data, na.rm = TRUE)) %>% disabled(),
    width = NULL, solidHeader = TRUE, collapsible = TRUE)
}

filtros = function(input, output, session, common) {
  observeEvent(input$especie, {
    if (input$especie != "") 
      updateSelectInput(session, "taxonid", selected = "")
  })
  
  observeEvent(input$taxonid, {
    if (input$taxonid != "") 
      updateSelectInput(session, "especie", selected = "")
  })
  
  observe({
    if (any(is.na(input$periodo)))
      return()
      
    tb = tbEstacoes %>% 
      filter(fonte %in% input$filtros)
    
    if (input$modoPeriodo)
      tb %<>% filter(data >= input$periodo[1] & data <= input$periodo[2])
    
    if (input$especie != "") {
      
      ids = especies %>% 
        filter(grepl(input$especie, `Nome Atribuido`, ignore.case = TRUE, fixed = TRUE)) %>%
        pull(Amostras)
      
      tb %<>% filter(id %in% ids)
    }
    
    if (input$taxonid != "") {

      ids = especies %>% 
        filter(TaxonID == input$taxonid) %>%
        pull(Amostras) %>%
        c(taxonBB %>% 
          filter(ncbitaxon == input$taxonid) %>%
          pull(station))
      
      tb %<>% filter(id %in% ids)
    }
    
    common$react$tbEstacoes = tb
  })
  
  observeEvent(input$modoPeriodo, {
    common$react$modoPeriodo = input$modoPeriodo
    
    if (input$modoPeriodo)
      enable("periodo")
    else
      disable("periodo")
  })
}