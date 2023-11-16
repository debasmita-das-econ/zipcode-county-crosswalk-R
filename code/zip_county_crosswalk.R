#-----------------------------------------------------------------------------------
# Script: zip_county_crosswalk.R
# Author: Debasmita Das (ddas83@gatech.edu)
# Date Written: 11/11/2023
# Last Updated: 11/16/2023
#-----------------------------------------------------------------------------------
#
# This script: 
#   - Creates zip-county crosswalk data using HUD-USPS data and Census Data.
#   - Produces a crosswalk between zip codes, counties (both FIPS codes and county names),
#     state FIPS code, state names
#   - I only kept the states in the Mainland US, and excluded the US Territories (as required in my research project)
#-----------------------------------------------------------------------------------
# Input:
#-----------------------------------------------------------------------------------
# 1. HUD-USPS ZIP Code Crosswalk file
#   - "ZIP_COUNTY_032023.xlsx" (2023 Q1 data)
#   - URL: https://www.huduser.gov/portal/datasets/usps_crosswalk.html
#   - We need to register and login to download the data (alternatively the data can be retrieved using the HUD API)
#   - Note: The HUD-USPS ZIP Code Crosswalk files are now available for 2020 Census geographies beginning with the 2023 Q1 data release.
#     
#   IMPORTANT: The following article demonstrates how to more effectively use the HUS-USPS ZIP Code Crosswalk Files 
#   Wilson, Ron and Din, Alexander, 2018. “Understanding and Enhancing the U.S. Department of Housing and Urban Development’s 
#   ZIP Code Crosswalk Files,” Cityscape: A Journal of Policy Development and Research, Volume 20 Number 2, 277 – 294. 
#   URL: https://www.huduser.gov/portal/periodicals/cityscpe/vol20num2/ch16.pdf
#
# 2. Retrieve County Names from Census Data
# - URL: https://www.census.gov/data/datasets/2021/demo/saipe/2021-state-and-county.html
# 
#-----------------------------------------------------------------------------------
# Output:
#-----------------------------------------------------------------------------------
# Excel File: "county_zip_crosswalk.xlsx"
# Rows: 39,314; Columns: 12
# Variables:
#   - zipcode               <chr> 5 digit zip code number
#   - CountyFIPS_5          <chr> 5 digit FIPS code (2 digit state code + 3 digit county code)
#   - CountyName            <chr> County names from the Census
#   - StateAbbr             <chr> Two-letter Postal State abbreviation
#   - StateFIPSCode         <chr> 2 digit FIPS State code
#   - CountyFIPSCode        <chr> 3 digit FIPS County code
#   - max_tot_ratio         <dbl> Largest Total Address Ratio corresponding to that ZIP Code
#   - RES_RATIO             <dbl> proportion of residential addresses in that ZIP Code
#-----------------------------------------------------------------------------------
# Libraries
#-----------------------------------------------------------------------------------
# install.packages(c("tidyverse", "dplyr", "readxl", "writexl", "data.table"))

library(tidyverse)
library(dplyr)
library(readxl)
library(writexl)
library(data.table)

#-----------------------------------------------------------------------------------
# Read ZIP County Crosswalk using HUD data
#-----------------------------------------------------------------------------------
input_directory <- "/Users/ddas83/Dropbox (GaTech)/DD_Research/county_zip_crosswalk/input" # !! Change it to your working directory !!
file_name <- "ZIP_COUNTY_032023.xlsx" # First Quarter, 2023
file_path <- file.path(input_directory, file_name)

county_zip_q1_2023 <- read_excel(file_path)

glimpse(county_zip_q1_2023) # Rows: 54,447

length(unique(county_zip_q1_2023$ZIP)) # 39501 
length(unique(county_zip_q1_2023$COUNTY)) # 3230 counties (contains counties in the territories)
length(unique(county_zip_q1_2023$USPS_ZIP_PREF_STATE)) # 56 states, includes Territories

unique(county_zip_q1_2023$USPS_ZIP_PREF_STATE)

# Create an indicator variable to flag territories
county_zip_q1_2023 <- county_zip_q1_2023 %>%
  mutate(is_territory = ifelse(USPS_ZIP_PREF_STATE %in% c("AS", "AE", 
                                                          "FM", "GU", "MH", "MP", "PR", "PW", "VI", "AA", "AP"), 1, 0))
county_zip_q1_2023 <- county_zip_q1_2023 %>% filter(is_territory != 1) 

length(unique(county_zip_q1_2023$ZIP)) # 39313
length(unique(county_zip_q1_2023$COUNTY)) # 3144

