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

# how many are eligible to retire
result %>% group_by(c_retire_elg) %>% summarize(count_resp = n()) %>% print(n=Inf)

# explore results for those eligible to retire on independent variables
result %>% filter(c_retire_elg==1) %>% group_by(d_resign_gov) %>% summarize(count_resp = n()) %>% print(n=Inf)
result %>% filter(!c_retire_elg==1) %>% group_by(d_resign_gov) %>% summarize(count_resp = n()) %>% print(n=Inf)

# filter out those who are eligible to retire
query <- "SELECT * FROM  mps_training WHERE c_retire_elg = '0';"
# execute query and load the result as a dataframe for analysis
result <- dbGetQuery(con,query)

# breakdown the responses to the main questions (i_prov_nec_train & d_resign_gov)
result %>% group_by(i_prov_nec_train) %>% summarize(count_resp = n()) %>% print(n=Inf)
result %>% group_by(d_resign_gov) %>% summarize(count_resp = n()) %>% print(n=Inf)
result %>% group_by(mps_supervisor) %>% summarize(count_resp = n()) %>% print(n=Inf)
result %>% group_by(c_gender) %>% summarize(count_resp = n()) %>% print(n=Inf)
result %>% group_by(c_age) %>% summarize(count_resp = n()) %>% print(n=Inf)
# filter out those who are eligible to retire, and provided numerical responses to the two main questions (i_prov_nec_train & d_resign_gov)
query <- "SELECT 
            i_prov_nec_train::int, 
            d_resign_gov::int 
          FROM mps_training 
          WHERE c_retire_elg = '0' AND 
          (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL) AND 
          (d_resign_gov != 'D' AND d_resign_gov IS NOT NULL);"

# execute query and load the result as a dataframe for analysis
result <- dbGetQuery(con,query)

# histograms of the values
hist(result$d_resign_gov)
hist(result$i_prov_nec_train)

# plot of the regression results
plot(result)
abline(lm(result$d_resign_gov ~ result$i_prov_nec_train), col="red")

### Intent to Turnover measures
query <- "SELECT
  mps_weight,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average, 
	d_resign_gov::int
FROM mps_training 
WHERE c_retire_elg = '0' 
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	AND (d_resign_gov != 'D' AND d_resign_gov IS NOT NULL);"
result <- dbGetQuery(con,query)

# plot(result)
# abline(lm(result$d_average ~ result$i_average, weights = result$mps_weight), col="red")
# lm(result$d_average ~ result$i_average, weights = result$mps_weight)

# histograms of the values
hist(result$i_average, main=NULL,xlab="Average of Responses",ylab="Count of Responses",ylim=range(0,6500))
mean(result$i_average)

hist(result$d_resign_gov, main=NULL,xlab="Response Value",ylab="Count of Responses",ylim=range(0,12000))
sink("itt_lm_summary.txt")
print(paste("mean ",mean(result$d_resign_gov)))
print(paste("r-value ",cor(result$i_average,result$d_resign_gov)))
model <- lm(result$d_resign_gov ~ result$i_average, weights = result$mps_weight)
print(summary(model))
sink()

## Personal Job Satisfaction
query <- "SELECT
  mps_weight,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average,
	(d_meaningful_work::DECIMAL + d_recommend_agency::DECIMAL + d_use_job_skills::DECIMAL)/3 as d_average
