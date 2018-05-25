
dashboardPage(
  dashboardHeader(disable = TRUE),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Principal", tabName = "tabPrincipal")
    ),
    disable = TRUE
  ),
  dashboardBody(
    tabItem(
      tabName = "Principal",
      fluidRow(
        useShinyjs(),
        column(width = 8,
          tabBox(title = "",
            mapaUI("mapa"),
            graficosUI("graficos"),
            width = NULL
          )
        ),
        column(width = 4,
          barraUI("barra"),
          filtrosUI("filtros")
        )
      )
    )
  )
)