# Leaf Mechanics under Dehydration

Analysis notebooks for leaf mechanical properties under dehydration, using
three-point bending and tensile tests. This is a private draft of the manuscript
analysis site. Manuscript citation, dataset DOI, and reuse licenses are pending.

## Quickstart

Run commands from the repository root.

1. Obtain the 56 instrument CSV files and three metadata/exclusion CSV files
   described in [data/README.md](data/README.md).
2. Copy `.Renviron.example` to `.Renviron`, set `PROJECT_DATA_DIR` to the folder
   containing `raw/` and `manual/`, and restart R. Use forward slashes on Windows.
3. Restore the R packages recorded in `renv.lock`:

   ```r
   renv::restore()
   ```

   Run this in R with the repository root as the working directory. The
   project uses an isolated `renv` library: packages installed in your usual
   user library are not automatically available here. `knitr` and `rmarkdown`
   are already recorded in the lockfile and are required for render/preview.
   If Quarto reports either as missing, restore the environment before retrying;
   do not update the lockfile just to silence a version mismatch warning.
   `renv::status()` can also report inherited `readxl` dependencies as installed
   and recorded but unused. That status is distinct from missing packages and
   does not prevent rendering.

4. Execute the notebooks in order and render the analysis:

   ```sh
   quarto render
   ```

To run one chapter, use `quarto render notebook/03-bending.qmd` after running
`notebook/01-data-integration.qmd`. The first notebook creates the integrated
CSV files used by all later analyses.

## Layout

| Path | Purpose |
| --- | --- |
| `notebook/01-data-integration.qmd` | Import exports, merge metadata, apply exclusions. |
| `notebook/02-species-summary.qmd` | Thickness, LDMC, and LMA summaries. |
| `notebook/03-bending.qmd` | Main Figure 1. |
| `notebook/04-tensile.qmd` | Main Figure 2. |
| `notebook/05-bending-tensile-ratios.qmd` | Main Figure 3. |
| `notebook/06-stiffness-comparison.qmd` | Supplementary Figure S2. |
| `R/` | Shared functions and notebook setup. |
| `index.qmd`, `_quarto.yml` | Quarto book home page and chapter navigation. |
| `notebook/07-analysis-notes.qmd` | Reproduction checks and unresolved manuscript reporting. |
| `notebook/08-functions.qmd` | Shared function reference. |
| `notebook/09-submission-figures.qmd` | Folded PDF generation code and submission figure downloads. |
| `data/README.md` | External data requirements. |
| `outputs/tables/`, `outputs/figures/` | Generated CSV and SVG files, ignored by Git. |
| `renv.lock`, `renv/` | Original R package environment. |

R (the lockfile records 4.5.1) and Quarto are required. Analyses use base R
and the existing `mgcv` dependency; no new analysis packages were introduced.

## Reproduction status

The source and migrated analyses were checked under R 4.5.3 using the lockfile's
mgcv 1.9-3, Matrix 1.7-3, nlme 3.1-168, and lattice 0.22-7. Integrated tables
contain 496 bending records and 262 tensile records. The notebook conversion
retains the main-figure cutoff of 60% RWC and the supplementary comparison's
cutoff of 50% RWC. The supplementary comparison was previously named S3 in code;
it is S2 in the manuscript.

The manuscript's Table 1 sample-count definition, Aucuba thickness standard
deviation, and supplementary regression reporting still require reconciliation.
The force-displacement examples (S1) and microscopy panels (S3) are not yet
recreated by these notebooks.

## Data and manuscripts

Original inputs remain outside Git; outputs are generated in the code checkout.
`manuscripts/` is a local working folder excluded from Git and the rendered site.
A dataset DOI and an agreed license will be added before public release.

## Site preview

`quarto render` builds the book in `_site/` (ignored by Git).
The default language is English. `quarto render` builds English and then runs
`scripts/render-japanese.R` to build Japanese, producing `_site/index.html`
and `_site/ja/index.html`. `./scripts/render-bilingual.ps1` is a PowerShell
wrapper for the same build. Use `quarto preview` and its JP/EN links to preview
both languages under the same site root. `quarto preview --profile ja` serves
Japanese alone; use the default preview for language switching.

Each page has a language callout and a navbar switch to the corresponding page.
The navbar uses an SVG Japanese flag so it also displays on Windows.
English and Japanese prose live together in the QMD files, selected with
Quarto's `en` and `ja` profiles. R chunks, numeric tables, figure labels, and
submission PDFs are shared; code and scientific species names retain their
original notation. Japanese page titles use `title-ja` and the small
`filters/language-title.lua` filter.

Japanese prose is the editorial source of truth. Edit the `when-profile="ja"`
blocks and `title-ja` in the QMD sources, then update the corresponding English
prose to match. Keep the shared R chunks, numerical results, and scientific
notation consistent between languages; do not edit generated files in `_site/`.

The final chapter creates four draft PDFs in `outputs/figures/submission/`
and copies them into the site for download. Figures 2, 3, and S2 now use tensile
stiffness `EA = E.x * thick * width.x` (N), replacing the legacy tensile `EI`.
Update the manuscript's figure units and S2 statistics to the corrected results.
Use `quarto preview` for a local browser preview. This draft does not deploy
automatically or make the private repository public.

Edit this `README.md` directly; it is not generated from Quarto.
