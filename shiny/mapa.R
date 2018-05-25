
mapaUI = function(id) {
  ns = NS(id)
  
  tabPanel(title = "Mapa",
    leafletOutput(ns("lfobj"), height = 500),
    value = 1
  )
}

makeMarkers = function(tb, check = FALSE) {
  awesomeIcons(
    icon = if (check) "check-circle" else "",
    iconColor = "black",
    library = "fa",
    markerColor = tb$color
  )
}

mapa = function(input, output, session, common) {
  
  output$lfobj = renderLeaflet({
    isolate({
      leaflet(common$react$tbEstacoes) %>%
        addProviderTiles(providers$Esri.WorldImagery) %>%
        addAwesomeMarkers(
          icon = makeMarkers(common$react$tbEstacoes),
          options = markerOptions(opacity = 0.5),
          group = "Amostras",
          label = ~id,
          layerId = ~id,
          lat = ~latitude, 
          lng = ~longitude
        ) %>%
        addRasterImage(r, colors = pal, opacity = 0.8, group = "Isolinhas") %>%
        addPolylines(data = rasterToContour(r), group = "Isolinhas", weight = 1,
                     color = "black") %>%
        addLayersControl(
          overlayGroups = c("Amostras", "Isolinhas"), 
          options = layersControlOptions(collapsed = FALSE)
        ) %>%
        hideGroup("Isolinhas")
    })
  })
  
  observeEvent(common$react$tbEstacoes, {
    if (is.null(common$react$tbEstacoes) || nrow(common$react$tbEstacoes) == 0)
      return(NULL)
    leafletProxy("lfobj") %>%
      clearMarkers() %>%
      addAwesomeMarkers(
        icon = makeMarkers(common$react$tbEstacoes),
        options = markerOptions(opacity = 0.5),
        group = "Amostras",
        label = common$react$tbEstacoes$id,
        layerId = common$react$tbEstacoes$id,
        lat = common$react$tbEstacoes$latitude, 
        lng = common$react$tbEstacoes$longitude
      )
  })
  
  # controla a selecionada
  observe({
    if (is.null(input$lfobj_marker_click)) 
      return(NULL)
    
    lf = leafletProxy("lfobj")
    row = common$react$row
    
    if (!is.null(common$react$selecionada)) {
      lf %>%
        removeMarker(common$react$selecionada) %>%
        addAwesomeMarkers(
          icon = makeMarkers(row),
          options = markerOptions(opacity = 0.5),
          group = "Amostras",
          label = row$id,
          layerId = row$id, 
          lat = row$latitude, 
          lng = row$longitude
        ) 
    }
    
    lf %>% removeMarker(input$lfobj_marker_click$id)
    
    common$react$selecionada = input$lfobj_marker_click$id
    common$react$row = tbEstacoes %>% 
      filter(id == common$react$selecionada)
    row = common$react$row
    
    lf %>%
      removeMarker(common$react$selecionada) %>%
      addAwesomeMarkers(
        icon = makeMarkers(row, TRUE),
        options = markerOptions(opacity = 1),
        group = "Amostras",
        label = row$id,
        layerId = row$id, 
        lat = row$latitude, 
        lng = row$longitude
      )
  })
  
}