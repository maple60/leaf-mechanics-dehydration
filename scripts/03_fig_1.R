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
df_sp <- df[df$spp == spp[5], ]
df_adaxial <- droplevels(subset(df_sp, leaf_side == "adaxial")) # adaxial
df_abaxial <- droplevels(subset(df_sp, leaf_side == "abaxial")) # abaxial

# Plot GAM with confidence intervals ----
plot_gam_ci(
  data = df_adaxial,
  x = "water_content",
  y = "EI",
  side = "adaxial",
  pred_range = c(50, 100),
  xlim = c(100, 50)
)
plot_gam_ci(
  data = df_abaxial,
  x = "water_content",
  y = "EI",
  side = "abaxial",
  pred_range = c(50, 100),
  xlim = c(100, 50),
  add = TRUE # add to existing plot
)


# Generalized Additive Model (GAM) ----
x <- "water_content"
y <- "EI"


df_gam <- df_adaxial[, c(x, y)]
fml <- as.formula(paste(y, "~ s(", x, ")")) # formula for GAM
model_gam <- gam(
  formula = fml,
  data = df_gam,
  method = "REML", # 推定が安定しやすい
  na.action = na.exclude # 予測時に行合わせが維持される
)
new_x <- data.frame(x = seq(50, 100, length.out = 100)) # new data for prediction
colnames(new_x) <- x # set column name for prediction
pred <- predict(model_gam, newdata = new_x, se.fit = TRUE)
# 95%CI
ci_col <- adjustcolor(6, alpha.f = 0.1)
ci_lo <- pred$fit - 1.96 * pred$se.fit
ci_hi <- pred$fit + 1.96 * pred$se.fit
# plot
ord <- order(new_x[[x]]) # order for plotting
par(mar = c(5, 5, 0, 0)) # Set margins for the plot
# Set up the plot area
plot(
  df_gam[[x]],
  df_gam[[y]],
  xlim = c(100, 50),
  type = "n",
  xlab = "",
  ylab = "",
  xaxt = "n",
  yaxt = "n"
)
# x-axis label
axis(
  1,
  at = seq(50, 100, 5),
  labels = seq(50, 100, 5),
  cex.axis = 2.5,
  mgp = c(3, 1.5, 0)
)
# y-axis label
axis(
  2,
  las = 2,
  cex.axis = 2.5,
  mgp = c(3, 1.5, 0)
)
# CI polygon
polygon(
  c(new_x[[x]][ord], rev(new_x[[x]][ord])),
  c(ci_lo[ord], rev(ci_hi[ord])),
  col = ci_col,
  border = NA
)
# line for lower CI
lines(
  new_x[[x]][ord],
  ci_lo[ord],
  lty = 2,
  col = adjustcolor(6, alpha.f = 0.9)
)
# line for upper CI
lines(
  new_x[[x]][ord],
  ci_hi[ord],
  lty = 2,
  col = adjustcolor(6, alpha.f = 0.9)
)
points(
  df_gam[[x]],
  df_gam[[y]],
  pch = 22,
  cex = 2,
  col = adjustcolor(6, alpha.f = 0.9), # point border color
  bg = adjustcolor(6, alpha.f = 0.5), # point fill color
)
# regression line
lines(new_x[[x]][ord], pred$fit[ord], col = 6, lwd = 5)
