################################################################################
##
##
################################################################################

## libraries
libs <- c("tidyverse", "tidycensus")
sapply(libs, require, character.only = TRUE)

## paths
dat_dir <- here::here("data")
cln_dir <- file.path(dat_dir, "cleaned")

## set Census API key based on user
## NB: I would recommend placing the key in the ~/.Renviron file as
##
## CENSUS_API_KEY=<...key...> (no need for quotation marks)
acs_key <- Sys.getenv("CENSUS_API_KEY")

## set key
census_api_key(acs_key)

## set geography
my_geo <- "zcta"

v19 <- load_variables(2019, "acs5", cache = TRUE)

var_list <- paste0("B15002_",c("001",
                               "015",
                               "016",
                               "017",
                               "018",
                               "032",
                               "033",
                               "034",
                               "035"))

## education data pull
educ <- get_acs(geography = my_geo,
                variables = var_list,
                output = "wide",
                year = 2019)

## lower variable names
names(educ) <- tolower(names(educ))

## munge data
educ <- educ |>
  group_by(name) |>
  mutate(college_educ=((b15002_015e +
                          b15002_016e +
                          b15002_017e +
                          b15002_018e +
                          b15002_032e +
                          b15002_033e +
                          b15002_034e +
                          b15002_035e) / b15002_001e) * 100) |>
  select(name, college_educ)

## income data
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

income <- income|>
  group_by(name) |>
  mutate(income_75 = ((
    b19001_013e +
      b19001_014e +
      b19001_015e +
      b19001_016e +
      b19001_017e) / b19001_001e) * 100) |>
  select(name, geoid, income_75)

## health data
var_list <- paste0("B27001_", c("001",
                                "004",
                                "007",
                                "010",
                                "013",
                                "016",
                                "019",
                                "022",
                                "025",
                                "028",
                                "032",
                                "035",
                                "038",
                                "041",
                                "044",
                                "047",
                                "041",
                                "050",
                                "053",
                                "056"))

health <- get_acs(my_geo,
                  variables = var_list,
                  output = "wide",
                  year = 2019)

names(health) <- tolower(names(health))

health <- health |>
  select(-ends_with("m")) |> # estimates only (no moe values)
  mutate(insured_num = rowSums(across(b27001_004e:b27001_056e))) |>
  mutate(perc_insured = (insured_num / b27001_001e) * 100) |>
  select(name, perc_insured)

## labor force

var_list <- paste0("B23025_",c("001",
                               "002"))

labor <- get_acs(my_geo,
                 variables = var_list,
                 output = "wide",
                 year = 2019)

names(labor) <- tolower(names(labor))

labor <- labor |>
  group_by(name) |>
  mutate(perc_in_labor_force = (b23025_002e / b23025_001e) * 100) |>
  select(name, perc_in_labor_force)

## mobility
var_list <- paste0("B07003_", c("001", "013"))

mobility <- get_acs(my_geo,
                    variables = var_list,
                    output = "wide",
                    year = 2019)

names(mobility) <- tolower(names(mobility))

mobility <- mobility |>
  group_by(name) |>
  mutate(perc_moved_in = (b07003_013e / b07003_001e) * 100)|>
  select(name, perc_moved_in)

## commute
var_list <- paste0("B08134_", c("001","007","008","009","010"))

commute <- get_acs(my_geo,
                   variables = var_list,
                   output = "wide",
                   year = 2019)

names(commute) <- tolower(names(commute))

commute <- commute |>
  select(-ends_with("m")) |> # estimates only (no moe values)
  mutate(commute_num = rowSums(across(b08134_007e:b08134_010e))) |>
  mutate(perc_commute_30p = (commute_num / b08134_001e) * 100) |>
  select(name, perc_commute_30p)

## homeownership
var_list <- paste0("B25008_", c("001","002"))

homeown <- get_acs(my_geo,
                   variables = var_list,
                   output = "wide",
                   year = 2019)

names(homeown) <- tolower(names(homeown))

homeown <- homeown |>
  mutate(perc_homeown = (b25008_002e / b25008_001e) * 100) |>
  select(name, perc_homeown)


## joins
area_data <- educ |>
  left_join(homeown, by = "name") |>
  left_join(income, by = "name") |>
  left_join(mobility, by = "name") |>
  left_join(labor, by = "name")

## final munge
area_data <- area_data |>
  ungroup() |>
  rename(zip = geoid) |>
  select(zip, college_educ, perc_homeown, income_75,
         perc_moved_in, perc_in_labor_force)


## save data
write_rds(area_data, file = file.path(cln_dir, "zip_data.rds"))

## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
