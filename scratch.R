library(tidyverse)
library(reticulate)

py_config()

getwd()

d <- read_csv("lab-1/data/ipeds-all-title-9-2022-data.csv")

d %>% View()

library(reticulate)
pd <- import("pandas")

