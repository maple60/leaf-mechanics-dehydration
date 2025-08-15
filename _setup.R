# _setup.R

# Load libraries
library(tools)
library(mgcv)
#library(readxl)

# Source all R scripts in the R directory
invisible(lapply(list.files("R", full.names = TRUE, pattern = "\\.R$"), source))
# Set color palette
palette("Okabe-Ito")