#-----------------------------------------------------------------------------------
# NOTES:
#  -  As of 2020, there are 3,143 counties and county-equivalents in the 50 states and the District of Columbia. 
#  -  If the 100 county equivalents in the U.S. territories are counted, then the total is 3,243 counties and 
#      county-equivalents in the United States.
#-----------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------
# REFERENCE:
#   Wilson, Ron and Din, Alexander, 2018. “Understanding and Enhancing the U.S. Department 
#   of Housing and Urban Development’s ZIP Code Crosswalk Files,” Cityscape: A Journal of 
#   Policy Development and Research, Volume 20 Number 2, 277 – 294. 
#   URL: https://www.huduser.gov/portal/periodicals/cityscpe/vol20num2/ch16.pdf
#
#   - Because many ZIP codes overlap the boundaries of the other geographies, duplicate ZIP code records 
#     will exist, requiring the user to make a decision about which geography to associate the ZIP code.
#   - As we see in the structure of the HUD ZIP Code to County Crosswalk dataframe, 
#     2 records for ZIP code "01010", such that this ZIP code overlaps 2 counties, with 
#     residential ratios distributed at 0.972 (97.2%) and 0.0276 (2.76%) ~ add up to 1
#-----------------------------------------------------------------------------------

county_zip_q1_2023 %>% filter(ZIP == "01010")

# ZIP   COUNTY USPS_ZIP_PREF_CITY USPS_ZIP_PREF_STATE RES_RATIO BUS_RATIO OTH_RATIO TOT_RATIO
# <chr> <chr>  <chr>              <chr>                   <dbl>     <dbl>     <dbl>     <dbl>
# 1 01010 25013  BRIMFIELD          MA                     0.972          1         1    0.973 
# 2 01010 25027  BRIMFIELD          MA                     0.0276         0         0    0.0265

# The res_ratio, bus_ratio, and oth_ratio columns show the proportions of the corresponding
# address type within each county.
#
# RES_RATIO: proportion of residential addresses in that ZIP Code.
# BUS_RATIO: proportion of business addresses in that ZIP Code.
# OTH_RATIO: proportion of other addresses in that ZIP Code.
# TOT_RATIO: proportion of all addresses in that ZIP Code.
#
# These ratios can be used to help decide which county to assign to the ZIP code!
# - For ZIP Codes with ratio 1.0, NO decision needs to be made, because all the addresses are contained within a single county.
# For example:

county_zip_q1_2023 %>% filter(ZIP == "00923")

# ZIP   COUNTY USPS_ZIP_PREF_CITY USPS_ZIP_PREF_STATE RES_RATIO BUS_RATIO OTH_RATIO TOT_RATIO
# <chr> <chr>  <chr>              <chr>                   <dbl>     <dbl>     <dbl>     <dbl>
# 1    00923 72127  SAN JUAN           PR                1         1         1         1

#-----------------------------------------------------------------------------------
# BUT for ZIP codes with ratio proportions, a decision can be made to assign the addresses to a 
# county based on 2 approaches:
#
#   1. Assign all addresses to the LARGEST Ratio (I am using this approach)
#       - keep only the zip-county pair for which the residential ratio or total ratio is highest.
#       - I.e. allocate the zipcode to the County in which the largest fraction of its population falls.
#
#   2. proportionally assign the adderesses to each county through geoprocessing in a GIS or 
#      cross-tabulating in a statistical software (...this is no required for our use!)
#-----------------------------------------------------------------------------------

county_zip_q1_2023 <- county_zip_q1_2023 %>%
  group_by(ZIP) %>%
  mutate(max_tot_ratio = max(TOT_RATIO))

county_zip_q1_2023 <- county_zip_q1_2023 %>% ungroup()

county_zip_q1_2023 <- county_zip_q1_2023 %>% filter(TOT_RATIO == max_tot_ratio)

glimpse(county_zip_q1_2023) # Rows: 39,316
length(unique(county_zip_q1_2023$ZIP)) # 39,313
#... we have 3 extra rows

# create a column counting number of times each ZIP is appearing in the data
county_zip_q1_2023 <- county_zip_q1_2023 %>%
  group_by(ZIP) %>%
  mutate(n_times = n())

county_zip_q1_2023 <- county_zip_q1_2023 %>% ungroup()

# filter ZIP that are appearing more than once
county_zip_q1_2023 %>% filter(n_times !=1)

# ZIP   COUNTY USPS_ZIP_PREF_CITY USPS_ZIP_PREF_STATE RES_RATIO BUS_RATIO OTH_RATIO TOT_RATIO is_territory max_tot_ratio n_times
# <chr> <chr>  <chr>              <chr>                   <dbl>     <dbl>     <dbl>     <dbl>        <dbl>         <dbl>   <int>
# 1 51603 19071  SHENANDOAH         IA                      0           0.5     0           0.5            0         0.5       2
# 2 51603 19145  SHENANDOAH         IA                      0           0.5     0           0.5            0         0.5       2
# 3 16871 42033  POTTERSDALE        PA                      0.479       1       1           0.5            0         0.5       2
# 4 16871 42035  POTTERSDALE        PA                      0.521       0       0           0.5            0         0.5       2
# 5 96142 06017  TAHOMA             CA                      1           0       0.457       0.5            0         0.5       2
# 6 96142 06061  TAHOMA             CA                      0           0       0.543       0.5            0         0.5       2

