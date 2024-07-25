library(tidyverse)
library(tidymodels)

starwars_recoded <- starwars %>% # built-in data available just by typing
    mutate(species_human = ifelse(species == "Human", "Human", "Not human")) # recoding species to create a categorical variable

starwars_recoded %>% 
    count(species_human) # how many humans are there?

train_test_split <- initial_split(starwars_recoded, prop = .55, strata = "species_human")

train_test_split

# stratify!
# with a larger data set, you can "afford" to use a higher proportion (in your training data)
# with a smaller data set, usually something approaching a 50-50 split is needed
# the over-arching aim is to have as small a test set as possible *while maintaining representativeness in your test set sample*

data_train <- training(train_test_split)
data_test <- testing(train_test_split)

data_train

# predicting humans based on the independent effects of height and mass
my_rec <- recipe(species_human ~ height + mass + birth_year + gender, data = data_train) %>% 
    step_novel(gender)

my_rec %>% 
    prep()

# specify model
my_mod <- logistic_reg() %>%
    set_engine("glm") %>%
    set_mode("classification")

my_mod

# specify workflow
my_wf <- workflow() %>%
    add_model(my_mod) %>% 
    add_recipe(my_rec)

fit_model <- fit(my_wf, data_train)

predictions <- predict(fit_model, data_train) %>% 
    bind_cols(data_train) %>% 
    mutate(species_human = as.factor(species_human))

predictions %>%
    metrics(species_human, .pred_class) %>%
    filter(.metric == "accuracy")

## only run this once you're done training/messing with your model!
## this way, these estimates will be unbiased

final_fit <- last_fit(my_wf, train_test_split)

final_fit %>%
    collect_metrics()
