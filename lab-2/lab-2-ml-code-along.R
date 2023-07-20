library(tidyverse)
# install.packages("tidyverse)
library(tidymodels)

starwars_recoded <- starwars %>% # built-in data available just by typing
    mutate(species_human = ifelse(species == "Human", "human", "not human"))

starwars_recoded %>% 
    count(species_human) # how many humans are there?

starwars_recoded <- starwars_recoded %>% 
    mutate(homeworld_lumped = fct_lump_min(homeworld, min = 4)) 

train_test_split <- initial_split(starwars_recoded, prop = .70)
data_train <- training(train_test_split)

starwars_recoded %>% count(homeworld_lumped)

my_rec <- recipe(species_human ~ height + mass + 
                     homeworld_lumped +
                     birth_year + eye_color, 
                 data = data_train) %>% 
    step_dummy(eye_color) %>% 
    step_dummy(homeworld_lumped)

my_mod <-
    logistic_reg() %>% 
    set_engine("glm") %>%
    set_mode("classification")
my_wf <-
    workflow() %>%
    add_model(my_mod) %>% 
    add_recipe(my_rec)

fitted_model <- fit(my_wf, data = data_train) # ignore warning for this example
class_metrics <- metric_set(accuracy, sensitivity, specificity, ppv, npv, kap) # this is new
final_fit <- last_fit(fitted_model, train_test_split, metrics = class_metrics)

final_fit %>%
    collect_metrics()

final_fit %>% 
    collect_predictions()