# - for ZIP = 96142, RES_RATIO is 1 for county 06017, so we will keep this record and drop the other one.
county_zip_q1_2023 <- county_zip_q1_2023 %>% filter(!(ZIP == "96142" & RES_RATIO == 0))

# - for ZIP = 16871, we found from google search that this zip belongs to Clearfield County (fips = 42033), 
# so we will keep this record and drop the other one.
county_zip_q1_2023 <- county_zip_q1_2023 %>% filter(!(ZIP == "16871" & COUNTY == "42035"))

# - for ZIP = 51603, it seems this is in Shenandoah Forest with no residential address - can we drop this zipcode?
#  Moreover, should we drop zip codes with 0 RES_RATIO?

# Check how many zipcodes with 0 RES_RATIO
county_zip_q1_2023 %>% filter(RES_RATIO == 0) # 3,993  zipcodes

nrow(county_zip_q1_2023) # 39314 

# NOTE that in our research data we have 36058 zip codes, so it makes sense that out of 39314 zipcodes, some are not residential addresses
# and do not have consumers with credit records

length(unique(county_zip_q1_2023$ZIP)) # 39313
length(unique(county_zip_q1_2023$COUNTY)) # 3141 (<3143)
length(unique(county_zip_q1_2023$USPS_ZIP_PREF_STATE)) # 51

#-----------------------------------------------------------------------------------
# ...Now, Import Census FIPS-County Names:
#
# Download the Census Data:
# URL: https://www.census.gov/data/datasets/2021/demo/saipe/2021-state-and-county.html
#  - Download the excel file by clicking on "US and All States and Counties", this will automatically download "est21all.xls" file
#  - For convenience, I cleaned this file, kept the variables I need, and saved as "state_county_census_2021.xlsx"
#
# Learn more about census geographies here:
# https://www.census.gov/newsroom/blogs/random-samplings/2014/07/understanding-geographic-relationships-counties-places-tracts-and-more.html
#-----------------------------------------------------------------------------------
input_directory <- "/Users/ddas83/Dropbox (GaTech)/DD_Research/county_zip_crosswalk/input" # !! Change it to your working directory !!
file_name <- "state_county_census_2021.xlsx"
file_path <- file.path(input_directory, file_name)
state_county_census_2021 <- read_excel(file_path)

state_county_census_2021$statecountyfips <- paste0(state_county_census_2021$StateFIPSCode, 
                                                   state_county_census_2021$CountyFIPSCode)
glimpse(state_county_census_2021)

unique(state_county_census_2021$StateAbbr)
length(unique(state_county_census_2021$StateAbbr)) # 51 states + US, does not include territories

# drop US and state level data
state_county_census_2021 <- state_county_census_2021 %>% filter(CountyFIPSCode != "000") # now we have 3,143 rows = 3,143 counties
glimpse(state_county_census_2021)

#-----------------------------------------------------------------------------------
# Merge "county_zip_q1_2023" and state_county_census_2021" 
#-----------------------------------------------------------------------------------
county_zip <- county_zip_q1_2023 %>%
  left_join(state_county_census_2021, by = c("COUNTY" = "statecountyfips"))

# Keep required columns
county_zip <- county_zip %>% 
  dplyr::select(ZIP, COUNTY, StateAbbr,
                StateFIPSCode, CountyFIPSCode, Name, RES_RATIO, max_tot_ratio)

# rename variables
county_zip <- county_zip %>% 
  rename(CountyFIPS_5 = COUNTY,
         zipcode = ZIP,
         CountyName = Name)

# reorder
county_zip <- county_zip %>% 
  dplyr::select(zipcode, CountyFIPS_5, CountyName, StateAbbr, 
                StateFIPSCode, CountyFIPSCode, RES_RATIO, max_tot_ratio)
glimpse(county_zip)

# Check how many zipcodes with 0 RES_RATIO
county_zip %>% filter(RES_RATIO == 0) # 3,993  zipcodes

length(unique(county_zip$zipcode)) # 39313

#-----------------------------------------------------------------------------------
# Save the resulting data to an Excel file 
#-----------------------------------------------------------------------------------
output_directory <- input_directory <- "/Users/ddas83/Dropbox (GaTech)/DD_Research/county_zip_crosswalk/output" # !! Change it to your working directory !!
excel_file_name <- "county_zip_crosswalk.xlsx"
excel_file_path <- file.path(output_directory, excel_file_name)
write_xlsx(county_zip, excel_file_path)
cat("Saving zip-county crosswalk to", excel_file_path, "\n")


