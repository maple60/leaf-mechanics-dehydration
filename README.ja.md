# 6種の植物における脱水過程での葉の力学特性の変化 ―曲げ試験および引張試験による評価―

[English](README.md) | 日本語

"Changes in leaf mechanical properties under bending and tensile tests during dehydration in six plant species" の論文に関する解析についてまとめた公開リポジトリです。

論文中に掲載されている図表の再現性の担保のためのリポジトリです。

Webサイトとして、以下のURLから閲覧可能です。

* https://maple60.github.io/leaf-mechanics-dehydration/

## クイックスタート

コマンドはリポジトリのルートで実行してください。

1. データを入手します（後述の「データ」を参照）。
2. `.Renviron.example` を `.Renviron` にコピーし、`PROJECT_DATA_DIR` を `raw/` と `manual/` を含む
   フォルダに設定します。Windows でもスラッシュ (`/`) を使ってください。

   **.Renviron**

   ```
   PROJECT_DATA_DIR=/path/to/your/data
   ```

3. R を再起動し、R パッケージ環境を復元します。

   ```r
   renv::restore()
   ```

4. 解析をレンダリングします（[Quarto](https://quarto.org/) が必要です）。

   ```sh
   quarto render
   ```

   1 章だけ実行する場合は、`notebook/01-data-integration.qmd` を実行した後に
   `quarto render notebook/03-bending.qmd` のように指定します。
   最初のノートブックが、以降の解析で使う統合 CSV ファイルを作成します。

## 動作確認環境

| ソフトウェア | バージョン | 備考 |
| --- | --- | --- |
| [R](https://www.r-project.org/) | 4.5.3 | `renv.lock` に記録 |
| [renv](https://rstudio.github.io/renv/index.html) | 1.1.5 | `renv.lock` に記録 |
| [Quarto](https://quarto.org/) | 1.10.18 | 動作確認済みのバージョン（これ以前の版は未検証） |

R パッケージは `renv::restore()` で `renv.lock` の版に揃います。[R](https://www.r-project.org/) と [Quarto](https://quarto.org/) は未インストールの場合、インストールしてください。

## データ

測定機器の CSV ファイル 56 件と、メタデータ・除外情報の CSV ファイル 3 件を使います。
Git では管理していません。入手方法と各ファイルの内容は [data/README.md](data/README.md) を参照してください。
データセットの DOI は準備中です。

## 出力

生成物はリポジトリ内の次の場所に出力されます（Git 管理対象外）。

* `outputs/tables/`: 統合した CSV などの表
* `outputs/figures/`: 図（SVG）
* `outputs/figures/submission/`: 投稿用の図（PDF と 600 dpi PNG）

統合テーブルには曲げ試験 496 件、引張試験 262 件の記録が含まれます。
主要な図と補足の比較は、相対含水率 (RWC) 60% 以上を対象にしています。

## リポジトリの構成

| パス | 内容 |
| --- | --- |
| `notebook/01-data-integration.qmd` | 測定データの取り込み、メタデータの統合、除外の適用 |
| `notebook/02-species-summary.qmd` | 厚さ、LDMC、LMA の種別要約 |
| `notebook/03-bending.qmd` | 主要 Figure 1 |
| `notebook/04-tensile.qmd` | 主要 Figure 2 |
| `notebook/05-bending-tensile-ratios.qmd` | 主要 Figure 3 |
| `notebook/06-stiffness-comparison.qmd` | 補足 Figure S2 |
| `notebook/11-force-displacement.qmd` | 元の指定IDによるFigure S1の再現と使用試料一覧（投稿用の図の章より先に実行） |
| `notebook/07-analysis-notes.qmd` から `10-gam-results.qmd` | 解析ノート、関数リファレンス、投稿用の図、GAM の結果 |
| `R/` | 共通関数とノートブックの設定 |
| `data/` | 外部データの要件（データ本体は含まない） |
| `index.qmd`, `_quarto*.yml` | Quarto ブックのホームページと設定（英語・日本語） |
| `renv.lock`, `renv/` | R パッケージ環境 |

## よくある問題

* **`PROJECT_DATA_DIR` が未設定、または場所が違う**
  ファイルが見つからないエラーになります。`.Renviron` がリポジトリのルートにあり、
  正しいパスが書かれているか確認し、R を再起動してください。
* **`renv::restore()` が失敗する**
  R のバージョンを確認してください（4.5.3 で動作確認）。`knitr` と `rmarkdown` は
  `renv.lock` に記録されており、Quarto のレンダリングに必要です。
  警告を消すためだけに `renv.lock` を更新しないでください。
* **Quarto が見つからない**
  [Quarto](https://quarto.org/) をインストールし、`quarto --version` で確認してください。

## サイトの構築と公開

`quarto render` は英語版と日本語版を `_site/` にビルドします（日本語版は `_site/ja/`）。
プレビューには `quarto preview` を使います。日本語版のみのプレビューは `quarto preview --profile ja` です。

英語と日本語の本文は QMD ファイル内に同居しており、Quarto の `en` と `ja` プロファイルで切り替えます。
日本語の本文（`when-profile="ja"` ブロックと `title-ja`）を正本とし、英語はそれに合わせます。
`_site/` 内の生成ファイルは編集しないでください。

[GitHub Pages](https://docs.github.com/en/pages) へは、ローカルでレンダリングしてから公開します。

```sh
quarto render
quarto publish gh-pages --no-render
```

## AI の利用

コードの整理とドキュメントの作成に、[Codex](https://openai.com/codex) と
[Claude Code](https://claude.com/claude-code) を使用しました。
