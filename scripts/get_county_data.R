# CC Earn Data
## Olivia Morales
## 2022-1-18

library(tidyverse)
library(tidycensus)
library(noncensus)
library(devtools)
library(blsR)
library(blscrapeR)
library(readxl)
data(states)


## pull/wrangle data
my_acs_key<-readLines("./my_acs_key",warn = FALSE)
acs_key<-my_acs_key
census_api_key(acs_key)
my_geo<-"county"
v19 <- load_variables(2019, "acs5", cache = TRUE)
var_list<-paste0("B15002_",c("001",
                             "015",
                             "016",
                             "017",
                             "018",
                             "032",
                             "033",
                             "034",
                             "035"))

# creating educ df by county
educ<-get_acs(geography=my_geo,
              variables=var_list,
              output="wide",
              year = 2019)

names(educ)[names(educ)=='GEOID'] <- 'fips'

names(educ)<-tolower(names(educ))
educ<-educ%>%
  group_by(name)%>%
  mutate(college_educ=((b15002_015e+
                          b15002_016e+
                          b15002_017e+
                          b15002_018e+
                          b15002_032e+
                          b15002_033e+
                          b15002_034e+
                          b15002_035e)/b15002_001e)*100) %>%
  select(name,college_educ,fips)

county_n_fips <- subset(educ, select = -c(college_educ))

names(county_n_fips)[names(county_n_fips)=='name'] <- 'ctyname'

#median income df by county
var_list<-paste0("B19013_",c("001"))

income<-get_acs(my_geo,
                variables=var_list,
                output="wide",
                year=2019)

names(income) <- tolower(names(income))
income = subset(income, select = -c(b19013_001m, geoid))

names(income)[names(income)=='b19013_001e'] <- 'median_income'

#labor force participation df by county

var_list<-paste0("B23025_",c("001", "002"))

labor<-get_acs(my_geo,
               variables=var_list,
               output="wide",
               year=2019)

names(labor)<-tolower(names(labor))
labor<-labor %>%
  group_by(name)%>%
  mutate(perc_in_labor_force = (b23025_002e/b23025_001e) *100) %>%
  select(name,perc_in_labor_force)


#housing df by county

var_list<-paste0("B25008_",c("001","002"))

homeown<-get_acs(my_geo,
                 variables=var_list,
                 output="wide",
                 year=2019)

names(homeown) <- tolower(names(homeown))

homeown<-
  homeown%>%
  mutate(perc_homeown=(b25008_002e/ b25008_001e)*100)%>%
  select(name,perc_homeown)

area_data <- educ %>%
  left_join(homeown, by = "name")

area_data <- area_data %>%
  left_join(income, by = "name")

area_data <- area_data %>%
  left_join(labor, by = "name")


##names(area_data)[names(area_data)=='college_educ'] <- '% college educated'
##names(area_data)[names(area_data)=='perc_homeown'] <- '% of homeowners'
##names(area_data)[names(area_data)=='perc_in_labor_force'] <- '% in labor force'

area_data_final <- area_data[,c(3,1,2,4,5,6)]

#BLS data (business dynamics & employment by county)
#employment/unemployment, labor force, etc. by county

county_emp_data <- read_excel("./laucnty19.xlsx")  %>%
  subset(select = -c(...6))


colnames(county_emp_data) <- c('code',
                               'state_fips_code',
                               'county_fips_code',
                               'county_name_abbrev',
                               'year',
                               'labor_force',
                               'employed',
                               'unemployment',
                               'unemployment_rate_%')
                              

county_emp_data <- county_emp_data[-c(1:5), ] 

county_emp_data$fips <- str_c(county_emp_data$state_fips_code, "", county_emp_data$county_fips_code)

final_countyemp_data <- subset(county_emp_data, select = -c(state_fips_code, county_fips_code, 1)) %>%
  relocate(fips)

#business dynamics data by county

#reading in csv & txt files from BLS website

cty_bds <- read.csv("./bds2019_cty.csv") 
codes <- read.table("./georef.txt", header=TRUE, sep = ",", dec = ".")

#cleaning data, merging dataframe to include fips codes, county names

cty_bds_2019 <- subset(cty_bds, year == 2019)
cty_bds_2019_w_codes <- merge(cty_bds_2019, codes, by=c("cty","st"))
  
cty_bds_2019_fips <- merge(cty_bds_2019_w_codes, county_n_fips, by = c("ctyname")) %>%
  subset(select = -c(cty, st)) %>%
  relocate(fips)


