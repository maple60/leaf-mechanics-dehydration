# _setup.R

data_dir <- Sys.getenv("PROJECT_DATA_DIR", unset = "data")
data_path <- function(...) file.path(data_dir, ...)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

# Load libraries
library(tools)
library(mgcv)
#library(readxl)

# Source all R scripts in the R directory
invisible(lapply(list.files("R", full.names = TRUE, pattern = "\\.R$"), source))
# Set color palette
palette("Okabe-Ito")
