library(tidyverse)
library(arrow)

# this data is ignored in .gitignore
# the raw data is available from: https://analyse.kmi.open.ac.uk/
interactions <- read_csv("module-4/data/oulad-interactions.csv")
vle <- read_csv("module-4/data/oulad-vle.csv")

interactions <- interactions %>% 
    left_join(vle, by = c("id_site", "code_module", "code_presentation"))

write_parquet(interactions, "module-4/data/oulad-interactions.parquet")
