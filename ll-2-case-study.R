## ----setup, include=FALSE---------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ---------------------------------------------------------------------------------------------------
library(tidyverse)
library(tidymodels)
library(janitor)


## ---------------------------------------------------------------------------------------------------
students <- read_csv("data/oulad-students.csv")
assessments <- read_csv("data/oulad-assessments.csv")


## ---------------------------------------------------------------------------------------------------
assessments %>% 
    count(assessment_type)


## ---------------------------------------------------------------------------------------------------
assessments %>% 
    distinct(id_assessment) # this many unique assessments


## ---------------------------------------------------------------------------------------------------
assessments %>% 
    count(assessment_type, code_module, code_presentation)


## ---------------------------------------------------------------------------------------------------
assessments %>% 
    summarize(mean_date = mean(date, na.rm = TRUE), # find the mean date for assignments
              median_date = median(date, na.rm = TRUE), # find the median
              sd_date = sd(date, na.rm = TRUE), # find the sd
              min_date = min(date, na.rm = TRUE), # find the min
              max_date = max(date, na.rm = TRUE)) # find the mad


## ---------------------------------------------------------------------------------------------------
assessments %>% 
    group_by(code_module, code_presentation) %>% # first, group by course (module: course; presentation: semester)
    summarize(mean_date = mean(date, na.rm = TRUE),
              median_date = median(date, na.rm = TRUE),
              sd_date = sd(date, na.rm = TRUE),
              min_date = min(date, na.rm = TRUE),
              max_date = max(date, na.rm = TRUE),
              first_quantile = quantile(date, probs = .25, na.rm = TRUE)) # find the first (25%) quantile


## ---------------------------------------------------------------------------------------------------
code_module_dates <- assessments %>% 
    group_by(code_module, code_presentation) %>% 
    summarize(quantile_cutoff_date = quantile(date, probs = .25, na.rm = TRUE))


## ---------------------------------------------------------------------------------------------------


## ---------------------------------------------------------------------------------------------------
assessments_joined <- assessments %>% 
    left_join(code_module_dates) # join the data based on course_module and course_presentation


## ---------------------------------------------------------------------------------------------------
assessments_filtered <- assessments_joined %>% 
    filter(date < quantile_cutoff_date) # filter the data so only assignments before the cutoff date are included


## ---------------------------------------------------------------------------------------------------
assessments_summarized <- assessments_filtered %>% 
    mutate(weighted_score = score * weight) %>% # create a new variable that accounts for the "weight" (comparable to points) given each assignment
    group_by(id_student) %>% 
    summarize(mean_weighted_score = mean(weighted_score)) 


## ---------------------------------------------------------------------------------------------------
students <- students %>% 
    mutate(pass = ifelse(final_result == "Pass", 1, 0)) %>% # creates a dummy code
    mutate(pass = as.factor(pass)) # makes the variable a factor, helping later steps

students <- students %>% 
    mutate(imd_band = factor(imd_band, levels = c("0-10%",
                                                  "10-20%",
                                                  "20-30%",
                                                  "30-40%",
                                                  "40-50%",
                                                  "50-60%",
                                                  "60-70%",
                                                  "70-80%",
                                                  "80-90%",
                                                  "90-100%"))) %>% # this creates a factor with ordered levels
    mutate(imd_band = as.integer(imd_band)) # this changes the levels into integers based on the order of the factor levels


## ---------------------------------------------------------------------------------------------------
students_and_assessments <- students %>% 
    left_join(assessments_summarized)


## ---------------------------------------------------------------------------------------------------
set.seed(20230712)

students_and_assessments <- students_and_assessments %>% 
    drop_na(mean_weighted_score)

train_test_split <- initial_split(students_and_assessments, prop = .50, strata = "pass")
data_train <- training(train_test_split)
data_test <- testing(train_test_split)


## ---------------------------------------------------------------------------------------------------
my_rec <- recipe(pass ~ disability +
                     date_registration + 
                     gender +
                     code_module +
                     mean_weighted_score, 
                 data = data_train) %>% 
    step_dummy(disability) %>% 
    step_dummy(gender) %>%  
    step_dummy(code_module)



## ---------------------------------------------------------------------------------------------------
# specify model
my_mod <-
    logistic_reg() %>% 
    set_engine("glm") %>% # generalized linear model
    set_mode("classification") # since we are predicting a dichotomous outcome, specify classification; for a number, specify regression

# specify workflow
my_wf <-
    workflow() %>% # create a workflow
    add_model(my_mod) %>% # add the model we wrote above
    add_recipe(my_rec) # add our recipe we wrote above


## ---------------------------------------------------------------------------------------------------
fitted_model <- fit(my_wf, data = data_train)


## ---------------------------------------------------------------------------------------------------
class_metrics <- metric_set(accuracy, sensitivity, specificity, ppv, npv, kap) # add probs?


## ---------------------------------------------------------------------------------------------------
final_fit <- last_fit(fitted_model, train_test_split, metrics = class_metrics)


## ---------------------------------------------------------------------------------------------------
collect_predictions(final_fit)


## ---------------------------------------------------------------------------------------------------
collect_predictions(final_fit) %>% 
    conf_mat(.pred_class, pass)


## ---------------------------------------------------------------------------------------------------
collect_metrics(final_fit)

