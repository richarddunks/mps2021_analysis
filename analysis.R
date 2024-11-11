# install.packages('RPostgres')
# install.packages('config')

library(RPostgres)

db <- config::get("postgres-utd")

con<-dbConnect(RPostgres::Postgres(),
               dbname = db$dbname,
               host = db$host,
               port=db$port,
               user=db$user,
               password=db$password)

query <- "SELECT * FROM  mps_training;"

result <- dbGetQuery(con,query)
