# Summarize nonmissing measurement records; n is not an independent-leaf count.
summarize_trait <- function(data, column) {
  species <- if (is.factor(data$spp)) levels(data$spp) else unique(data$spp)
  do.call(rbind, lapply(species, function(sp) {
    values <- data[[column]][!is.na(data$spp) & data$spp == sp]
    values <- values[!is.na(values)]
    data.frame(species = sp, records = length(values),
               mean = mean(values), sd = sd(values))
  }))
}
