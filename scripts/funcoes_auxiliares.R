
printf = function(...) cat(sprintf(...))

newConnection = function() {
  invoke(DBI::dbConnect,
    c(RPostgreSQL::PostgreSQL(), yaml::yaml.load_file("config/database.yaml"))
  )
}

upTo_ = function(id, level, arvore) {
  while (TRUE) {
    if (is.na(id) || is.null(arvore[[id]]) || id == "1")
      return(NA)
    if (arvore[[id]]$rank == level)
      return(id)
    id = arvore[[id]]$parent
  }
}

upTo = Vectorize(upTo_, "id", USE.NAMES = FALSE)

pesos = function(x) {
  x = as.integer(x)
  if (x <= 4 || x >= 7 && x <= 9) c(1, 5, 21)
  else if (x == 5) c(1, 55, 144)
  else c(1, 34, 89)
}

