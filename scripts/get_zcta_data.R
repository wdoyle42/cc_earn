################################################################################
##
##
##
################################################################################

## libraries
libs <- c("tidyverse", "tidycensus", "here")
sapply(libs, require, character.only = TRUE)

## paths
dat_dir <- here("data")
cln_dir <- file.path(dat_dir, "cleaned")

## -----------------------------------------------------------------------------
## ACS settings
## -----------------------------------------------------------------------------

## set Census API key based on user
## NB: I would recommend placing the key in the ~/.Renviron file as
## CENSUS_API_KEY=<...key...> (no need for quotation marks)
acs_key <- Sys.getenv("CENSUS_API_KEY")

## set key
census_api_key(acs_key)

## set geography, year, and data set
acs_geog <- "zcta"
acs_year <- 2019
acs_data <- "acs5"

## load all variables for year
acs_all_vars <- load_variables(acs_year, acs_data, cache = TRUE)

## -----------------------------------------------------------------------------
## education
## -----------------------------------------------------------------------------

## create variable list
var_list <- paste0("B15002_", str_pad(c(1,15:18,32:35), 3, pad = "0"))

## data pull
df_educ <- get_acs(geography = acs_geog,
                   variables = var_list,
                   output = "wide",
                   year = acs_year) |>
  ## lower names
  rename_all(tolower) |>
  ## select estimates only
  select(-ends_with("m")) |>
  ## munge
  mutate(college_educ = rowSums(across(b15002_015e: b15002_035e)),
         college_educ = college_educ / b15002_001e * 100) |>
  ## subset
  select(name, college_educ)

## -----------------------------------------------------------------------------
## income
## -----------------------------------------------------------------------------

## create variable list
var_list <- paste0("B19001_", str_pad(c(1,13:17), 3, pad = "0"))

## data pull
df_income <- get_acs(geography = acs_geog,
                     variables = var_list,
                     output = "wide",
                     year = acs_year) |>
  ## lower names
  rename_all(tolower) |>
  ## select estimates only
  select(-ends_with("m")) |>
  ## munge
  mutate(income_75 = rowSums(across(b19001_013e:b19001_017e)),
         income_75 = income_75 / b19001_001e * 100) |>
  ## subset
  select(name, geoid, income_75)

## -----------------------------------------------------------------------------
## health
## -----------------------------------------------------------------------------

## create variable list
var_list <- paste0("B27001_", c(str_pad(seq(1,28,3), 3, pad = "0"),
                                str_pad(seq(32,56,3), 3, pad = "0")))

## data pull
df_health <- get_acs(geography = acs_geog,
                     variables = var_list,
                     output = "wide",
                     year = acs_year) |>
  ## lower names
  rename_all(tolower) |>
  ## select estimates only
  select(-ends_with("m")) |>
  ## munge
  mutate(perc_insured = rowSums(across(b27001_004e:b27001_056e)),
         perc_insured = perc_insured / b27001_001e * 100) |>
  ## subset
  select(name, perc_insured)

## -----------------------------------------------------------------------------
## labor force
## -----------------------------------------------------------------------------

## create variable list
var_list <- paste0("B23025_", str_pad(c(1,2), 3, pad = "0"))

## data pull
df_labor <- get_acs(geograph = acs_geog,
                    variables = var_list,
                    output = "wide",
                    year = acs_year) |>
  ## lower names
  rename_all(tolower) |>
  ## select estimates only
  select(-ends_with("m")) |>
  ## munge
  mutate(perc_in_labor_force = b23025_002e / b23025_001e * 100) |>
  ## subset
  select(name, perc_in_labor_force)

## -----------------------------------------------------------------------------
## mobility
## -----------------------------------------------------------------------------

## create variable list
var_list <- paste0("B07003_", str_pad(c(1,13), 3, pad = "0"))

## data pull
df_mobility <- get_acs(geography = acs_geog,
                       variables = var_list,
                       output = "wide",
                       year = acs_year) |>
  ## lower names
  rename_all(tolower) |>
  ## select estimates only
  select(-ends_with("m")) |>
  ## munge
  mutate(perc_moved_in = b07003_013e / b07003_001e * 100) |>
  ## subset
  select(name, perc_moved_in)

## -----------------------------------------------------------------------------
## commute
## -----------------------------------------------------------------------------

## create variable list
var_list <- paste0("B08134_", str_pad(c(1,7:10), 3, pad = "0"))

## data pull
df_commute <- get_acs(geography = acs_geog,
                      variables = var_list,
                      output = "wide",
                      year = acs_year) |>
  ## lower names
  rename_all(tolower) |>
  ## select estimates only
  select(-ends_with("m")) |>
  ## munge
  mutate(perc_commute_30p = rowSums(across(b08134_007e:b08134_010e)),
         perc_commute_30p = (perc_commute_30p / b08134_001e) * 100) |>
  ## subset
  select(name, perc_commute_30p)

## -----------------------------------------------------------------------------
## commute
## -----------------------------------------------------------------------------

## create variable list
var_list <- paste0("B25008_", str_pad(c(1:2), 3, pad = "0"))

## data pull
df_homeown <- get_acs(geography = acs_geog,
                      variables = var_list,
                      output = "wide",
                      year = acs_year) |>
  ## lower names
  rename_all(tolower) |>
  ## select estimates only
  select(-ends_with("m")) |>
  ## munge
  mutate(perc_homeown = (b25008_002e / b25008_001e) * 100) |>
  ## subset
  select(name, perc_homeown)

## -----------------------------------------------------------------------------
## joins, final munge, and save
## -----------------------------------------------------------------------------

## joins
df <- list(df_educ, df_income, df_health, df_labor, df_mobility,
           df_commute, df_homeown) |>
  reduce(left_join, by = "name") |>
  ## rename
  rename(zip = geoid) |>
  ## subset
  select(zip, college_educ, perc_homeown, income_75,
         perc_moved_in, perc_in_labor_force)

## save data
write_rds(df, file = file.path(cln_dir, "zip_data.rds"))

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
