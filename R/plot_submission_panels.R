# Draw manuscript panels using the same GAM function as the analysis chapters.
plot_submission_panels <- function(data, species, metrics, labels, file,
                                   x = "water_content", tensile = FALSE,
                                   reference_lines = NULL) {
  cairo_pdf(file, width = 178 / 25.4, height = 245 / 25.4,
            family = "Arial", pointsize = 8, bg = "white")
  on.exit(dev.off(), add = TRUE)
  layout(matrix(seq_len(length(species) * length(metrics)),
                nrow = length(species)))
  margins <- c(2.5, 4.5, 2.1, 0.5)
  par(mar = margins, oma = c(1.8, 0, 0.5, 0), tcl = -0.25)
  results <- list()
  for (j in seq_along(metrics)) {
    for (i in seq_along(species)) {
      subset_data <- data[data$spp == species[i], ]
      sides <- if (tensile) "tensile" else c("adaxial", "abaxial")
      for (side in sides) {
        side_data <- if (tensile) subset_data else
          droplevels(subset(subset_data, leaf_side == side))
        results[[length(results) + 1L]] <- plot_gam_ci(
          data = side_data, x = x, y = metrics[j], side = side,
          pred_range = c(60, 100), xlim = c(100, 60), mar = margins,
          add = side == "abaxial", pch = if (side == "abaxial") 22 else 21,
          cex_pt = 0.6, line_lwd = 1, cex.axis = 0.9, cex.lab = 1,
          mgp_x = c(1.7, 0.5, 0), mgp_y = c(2.5, 0.4, 0))
        if (!is.null(reference_lines) && metrics[j] == "E_ratio") {
          abline(h = reference_lines, lty = 2, lwd = 0.7)
        }
      }
      panel <- LETTERS[(j - 1L) * length(species) + i]
      mtext(labels[[j]], side = 2, line = 2.5, cex = 0.7)
      mtext(paste0("(", panel, ")"), side = 3, line = 0.25, adj = 0,
            cex = 0.9, font = 2)
      if (j == 1L) {
        mtext(names(species)[i], side = 3, line = 1.15, adj = 0,
              cex = 0.85, font = 3)
      }
    }
  }
  mtext("Relative water content (%)", side = 1, outer = TRUE, line = 0.4)
  invisible(results)
}

plot_submission_comparison <- function(comparison, file) {
  data <- comparison$data
  cairo_pdf(file, width = 120 / 25.4, height = 120 / 25.4,
            family = "Arial", pointsize = 9, bg = "white")
  on.exit(dev.off(), add = TRUE)
  par(mar = c(4, 4, 1, 1), mgp = c(2.5, 0.6, 0))
  plot(data$drop_tensile, data$drop_adaxial, type = "n", asp = 1,
       xlim = c(0, 100), ylim = c(0, 100),
       xlab = "Tensile stiffness decrease (%)",
       ylab = "Bending stiffness decrease (%)")
  abline(0, 1, lty = 2)
  for (side in c("adaxial", "abaxial")) {
    colour <- if (side == "adaxial") 7 else 6
    points(data$drop_tensile, data[[paste0("drop_", side)]],
           pch = if (side == "adaxial") 21 else 22, cex = 1.2,
           bg = adjustcolor(colour, alpha.f = 0.5),
           col = adjustcolor(colour, alpha.f = 0.9))
    abline(comparison[[side]], col = adjustcolor(colour, alpha.f = 0.9), lwd = 1.5)
  }
  legend("topleft", c("Adaxial", "Abaxial"), pch = c(21, 22),
         pt.bg = adjustcolor(c(7, 6), alpha.f = 0.5), col = c(7, 6), bty = "n")
  annotation <- vapply(c("adaxial", "abaxial"), function(side) {
    model <- comparison[[side]]
    statistics <- summary(model)
    sprintf("%s: y = %.3fx %+.3f; R² = %.3f; p = %.4f",
            side, coef(model)[2], coef(model)[1], statistics$r.squared,
            coef(statistics)[2, 4])
  }, character(1))
  legend("bottomright", annotation, text.col = c(7, 6), cex = 0.7, bty = "n")
}
