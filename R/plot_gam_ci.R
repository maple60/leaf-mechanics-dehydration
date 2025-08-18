plot_gam_ci <- function(
  data,
  x,
  y,
  side = c("adaxial", "abaxial", "tensile"),
  pred_range = NULL, # Prediction range; if NULL, use data range
  n_pred = 200, # Number of prediction points
  xlim = NULL,
  ylim = NULL,
  pch = 21,
  cex_pt = 1.8,
  draw_points = TRUE,
  ci_alpha = 0.12, # Transparency of CI band
  pt_fill_alpha = 0.5, # Transparency of points
  pt_border_alpha = 0.9, # Transparency of point borders
  line_alpha = 0.9, # Transparency of regression line
  line_lwd = 4,
  ci_lty = 2, # Line type for CI boundaries
  mar = c(3, 3, 0, 0), # Margins
  xaxt = "s",
  yaxt = "s",
  xlab = "",
  ylab = "",
  cex.axis = 2.5, # Axis label size
  cex.lab = 2.5, # Axis label size
  mgp_x = c(3, 1.5, 0),
  mgp_y = c(3, 0.5, 0), # Margins for axis labels
  add = FALSE, # Add to an existing plot
  ...
) {
  # Check arguments
  stopifnot(is.data.frame(data), is.character(x), is.character(y))
  side <- match.arg(side)

  # --- inherit axes when add=TRUE ---
  if (isTRUE(add)) {
    usr <- par("usr") # c(xmin, xmax, ymin, ymax)
    if (is.null(xlim)) {
      xlim <- usr[1:2]
    }
    if (is.null(ylim)) ylim <- usr[3:4]
  }

  # ---- Color settings (according to user's preference) ----
  if (side == "adaxial") {
    base_col <- 7 # In the user's environment, red
  } else if (side == "abaxial") {
    base_col <- 6 # In the user's environment, blue
  } else {
    base_col <- 9 # For tensile, gray
  }
  # Semi-transparent color for filling (CI band & point fill)
  fill_col <- adjustcolor(base_col, alpha.f = ci_alpha) # CI band fill color
  pt_fill <- adjustcolor(base_col, alpha.f = pt_fill_alpha) # Point fill color
  pt_border <- adjustcolor(base_col, alpha.f = pt_border_alpha) # Point border color
  line_col <- adjustcolor(base_col, alpha.f = line_alpha) # Line color
  ci_col <- fill_col # CI band color

  # ---- Prepare data ----
  df_gam <- data[, c(x, y)]
  # Model
  fml <- as.formula(paste(y, "~ s(", x, ")"))
  model_gam <- mgcv::gam(
    formula = fml,
    data = df_gam,
    method = "REML",
    na.action = na.exclude
  )

  # Prediction range
  if (is.null(pred_range)) {
    xr <- range(df_gam[[x]], na.rm = TRUE)
  } else {
    xr <- pred_range
  }
  new_x <- setNames(
    data.frame(seq(from = xr[1], to = xr[2], length.out = n_pred)),
    x
  )

  # Prediction
  pred <- predict(model_gam, newdata = new_x, se.fit = TRUE)
  ci_lo <- pred$fit - 1.96 * pred$se.fit
  ci_hi <- pred$fit + 1.96 * pred$se.fit

  # Order for plotting
  ord <- order(new_x[[x]])

  # ---- Axis ranges ----
  if (is.null(ylim)) {
    # Range including observations and CI
    yr <- c(0, max(c(df_gam[[y]], ci_lo, ci_hi), na.rm = TRUE))
    #pad <- diff(yr) * 0.05 # Padding for upper limit
    #ylim <- c(yr[1], yr[2] + pad) # Add padding to the upper limit
    ylim <- yr
  }
  if (is.null(xlim)) {
    xlim <- range(new_x[[x]], na.rm = TRUE)
  }

  # --- clip prediction to visible x-range ---
  xmin <- min(xlim)
  xmax <- max(xlim)
  keep <- which(new_x[[x]] >= xmin & new_x[[x]] <= xmax)
  # 予測点が全て範囲外なら何もしないで返す
  if (length(keep) < 2) {
    return(invisible(NULL))
  }

  xk <- new_x[[x]][keep] # x values to keep
  fik <- pred$fit[keep] # Predicted values
  lok <- ci_lo[keep] # CI lower bounds
  hik <- ci_hi[keep] # CI lower and upper bounds
  ordk <- order(xk) # Order for plotting

  # ---- Set up plot background ----
  if (!add) {
    op <- par(mar = mar, xpd = FALSE) # Set margins and allow clipping
    on.exit(par(op), add = TRUE) # Restore original parameters
    plot(
      NA,
      NA,
      xlim = xlim,
      ylim = ylim,
      xlab = xlab,
      ylab = ylab,
      xaxt = "n",
      yaxt = "n",
      ...
    )
    # Axes (customize if needed)
    if (xaxt != "n") {
      axis(
        1,
        at = pretty(new_x[[x]]),
        labels = pretty(new_x[[x]]),
        cex.axis = cex.axis,
        mgp = mgp_x
      )
    }
    if (yaxt != "n") {
      axis(2, at = pretty(ylim), las = 2, cex.axis = cex.axis, mgp = mgp_y)
    }
    if (xlab != "") {
      mtext(xlab, side = 1, line = mgp_x[1], cex = cex.lab)
    }
    if (ylab != "") mtext(ylab, side = 2, line = mgp_y[1], cex = cex.lab)
  }

  # ---- Draw in order: CI band → CI boundary lines → regression line → points ----
  polygon(
    c(xk[ordk], rev(xk[ordk])),
    c(lok[ordk], rev(hik[ordk])),
    col = ci_col,
    border = NA
  )
  lines(xk[ordk], lok[ordk], lty = ci_lty, col = line_col)
  lines(xk[ordk], hik[ordk], lty = ci_lty, col = line_col)
  lines(xk[ordk], fik[ordk], col = line_col, lwd = line_lwd)

  if (draw_points) {
    points(
      df_gam[[x]],
      df_gam[[y]],
      pch = pch,
      cex = cex_pt,
      col = pt_border,
      bg = pt_fill
    )
  }

  invisible(list(
    model = model_gam,
    newdata = new_x,
    fit = pred$fit,
    se = pred$se.fit,
    ci_lo = ci_lo,
    ci_hi = ci_hi,
    side = side,
    colors = list(base = base_col, line = line_col, fill = fill_col)
  ))
}
