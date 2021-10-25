# Random forest postestimation

load("tune_res.Rdata")

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


## use vi instead, then plot

vi_final_rf %>%
  slice(1:25) %>%
  ggplot(aes(x = Importance,
             y = fct_reorder(as_factor(Variable),
                             .x = Importance))) +
  geom_point()