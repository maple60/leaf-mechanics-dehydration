source("_setup.R")

# Load data
df_list <- list()
df_list[["bending"]] <- read.csv("data/processed/bending.csv")
df_list[["tensile"]] <- read.csv("data/processed/tensile.csv")
df_list[["merged"]] <- merge(
  df_list[["bending"]][, c(
    "spp",
    "leaf_side",
    "ID",
    "EI",
    "E.x",
    "water_content"
  )],
  df_list[["tensile"]][, c("spp", "ID1", "EI", "E.x", "water_content")],
  all = TRUE,
  suffixes = c("_bending", "_tensile"),
  by.x = c("spp", "ID"),
  by.y = c("spp", "ID1")
)

df <- df_list[["merged"]]
df <- df[df$water_content_bending >= 50 & df$water_content_tensile >= 50, ] # filter data for water content >= 50%

df$RWC_mean <- (df$water_content_bending + df$water_content_tensile) / 2 # calculate mean RWC
df$EI_ratio <- df$EI_bending / df$EI_tensile # calculate ratio of EI
df$E_ratio <- df$E.x_bending / df$E.x_tensile # calculate ratio of E

df$EI_ratio <- df$EI_ratio * 10^3 # convert unit of EI

spp <- c(
  "ubayuri",
  "youshuyamagobou",
  "yurinoki",
  "niseakashia",
  "aoki",
  "nezumimochi"
) # species names
names(spp) <- c(
  "Cardiocrinum_cordatum",
  "Phytolacca_americana",
  "Liriodendron_tulipifera",
  "Robinia_pseudoacacia",
  "Aucuba_japonica",
  "Ligustrum lucidum"
)


# Plot GAM with confidence intervals ----
output_dir <- "output/figure_03"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# (A) - (F) RWC vs EI_bending / EI_tensile
lapply(seq_along(spp), function(i) {
  sp <- spp[i]
  df_sp <- df[df$spp == sp, ]
  df_adaxial <- droplevels(subset(df_sp, leaf_side == "adaxial"))
  df_abaxial <- droplevels(subset(df_sp, leaf_side == "abaxial"))
  x <- "RWC_mean"
  y <- "EI_ratio"
  pred_range <- c(50, 100)
  xlim <- c(100, 50)
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[i], "_RWC_vs_EI_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_adaxial,
    x = x,
    y = y,
    side = "adaxial",
    pred_range = pred_range,
    xlim = xlim
  )
  # Add abaxial side to the same plot
  plot_gam_ci(
    data = df_abaxial,
    x = x,
    y = y,
    side = "abaxial",
    pred_range = pred_range,
    xlim = xlim,
    add = TRUE, # add to existing plot
    pch = 22 # Use different point shape for abaxial
  )
  dev.off()
})

# (G) - (L) RWC vs E
lapply(seq_along(spp), function(i) {
  sp <- spp[i]
  df_sp <- df[df$spp == sp, ]
  df_adaxial <- droplevels(subset(df_sp, leaf_side == "adaxial"))
  df_abaxial <- droplevels(subset(df_sp, leaf_side == "abaxial"))
  x <- "RWC_mean"
  y <- "E_ratio"
  pred_range <- c(50, 100)
  xlim <- c(100, 50)
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[6 + i], "_RWC_vs_E_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_adaxial,
    x = x,
    y = y,
    side = "adaxial",
    pred_range = c(50, 100),
    xlim = c(100, 50)
  )
  abline(h = 1, lty = 2, lwd = 3) # Add horizontal line at y = 1
  abline(h = 3, lty = 2, lwd = 3) # Add horizontal line at y = 1
  # Add abaxial side to the same plot
  plot_gam_ci(
    data = df_abaxial,
    x = x,
    y = y,
    side = "abaxial",
    pred_range = c(50, 100),
    xlim = c(100, 50),
    add = TRUE, # add to existing plot
    pch = 22 # Use different point shape for abaxial
  )
  abline(h = 1, lty = 2, lwd = 3) # Add horizontal line at y = 1
  abline(h = 3, lty = 2, lwd = 3) # Add horizontal line at y = 1
  dev.off()
})
