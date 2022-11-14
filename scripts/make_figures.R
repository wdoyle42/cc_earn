################################################################################
##
##
##
################################################################################

## libraries
libs <- c("tidyverse", "here", "tidymodels")
sapply(libs, require, character.only = TRUE)

## paths
dat_dir <- here("data")
cln_dir <- file.path(dat_dir, "cleaned")

## -----------------------------------------------------------------------------
## elastic net figures
## -----------------------------------------------------------------------------

load(file.path(cln_dir, "enet_fit.Rdata"))

gg <- enet_fit |>
  ggplot(aes(x=RMSE,color=tune_id,fill=tune_id))+
  geom_density(alpha=.1)+
  scale_x_continuous(labels=scales::dollar_format())

load(file.path(cln_dir, "enet_vi_final.Rdata"))

gg<-vi_final%>%
  slice(1:10)%>%
  ggplot(aes(y=Importance,x=fct_reorder(Variable,.x=Importance),fill=Sign))+
  geom_col()+
  coord_flip()+
  theme(legend.position="bottom")+
  xlab("")+
  ylab("")

## -----------------------------------------------------------------------------
## random forest figures
## -----------------------------------------------------------------------------

load(file.path(cln_dir, "tune_res.Rdata"))

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

tune_res%>%
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

load(file.path(cln_dir, "vi_final_rf.Rdata"))

gg<-vi_final_rf %>%
  slice(1:25) %>%
  ggplot(aes(x = Importance,
             y = fct_reorder(as_factor(Variable),
                            .x = Importance))) +
  geom_point()


## -----------------------------------------------------------------------------
## END SCRIPT
################################################################################
