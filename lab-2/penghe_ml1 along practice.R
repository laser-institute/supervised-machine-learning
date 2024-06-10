# Loading, setting up: create a .R file in /lab-1 and run this code
library(tidyverse)
library(tidymodels)

#view (starwars)
starwars %>% 
    count (species) %>% 
    arrange(desc(n))

view (starwars)

starwars_recoded <- starwars %>% # built-in data available just by typing
    mutate(species_human = ifelse(species == "Human", 1, 0)) %>% # recoding species to create a 0-1 outcome
    mutate (species_human = as.factor(species_human))

starwars_recoded %>% 
    count(species) %>% # how many humans are there? 

install.packages("janitor")
library(janitor)
starwars_recoded %>% 
    tabyl(species_human)
    
# Split data
train_test_split <- initial_split(starwars_recoded, prop = .80)

data_train <- training(train_test_split)
data_test <- testing(train_test_split)

# Engineer features
# predicting humans based on the independent effects of height and mass
my_rec <- recipe(species_human ~ height + mass, data = data_train)

# Specify recipe, model, and workflow
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

#Fit model
fitted_model <- fit(my_wf, data = data_train)

final_fit <- last_fit(fitted_model, train_test_split)

# Evaluate accuracy
final_fit %>%
    collect_metrics()
