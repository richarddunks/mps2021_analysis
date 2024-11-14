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

# Begin the descriptive analysis
library(dplyr)
# number of agencies
n_distinct(result$mps_agency)
# count of responses by agency
result %>% group_by(mps_agency) %>% summarize(count_resp = n()) %>% print(n=Inf)
# count responses by gender
result %>% group_by(c_gender) %>% summarize(count_resp = n()) %>% print(n=Inf)
# count responses by race/ethnicity
result %>% group_by(c_race_eth) %>% summarize(count_resp = n()) %>% print(n=Inf)