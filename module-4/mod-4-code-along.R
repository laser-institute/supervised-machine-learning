library(tidyverse)
library(tidymodels)
library(vip) # install.packages("vip")

starwars_recoded <- starwars %>% # built-in data available just by typing
    mutate(species_human = ifelse(species == "Human", "human", "not human"))

train_test_split <- initial_split(starwars_recoded, prop = .60)
data_train <- training(train_test_split)

kfcv <- vfold_cv(data_train, v = 10)

my_rec <- recipe(species_human ~ height + mass + birth_year + eye_color, data = data_train) %>% 
    step_novel(eye_color) # need to dummy code

my_mod <- rand_forest() %>% # different
    set_engine("ranger", importance = "impurity") %>% # different and with importance
    set_mode("classification")

class_metrics <- metric_set(accuracy, kap, sensitivity, specificity, ppv, npv) # this is new

my_wf <- workflow() %>% 
    add_model(my_wod) %>% 
    add_recipe(my_rec)

fitted_model_resamples <- fit_resamples(my_wf, 
                                        resamples = kfcv, # different
                                        metrics = class_metrics)

collect_metrics(fitted_model_resamples)

final_fit <- last_fit(my_wf, train_test_split, metrics = class_metrics) # only now we look at the testing data
collect_metrics(final_fit)

final_fit %>% 
    pluck(".workflow", 1) %>%   
    pull_workflow_fit() %>% 
    vip(num_features = 10)
