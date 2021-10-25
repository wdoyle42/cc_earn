# CC Earn Data
## Will Doyle
## 2021-10-13

library(tidyverse)
library(rscorecard)
library(tidycensus)
library(ipumsr)
library(janitor)
library(here)
library(tidymodels)
library(vip)

## Presets

hardhat::default_recipe_blueprint(allow_novel_levels = TRUE)

## Functions

## What prop of X is missing?
prop_na<-function(x){sum(is.na(x))/length(x)}

## Constants

## How many unique values require before it's not a factor?
n_unique<-100

## Load in zip code level data
zip_data<-read_rds(here("data","cleaned","zip_data.Rds"))

## Load in program level data
pr_df<-read_csv(here("data","raw","Most-Recent-Cohorts-Field-of-Study.csv"),
                     na = c("PrivacySuppressed","NULL")
                )%>%
  clean_names(case="snake")%>%
  filter(credlev<4)%>% ## UG degrees only
  filter(!is.na(earn_mdn_hi_1yr))%>% ## Complete data
  select(opeid6,creddesc,cipdesc, earn_mdn_hi_1yr) ## just id vars and earnings

## Load in scorecard data
cb_df<-read_csv(here("data","raw","Most-Recent-Cohorts-All-Data-Elements.csv"),
                 na=c("PrivacySuppressed","NULL"))%>%
  clean_names(case="snake")%>%
  mutate(opeid6=as.character(opeid6))

## Wrangle scorecard data
cb_df<-
  cb_df%>%
  select(!contains("num"))%>% # Count
  select(!contains("_n"))%>% #count
  select(!contains("count"))%>% # I am ze count ah ah ah....
  select(!contains("sd"))%>% #standar deviation
  select(!contains("earn"))%>% #overalignment with outcome
  select(!contains("den"))%>% # denominator, again
  select(!contains("url"))%>% # url
  select(!matches("^(cip\\d{2})"))%>% ## cip codes from scorecard
  select(-st_fips)%>% # duplicate var
  select(-c(latitude,longitude))%>% #id var
  select(-accredagency)%>% #duplicate
  select(-unitid)%>% #duplcicate id
  select(-fedschcd) #duplicate id

## Min and max values
n_unique_min<-100
n_unique_max<-length(unique(cb_df$opeid6))

cb_df<-cb_df%>%
  mutate_if( ~ (n_distinct(.) < n_unique_min), as.factor)%>% ## recode few distinct as factors
  group_by(opeid6)%>%  ##
  select_if((~(n_distinct(.)!=n_unique_max)))%>% ## drop replicate id vars
  ungroup()

## Records likely factors to look at later
likely_factors <- cb_df %>%
  select_if( ~ (is.factor(.))) %>%
  names()

## Convert factors
cb_df<-cb_df%>%
  mutate(across(where(is.factor), as.character))

## Proportion missing before dropped altogether

prop_miss<-.25

keep_names<-
  cb_df%>%
  summarise_all(prop_na)%>%
  select(which(.<prop_miss))%>%
  names()

cb_df<-cb_df%>%
  select(all_of(keep_names))

cb_df<-cb_df%>%
  left_join(zip_data,by="zip")

cb_df<-pr_df%>%
  left_join(cb_df,by="opeid6")

cb_df<-cb_df%>%drop_na()

write_rds(cb_df,here("data","cleaned","cb_df.Rds"))
