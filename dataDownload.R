# Data download script
# Created by Kaija Gahm
# You will need to use your own Movebank login credentials to download the data.

# Load packages -----------------------------------------------------------
library(move) # to access Movebank
library(here) # for file paths

# Read data from Movebank -------------------------------------------------
studyName <- "Ornitela_Vultures_Gyps_fulvus_TAU_UCLA_Israel" # define the study name so we don't have to keep typing it.

# XXX NOTE: here you will have to create your own password as an R object called "pw.Rda" and save it in a folder called "movebankCredentials/". Then you'll have to change the username below.
load(here::here("movebankCredentials", "pw.Rda")) # load the object called `pw`

# create the Movebank login object
MB.LoginObject <- movebankLogin(username = 'kaijagahm', # substitute your own username
                                password = pw) # again, this should be your password
# done using the password, so we can remove it from the environment.
rm(pw)

moveStack_2018.2021 <- getMovebankData(study = studyName,
                                        login = MB.LoginObject,
                                        includeExtraSensors = FALSE,
                                        deploymentAsIndividuals = FALSE,
                                        removeDuplicatedTimestamps = TRUE,
                                        timestamp_start = "20180101000000000", # start in January 2018
                                        timestamp_end = "20211231000000000") # end at the end of 2021, which is later than we need for the 2020-2021 breeding season

# Save the data -----------------------------------------------------------
save(moveStack_2018.2021, file = here::here("data", "inputs", "moveStack_2018.2021.Rda"))
