source("_setup.R")

# Load data
df_list <- list()
df_list[["tensile"]] <- read.csv("data/processed/tensile.csv")
categories <- c("bending", "tensile")
df <- df_list[[categories[2]]]
df <- df[df$water_content >= 60, ] # filter data for water content >= 50%
df$EI <- df$EI * 1000 # convert unit of EI
df$I <- df$I * 1000 # convert unit of I
df$LMA <- df$dry_weight / df$area * 10^3 # calculate leaf mass per area (LMA) (g m-2)
df$density <- df$dry_weight / df$thickness # calculate leaf density (kg m-3)
df$E_per_density <- df$E.x / df$density # calculate E per density (MPa kg m-3)
df$E_per_density <- df$E_per_density * 10^3 # convert unit of E per density (MPa g m-3)

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
pred_range <- c(60, 100)
xlim <- c(100, 60)
mar <- c(5, 5, 0.5, 0.5) # Margins

# Plot GAM with confidence intervals ----
output_dir <- "output/figure_02"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}
side <- "tensile"
# (A) - (F) RWC vs EI
lapply(seq_along(spp), function(i) {
  sp <- spp[i]
  df_sp <- df[df$spp == sp, ]
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[i], "_RWC_vs_EI_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_sp,
    x = "water_content",
    y = "EI",
    side = side,
    pred_range = pred_range,
    xlim = xlim,
    mar = mar
  )
  dev.off()
})

# (G) - (L) RWC vs E
lapply(seq_along(spp), function(i) {
  sp <- spp[i]
  df_sp <- df[df$spp == sp, ]
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[6 + i], "_RWC_vs_E_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_sp,
    x = "water_content",
    y = "E.x",
    side = side,
    pred_range = pred_range,
    xlim = xlim,
    mar = mar
  )
  dev.off()
})

# (M) - (R) RWC vs Leaf tissue density
lapply(seq_along(spp), function(i) {
  sp <- spp[i]
  df_sp <- df[df$spp == sp, ]
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[6 * 2 + i], "_RWC_vs_density_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_sp,
    x = "water_content",
    y = "density",
    side = "tensile",
    pred_range = pred_range,
    xlim = xlim,
    mar = mar
  )
  dev.off()
})

# (S) - (X) RWC vs E / Leaf tissue density
lapply(seq_along(spp), function(i) {
  sp <- spp[i]
  df_sp <- df[df$spp == sp, ]
  output_path <- file.path(
    output_dir,
    paste0(LETTERS[6 * 3 + i], "_RWC_vs_E_per_density_", names(spp)[i], ".svg")
  )
  svg(output_path, bg = "transparent")
  # Plot adaxial side
  plot_gam_ci(
    data = df_sp,
    x = "water_content",
    y = "E_per_density",
    side = "tensile",
    pred_range = pred_range,
    xlim = xlim,
    mar = mar
  )
  dev.off()
})
