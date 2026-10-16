# Run from the repository root: Rscript tests/check-gam-ci-ylim.R
source("R/plot_gam_ci.R")

# The second side has values far above the first and a CI below zero.
x <- seq(60, 100, length.out = 41)
data <- data.frame(
  water_content = rep(x, 2),
  value = c(1 + 0.1 * (x - 60) + 0.2 * sin(x),
            pmax(0, 2 * (x - 60) + c(0, rep(c(5, -5), 20)))),
  leaf_side = rep(c("adaxial", "abaxial"), each = length(x)))
ylim <- gam_ci_ylim(data, "water_content", "value", c(60, 100))

pdf(file = NULL)
par(mar = c(3, 3, 0, 0))
results <- lapply(c("adaxial", "abaxial"), function(side) {
  plot_gam_ci(subset(data, leaf_side == side), "water_content", "value",
              side = side, pred_range = c(60, 100), xlim = c(100, 60),
              ylim = ylim, add = side == "abaxial")
})
displayed <- par("usr")[3:4]
values <- c(0, data$value, unlist(lapply(results, function(result) {
  c(result$ci_lo, result$ci_hi)
})))
stopifnot(all(values >= displayed[1]), all(values <= displayed[2]),
          ylim[1] < 0, ylim[2] > max(subset(data, leaf_side == "adaxial")$value))
invisible(dev.off())
cat("PASS: both sides' observations and confidence intervals fit on the y axis\n")
