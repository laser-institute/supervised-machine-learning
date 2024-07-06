library(tidyverse)
library(tidymodels)

starwars_recoded <- starwars %>% # built-in data available just by typing
    mutate(species_human = ifelse(species == "Human", "human", "not human"))

starwars_recoded %>% 
    count(species_human, sort = TRUE)

starwars_recoded %>% 
    count(homeworld, sort = TRUE)

starwars_recoded <- starwars_recoded %>% 
    mutate(homeworld_lumped = fct_lump_min(homeworld, min = 5))

starwars_recoded %>% 
    count(homeworld_lumped, sort = TRUE)

train_test_split <- initial_split(starwars_recoded, prop = .70)
data_train <- training(train_test_split)

my_rec <- recipe(species_human ~ height + mass + birth_year + eye_color + homeworld_lumped, data = data_train) %>% 
    step_dummy(eye_color) # need to dummy code

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








band_members
band_instruments

band_members %>% left_join(band_instruments, by = join_by(name, course_id))
band_members %>% inner_join(band_instruments)



