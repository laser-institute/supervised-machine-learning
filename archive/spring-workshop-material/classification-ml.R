set.seed(0505)

library(tidymodels) # doesn't load forcats, stringr, readr from tidyverse
library(readr)
library(vip)

d <- read_csv("data-to-model.csv")

d <- select(d, -time_spent) # this is another outcome

d_class <- mutate(d, passing_grade = ifelse(final_grade > 70, 1, 0),
                  passing_grade = as.factor(passing_grade)) %>% 
    select(-final_grade)

train_test_split <- initial_split(d_class, prop = .70)

data_train <- training(train_test_split)

kfcv <- vfold_cv(data_train)

# pre-processing/feature engineering

d <- select(d, student_id:final_grade, subject:percomp) # selecting the contextual/demographic variables
# and the survey variables

d <- d %>% select(-student_id)

sci_rec <- recipe(passing_grade ~ ., data = d_class) %>% 
    add_role(student_id, course_id, new_role = "ID variable") %>% # this can be any string
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
    set_mode("classification") # note this difference!

# specify workflow
rf_wf_many <-
    workflow() %>%
    add_model(rf_mod_many) %>% 
    add_recipe(sci_rec)

# specify tuning grid
finalize(mtry(), data_train)
finalize(min_n(), data_train)

tree_grid <- grid_max_entropy(mtry(range(1, 16)),
                              min_n(range(2, 40)),
                              size = 10)

# fit model with tune_grid
tree_res <- rf_wf_many %>% 
    tune_grid(
        resamples = kfcv,
        grid = tree_grid,
        metrics = metric_set(roc_auc, accuracy, kap, sensitivity, specificity, precision)
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
    last_fit(train_test_split, metrics = metric_set(roc_auc, accuracy, kap, 
                                                    sensitivity, specificity, precision))

# fit stats
final_fit %>%
    collect_metrics()

# variable importance plot
final_fit %>% 
    pluck(".workflow", 1) %>%   
    pull_workflow_fit() %>% 
    vip(num_features = 10)

# test set predictions
final_fit %>%
    collect_predictions() 

lr_auc <- final_fit %>% 
    collect_predictions() %>% 
    roc_curve(passing_grade, .pred_0)

autoplot(lr_auc)
