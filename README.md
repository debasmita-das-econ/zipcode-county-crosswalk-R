# Zip Code County Crosswalk using R


The script [`zip_county_crosswalk.R`](https://github.com/debasmita-das-econ/zipcode-county-crosswalk-R/blob/main/code/zip_county_crosswalk.R) creates zip-county crosswalk data using HUD-USPS data and Census Data. I only kept the states in the Mainland US, and excluded the US Territories (as required in my research project).

## Data 

1. [HUD-USPS ZIP Code Crosswalk file](https://www.huduser.gov/portal/datasets/usps_crosswalk.html)
 - "ZIP_COUNTY_032023.xlsx" (2023 Q1 data)
 - We need to register and login to download the data (alternatively the data can be retrieved using the HUD API)
 - Note: The HUD-USPS ZIP Code Crosswalk files are now available for 2020 Census geographies beginning with the 2023 Q1 data release.
    
The following article demonstrates how to more effectively use the HUS-USPS ZIP Code Crosswalk Files.

Wilson, Ron and Din, Alexander, 2018. [“Understanding and Enhancing the U.S. Department of Housing and Urban Development’s 
ZIP Code Crosswalk Files,”](https://www.huduser.gov/portal/periodicals/cityscpe/vol20num2/ch16.pdf) Cityscape: A Journal of Policy Development and Research, Volume 20 Number 2, 277 – 294. 

2. Retrieve County Names from [Census Data](https://www.census.gov/data/datasets/2021/demo/saipe/2021-state-and-county.html)

## Required Packages
`dplyr`, `tidyverse`, `readxl`, `writexl`

## Output
Excel File: ["county_zip_crosswalk.xlsx"](https://github.com/debasmita-das-econ/zipcode-county-crosswalk-R/blob/main/output/county_zip_crosswalk.xlsx)

Variables:
   - zipcode               <chr> 5 digit zip code number
   - CountyFIPS_5          <chr> 5 digit FIPS code (2 digit state code + 3 digit county code)
   - CountyName            <chr> County names from the Census
   - StateAbbr             <chr> Two-letter Postal State abbreviation
   - StateFIPSCode         <chr> 2 digit FIPS State code
   - CountyFIPSCode        <chr> 3 digit FIPS County code
   - max_tot_ratio         <dbl> Largest Total Address Ratio corresponding to that ZIP Code
   - RES_RATIO             <dbl> proportion of residential addresses in that ZIP Code

## Author
Debasmita Das (Georgia Tech, 2023)

## License
This project is licensed under the MIT License.

## Other Useful Links
[Zip-county crosswalk using Python by James Graham](https://github.com/jagman88/Crosswalk-ZipCode-County-CBSA)


