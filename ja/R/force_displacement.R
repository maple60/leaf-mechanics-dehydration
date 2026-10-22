# Recover the fixed examples chosen in the legacy scripts/paper.R.
# Metadata are read before modelling exclusions so the original IDs are retained.
read_example_curves <- function(selection, data_dir) {
  stopifnot(all(c("spp", "side", "high", "medium", "low") %in% names(selection)))
  excluded <- read.csv(file.path(data_dir, "manual", "exclude_records_bending.csv"))
  raw_files <- list()
  samples <- list()
  curves <- list()
  for (i in seq_len(nrow(selection))) {
    side <- selection$side[i]
    stopifnot(side %in% c("adaxial", "tensile"))
    bending <- side == "adaxial"
    type <- if (bending) "bending" else "tensile"
    metadata <- read.csv(file.path(data_dir, "manual",
                                   paste0(type, "_sample_information.csv")),
                         fileEncoding = "UTF-8")
    metadata <- data.frame(
      id = metadata[[1]], spp = metadata$species, date = metadata$date,
      RWC = metadata[[if (bending) 13 else 12]],
      side = if (bending) metadata[[2]] else "tensile")
    for (group in c("high", "medium", "low")) {
      id <- selection[[group]][i]
      info <- metadata[metadata$spp == selection$spp[i] & metadata$id == id &
                         metadata$side == if (bending) "front" else "tensile", ]
      if (nrow(info) != 1L) stop("Expected one metadata row: ", selection$spp[i], "/", side, "/", id)
      in_group <- switch(group, high = info$RWC >= 90 & info$RWC <= 100,
                         medium = info$RWC >= 70 & info$RWC < 90,
                         low = info$RWC >= 0 & info$RWC < 70)
      if (!isTRUE(in_group)) stop("Example outside its RWC group: ", selection$spp[i], "/", id)
      filename <- paste0(info$date, "_", type, "_", info$spp, ".csv")
      if (is.null(raw_files[[filename]])) {
        raw_files[[filename]] <- read.csv(file.path(data_dir, "raw", filename),
                                          fileEncoding = "cp932", stringsAsFactors = FALSE)
      }
      raw <- raw_files[[filename]]
      dimension_row <- which(raw[[1]] == "寸法単位:")
      name_rows <- which(raw[[1]] == "名前")
      time_rows <- which(raw[[1]] == "時間")
      stopifnot(length(dimension_row) == 1L, length(name_rows) == 2L)
      raw_ids <- if (bending) c(paste0(id, "_f"), paste0(id, "f")) else as.character(id)
      sample_row <- which(raw[[1]] %in% raw_ids &
                            seq_len(nrow(raw)) > dimension_row &
                            seq_len(nrow(raw)) < name_rows[2])
      if (length(sample_row) != 1L) stop("Expected one instrument sample: ", filename, "/", id)
      block <- sample_row - dimension_row
      stopifnot(block >= 1L, block <= length(time_rows))
      header <- time_rows[block]
      stopifnot(identical(unname(as.character(raw[header + 1L, 1:3])), c("sec", "N", "mm")))
      # Preserve the legacy block boundaries, including the final failure/drop.
      end <- if (block < length(time_rows)) time_rows[block + 1L] - 3L else nrow(raw)
      curve <- as.data.frame(lapply(raw[seq.int(header + 2L, end), 1:3], as.numeric))
      names(curve) <- c("time_s", "force_N", "displacement_mm")
      stopifnot(nrow(curve) >= 100L, all(is.finite(as.matrix(curve))))
      displacement_offset <- min(curve$displacement_mm[1:100])
      force_offset <- min(curve$force_N[1:100])
      curve$corrected_displacement_mm <- curve$displacement_mm - displacement_offset
      curve$corrected_force_mN <- (curve$force_N - force_offset) * 1000
      excluded_rows <- which(excluded$species == info$spp & excluded$id == id)
      sample <- data.frame(panel = LETTERS[i], spp = info$spp, side = side,
                           rwc_group = group, id = id, RWC = info$RWC,
                           raw_file = filename, raw_id = raw[[1]][sample_row],
                           excluded_from_models = length(excluded_rows) > 0L,
                           exclusion_note = paste(unique(excluded$note[excluded_rows]), collapse = "; "),
                           n_points = nrow(curve), displacement_offset_mm = displacement_offset,
                           force_offset_N = force_offset)
      samples[[length(samples) + 1L]] <- sample
      curves[[length(curves) + 1L]] <- curve
    }
  }
  list(samples = do.call(rbind, samples), curves = curves)
}

# Scientific names for the species codes used in the data files.
example_species <- c(ubayuri = "Cardiocrinum cordatum", youshuyamagobou = "Phytolacca americana",
                     yurinoki = "Liriodendron tulipifera", niseakashia = "Robinia pseudoacacia",
                     aoki = "Aucuba japonica", nezumimochi = "Ligustrum lucidum")

# The same drawing is used for the site SVG and the submission PDF/PNG.
plot_example_curves <- function(examples) {
  species <- example_species
  colours <- c(high = "#08306b", medium = "#2171b5", low = "#6baed6")
  samples <- examples$samples
  stopifnot(nrow(samples) == 36L, length(examples$curves) == 36L)
  layout(matrix(seq_len(12), nrow = 6))
  par(mar = c(1.4, 3.2, 1.5, 0.5), oma = c(2.4, 2.3, 1.8, 0.2),
      mgp = c(1.7, 0.45, 0), tcl = -0.2, las = 1,
      cex.axis = 0.95, lwd = 0.5, xaxs = "i", yaxs = "i")
  for (side in c("adaxial", "tensile")) {
    for (i in seq_along(species)) {
      rows <- which(samples$spp == names(species)[i] & samples$side == side)
      stopifnot(length(rows) == 3L)
      ymax <- max(vapply(examples$curves[rows], function(d) max(d$corrected_force_mN), numeric(1)))
      plot(NA, xlim = c(0, 8.5), ylim = c(0, ymax * 1.08),
           xlab = "", ylab = "", xaxt = "n")
      axis(1, at = seq(0, 8, 2), labels = i == length(species))
      for (j in rows) {
        d <- examples$curves[[j]]
        lines(d$corrected_displacement_mm, d$corrected_force_mN,
              col = colours[samples$rwc_group[j]], lwd = 1)
      }
      mtext(species[i], side = 3, line = 0.25, font = 3, cex = 0.9)
      usr <- par("usr")
      text(0.15, usr[4] * 0.97, paste0("(", samples$panel[rows[1]], ")"),
           adj = c(0, 1), cex = 1)
      if (side == "adaxial" && i == 1L) {
        legend("topright", c("90–100", "70–<90", "<70"), title = "RWC (%)",
               col = colours, lty = 1, lwd = 1, cex = 0.85, bty = "n")
      }
    }
  }
  mtext("Displacement (mm)", side = 1, outer = TRUE, line = 1)
  mtext("Force (mN)", side = 2, outer = TRUE, line = 1, las = 0)
  mtext("Adaxial bending", side = 3, outer = TRUE, at = 0.25, line = 0.4)
  mtext("Tensile", side = 3, outer = TRUE, at = 0.75, line = 0.4)
  invisible(NULL)
}

save_example_curves <- function(examples, file) {
  width <- 155 / 25.4
  height <- 235 / 25.4
  cairo_pdf(file, width = width, height = height, family = "Arial", pointsize = 9)
  tryCatch(plot_example_curves(examples), finally = dev.off())
  save_submission_png(file, width, height, 9, function() plot_example_curves(examples))
}
