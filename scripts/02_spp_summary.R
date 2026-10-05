# The script for summarizing trait data of all species

source("_setup.R")
# Data Import ----
data_list <- list()
data_list[["bending"]] <- read.csv("outputs/tables/bending.csv")
data_list[["tensile"]] <- read.csv("outputs/tables/tensile.csv")


# Leaf thickness ----
# Extract data at 100% RWC
# Remove rows where dry_time is NA​
data_list[["bending"]] <- data_list[["bending"]][
  !is.na(data_list[["bending"]]$dry_time),
]
# Extract rows where dry_time = 0
data_list[["bending_turgid"]] <- data_list[["bending"]][
  data_list[["bending"]]$dry_time == 0,
]
data_list[["tensile_turgid"]] <- data_list[["tensile"]][
  data_list[["tensile"]]$dry_time == 0,
]
# Extract and combine leaf thickness data from bending and tensile tests
data_list[["bending_thickness_turgid"]] <- data_list[["bending_turgid"]][, c(
  "spp",
  "thick"
)]
data_list[["tensile_thickness_turgid"]] <- data_list[["tensile_turgid"]][, c(
  "spp",
  "thick"
)]
data_list[["thickness_turgid"]] <- rbind(
  data_list[["bending_thickness_turgid"]],
  data_list[["tensile_thickness_turgid"]]
)
data_list[["thickness_turgid"]]$spp <- factor(
  data_list[["thickness_turgid"]]$spp,
  levels = c(
    "nezumimochi",
    "aoki",
    "niseakashia",
    "yurinoki",
    "youshuyamagobou",
    "ubayuri"
  )
)

# Output the result images
output_dir <- "outputs/figures"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}
output_path <- file.path(output_dir, "leaf_thickness_boxplot.svg")
svg(output_path, bg = "transparent")
par(mar = c(3, 9, 0, 0))
boxplot(
  thick ~ spp,
  data = data_list[["thickness_turgid"]],
  col = c(6, 6, 2, 2, 4, 4),
  xlab = "",
  ylab = "",
  xaxt = "n",
  yaxt = "n",
  horizontal = TRUE
)
spp_names <- c(
  "L. lucidum",
  "A. japonica",
  "R. pseudoacacia",
  "L. tulipifera",
  "P. americana",
  "C. cordatum"
)
# x axis
axis(
  2,
  at = 1:6,
  labels = spp_names,
  las = 2,
  cex.axis = 2.5,
  mgp = c(3, 0.7, 0),
  font = 3, # Bold font for species names
)
axis(
  1,
  at = axTicks(1),
  labels = sprintf("%.1f", axTicks(1)),
  cex.axis = 2.5,
  mgp = c(3, 1.5, 0)
) # y axis
dev.off()


# Calculate mean and standard deviation of leaf thickness ----
# mean
data_list[["thickness_turgid_mean"]] <- aggregate(
  data_list[["thickness_turgid"]][, c("thick")],
  by = list(spp = data_list[["thickness_turgid"]]$spp),
  mean
)
# standard deviation
data_list[["thickness_turgid_sd"]] <- aggregate(
  data_list[["thickness_turgid"]][, c("thick")],
  by = list(spp = data_list[["thickness_turgid"]]$spp),
  sd
)


# Leaf dry matter content ----
data_list[["bending_weight"]] <- data_list[["bending"]][, c(
  "spp",
  "turgid_weight",
  "dry_weight"
)]
data_list[["tensile_weight"]] <- data_list[["tensile"]][, c(
  "spp",
  "turgid_weight",
  "dry_weight"
)]
data_list[["LDMC"]] <- rbind(
  data_list[["bending_weight"]],
  data_list[["tensile_weight"]]
)
data_list[["LDMC"]]$spp <- factor(
  data_list[["LDMC"]]$spp,
  levels = c(
    "nezumimochi",
    "aoki",
    "niseakashia",
    "yurinoki",
    "youshuyamagobou",
    "ubayuri"
  )
)
data_list[["LDMC"]]$LDMC <- data_list[["LDMC"]]$dry_weight /
  data_list[["LDMC"]]$turgid_weight


# Output the leaf dry matter content boxplot ----
output_dir <- "outputs/figures"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}
output_path <- file.path(output_dir, "LDMC_boxplot.svg")
svg(output_path, bg = "transparent")
par(mar = c(3, 9, 0, 0))
boxplot(
  LDMC ~ spp,
  data = data_list[["LDMC"]],
  col = c(6, 6, 2, 2, 4, 4),
  xlab = "",
  ylab = "",
  xaxt = "n",
  yaxt = "n",
  horizontal = TRUE
)
spp_names <- c(
  "L. lucidum",
  "A. japonica",
  "R. pseudoacacia",
  "L. tulipifera",
  "P. americana",
  "C. cordatum"
)
# x axis
axis(
  2,
  at = 1:6,
  labels = spp_names,
  las = 2,
  cex.axis = 2.5,
  mgp = c(3, 0.7, 0),
  font = 3, # Bold font for species names
)
axis(
  1,
  at = axTicks(1),
  labels = sprintf("%.1f", axTicks(1)),
  cex.axis = 2.5,
  mgp = c(3, 1.5, 0)
) # y axis
dev.off()


# Leaf mass per area (LMA) ----
# Bending
data_list[["bending_LMA"]] <- data_list[["bending"]][, c(
  "spp",
  "area",
  "dry_weight"
)]
# Tensile
data_list[["tensile_LMA"]] <- data_list[["tensile"]][, c(
  "spp",
  "area",
  "dry_weight"
)]
# Combine bending and tensile data
data_list[["LMA"]] <- rbind(
  data_list[["bending_LMA"]],
  data_list[["tensile_LMA"]]
)
data_list[["LMA"]] <- na.omit(data_list[["LMA"]]) # Remove rows with NA values
data_list[["LMA"]]$spp <- factor(
  data_list[["LMA"]]$spp,
  levels = c(
    "nezumimochi",
    "aoki",
    "niseakashia",
    "yurinoki",
    "youshuyamagobou",
    "ubayuri"
  )
)
# Calculate LMA (units: g/m^2)
data_list[["LMA"]]$LMA <- data_list[["LMA"]]$dry_weight /
  data_list[["LMA"]]$area *
  10^3

# Output the LMA boxplot
output_dir <- "outputs/figures"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}
output_path <- file.path(output_dir, "LMA_boxplot.svg")
svg(output_path, bg = "transparent")
par(mar = c(3, 9, 0, 0))
boxplot(
  LMA ~ spp,
  data = data_list[["LMA"]],
  col = c(6, 6, 2, 2, 4, 4),
  xlab = "",
  ylab = "",
  xaxt = "n",
  yaxt = "n",
  horizontal = TRUE
)
spp_names <- c(
  "L. lucidum",
  "A. japonica",
  "R. pseudoacacia",
  "L. tulipifera",
  "P. americana",
  "C. cordatum"
)
# x axis
axis(
  2,
  at = 1:6,
  labels = spp_names,
  las = 2,
  cex.axis = 2.5,
  mgp = c(3, 0.7, 0),
  font = 3, # Bold font for species names
)
axis(
  1,
  at = axTicks(1),
  labels = axTicks(1),
  cex.axis = 2.5,
  mgp = c(3, 1.5, 0)
) # y axis
# add "100" at y-axis manually
axis(
  1,
  at = 100,
  labels = 100,
  cex.axis = 2.5,
  mgp = c(3, 1.5, 0)
) # y axis
dev.off()
