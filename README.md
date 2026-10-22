# Changes in leaf mechanical properties under bending and tensile tests during dehydration in six plant species

English | [日本語](README.ja.md)

This public repository contains the analysis for the manuscript "Changes in leaf mechanical properties under bending and tensile tests during dehydration in six plant species".

Its purpose is to ensure the reproducibility of the figures and tables in the manuscript.

The analysis is available as a website at:

* https://maple60.github.io/leaf-mechanics-dehydration/

## Quickstart

Run commands from the repository root.

1. Get the data (see the "Data" section below).
2. Copy `.Renviron.example` to `.Renviron` and set `PROJECT_DATA_DIR` to the folder
   containing `raw/` and `manual/`. Use forward slashes on Windows.

   **.Renviron**

   ```
   PROJECT_DATA_DIR=/path/to/your/data
   ```

3. Restart R and restore the R package environment:

   ```r
   renv::restore()
   ```

4. Render the analysis ([Quarto](https://quarto.org/) is required):

   ```sh
   quarto render
   ```

   To run a single chapter, run `notebook/01-data-integration.qmd` first, then, for example,
   `quarto render notebook/03-bending.qmd`.
   The first notebook creates the integrated CSV files used by all later analyses.

## Tested environment

| Software | Version | Notes |
| --- | --- | --- |
| [R](https://www.r-project.org/) | 4.5.3 | Recorded in `renv.lock` |
| [renv](https://rstudio.github.io/renv/index.html) | 1.1.5 | Recorded in `renv.lock` |
| [Quarto](https://quarto.org/) | 1.10.18 | Tested version (earlier versions not tested) |

R packages are restored to the versions in `renv.lock` with `renv::restore()`. Install [R](https://www.r-project.org/) and [Quarto](https://quarto.org/) separately if they are not installed.

## Data

The analysis uses 56 instrument CSV files and three metadata/exclusion CSV files.
They are not tracked in Git. See [data/README.md](data/README.md) for how to obtain them and for the contents of each file.
The dataset DOI is in preparation.

## Outputs

Generated files are written to the following locations in the repository (ignored by Git):

* `outputs/tables/`: integrated CSV files and other tables
* `outputs/figures/`: figures (SVG)
* `outputs/figures/submission/`: submission figures (PDF and 600 dpi PNG)

The integrated tables contain 496 bending records and 262 tensile records.
The main figures and the supplementary comparison use relative water content (RWC) of at least 60%.

## Repository layout

| Path | Purpose |
| --- | --- |
| `notebook/01-data-integration.qmd` | Import instrument exports, merge metadata, apply exclusions |
| `notebook/02-species-summary.qmd` | Thickness, LDMC, and LMA summaries by species |
| `notebook/03-bending.qmd` | Main Figure 1 |
| `notebook/04-tensile.qmd` | Main Figure 2 |
| `notebook/05-bending-tensile-ratios.qmd` | Main Figure 3 |
| `notebook/06-stiffness-comparison.qmd` | Supplementary Figure S2 |
| `notebook/11-force-displacement.qmd` | Original Figure S1 examples and their sample IDs (run before the submission-figure chapter) |
| `notebook/07-analysis-notes.qmd` to `10-gam-results.qmd` | Analysis notes, function reference, submission figures, GAM results |
| `R/` | Shared functions and notebook setup |
| `data/` | External data requirements (the data themselves are not included) |
| `index.qmd`, `_quarto*.yml` | Quarto book home page and configuration (English and Japanese) |
| `renv.lock`, `renv/` | R package environment |

## Common pitfalls

* **`PROJECT_DATA_DIR` is not set or points to the wrong location**
  Symptom: file-not-found errors. Confirm that `.Renviron` is in the repository root
  and contains the correct path, then restart R.
* **`renv::restore()` fails**
  Check the R version (tested with 4.5.3). `knitr` and `rmarkdown` are recorded in
  `renv.lock` and are required by Quarto rendering.
  Do not update `renv.lock` just to silence a warning.
* **Quarto is missing**
  Install [Quarto](https://quarto.org/) and verify with `quarto --version`.

## Building and publishing the site

`quarto render` builds the English and Japanese sites in `_site/` (Japanese under `_site/ja/`).
Use `quarto preview` to preview; `quarto preview --profile ja` previews Japanese only.

English and Japanese prose live together in the QMD files and are selected with
Quarto's `en` and `ja` profiles. The Japanese prose (`when-profile="ja"` blocks and `title-ja`)
is the source of truth; keep the English consistent with it.
Do not edit the generated files in `_site/`.

To publish to [GitHub Pages](https://docs.github.com/en/pages), render locally first:

```sh
quarto render
quarto publish gh-pages --no-render
```

## Use of AI

[Codex](https://openai.com/codex) and [Claude Code](https://claude.com/claude-code) were used
to refactor the code and write the documentation.
