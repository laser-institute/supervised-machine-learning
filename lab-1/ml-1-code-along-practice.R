library(tidyverse)
library(tidymodels)

set.seed(20230718)

starwars_recoded <- starwars %>% # built-in data available just by typing
    mutate(species_human = ifelse(species == "Human", "1", "0"),
           species_human = as.factor(species_human))

starwars_recoded %>% 
    count(species_human)

train_test_split <- initial_split(starwars_recoded, prop = .80)
data_train <- training(train_test_split)

starwars

# predicting humans based on the independent effects of height and mass
my_rec <- recipe(species_human ~ height + mass, data = data_train)

# specify model
my_mod <-
    logistic_reg() %>% 
    set_engine("glm") %>%
    set_mode("classification")
# specify workflow
my_wf <-
    workflow() %>%
    add_model(my_mod) %>% 
    add_recipe(my_rec)

fitted_model <- fit(my_wf, data = data_train)
final_fit <- last_fit(fitted_model, train_test_split)

fitted_model

final_fit %>%
    collect_metrics()
