library(tidyverse)
library(tidymodels)

starwars_recoded <- starwars %>% # built-in data available just by typing
    mutate(species_human = ifelse(species == "Human", "Human", "Not human")) # recoding species to create a categorical variable
starwars_recoded %>% 
    count(species_human) # how many humans are there?

train_test_split <- initial_split(starwars_recoded, prop = .90)
data_train <- training(train_test_split)
data_test <- testing(train_test_split)

# predicting humans based on the independent effects of height and mass
my_rec <- recipe(species_human ~ height + mass, data = data_train)

# specify model
my_mod <- logistic_reg() %>% 
    set_engine("glm") %>%
    set_mode("classification")

# specify workflow
my_wf <- workflow() %>%
    add_model(my_mod) %>% 
    add_recipe(my_rec)

fitted_model <- fit(my_wf, data = data_train)

final_fit <- last_fit(fitted_model, train_test_split)

final_fit %>%
    collect_metrics()
