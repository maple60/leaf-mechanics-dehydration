# 図と同じ条件でGAMを再推定し、統計値の表・モデル本体・使用バージョンを返す。
# table_dir は、データ統合で作成した曲げ・引張のCSVがあるフォルダー。
summarize_gams <- function(table_dir = "outputs/tables") {
  bending <- read.csv(file.path(table_dir, "bending.csv"))
  tensile <- add_tensile_stiffness(read.csv(file.path(table_dir, "tensile.csv")))
  species <- c(ubayuri = "Cardiocrinum cordatum",
               youshuyamagobou = "Phytolacca americana",
               yurinoki = "Liriodendron tulipifera",
               niseakashia = "Robinia pseudoacacia",
               aoki = "Aucuba japonica", nezumimochi = "Ligustrum lucidum")

  # 図3：種と試料IDで両試験を対応付け、両方のRWCが60%以上の組だけを使う。
  ratios <- merge(
    bending[, c("spp", "leaf_side", "ID", "EI", "E.x", "water_content")],
    tensile[, c("spp", "ID1", "EA", "E.x", "water_content")],
    all = TRUE, suffixes = c("_bending", "_tensile"),
    by.x = c("spp", "ID"), by.y = c("spp", "ID1"))
  ratios <- subset(ratios, water_content_bending >= 60 & water_content_tensile >= 60)
  # 両試験の平均RWCを説明変数とし、「曲げ / 引張」の比を計算する。
  ratios$RWC_mean <- (ratios$water_content_bending + ratios$water_content_tensile) / 2
  ratios$stiffness_ratio <- ratios$EI / ratios$EA * 1000
  ratios$E_ratio <- ratios$E.x_bending / ratios$E.x_tensile
  # 図と同じ単位・定義にそろえる。密度で使うthicknessは試料情報の葉厚。
  bending$EI <- bending$EI * 1000
  bending$I <- bending$I * 1000
  tensile$density <- tensile$dry_weight / tensile$thickness
  tensile$E_per_density <- tensile$E.x / tensile$density * 1000

  rows <- list()
  models <- list()
  # 形質・種・試験方向ごとに当てはめ、1モデルにつき表の1行を追加する。
  add_models <- function(data, figure, metrics, traits, units, cutoff,
                         x = "water_content", sides = c("adaxial", "abaxial")) {
    for (j in seq_along(metrics)) for (sp in names(species)) for (side in sides) {
      z <- data[data$spp == sp, ]
      if (side != "tensile") z <- subset(z, leaf_side == side)
      # 応答変数かRWCが欠測の記録を除き、その図のRWC下限を適用する。
      z <- z[complete.cases(z[, c(x, metrics[j])]), ]
      z <- z[z[[x]] >= cutoff, ]
      # 「形質 ~ s(RWC)」を組み立てる。s()は直線にも曲線にもなれる平滑項。
      # 図のコードと同じ既定のGaussianモデルで、滑らかさをREMLで推定する。
      model <- mgcv::gam(as.formula(paste(metrics[j], "~ s(", x, ")")),
                         data = z[, c(x, metrics[j])], method = "REML",
                         na.action = na.exclude)
      # gam()がモデルを推定し、summary()がR²や平滑項の検定結果を取り出す。
      statistics <- summary(model)
      # s.tableの各行は平滑項。このモデルはRWCの1項だけなので1行目を使う。
      # p値は「RWCの平滑項が全体としてゼロ」の近似検定で、増減方向の検定ではない。
      term <- statistics$s.table[1, ]
      id <- paste(figure, sp, metrics[j], side, sep = "/")
      # <<-で外側のリストに保存し、各図の呼び出し結果を一つに蓄積する。
      models[[id]] <<- model
      rows[[length(rows) + 1L]] <<- data.frame(
        figure = figure, panel = if (figure == "S2") NA_character_ else
          LETTERS[(j - 1L) * length(species) + match(sp, names(species))],
        species = unname(species[sp]), trait = traits[j], unit = units[j],
        side = side, predictor = x, rwc_cutoff = cutoff, n = nobs(model),
        rwc_min = min(z[[x]]), rwc_max = max(z[[x]]),
        # edfは曲線の複雑さ（約1ならほぼ直線）、Ref.dfは検定の参照自由度。
        edf = unname(term["edf"]), ref_df = unname(term["Ref.df"]),
        # F値と、多重比較補正前のp値。非有意でも「変化なし」とは断定しない。
        F = unname(term["F"]), p_value = unname(term["p-value"]),
        # mgcvのr.sqは自由度調整済みR²。dev.explは説明された逸脱度の割合。
        adjusted_r_squared = statistics$r.sq,
        deviance_explained = statistics$dev.expl,
        model_id = id)
    }
  }
  # 主要図はRWC 60%以上：図1が36、図2が24、図3が24モデル。
  add_models(bending, "1", c("EI", "E.x", "I"),
             c("Bending stiffness", "Bending Young's modulus", "Second moment of area"),
             c("10^-3 N mm^2", "MPa", "10^-3 mm^4"), 60)
  add_models(tensile, "2", c("EA", "E.x", "density", "E_per_density"),
             c("Tensile stiffness", "Tensile Young's modulus", "Tissue density",
               "Tensile Young's modulus / density"),
             c("N", "MPa", "kg m^-3", "MPa cm^3 g^-1"), 60, sides = "tensile")
  add_models(ratios, "3", c("stiffness_ratio", "E_ratio"),
             c("Bending / tensile stiffness", "Bending / tensile Young's modulus"),
             c("10^-3 mm^2", "dimensionless"), 60, x = "RWC_mean")
  # S2も主要図と同じ60%以上で18モデル。後段の種間回帰はここには含めない。
  add_models(bending, "S2", "EI", "Bending stiffness", "10^-3 N mm^2", 60)
  add_models(tensile, "S2", "EA", "Tensile stiffness", "N", 60, sides = "tensile")
  # tableはCSV用、modelsとversionsはモデルを再確認できるようRDSに保存するため。
  list(table = do.call(rbind, rows), models = models,
       versions = c(R = as.character(getRversion()),
                    mgcv = as.character(utils::packageVersion("mgcv"))))
}
