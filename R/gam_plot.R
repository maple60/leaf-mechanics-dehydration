# GAMプロットを作成する関数 GAM plot -------------------------------------------------

gam_plot <- function(
  category = c("adaxial", "abaxial"),
  x = col.RWC,
  y = col.EI
) {
  for (i in category) {
    #cat(i, sep="\n")
    x <- col.RWC
    y <- col.EI
    i <- "adaxial"
    X <- d.spp[, x[grep(i, names(d.spp)[x])]]
    cat(names(d.spp)[x[grep(i, names(d.spp)[x])]], sep = "\n")
    #E.i <- d.spp[,col.E[grep(i, names(d.spp)[col.E])]]
    #cat(names(d.spp)[col.E[grep(i, names(d.spp)[col.E])]], sep="\n")
    Y <- d.spp[, y[grep(i, names(d.spp)[y])]]
    cat(names(d.spp)[y[grep(i, names(d.spp)[y])]], sep = "\n")
    df.gam <- data.frame(col.x = X, col.y = Y)
    cat(df.gam$col.x)
    cat(df.gam$col.y)
    #df.gam <- na.omit(df.gam)
    points(
      df.gam$col.x,
      df.gam$col.y,
      pch = 16,
      col = ifelse(
        i == "adaxial",
        "#0000FF50",
        ifelse(i == "abaxial", "#FF000050", "#00000050")
      )
    )

    gam.y <- df.gam$col.y
    gam.x <- df.gam$col.x
    gam.model <- gam(df.gam$col.y ~ s(df.gam$col.x))
    new <- data.frame(
      X = seq(
        min(d.spp$water.adaxial, na.rm = T),
        max(d.spp$water.adaxial, na.rm = T),
        1
      )
    ) # コードの意味がわからない
    gam.pred <- predict(gam.model, new, se.fit = T)
    upr <- gam.pred$fit + (1.96 * gam.pred$se.fit)
    lwr <- gam.pred$fit - (1.96 * gam.pred$se.fit)
    uprlwr <- matrix(c(unlist(new), rev(unlist(new)), upr, rev(lwr)), ncol = 2)
    # 95%信頼区間
    polygon(
      uprlwr,
      col = ifelse(
        i == "adaxial",
        "#0000FF30",
        ifelse(i == "abaxial", "#FF000030", "#00000030")
      ),
      border = NA
    )
    # regression line
    lines(
      gam.pred$fit ~ new$X,
      col = ifelse(
        i == "adaxial",
        "blue",
        ifelse(i == "abaxial", "red", "black")
      )
    )
  }
  #dev.off()
}

plt.base <- function(
  x = d.spp$water.adaxial,
  y = d.spp$EI.adaxial,
  xlim = c(
    max(d.spp$water.adaxial, d.spp$water.abaxial),
    min(d.spp$water.adaxial, d.spp$water.abaxial)
  ),
  ylim = c(
    min(d.spp$EI.adaxial, d.spp$EI.abaxial),
    max(d.spp$EI.adaxial, d.spp$EI.abaxial)
  ),
  xlab = "RWC (%)",
  ylab = "ylab"
) {
  plot(
    x,
    y,
    main = paste(spp),
    ylim = ylim,
    xlim = xlim,
    pch = 16,
    type = "n",
    xlab = xlab,
    ylab = ylab
  )
}
