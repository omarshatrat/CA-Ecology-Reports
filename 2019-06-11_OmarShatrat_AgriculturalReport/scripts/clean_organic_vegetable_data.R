# Read in USDA organic vegetable data and clean for analysis
# Will focus on 2002 - 2011

# Naupaka Zimmerman
# nzimmerman@usfca.edu
# June 6, 2019

# Downloaded from
# https://www.ers.usda.gov/data-products/organic-production/
#         organic-production/#State-Level%20Tables


# Organic Production ERS collected data from USDA-accredited State and private
# certification groups to calculate the extent of certified organic farmland
# acreage and livestock in the United States. These are presented in tables
# showing the change in U.S. organic acreage and livestock numbers from 1992 to
# 2011 (see the National tables section). Data for 1997 and 2000-11 are
# presented by State and commodity (see the State tables section).
#
# Organic production tables are in .xls format. Each workbook contains multiple
# years of data in worksheets that are accessed through tabs. State-level tables
# cover the years 1997 and 2000-2011 (no data are available for 2009).
# National-level tables also include data from earlier years.
#
# Errata: On October 24, 2013, table 3 was revised. The correct 2011 value for
# certified organic peanut acres was 5,066.

# load packages
library("readxl")
library("stringr")
library("dplyr")
library("tidyr")
library("readr")

# read in data for section of each tab

# choose years and left pad
years <- str_pad(c(2, 3, 4, 5, 6, 7, 8, 10, 11), pad = "0", width = 2)

# set loop variables for list index
i <- 1
list_years <- list()

# loop over the target tabs in the excel worksheet and pull out only the
# sections that contain the state level data, skipping headers and etc
for (year in years) {
  temp_data <- read_excel("Vegetables.xls",
                          range = paste0("vegetables",
                                         year,
                                         "!A9:H58"),
                          col_names = c("state",
                                        "tomatoes",
                                        "lettuce",
                                        "carrots",
                                        "mixed_less_than_5_acres",
                                        "mixed_more_than_5_acres",
                                        "unclassified_vegetables",
                                        "total_acres_all_vegetables"))
  temp_data[is.na(temp_data)] <- 0 # set all NAs to 0s for consistency
  temp_data$year <- paste0("20", year) # add year column for late row binding
  list_years[[i]] <- temp_data # add to end of growing list object

  # increment list index
  i <- i + 1
}

# combine all data frames from the list into a single data frame
bound_row_data <- bind_rows(list_years)

# tidy the combined data
bound_row_data <- bound_row_data %>%
  # change wide to long form
  gather(key = type,
         value = acres,
         -c(state, year, total_acres_all_vegetables)) %>%
  # reorder columns
  select(year, state, type, acres, total_acres_all_vegetables)

# write out the combined dataset for use in analysis
write_csv(bound_row_data, "organic_vegetables_cleaned.csv")


