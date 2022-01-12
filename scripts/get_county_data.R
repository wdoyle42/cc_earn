# CC Earn Data
## Olivia Morales
## 2022-1-10

library(tidyverse)
library(tidycensus)
library(noncensus)
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

names(educ)[names(educ)=='GEOID'] <- 'County ID (FIPS)'

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
  select(name,college_educ)

#median income df by county
var_list<-paste0("B19013_",c("001"))

income<-get_acs(my_geo,
                variables=var_list,
                output="wide",
                year=2019)

#will use later functions as templates for remaining variables

#labor<-get_acs(my_geo,
               #variables=var_list,
              # output="wide",
              # year=2019)

#names(labor)<-tolower(names(labor))
#labor<-labor %>%
 # group_by(name)%>%
 # mutate(
 #   perc_in_labor_force = (
 #     b23025_002e / b23025_001e)*100
 # )%>%
#  select(name,perc_in_labor_force)
#var_list<-paste0("B07003_",c("001","013" ))
#mobility<-get_acs(my_geo,
                  #variables=var_list,
                 # output="wide",
                #  year=2019)


#var_list<-paste0("B25008_",c("001","002"))

#homeown<-get_acs(my_geo,
           #      variables=var_list,
          #       output="wide",
          #       year=2019)

#vnames(homeown)<-tolower(names(homeown))

#homeown<-
 # homeown%>%
#  mutate(perc_homeown=(b25008_002e/ b25008_001e)*100)%>%
#  select(name,perc_homeown)



