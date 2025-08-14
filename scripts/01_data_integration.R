library(tools)

filenames <- list.files("data/raw", pattern = ".csv")
date <- sapply(filenames, function(x) strsplit(x, "_")[[1]][1])
type <- sapply(filenames, function(x) strsplit(x, "_")[[1]][2])
spp <- sapply(
  filenames,
  function(x) tools::file_path_sans_ext(strsplit(x, "_")[[1]][3])
)

# Data Integration ----
filepath <- list.files("data/raw", pattern = ".csv", full.names = TRUE)
tensile_list <- list()
bending_list <- list()

for (i in seq_along(filepath)) {
  filename <- basename(tools::file_path_sans_ext(filepath[i])) # Get filename without extension
  cat(paste0(filename, "\n")) # Print filename to console
  d <- read.csv(filepath[i], fileEncoding = "cp932") # Read CSV file with Japanese encoding
  # Bending test
  if (d[1, 3] == "3点曲げ") {
    N <- which(d[, 1] == "名前")
    sample_info <- d[
      (N[1] + 2):(N[2] - ifelse(d[N[2] - 1, 1] == "", 2, 1)),
      1:4
    ]
    result <- d[
      (N[2] + 3):(N[2] + (diff(N) - ifelse(d[N[2] - 1, 1] == "", 1, 0))),
      1:4
    ]
    res <- cbind(sample_info, result)
    names(res) <- c(
      "ID1",
      "thick",
      "width",
      "span",
      "ID2",
      "Fmax",
      "DISmax",
      "E"
    )
    res$filename <- filename
    res$date <- strsplit(filename, "_")[[1]][1]
    res$spp <- strsplit(filename, "_")[[1]][3]
    res$spp <- spp[i]
    bending_list[[filename]] <- res
  }

  # Tensile test
  if (d[1, 3] == "引張") {
    N <- which(d[, 1] == "名前")
    sample_info <- d[
      (N[1] + 2):(N[2] - ifelse(d[N[2] - 1, 1] == "", 2, 1)),
      1:4
    ]
    result <- d[
      (N[2] + 3):(N[2] + (diff(N)) - ifelse(d[N[2] - 1, 1] == "", 1, 0)),
      1:4
    ]
    res <- cbind(sample_info, result)
    names(res) <- c(
      "ID1",
      "thick",
      "width",
      "span",
      "ID2",
      "E",
      "strength",
      "strain"
    )
    res$filename <- filename
    res$date <- strsplit(filename, "_")[[1]][1]
    res$spp <- strsplit(filename, "_")[[1]][3]
    res$spp <- spp[i]
    tensile_list[[filename]] <- res
  }
}
d_bending <- do.call(rbind, bending_list) # Combine all bending test data into a single data frame
d_tensile <- do.call(rbind, tensile_list) # Combine all tensile test data into a single data frame


# Data cleaning ----
d_bending$ID <- sub("_", "", d_bending$ID1) # Remove underscore from ID
d_bending$ID <- sub("f|b", "", d_bending$ID) # Remove leaf side indicator from ID
d_bending$leaf_side <- ifelse(grepl("f", d_bending$ID1), "f", "b") # adaxial or abaxial
d_bending$leaf_side <- ifelse(d_bending$leaf_side == "f", "adaxial", "abaxial")
d_tensile <- d_tensile[-which(d_tensile$ID1 == "failed"), ] # Remove rows where tensile test failed
# Remove rows where tensile test failed
d_tensile <- d_tensile[
  -which(d_tensile$ID1 == 31 & d_tensile$spp == "youshuyamagobou"),
]
d_tensile <- d_tensile[
  -which(d_tensile$ID1 == 39 & d_tensile$spp == "youshuyamagobou"),
]
# Remove rows with empty E values
d_bending <- d_bending[-which(d_bending$E == "-.-"), ]


# Merging data with sample information ----
d_info_bending <- read.csv("data/manual/bending_sample_information.csv")
d_info_tensile <- read.csv("data/manual/tensile_sample_information.csv")
# rename column names
names(d_info_bending) <- c(
  "ID",
  "leaf_side",
  "dry_time",
  "turgid_weight",
  "fresh_weight",
  "thickness",
  "width",
  "length",
  "F_max",
  "DIS_max",
  "E",
  "dry_weight",
  "water_content",
  "I",
  "EI",
  "area",
  "water_weight",
  "liquid",
  "solid",
  "air",
  "air_fraction",
  "date",
  "thickness_TW", # leaf thickness at turgid weight
  "spp"
)
names(d_info_tensile) <- c(
  "ID",
  "dry_time",
  "turgid_weight",
  "fresh_weight",
  "thickness",
  "width",
  "length",
  "E",
  "F_max",
  "DIS_max",
  "dry_weight",
  "water_content",
  "I",
  "EI",
  "area",
  "water_weight",
  "liquid",
  "solid",
  "air",
  "air_fraction",
  "date",
  "thickness_TW", # leaf thickness at turgid weight
  "spp"
)
d_info_bending$leaf_side <- ifelse(
  d_info_bending$leaf_side == "front",
  "adaxial",
  "abaxial"
)

# Merge
data_list <- list()
data_list[["bending"]] <- merge(
  d_bending,
  d_info_bending,
  by = c("spp", "leaf_side", "ID"),
  all = TRUE
)
data_list[["tensile"]] <- merge(
  d_tensile,
  d_info_tensile,
  by.x = c("spp", "ID1"),
  by.y = c("spp", "ID")
)


# Save data ----
write.csv(
  data_list[["bending"]],
  "data/processed/bending.csv",
  row.names = FALSE
)
write.csv(
  data_list[["tensile"]],
  "data/processed/tensile.csv",
  row.names = FALSE
)
