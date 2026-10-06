# Draw manuscript panels using the same GAM function as the analysis chapters.
plot_submission_panels <- function(data, species, metrics, labels, file,
                                   x = "water_content", tensile = FALSE,
                                   reference_lines = NULL, label_offsets = NULL) {
  # Horizontal offsets from each column's left edge, as fractions of page width.
  if (is.null(label_offsets)) {
    label_offsets <- rep(0.04 / length(metrics), length(metrics))
  }
  stopifnot(length(label_offsets) == length(metrics), all(is.finite(label_offsets)))
  # Dimensions of the corresponding embedded figures in the current Word file.
  dimensions_pt <- switch(as.character(length(metrics)),
                          "2" = c(190.5, 569.25),
                          "3" = c(323.65, 646.15),
                          "4" = c(387.4, 584.65))
  stopifnot(!is.null(dimensions_pt))
  # Match the orange/blue appearance of the embedded manuscript figures.
  original_palette <- palette()
  manuscript_palette <- original_palette
  manuscript_palette[c(6, 7)] <- c("#2977B5", "#D7673B")
  palette(manuscript_palette)
  on.exit(palette(original_palette), add = TRUE)
  cairo_pdf(file, width = dimensions_pt[1] / 72, height = dimensions_pt[2] / 72,
            family = "Arial", pointsize = 6.5, bg = "white")
  on.exit(dev.off(), add = TRUE)
  layout(matrix(seq_len(length(species) * length(metrics)),
                nrow = length(species)))
  margins <- c(1.5, 2.9, 1.8, 0.4)
  # Figure 3 needs extra room for both the ratio title and decimal tick labels.
  if (length(metrics) == 2L) margins[2] <- 4.4
  par(mar = margins, oma = c(1.8, 0, 0, 0), tcl = -0.2,
      pty = "s", cex = 1, lwd = 0.4, fg = "black", col.axis = "black")
  results <- list()
  plot_regions <- list()
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
          cex_pt = 0.75, pt_border_alpha = 0.5, line_lwd = 1.2,
          cex.axis = 0.95, cex.lab = 1, axis_lwd = 0.4,
          ci_lty = 3, mgp_x = c(1.7, 0.4, 0), mgp_y = c(2.5, 0.3, 0))
        if (!is.null(reference_lines) && metrics[j] == "E_ratio") {
          abline(h = reference_lines, lty = 2, lwd = 0.7)
        }
      }
      panel <- LETTERS[(j - 1L) * length(species) + i]
      usr <- par("usr")
      text(usr[1] + 0.025 * diff(usr[1:2]),
           usr[4] - 0.025 * diff(usr[3:4]), paste0("(", panel, ")"),
           adj = c(0, 1), cex = 1, col = "black")
      if (i == 1L && j == 1L && !tensile) {
        legend("topright", c("Adaxial", "Abaxial"), pch = c(21, 22),
               pt.bg = adjustcolor(c(7, 6), alpha.f = 0.5), col = c(7, 6),
               pt.cex = 0.9, cex = 0.85, bg = "white", box.col = "black",
               text.col = "black")
      }
      # Store physical plot rectangles to check that each panel is square.
      plot_regions[[length(plot_regions) + 1L]] <- c(
        row = i, column = j, width = par("pin")[1], height = par("pin")[2],
        left = grconvertX(usr[1], "user", "ndc"),
        top = grconvertY(usr[4], "user", "ndc"))
    }
  }
  # One shared y label per column, and species names above the first column.
  layout(1)
  par(fig = c(0, 1, 0, 1), mar = rep(0, 4), oma = rep(0, 4),
      pty = "m", plt = c(0, 1, 0, 1), new = TRUE)
  plot.new()
  plot.window(xlim = c(0, 1), ylim = c(0, 1), xaxs = "i", yaxs = "i")
  for (j in seq_along(metrics)) {
    text((j - 1) / length(metrics) + label_offsets[j], 0.5,
         labels[[j]], srt = 90, cex = 1, col = "black")
  }
  for (i in seq_along(species)) {
    region <- plot_regions[[i]]
    species_x <- if (length(metrics) == 2L) region["left"] else 0.07 / length(metrics)
    text(species_x, region["top"] + 0.008,
         names(species)[i], adj = c(0, 0), font = 3, cex = 1, col = "black")
  }
  text(0.5, 0.006, "Relative water content (%)", adj = c(0.5, 0), col = "black")
  attr(results, "plot_regions") <- do.call(rbind, plot_regions)
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
