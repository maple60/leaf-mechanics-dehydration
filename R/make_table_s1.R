# gam-results.csv から Table S1 を作る。BH補正は図ごと（Fig. 1, 2, 3）の族で行う。
make_table_s1 <- function(path = "outputs/tables/gam-results.csv",
                          out = "outputs/tables/table-s1.csv") {
  d <- read.csv(path)
  # 図S2のEI・EAは図1・図2と同一のモデルなので、重複を避けて除く。
  d <- d[d$figure != "S2", ]
  d$p_bh <- ave(d$p_value, d$figure, FUN = function(p) p.adjust(p, "BH"))
  d$significant_bh <- d$p_bh < 0.05
  s1 <- d[, c("figure", "panel", "species", "trait", "side", "n", "rwc_min",
              "rwc_max", "edf", "F", "p_value", "p_bh", "adjusted_r_squared")]
  write.csv(s1, out, row.names = FALSE)
  invisible(d)
}
