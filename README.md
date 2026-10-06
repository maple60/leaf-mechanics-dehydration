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

Edit this `README.md` directly; it is not generated from Quarto.
