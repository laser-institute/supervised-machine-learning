library(tidyverse)
library(tidyLPA)
library(tidytext)

d <- read_csv("lab-4/data/r-processed-transcripts.csv")

nrc <- get_sentiments("nrc")

d <- d %>% 
    select(group, index, start, end, duration, transcript)

d %>% 
    unnest_tokens(word, transcript) %>%
    left_join(nrc, relationship = "many-to-many") %>% # ignore warnings
    count(sentiment)

# Set the chunk size and the starting point
chunk_size <- 15  # Chunk size in seconds
start_point <- d$start %>% as.integer() %>% pluck(1)
end_point <- d$end %>% as.integer() %>% pluck(nrow(d))

d$start <- as.integer(d$start)
d$end <- as.integer(d$end)

# Create a new variable for the chunks
d$segment_id <- cut(d$start, breaks = seq(from = start_point, to = end_point, by = chunk_size))

data_for_lpa <- d %>% 
    unnest_tokens(word, transcript) %>% 
    left_join(nrc, relationship = "many-to-many") %>% # ignore warnings
    count(segment_id, sentiment) %>% 
    spread(sentiment, n) %>% 
    janitor::clean_names() %>% 
    reframe(pct_fear = fear / na,
            pct_joy = joy / na,
            pct_anticipation = anticipation / na,
            pct_disgust = disgust / na,
            pct_sadness = sadness / na,
            pct_surprise = surprise / na,
            pct_trust = trust / na) %>% 
    mutate_if(is.numeric, replace_na, 0)

# my_scale <- function(x) {
#     x <- x - mean(x)
#     x / sd(x)
# }
# 
# data_for_lpa <- data_for_lpa %>% 
#     mutate_if(is.numeric, my_scale)

data_for_lpa %>% 
    tidyLPA::estimate_profiles(n_profiles = 3) %>% 
    tidyLPA::plot_profiles(add_line = TRUE)

data_for_lpa %>% 
    tidyLPA::estimate_profiles(n_profiles = 4) %>% 
    tidyLPA::plot_profiles(add_line = TRUE)

data_for_lpa %>%
    estimate_profiles(3:7) %>% 
    compare_solutions()

our_solution <- data_for_lpa %>%
    estimate_profiles(4)

our_solution %>% 
    get_estimates()

plot_profiles(our_solution, add_line = TRUE) +
    theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1)) # this rotates the x-axis labels to make them easier to read
