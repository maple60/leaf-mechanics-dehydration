# Shared notebook setup. Run notebooks from the project root.
data_dir <- Sys.getenv("PROJECT_DATA_DIR", unset = "data")
data_path <- function(...) file.path(data_dir, ...)

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

library(mgcv)
source("R/plot_gam_ci.R")
source("R/summarize_trait.R")
palette("Okabe-Ito")
