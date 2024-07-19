library(tidyverse)

interactions <- read_csv("data/oulad-interactions.csv")
assessments <- read_csv("data/oulad-assessments.csv")

code_module_dates <- assessments %>% 
  group_by(code_module, code_presentation) %>% 
  summarize(quantile_cutoff_date = quantile(date, probs = .33, na.rm = TRUE)) # change this throughout

students_and_assessments <- read_csv("data/oulad-students-and-assessments.csv")

interactions_joined <- interactions %>% 
    left_join(code_module_dates) # join the data based on course_module and course_presentation

interactions_filtered <- interactions_joined %>% 
    filter(date < quantile_cutoff_date) # filter the data so only assignments before the cutoff date are included