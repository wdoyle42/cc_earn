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

## Load Data
cb_df<-read_rds(here("data","cleaned","cb_df.Rds"))

cb_rs<-vfold_cv(cb_df,v = 10)

earn_formula<-("earn_mdn_hi_1yr~.")

earn_recipe<-recipe(cb_df,earn_formula) %>%
  step_zv(all_predictors())%>%
  step_nzv(all_numeric_predictors())%>%
  update_role(-opeid6,new_role="predictor")%>%
  update_role(earn_mdn_hi_1yr,new_role="outcome")%>%
  update_role(opeid6,new_role="id variable")%>%
  step_naomit(all_predictors())%>%
  step_other(all_nominal_predictors(),threshold = .005)%>%
  step_dummy(all_nominal_predictors())%>%
  step_zv(all_predictors(),skip=TRUE) %>%
  step_nzv(all_numeric_predictors(),skip=TRUE)%>%
  step_normalize(all_numeric_predictors())%>%
  step_corr(all_numeric_predictors(),skip=TRUE,threshold = .95)

earn_prep<-prep(earn_recipe)
## Next model: random forest

tune_spec <- rand_forest(
  mtry = tune(),
  trees = 1000,
  min_n = tune()
) %>%
  set_mode("regression") %>%
  set_engine("ranger")

tune_wf <- workflow() %>%
  add_recipe(earn_recipe) %>%
  add_model(tune_spec)

doParallel::registerDoParallel(cores = 20)

tune_res <- tune_grid(tune_wf,
                      resamples = cb_rs,
                      grid = 20)

save(tune_res,file="tune_res.Rdata")

load("tune_res.Rdata")

gg<-tune_res%>%
  collect_metrics() %>%
  filter(.metric == "rmse")%>%
  select(mean,mtry,min_n)%>%
  pivot_longer(min_n:mtry,
               values_to = "value",
               names_to = "parameter"
  ) %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "RMSE")

save(gg,file = "rf_fit.Rdata")


best_rmse <- select_best(tune_res, "rmse")

final_rf <- finalize_model(
  tune_spec,
  best_rmse
)


final_rf


vi_final_rf<-final_rf %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(earn_mdn_hi_1yr ~ .,
      data = juice(earn_prep)
  ) %>%
  vip::vi(scale=TRUE)

save(vi_final_rf,file="vi_final_rf.Rdata")

load("vi_final_rf.Rdata")

## use vi instead, then plot

gg<-vi_final_rf %>%
  slice(1:25) %>%
  ggplot(aes(x = Importance,
             y = fct_reorder(as_factor(Variable),
                            .x = Importance))) +
  geom_point()


save(gg,file = "rf_vi.Rdata")
