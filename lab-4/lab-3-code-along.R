library(tidyverse)
library(tidymodels)
library(vip)

starwars_recoded <- starwars %>% # built-in data available just by typing
    mutate(species_human = ifelse(species == "Human", "human", "not human"))

starwars_recoded <- starwars_recoded %>% 
    filter(!is.na(species_human))

train_test_split <- initial_split(starwars_recoded, prop = .70)
data_train <- training(train_test_split)

vfcv <- vfold_cv(data_train, v = 5)

my_rec <- recipe(species_human ~ height + mass, data = data_train)

my_rec <- my_rec %>% 
    step_impute_mean(height, mass)

my_mod <- rand_forest() %>% # different
    set_engine("ranger", importance = "impurity") %>% # different and with importance
    set_mode("classification")
my_wf <- workflow() %>%
    add_model(my_mod) %>% 
    add_recipe(my_rec)
fitted_model_resamples <- fit_resamples(my_wf, 
                                        resamples = vfcv,
                                        metrics = class_metrics)
