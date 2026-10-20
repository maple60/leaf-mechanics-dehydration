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
contain 496 bending records and 262 tensile records. Current analyses
use a cutoff of 60% RWC for both the main figures and supplementary comparison.
The supplementary comparison was previously named S3 in code;
it is S2 in the manuscript.

The manuscript's Table 1 sample-count definition, Aucuba thickness standard
deviation, and supplementary regression reporting still require reconciliation.
The force-displacement examples (S1) and microscopy panels (S3) are not yet
recreated by these notebooks.

## Data and manuscripts

Original inputs remain outside Git; outputs are generated in the code checkout.
Working manuscripts are stored in
`C:/Users/Konrai/Dropbox/GitHub/leaf-mechanics-dehydration/manuscripts/`,
outside the code checkout and rendered site.
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

The final chapter creates a vector PDF for journal submission and a 600 dpi PNG
for preview/preprint preparation for each of Figures 1–3 and S2, in
`outputs/figures/submission/`. Both formats use the intended manuscript dimensions: approximately
120 × 235 mm for Figure 1, 155 × 228 mm for Figure 2, 85.5 × 231 mm for Figure 3,
and 120 × 120 mm for S2. The original six-species rows, trait columns, square
plotting regions, panel letters, and species/trait associations are retained.
Widths vary within the journal's 178 mm limit to avoid excessive heights.
Text uses Arial at a 9 pt base size, with 8.55 pt tick labels/legends and 8.1 pt
italic species names and regression annotations.
The R drawing code creates both; no PDF enlargement or Python output step is needed.
After the data integration and stiffness comparison chapters, run
`quarto render notebook/09-submission-figures.qmd` to regenerate the pairs.

Keep figure images out of the journal's main DOCX/ODT, retain the figure legends
at the end, and upload each main figure as a separate PDF. For previews or
preprints, use a separate document with the PNGs inserted as pictures, keep their
aspect ratios, and disable Word image compression. Export that document to PDF
as required by the selected service. Supporting information follows the journal's
separate instructions, preferably as a combined PDF.

Vector output avoids raster blur, but final printed dimensions and lettering
still require review at the intended printed size. The base and axis text sizes
follow the journal's 8–12 pt lettering range. See the [official guidelines](https://physiologiaplantarum.org/instructions-for-manuscrip/).

Figures 2, 3, and S2 now use tensile
stiffness `EA = E.x * thick * width.x` (N), replacing the legacy tensile `EI`.
Update the manuscript's figure units and S2 statistics to the corrected results.
Use `quarto preview` for a local browser preview. This draft does not deploy
automatically or make the private repository public.

Edit this `README.md` directly; it is not generated from Quarto.
