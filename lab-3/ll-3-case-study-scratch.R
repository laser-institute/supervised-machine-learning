## ----setup, include=FALSE---------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ---------------------------------------------------------------------------------------------------

library(tidyverse)
library(tidymodels)
library(janitor)
library(ranger)
library(vip)

## ---------------------------------------------------------------------------------------------------

assessments <- read_csv("lab-3/data/oulad-assessments.csv")

code_module_dates <- assessments %>% 
    group_by(code_module, code_presentation) %>% 
    summarize(quantile_cutoff_date = quantile(date, probs = .25, na.rm = TRUE))

## ---------------------------------------------------------------------------------------------------

# students and assessments 
students_and_assessments <- read_csv("lab-3/data/oulad-students-and-assessments.csv")

## ---------------------------------------------------------------------------------------------------

# log-data
interactions <- read_csv("lab-3/data/oulad-interactions.csv")

interactions %>% 
    count(activity_type)

interactions %>% 
    ggplot(aes(x = log(sum_click))) +
    geom_histogram()

interactions %>% 
    ggplot(aes(x = date)) +
    geom_histogram()

interactions %>% 
    count(id_site, code_module, code_presentation)

## ---

code_module_dates <- assessments %>% 
    group_by(code_module, code_presentation) %>% 
    summarize(quantile_cutoff_date = quantile(date, probs = .25, na.rm = TRUE))

interactions_joined <- interactions %>% 
    left_join(code_module_dates) # join the data based on course_module and course_presentation

interactions_filtered <- interactions_joined %>% 
    filter(date < quantile_cutoff_date) # filter the data so only assignments before the cutoff date are included

## ---------------------------------------------------------------------------------------------------

interactions_summarized <- interactions_filtered %>% 
    group_by(id_student, code_module, code_presentation) %>% 
    summarize(sum_clicks = sum(sum_click),
              sd_clicks = sd(sum_click), 
              max_clicks = max(sum_click))

interactions_summarized %>% 
    ggplot(aes(x = sum_clicks)) +
    geom_histogram()

interactions_summarized_activity <- interactions_filtered %>% 
    group_by(id_student, code_module, code_presentation, activity_type) %>% 
    summarize(sum_clicks = sum(sum_click))

interactions_summarized_activity %>% 
    ggplot(aes(x = sum_clicks)) +
    geom_histogram() +
    facet_wrap(~activity_type)

interactions_slopes <- interactions_filtered %>% 
    group_by(id_student, code_module, code_presentation) %>% 
    nest() %>% 
    mutate(model = map(data, ~lm(sum_click ~ 1 + date, data = .x) %>% 
                           tidy)) %>% 
    unnest(model)

interactions_slopes %>% 
    filter(term == "date")

students_assessments_and_interactions <- left_join(students_and_assessments, 
                                                   interactions_summarized)

students_assessments_and_interactions <- students_assessments_and_interactions %>% 
    mutate(pass = as.factor(pass))

## ---------------------------------------------------------------------------------------------------

set.seed(20230712)

train_test_split <- initial_split(students_assessments_and_interactions , prop = .50, strata = "pass")
data_train <- training(train_test_split)
kfcv <- vfold_cv(data_train) # this differentiates this from what we did before
# before, we simple used data_train to fit our model
data_test <- testing(train_test_split)


## ---------------------------------------------------------------------------------------------------
my_rec <- recipe(pass ~ disability +
                     date_registration + 
                     gender +
                     code_module +
                     mean_weighted_score +
                     sum_clicks, 
                 data = data_train) %>% 
    step_dummy(disability) %>% 
    step_dummy(gender) %>%  
    step_dummy(code_module) %>% 
    step_impute_knn(sum_clicks) %>% 
    step_impute_knn(date_registration)

## ---------------------------------------------------------------------------------------------------
# specify model
my_mod <-
    rand_forest() %>% 
    set_engine("ranger", importance = "impurity") %>% # random
    set_mode("classification") # since we are predicting a dichotomous outcome, specify classification; for a number, specify regression

# specify workflow
my_wf <-
    workflow() %>% # create a workflow
    add_model(my_mod) %>% # add the model we wrote above
    add_recipe(my_rec) # add our recipe we wrote above


## ---------------------------------------------------------------------------------------------------
fitted_model_resamples <- fit_resamples(my_wf, resamples = kfcv,
                              control = control_grid(save_pred = TRUE)) # this allows us to inspect the predictions

fitted_model_resamples %>%
    collect_metrics()

## ---------------------------------------------------------------------------------------------------
class_metrics <- metric_set(accuracy, sensitivity, specificity, ppv, npv, kap) # add probs?

fitted_model <- fit(my_wf, data_train)
final_fit <- last_fit(fitted_model, train_test_split, metrics = class_metrics)

final_fit %>% 
    collect_metrics()

final_fit %>% 
    pluck(".workflow", 1) %>%   
    extract_fit_parsnip() %>% 
    vip(num_features = 10)

## ---------------------------------------------------------------------------------------------------
collect_predictions(final_fit)


## ---------------------------------------------------------------------------------------------------
collect_predictions(final_fit) %>% 
    conf_mat(.pred_class, pass)


## ---------------------------------------------------------------------------------------------------
collect_metrics(final_fit)

