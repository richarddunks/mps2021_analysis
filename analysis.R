# install.packages('RPostgres')
# install.packages('config')

library(DBI)
# load the configuration parameters from the config.yml file
# don't use the library(config) because will mask get function in base R
db <- config::get("postgres-utd")

# instantiate the connection object from DBI package using the Postgres function from RPostgres library
con<-dbConnect(RPostgres::Postgres(),
               dbname = db$dbname,
               host = db$host,
               port=db$port,
               user=db$user,
               password=db$password)

# query string
query <- "SELECT * FROM  mps_training;"

# execute query and load the result as a dataframe for analysis
result <- dbGetQuery(con,query)
