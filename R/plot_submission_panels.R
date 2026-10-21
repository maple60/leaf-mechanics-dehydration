# Draw directly to PNG so device-dependent clipping matches the intended layout.
save_submission_png <- function(file, width, height, pointsize, draw, dpi = 600) {
  png(sub("\\.pdf$", ".png", file), width = width, height = height,
      units = "in", res = dpi, type = "cairo", family = "Arial",
      pointsize = pointsize, bg = "white")
  on.exit(dev.off(), add = TRUE)
  draw()
}

# Draw manuscript panels using the same GAM function as the analysis chapters.
plot_submission_panels <- function(data, species, metrics, labels, file,
                                   x = "water_content", tensile = FALSE,
                                   reference_lines = NULL, label_offsets = NULL) {
  width_mm <- switch(as.character(length(metrics)), "2" = 85.5, "3" = 120, "4" = 155)
  stopifnot(!is.null(width_mm))
  # Horizontal offsets from each column's left edge, as fractions of page width.
  if (is.null(label_offsets)) {
    label_offsets <- rep(if (length(metrics) == 2L) 4 / width_mm else 2.5 / width_mm,
                         length(metrics))
  }
  stopifnot(length(label_offsets) == length(metrics), all(is.finite(label_offsets)))
  # Keep the original species rows, trait columns, and square plotting regions.
  margins <- c(1.3, 3.1, 1.6, 0.3)
  if (length(metrics) == 2L) margins[2] <- 4
  line_mm <- 9 / 72 * 25.4 * 1.2
  panel_mm <- width_mm / length(metrics) - sum(margins[c(2, 4)]) * line_mm
  height_mm <- length(species) * (panel_mm + sum(margins[c(1, 3)]) * line_mm) +
    1.8 * line_mm
  panels <- matrix(seq_len(length(species) * length(metrics)), nrow = length(species))
  # Match the orange/blue appearance of the embedded manuscript figures.
  original_palette <- palette()
  manuscript_palette <- original_palette
  manuscript_palette[c(6, 7)] <- c("#2977B5", "#D7673B")
  palette(manuscript_palette)
  on.exit(palette(original_palette), add = TRUE)
  cairo_pdf(file, width = width_mm / 25.4, height = height_mm / 25.4,
            family = "Arial", pointsize = 9, bg = "white")
  on.exit(dev.off(), add = TRUE)
  draw <- function() {
    layout(panels)
    par(mar = margins, oma = c(1.8, 0, 0, 0), tcl = -0.2,
        pty = "s", cex = 1, lwd = 0.5, fg = "black", col.axis = "black")
    results <- list()
    plot_regions <- list()
    for (j in seq_along(metrics)) {
      for (i in seq_along(species)) {
        subset_data <- data[data$spp == species[i], ]
        sides <- if (tensile) "tensile" else c("adaxial", "abaxial")
        ylim <- if (tensile) NULL else
          gam_ci_ylim(subset_data, x, metrics[j], c(60, 100))
        for (side in sides) {
          side_data <- if (tensile) subset_data else
            droplevels(subset(subset_data, leaf_side == side))
          results[[length(results) + 1L]] <- plot_gam_ci(
            data = side_data, x = x, y = metrics[j], side = side,
            pred_range = c(60, 100), xlim = c(100, 60), ylim = ylim, mar = margins,
            add = side == "abaxial", pch = if (side == "abaxial") 22 else 21,
            cex_pt = 0.75, pt_border_alpha = 0.5, line_lwd = 1.2,
            cex.axis = 0.95, cex.lab = 1, axis_lwd = 0.5, xaxt = "n",
            ci_lty = 3, mgp_x = c(1.7, 0.4, 0), mgp_y = c(2.5, 0.3, 0))
          if (!is.null(reference_lines) && metrics[j] == "E_ratio") {
            abline(h = reference_lines, lty = 2, lwd = 0.7)
          }
        }
        axis(1, at = seq(100, 60, -10), cex.axis = 0.95, gap.axis = 0.5,
             mgp = c(1.7, 0.4, 0), lwd = 0.5, lwd.ticks = 0.5)
        panel <- LETTERS[(j - 1L) * length(species) + i]
        usr <- par("usr")
        text(usr[1] + 0.025 * diff(usr[1:2]),
             usr[4] - 0.025 * diff(usr[3:4]), paste0("(", panel, ")"),
             adj = c(0, 1), cex = 1, col = "black")
        if (i == 1L && j == 1L && !tensile) {
          legend("topright", c("Adaxial", "Abaxial"), pch = c(21, 22),
                 pt.bg = adjustcolor(c(7, 6), alpha.f = 0.5), col = c(7, 6),
                 pt.cex = 0.9, cex = 0.95, bg = "white", box.col = "black",
                 text.col = "black")
        }
        # Store physical plot rectangles for layout checks.
        plot_regions[[length(plot_regions) + 1L]] <- c(
          row = i, column = j,
          width = par("pin")[1], height = par("pin")[2],
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
      text((j - 1L) / length(metrics) + label_offsets[j], 0.5,
           labels[[j]], srt = 90, cex = 1, col = "black")
    }
    for (i in seq_along(species)) {
      region <- plot_regions[[i]]
      text(region["left"], region["top"] + 0.008,
           names(species)[i], adj = c(0, 0), font = 3, cex = 0.9,
           col = "black", xpd = NA)
    }
    text(0.5, 0.006, "Relative water content (%)", adj = c(0.5, 0), col = "black")
    attr(results, "plot_regions") <- do.call(rbind, plot_regions)
    invisible(results)
  }
  results <- draw()
  png_results <- save_submission_png(file, width_mm / 25.4, height_mm / 25.4, 9, draw)
  attr(results, "png_plot_regions") <- attr(png_results, "plot_regions")
  invisible(results)
}

plot_submission_comparison <- function(comparison, file) {
  data <- comparison$data
  cairo_pdf(file, width = 120 / 25.4, height = 120 / 25.4,
            family = "Arial", pointsize = 9, bg = "white")
  on.exit(dev.off(), add = TRUE)
  draw <- function() {
    par(mar = c(4, 4, 1, 1), mgp = c(2.5, 0.6, 0), cex = 1)
    # Include negative decreases (predicted stiffness increases) in the plot.
    plot_limits <- range(c(0, 100, unlist(data[, c(
      "drop_tensile", "drop_adaxial", "drop_abaxial")])), na.rm = TRUE)
    plot(data$drop_tensile, data$drop_adaxial, type = "n", asp = 1,
         xlim = plot_limits, ylim = plot_limits,
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
           pt.bg = adjustcolor(c(7, 6), alpha.f = 0.5), col = c(7, 6),
           cex = 0.95, bty = "n")
    annotation <- vapply(c("adaxial", "abaxial"), function(side) {
      model <- comparison[[side]]
      statistics <- summary(model)
      sprintf("%s: y = %.3fx %+.3f; R\u00b2 = %.3f; p = %.4f",
              side, coef(model)[2], coef(model)[1], statistics$r.squared,
              coef(statistics)[2, 4])
    }, character(1))
    legend("bottomright", annotation, text.col = c(7, 6), cex = 0.9, bty = "n")
  }
  draw()
  save_submission_png(file, 120 / 25.4, 120 / 25.4, 9, draw)
}
