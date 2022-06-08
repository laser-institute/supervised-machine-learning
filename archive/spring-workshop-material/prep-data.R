library(tidyverse)
library(janitor)

gb <- read_csv("gradebook.csv", col_types = cols(last_access_data = col_date())) %>% clean_names()
s <- read_csv("survey.csv") %>% clean_names()
t <- read_csv("trace.csv") %>% clean_names()

disc_final <- read_csv("disc-final.csv") # this is processed because it is not easy to anonymize the text

s_ss <- s %>% 
    select(student_id:tv) %>% 
    mutate(student_id = as.double(student_id))

gb_ss <- gb %>%
    filter(gradebook_type != "T") %>% 
    group_by(student_id, course_id) %>%
    arrange(student_id, item_position) %>% 
    slice(1:20) # first 20 assignments

gb_final <- gb_ss %>% 
    mutate(points_earned = as.double(points_earned)) %>% 
    summarize(total_points_possible = sum(points_possible, na.rm = T),
              total_points_earned = sum(points_earned, na.rm = T)) %>% 
    mutate(percentage_earned = total_points_earned / total_points_possible)

# for the next function
clean_text <- function(htmlString) {
    return(gsub("<.*?>", "", htmlString))
}

find_length <- function(x) {
    stringr::str_split(x, " ") %>% 
        pluck(1) %>% 
        length()
}

d <- t %>% 
    left_join(s_ss) %>% 
    left_join(gb_final) %>% 
    left_join(disc_final)

# remove students with substantial missing data
# d %>% 
#     visdat::vis_dat() 

# a little further prep
d <- select(d, -total_points_possible, -total_points_earned, -tv)

d_ss <- d %>% filter(!is.na(uv))

write_csv(d_ss, "data-to-model.csv")

