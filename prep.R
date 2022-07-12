# ll1

library(tidyverse)
library(here)
library(tidymodels)

d <- read_rds(here("data", "ngsschat-data.rds"))

codes <- read_csv(here("data", "ngsschat-qualitative-codes.csv"))

codes <- codes %>% 
    select(id_string = ID, code = Code) # this changes the variables names in the codes data frame to be the esame as in the tweets

dd <- d %>% 
    left_join(codes) %>% # join the two files together
    filter(!is.na(code)) %>% 
    filter(code != "OT" & code != "RT" & code != "TF") # here, because TF (transformational) codes are so rare, we exclude them, as well as OT (off-topic) and RT (retweet) tweets and those missing a code

ddd <- dd %>% 
    select(favorite_count, retweet_count, followers_count, friends_count, statuses_count, display_text_width, 
           code, id_string) %>% # select the variables we'll use for our supervised machine learning model
    filter(!is.na(favorite_count)) %>% 
    group_by(id_string) %>% # group the tweets by thread and calculate summary variables
    summarize(mean_favorite_count = mean(favorite_count), # this and the next are means; this could, though, be a sum; it represents the average number of favorites each tweet in the thread received
              mean_retweet_count = mean(retweet_count), # how many retweets each tweet received
              sum_display_text_width = sum(display_text_width), # this is a variable for the length of the tweet; sum seems more sensible than mean
              n = n()) %>% # the number of tweets in the thread
    left_join(distinct(dd, id_string, code)) %>%  # here, we join back the codes, as we lost them in the summary step
    select(-id_string)

write_csv(ddd, here("data", "ngsschat-processed-data.csv"))

# ll3

library(tidyverse)
library(here)
library(tidymodels)

d <- read_rds(here("data", "ngsschat-data.rds"))

codes <- read_csv(here("data", "ngsschat-qualitative-codes.csv"))

codes <- codes %>% 
    select(id_string = ID, code = Code) # this changes the variables names in the codes data frame to be the esame as in the tweets

dd <- d %>% 
    left_join(codes) %>% # join the two files together
    filter(!is.na(code)) %>% 
    filter(code != "OT" & code != "RT" & code != "TF") # here, because TF (transformational) codes are so rare, we exclude them, as well as OT (off-topic) and RT (retweet) tweets and those missing a code

ddd <- dd %>% 
    select(favorite_count, retweet_count, followers_count, friends_count, statuses_count, display_text_width, 
           code, id_string, screen_name) %>% # select the variables we'll use for our supervised machine learning model
    filter(!is.na(favorite_count)) %>% 
    group_by(id_string) %>% # group the tweets by thread and calculate summary variables
    summarize(mean_favorite_count = mean(favorite_count), # this and the next are means; this could, though, be a sum; it represents the average number of favorites each tweet in the thread received
              sum_favorite_count = sum(favorite_count),
              mean_retweet_count = mean(retweet_count), # how many retweets each tweet received
              sum_retweet_count = sum(retweet_count),
              mean_display_text_width = mean(display_text_width), # this is a variable for the length of the tweet; sum seems more sensible than mean
              sum_display_text_width = sum(display_text_width), # this is a variable for the length of the tweet; sum seems more sensible than mean
              n = n()) %>% # the number of tweets in the thread
    left_join(distinct(dd, id_string, code)) %>%  # here, we join back the codes, as we lost them in the summary step
    select(-id_string)

write_csv(ddd, here("data", "ngsschat-processed-data-add-three-features.csv"))