FROM mps_training 
WHERE 
	-- independent variables
	(i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- dependent variables
	AND (d_meaningful_work != 'D' AND d_meaningful_work IS NOT NULL)
	AND (d_recommend_agency != 'D' AND d_recommend_agency IS NOT NULL)
	AND (d_use_job_skills != 'D' AND d_use_job_skills IS NOT NULL);"
result <- dbGetQuery(con,query)

# plot(result)
# abline(lm(result$d_average ~ result$i_average, weights = result$mps_weight), col="red")

# histograms of the values
hist(result$i_average, main=NULL,xlab="Average of Responses",ylab="Count of Responses",ylim=range(0,8500))
mean(result$i_average)

hist(result$d_average, main=NULL,xlab="Average of Responses",ylab="Count of Responses",ylim=range(0,10000))
model <- lm(result$d_average ~ result$i_average, weights = result$mps_weight)
sink("pjs_lm_summary.txt")
print(paste("mean ",mean(result$d_average)))
print(paste("r-value ",cor(result$i_average,result$d_average)))
print(summary(model))
sink()

## Professional Growth Opportunities
query <- "SELECT
  mps_weight,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average,
	(d_take_new_roles::DECIMAL + d_take_high_tech_resp::DECIMAL + d_take_super_resp::DECIMAL)/3 as d_average
FROM mps_training 
WHERE 
  (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- dependent variables
	AND (d_take_new_roles != 'D' AND d_take_new_roles IS NOT NULL)
	AND (d_take_high_tech_resp != 'D' AND d_take_high_tech_resp IS NOT NULL)
	AND (d_take_super_resp != 'D' AND d_take_super_resp IS NOT NULL);"
result <- dbGetQuery(con,query)

# histograms of the values
hist(result$i_average, main=NULL,xlab="Average of Responses",ylab="Count of Responses",ylim=range(0,7000))
mean(result$i_average)

hist(result$d_average, main=NULL,xlab="Average of Responses",ylab="Count of Responses",ylim=range(0,5000))
model <- lm(result$d_average ~ result$i_average, weights = result$mps_weight)
sink("pgo_lm_summary.txt")
print(paste("mean ",mean(result$d_average)))
print(paste("r-value ",cor(result$i_average,result$d_average)))
print(summary(model))
sink()

## Agency Satisfaction
query <- "SELECT
  mps_weight,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average,
	(d_unit_high_qual_prod::DECIMAL + d_use_wf_eff::DECIMAL + d_retain_best::DECIMAL)/3 as d_average 
FROM mps_training
WHERE 
	-- independent variables
	(i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- dependent variables
	AND (d_unit_high_qual_prod != 'D' AND d_unit_high_qual_prod IS NOT NULL)
	AND (d_use_wf_eff != 'D' AND d_use_wf_eff IS NOT NULL)
	AND (d_retain_best != 'D' AND d_retain_best IS NOT NULL);"
result <- dbGetQuery(con,query)

# histograms of the values
hist(result$i_average, main=NULL,xlab="Average of Responses",ylab="Count of Responses",ylim=range(0,5000))
mean(result$i_average)
hist(result$d_average, main=NULL,xlab="Average of Responses",ylab="Count of Responses",ylim=range(0,4000))


hist(result$d_average, main=NULL,xlab="Average of Responses",ylab="Count of Responses",ylim=range(0,6000))
model <- lm(result$d_average ~ result$i_average, weights = result$mps_weight)
sink("as_lm_summary.txt")
print(paste("mean ",mean(result$d_average)))
print(paste("r-value ",cor(result$i_average,result$d_average)))
print(summary(model))
sink()

### multivariate analysis
# install.packages("stargazer")
library("stargazer")

## ITT model
itt_query <- "SELECT
	mps_weight,
	MPS_Agency,
	-- dummy variable for supervisor or executive
	CASE WHEN MPS_Supervisor = 'S' OR MPS_Supervisor = 'X' THEN 1
		ELSE 0 END AS mps_supervisor_dummy,
		CASE WHEN c_gender = '1' THEN 1
		WHEN c_gender = '2' THEN 0
		ELSE NULL END AS is_female,
	c_race_eth::int AS is_minority,
	-- dummy variable for age 39 or less
	CASE 
		WHEN c_age = '4' THEN 0
		WHEN c_age = '1' THEN 1 
		ELSE NULL END AS age_39_less,
	CASE WHEN c_ed_level = '5' THEN 1
		WHEN c_ed_level = '3' THEN 0
		WHEN c_ed_level = '1' THEN 0
		ELSE NULL END AS has_masters_plus,
	c_fair_org_pay::int,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average, 
	d_resign_gov::INT
FROM mps_training 
WHERE c_retire_elg = '0' 
	-- control variables
	AND mps_supervisor IS NOT NULL
	AND c_gender IS NOT NULL
	AND c_race_eth IS NOT NULL
	AND c_age IS NOT NULL
	AND c_ed_level IS NOT NULL
	AND (c_fair_org_pay	 != 'D' AND c_fair_org_pay IS NOT NULL)
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- ITT dependent variables
	AND (d_resign_gov != 'D' AND d_resign_gov IS NOT NULL);"

# execute query and load the result as a dataframe for analysis
itt_result <- dbGetQuery(con,itt_query)

# model building (ITT)
itt_model <- lm(itt_result$d_resign_gov ~ itt_result$i_average + itt_result$mps_supervisor_dummy + itt_result$is_female + itt_result$is_minority + itt_result$age_39_less + itt_result$has_masters_plus + itt_result$c_fair_org_pay, weights = itt_result$mps_weight)
sink("multi_itt_results.txt")
print(summary(itt_model))
sink()

# model building (PJS)
pjs_query <- "SELECT
	mps_weight,
	MPS_Agency,
	-- dummy variable for supervisor or executive
	CASE WHEN MPS_Supervisor = 'S' OR MPS_Supervisor = 'X' THEN 1
		ELSE 0 END AS mps_supervisor_dummy,
	-- gender dummy variable
	CASE WHEN c_gender = '1' THEN 1
		WHEN c_gender = '2' THEN 0
		ELSE NULL END AS is_female,
	c_race_eth::int AS is_minority,
	-- dummy variable for age 39 or less
	CASE 
		WHEN c_age = '4' THEN 0
		WHEN c_age = '1' THEN 1 
		ELSE NULL END AS age_39_less,
	-- dummy variable for education level
	CASE WHEN c_ed_level = '5' THEN 1
		WHEN c_ed_level = '3' THEN 0
		WHEN c_ed_level = '1' THEN 0
		ELSE NULL END AS has_masters_plus,
	c_fair_org_pay::int,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average, 
	(d_meaningful_work::DECIMAL + d_recommend_agency::DECIMAL + d_use_job_skills::DECIMAL)/3 as d_pjs_avg
FROM mps_training 
WHERE 
	-- control variables
	mps_supervisor IS NOT NULL
	AND c_gender IS NOT NULL
	AND c_race_eth IS NOT NULL
	AND c_age IS NOT NULL
	AND c_ed_level IS NOT NULL
	AND (c_fair_org_pay	 != 'D' AND c_fair_org_pay IS NOT NULL)
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- PJS dependent variables
	AND (d_meaningful_work != 'D' AND d_meaningful_work IS NOT NULL)
	AND (d_recommend_agency != 'D' AND d_recommend_agency IS NOT NULL)
	AND (d_use_job_skills != 'D' AND d_use_job_skills IS NOT NULL)
;"

# execute query and load the result as a dataframe for analysis
pjs_result <- dbGetQuery(con,pjs_query)


pjs_model <- lm(pjs_result$d_pjs_avg ~ pjs_result$i_average + pjs_result$mps_supervisor_dummy + pjs_result$is_female + pjs_result$is_minority + pjs_result$age_39_less + pjs_result$has_masters_plus + pjs_result$c_fair_org_pay, weights = pjs_result$mps_weight)
sink("multi_pjs_results.txt")
print(summary(pjs_model))
sink()

# model building (PGO)
pgo_query <- "SELECT
	mps_weight,
	MPS_Agency,
	-- dummy variable for supervisor or executive
	CASE WHEN MPS_Supervisor = 'S' OR MPS_Supervisor = 'X' THEN 1
		ELSE 0 END AS mps_supervisor_dummy,
	-- gender dummy variable
	CASE WHEN c_gender = '1' THEN 1
		WHEN c_gender = '2' THEN 0
		ELSE NULL END AS is_female,
	c_race_eth::int AS is_minority,
	-- dummy variable for age 39 or less
	CASE 
		WHEN c_age = '4' THEN 0
		WHEN c_age = '1' THEN 1 
		ELSE NULL END AS age_39_less,
	-- dummy variable for education level
	CASE WHEN c_ed_level = '5' THEN 1
		WHEN c_ed_level = '3' THEN 0
		WHEN c_ed_level = '1' THEN 0
		ELSE NULL END AS has_masters_plus,
	c_fair_org_pay::int,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average, 
	(d_take_new_roles::DECIMAL + d_take_high_tech_resp::DECIMAL + d_take_super_resp::DECIMAL)/3 as d_pgo_avg
FROM mps_training 
WHERE 
	-- control variables
	mps_supervisor IS NOT NULL
	AND c_gender IS NOT NULL
	AND c_race_eth IS NOT NULL
	AND c_age IS NOT NULL
	AND c_ed_level IS NOT NULL
	AND (c_fair_org_pay	 != 'D' AND c_fair_org_pay IS NOT NULL)
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- PGO dependent variables
	AND (d_take_new_roles != 'D' AND d_take_new_roles IS NOT NULL)
	AND (d_take_high_tech_resp != 'D' AND d_take_high_tech_resp IS NOT NULL)
	AND (d_take_super_resp != 'D' AND d_take_super_resp IS NOT NULL)
;"

# execute query and load the result as a dataframe for analysis
pgo_result <- dbGetQuery(con,pgo_query)

pgo_model <- lm(pgo_result$d_pgo_avg ~ pgo_result$i_average + pgo_result$mps_supervisor_dummy + pgo_result$is_female + pgo_result$is_minority + pgo_result$age_39_less + pgo_result$has_masters_plus + pgo_result$c_fair_org_pay, weights = pgo_result$mps_weight)
sink("multi_pgo_results.txt")
print(summary(pgo_model))
sink()

# model building (AS)
as_query <- "SELECT
	mps_weight,
	MPS_Agency,
	-- dummy variable for supervisor or executive
	CASE WHEN MPS_Supervisor = 'S' OR MPS_Supervisor = 'X' THEN 1
		ELSE 0 END AS mps_supervisor_dummy,
	-- gender dummy variable
	CASE WHEN c_gender = '1' THEN 1
		WHEN c_gender = '2' THEN 0
		ELSE NULL END AS is_female,
	c_race_eth::int AS is_minority,
	-- dummy variable for age 39 or less
	CASE 
		WHEN c_age = '4' THEN 0
		WHEN c_age = '1' THEN 1 
		ELSE NULL END AS age_39_less,
	-- dummy variable for education level
	CASE WHEN c_ed_level = '5' THEN 1
		WHEN c_ed_level = '3' THEN 0
		WHEN c_ed_level = '1' THEN 0
		ELSE NULL END AS has_masters_plus,
	c_fair_org_pay::int,
	(i_prov_nec_train::DECIMAL + i_prov_opp_growth::DECIMAL + i_given_opp_skills::DECIMAL)/3 as i_average, 
	(d_unit_high_qual_prod::DECIMAL + d_use_wf_eff::DECIMAL + d_retain_best::DECIMAL)/3 as d_as_average
FROM mps_training 
WHERE 
	-- control variables
	mps_supervisor IS NOT NULL
	AND c_gender IS NOT NULL
	AND c_race_eth IS NOT NULL
	AND c_age IS NOT NULL
	AND c_ed_level IS NOT NULL
	AND (c_fair_org_pay	 != 'D' AND c_fair_org_pay IS NOT NULL)
	-- independent variables
	AND (i_prov_nec_train != 'D' AND i_prov_nec_train IS NOT NULL)
	AND (i_prov_opp_growth != 'D' AND i_prov_opp_growth IS NOT NULL) 
	AND (i_given_opp_skills != 'D' AND i_given_opp_skills IS NOT NULL)
	-- AS dependent variables
	AND (d_unit_high_qual_prod != 'D' AND d_unit_high_qual_prod IS NOT NULL)
	AND (d_use_wf_eff != 'D' AND d_use_wf_eff IS NOT NULL)
	AND (d_retain_best != 'D' AND d_retain_best IS NOT NULL)
;"

# execute query and load the result as a dataframe for analysis
as_result <- dbGetQuery(con,as_query)

as_model <- lm(as_result$d_as_average ~ as_result$i_average + as_result$mps_supervisor_dummy + as_result$is_female + as_result$is_minority + as_result$age_39_less + as_result$has_masters_plus + as_result$c_fair_org_pay, weights = as_result$mps_weight)
sink("multi_as_results.txt")
print(summary(as_model))
sink()

## output results with stargazer
stargazer(itt_model,pjs_model,pgo_model,as_model,type="html",summary=TRUE,out= "multi_model_out.htm",multicolumn = FALSE)

### Additional analysis

## calculate the cronbach's alpha
# install.packages("ltm")
library("ltm")

# cronbach's alpha for IV
# query string
query <- "SELECT * FROM  mps_training;"

# execute query and load the result as a dataframe for analysis
result <- dbGetQuery(con,query)

ivs <- result[c("i_prov_nec_train","i_prov_opp_growth","i_given_opp_skills")]
cronbach.alpha(ivs %>% filter(!is.na(i_prov_nec_train) & !is.na(i_prov_opp_growth) & !is.na(i_given_opp_skills)))


# cronbach's alpha for PJS
pjs <- result[c("d_meaningful_work","d_recommend_agency","d_use_job_skills")]

cronbach.alpha(pjs %>% filter(!is.na(d_meaningful_work) & !is.na(d_recommend_agency) & !is.na(d_use_job_skills)))

# cronbach's alpha for AS
as <- result[c("d_unit_high_qual_prod","d_use_wf_eff","d_retain_best")]
cronbach.alpha(as %>% filter(!is.na(d_unit_high_qual_prod) & !is.na(d_use_wf_eff) & !is.na(d_retain_best)))

# cronbach's alpha for PGO
pgo <- result[c("d_take_new_roles","d_take_high_tech_resp","d_take_super_resp")]
cronbach.alpha(pgo %>% filter(!is.na(d_take_new_roles) & !is.na(d_take_high_tech_resp) & !is.na(d_take_super_resp)))

# cronbach's alpha for IT
it <- result[c("d_move_diff_occ","d_resign_gov")]
cronbach.alpha(it %>% filter(!is.na(d_move_diff_occ) & !is.na(d_resign_gov)))

## Additional

install.packages("survey")
install.packages("srvyr")

# query string
query <- "SELECT * FROM  mps_training;"

# execute query and load the result as a dataframe for analysis
result <- dbGetQuery(con,query)


# check correlations of weights to variables of interest
# check weighted and unweighted descriptive estimates, check with standard errors
# see if change in standard estimates with respect to standard errors