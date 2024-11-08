# Commands to cut down and cleanup the MSP datafile
# downloaded from https://www.mspb.gov/foia/files/msp2021/MSPB_MPS2021_Release-CSV.zip

# create a 100 line sample of the file with all columns for testing
head -n 100 MSPB_MPS2021_Release.CSV >> MSPB_MPS2021_Release_100.csv

# Configuring the pgconf.hba file
# https://stackoverflow.com/questions/76899023/rds-while-connection-error-no-pg-hba-conf-entry-for-host

# code to create table for the database
psql -h database-1.comlwdp1urqg.us-east-2.rds.amazonaws.com -U postgres_utd -p 5432 -d postgres -f "create_mps_2021.sql"

# copy the csv file to the database
psql -h database-1.comlwdp1urqg.us-east-2.rds.amazonaws.com -U postgres_utd -p 5432 -d postgres -c "\copy mps2021 FROM '/Users/richarddunks/Documents/MSPB_MPS2021_Release.CSV' DELIMITER ',' CSV HEADER;"

# create view from the data
psql -h database-1.comlwdp1urqg.us-east-2.rds.amazonaws.com -U postgres_utd -p 5432 -d postgres -f "create_view_mps_training.sql"