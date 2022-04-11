set.seed(0505)

library(tidymodels) # doesn't load forcats, stringr, readr from tidyverse
library(readr)
library(vip)

d <- read_csv("data-to-model.csv")

d <- select(d, -time_spent) # this is another continuous outcome

train_test_split <- initial_split(d, prop = .70)

data_train <- training(train_test_split)

kfcv <- vfold_cv(data_train)

# pre-processing/feature engineering

# d <- select(d, student_id:final_grade, subject:percomp) # selecting the contextual/demographic variables
# and the survey variables

d <- d %>% select(-student_id)

sci_rec <- recipe(final_grade ~ ., data = d) %>% 
    add_role(course_id, new_role = "ID variable") %>% # this can be any string
    step_novel(all_nominal_predictors()) %>% 
    step_normalize(all_numeric_predictors()) %>%
    step_dummy(all_nominal_predictors()) %>% 
    step_nzv(all_predictors()) %>% 
    step_impute_knn(all_predictors(), all_outcomes())

# specify model
rf_mod_many <-
    rand_forest(mtry = tune(),
                min_n = tune()) %>%
    set_engine("ranger", importance = "impurity") %>%
    set_mode("regression")

# specify workflow
rf_wf_many <-
    workflow() %>%
    add_model(rf_mod_many) %>% 
    add_recipe(sci_rec)

# specify tuning grid
finalize(mtry(), data_train)
finalize(min_n(), data_train)

tree_grid <- grid_max_entropy(mtry(range(1, 15)),
                              min_n(range(2, 40)),
                              size = 10)

# fit model with tune_grid
tree_res <- rf_wf_many %>% 
    tune_grid(
        resamples = kfcv,
        grid = tree_grid,
        metrics = metric_set(rmse, mae, rsq)
    )

# examine best set of tuning parameters; repeat?
show_best(tree_res, n = 10)

# select best set of tuning parameters
best_tree <- tree_res %>%
    select_best()

# finalize workflow with best set of tuning parameters
final_wf <- rf_wf_many %>% 
    finalize_workflow(best_tree)

# fit split data (separately)
final_fit <- final_wf %>% 
    last_fit(train_test_split, metrics = metric_set(rmse, mae, rsq))

# variable importance plot
final_fit %>% 
    pluck(".workflow", 1) %>%   
    pull_workflow_fit() %>% 
    vip(num_features = 10)

# fit stats
final_fit %>%
    collect_metrics()

# test set predictions
final_fit %>%
    collect_predictions() 

preds <- final_fit %>%
    collect_predictions() %>% 
    mutate(diff = final_grade - .pred)

# plot of observed versus predicted final grades
preds %>%
    ggplot(aes(x = final_grade, y = .pred, color = diff)) +
    geom_abline(slope = 1, intercept = 0) +
    xlim(0, 100) +
    ylim(0, 100) +
    xlab("Observed") +
    ylab("Predicted") +
    labs(caption = "The black line represents predictions that match observed values.") +
    scale_color_gradient2("Deviance", high = "darkgreen", mid = "lightgray", low = "red") +
    geom_point()
