# biodiversidade

## Dependências:
```
$ sudo apt-get install gdebi-core libpq-dev libgdal-dev r-base
$ wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.7.907-amd64.deb
$ sudo gdebi shiny-server-1.5.7.907-amd64.deb
```

## Dependências R:
```
> install.packages(
  c("tidyverse",
    "dbplyr", 
    "RPostgreSQL", 
    "rlang", 
    "shiny", 
    "shinydashboard",
    "leaflet", 
    "raster",
    "formattable",
    "shinyjs",
    "rgdal",
    "DiversitySampler")
 )
> 
```
