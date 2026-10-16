# Both profiles use the same QMD paths. Keep the English navigation index so
# preview does not resolve English chapters using the Japanese configuration.
local({
  qmd <- c("index.qmd", list.files("notebook", pattern = "\\.qmd$", full.names = TRUE))
  pages <- file.path("_site/ja", sub("\\.qmd$", ".html", qmd))
  inputs <- c(qmd, Sys.glob("_quarto*.yml"), "language-switch.html",
              "language-switch.css", list.files(c("R", "scripts", "filters"),
              recursive = TRUE, full.names = TRUE))
  # Reuse Japanese pages during preview when their sources have not changed.
  fresh <- all(file.exists(pages)) &&
    max(file.info(inputs)$mtime) <= min(file.info(pages)$mtime)
  if (fresh && Sys.getenv("QUARTO_PROJECT_RENDER_ALL") != "1") {
    message("Japanese pages are up to date.")
  } else {
    index_files <- list.files(".quarto/idx", recursive = TRUE, full.names = TRUE)
    english_index <- lapply(index_files, function(file) {
      readBin(file, what = "raw", n = file.info(file)$size)
    })
    on.exit({
      for (i in seq_along(index_files)) writeBin(english_index[[i]], index_files[i])
    }, add = TRUE)

    status <- system2("quarto", c("render", "--profile", "ja"))
    if (status != 0L) stop("Japanese render failed.")
  }
})
