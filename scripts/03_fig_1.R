source("_setup.R")

# Load data
df_list <- list()
df_list[["bending"]] <- read.csv("data/processed/bending.csv")
df_list[["tensile"]] <- read.csv("data/processed/tensile.csv")

categories <- c("bending", "tensile")
df <- df_list[[categories[1]]]
df <- df[df$water_content >= 50, ] # filter data for water content >= 50%
df$EI <- df$EI * 1000 # convert unit of EI
df$I <- df$I * 1000 # convert unit of I
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
output_dir <- "output/figure_01"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# (A) - (F) RWC vs EI
lapply(seq_along(spp), function(i) {
  sp <- spp[i]
  df_sp <- df[df$spp == sp, ]
  df_adaxial <- droplevels(subset(df_sp, leaf_side == "adaxial"))
  df_abaxial <- droplevels(subset(df_sp, leaf_side == "abaxial"))
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[i], "_RWC_vs_EI_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_adaxial,
    x = "water_content",
    y = "EI",
    side = "adaxial",
    pred_range = c(50, 100),
    xlim = c(100, 50)
  )
  # Add abaxial side to the same plot
  plot_gam_ci(
    data = df_abaxial,
    x = "water_content",
    y = "EI",
    side = "abaxial",
    pred_range = c(50, 100),
    xlim = c(100, 50),
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
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[6 + i], "_RWC_vs_E_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_adaxial,
    x = "water_content",
    y = "E.x",
    side = "adaxial",
    pred_range = c(50, 100),
    xlim = c(100, 50)
  )
  # Add abaxial side to the same plot
  plot_gam_ci(
    data = df_abaxial,
    x = "water_content",
    y = "E.x",
    side = "abaxial",
    pred_range = c(50, 100),
    xlim = c(100, 50),
    add = TRUE, # add to existing plot
    pch = 22
  )
  dev.off()
})

# (M) - (R) RWC vs I
lapply(seq_along(spp), function(i) {
  sp <- spp[i]
  df_sp <- df[df$spp == sp, ]
  df_adaxial <- droplevels(subset(df_sp, leaf_side == "adaxial"))
  df_abaxial <- droplevels(subset(df_sp, leaf_side == "abaxial"))
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[6 * 2 + i], "_RWC_vs_I_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_adaxial,
    x = "water_content",
    y = "I",
    side = "adaxial",
    pred_range = c(50, 100),
    xlim = c(100, 50)
  )
  # Add abaxial side to the same plot
  plot_gam_ci(
    data = df_abaxial,
    x = "water_content",
    y = "I",
    side = "abaxial",
    pred_range = c(50, 100),
    xlim = c(100, 50),
    add = TRUE, # add to existing plot
    pch = 22 # Use different point shape for abaxial
  )
  dev.off()
})
