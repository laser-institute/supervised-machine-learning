# Load necessary package
if (!require("quarto")) install.packages("quarto")
library(quarto)

# Set the directory path (you can customize this)
directory <- "."

# List all .qmd files in the directory
qmd_files <- list.files(path = directory, pattern = "\\.qmd$", full.names = TRUE)

# Render each .qmd file
for (file in qmd_files) {
    cat("Rendering", file, "...\n")
    quarto::quarto_render(file)
}
