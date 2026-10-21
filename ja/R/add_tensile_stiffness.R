# Use the instrument dimensions associated with the instrument Young's modulus.
# E.x is in MPa = N/mm^2; thick and width.x are in mm; EA is in N.
add_tensile_stiffness <- function(data) {
  stopifnot(all(c("E.x", "thick", "width.x") %in% names(data)))
  stopifnot(all(is.finite(data$E.x)), all(is.finite(data$thick)),
            all(is.finite(data$width.x)), all(data$thick > 0),
            all(data$width.x > 0))
  data$cross_section_area <- data$thick * data$width.x
  data$EA <- data$E.x * data$cross_section_area
  data
}
