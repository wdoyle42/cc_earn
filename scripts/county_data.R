library(tidyverse)
library(tidycensus)
library(zipcodeR)
library(crosswalkr)
library(here)



## Goal: list of counties associated with each zip code in IPEDS, then get ACS data

cb_df<-read_rds(here("data","cleaned","cb_df.Rds"))

cb_df<-cb_df%>%
  filter(stabbr!="PR")

zip_list<-unique(cb_df$zip)
zip_list<-str_sub(zip_list,1,5)

county_list<-map_df(zip_list,reverse_zipcode)%>%
  rename(stabbr=state)%>%
  left_join(stcrosswalk,by="stabbr")%>%
  rename(state_name=stname)%>%
  left_join(fips_codes,by=c("state_name","county"))%>%
  rename(zip=zipcode)%>%
  select(zip,
         county,
         state_code,
         county_code)

cb_df<-cb_df%>%
  left_join(county_list,by="zip")

cb_df<-cb_df%>%
  mutate(county_fips=paste0(state_code,county_code))

## Get Key

my_acs_key <-
  readLines("~/hod_datasci_keys/my_acs_key.txt", warn = FALSE)

acs_key <- my_acs_key

census_api_key(acs_key)

my_geo <- "county"

v19 <- load_variables(2019, "acs5", cache = TRUE)

## College Educated

var_list <- paste0("B15002_",
                   c("001",
                     "015",
                     "016",
                     "017",
                     "018",
                     "032",
                     "033",
                     "034",
                     "035"))

educ <- get_acs(
  geography = my_geo,
  variables = var_list,
  output = "wide",
  year = 2019
)

names(educ) <- tolower(names(educ))

educ <- educ %>%
  group_by(name) %>%
  mutate(county_college_educ = ((
    b15002_015e +
      b15002_016e +
      b15002_017e +
      b15002_018e +
      b15002_032e +
      b15002_033e +
      b15002_034e +
      b15002_035e
  ) / b15002_001e
  ) * 100) %>%
  ungroup()%>%
  select(geoid, college_educ)%>%
  rename(county_fips=geoid)

cb_df<-cb_df%>%left_join(educ,by="county_fips")

## Income above 75k

var_list <- paste0("B19001_", c("001",
                                "013",
                                "014",
                                "015",
                                "016",
                                "017"))

income <- get_acs(my_geo,
                  variables = var_list,
                  output = "wide",
                  year = 2019)

names(income) <- tolower(names(income))

income <- income %>%
  group_by(name) %>%
  mutate(county_income_75 = ((
    b19001_013e +
      b19001_014e +
      b19001_015e +
      b19001_016e +
      b19001_017e
  ) / b19001_001e
  ) * 100) %>%
  select(name, geoid, county_income_75)

## In labor force

var_list <- paste0("B23025_", c("001",
                                "002"))

labor <- get_acs(my_geo,
                 variables = var_list,
                 output = "wide",
                 year = 2019)

names(labor) <- tolower(names(labor))

labor <- labor %>%
  group_by(name) %>%
  mutate(perc_in_labor_force = (b23025_002e / b23025_001e) * 100) %>%
  select(name, perc_in_labor_force)

## Moved into zip code

var_list <- paste0("B07003_", c("001", "013"))

mobility <- get_acs(my_geo,
                    variables = var_list,
                    output = "wide",
                    year = 2019)

names(mobility) <- tolower(names(mobility))

mobility <- mobility %>%
  group_by(name) %>%
  mutate(perc_moved_in = (b07003_013e / b07003_001e) * 100) %>%
  select(name, perc_moved_in)


var_list <- paste0("B25008_", c("001", "002"))

homeown <- get_acs(my_geo,
                   variables = var_list,
                   output = "wide",
                   year = 2019)

names(homeown) <- tolower(names(homeown))

homeown <-
  homeown %>%
  mutate(perc_homeown = (b25008_002e / b25008_001e) * 100) %>%
  select(name, perc_homeown)



area_data <- educ %>%
  left_join(homeown, by = "name") %>%
  left_join(income, by = "name") %>%
  left_join(mobility, by = "name") %>%
  left_join(labor, by = "name")


area_data <- area_data %>%
  ungroup() %>%
  rename(zip = geoid) %>%
  select(zip,
         college_educ,
         perc_homeown,
         income_75,
         perc_moved_in,
         perc_in_labor_force)



```{
  r
}
write_rds(area_data, file = "../data/cleaned/zip_data.Rds")
```
