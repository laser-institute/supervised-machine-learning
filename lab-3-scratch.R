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

