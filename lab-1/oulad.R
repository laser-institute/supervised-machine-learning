library(tidyverse)

f <- list.files("lab-1/data/oulad", full.names = TRUE)
f

l <- map(f, read_csv)

# l[[2]] # courses
l[[3]] # student assessment
l[[4]] # student info
l[[5]] # student registration
l[[6]] # student interactions

# how many students?
l[[5]] %>% count(id_student)
l[[5]] %>% count(id_student, code_module, code_presentation)

# how many courses
l[[2]] %>% count(code_module, code_presentation)

# how many assessments
l[[1]] %>% count(id_assessment) # some assessments apparently not taken
l[[3]] %>% count(id_assessment)

# how many interactions
l[[7]] %>% count(id_site)
l[[6]] %>% count(id_site)

# ---

# student assessment (3), info (4), registration (5), assessments (1), and courses (2)
l[[3]] %>% count(id_assessment)

students <- l[[4]] %>% # student info
    left_join(l[[2]]) %>% # courses
    left_join(l[[5]])

assessments <- l[[3]] %>% 
    left_join(l[[1]])

# student VLE (6), VLE (7), and courses (2)
interactions <- l[[6]] %>% 
    left_join(l[[7]]) %>% 
    left_join(l[[2]])

students

assessments %>% 
    count(assessment_type)

interactions %>% 
    count(activity_type)

interactions %>% 
    group_by(activity_type) %>% 
    summarize(mean = mean(sum_click), n = n()) %>% 
    arrange(desc(mean))
