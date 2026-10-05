# Input data

Measurement data are not included in the migrated source repository. No public
dataset DOI has been supplied yet. This repository currently contains code and
instructions, not a complete data release.

Set `PROJECT_DATA_DIR` in `.Renviron` to the directory containing:

| Path | Content expected by the existing analysis |
| --- | --- |
| `raw/*.csv` | Instrument exports in CP932; filenames encode date, test type, and species separated by underscores. Both bending and tensile exports are required. |
| `manual/bending_sample_information.csv` | Bending sample metadata; 25 columns in the order specified in `scripts/01_data_integration.R`. |
| `manual/tensile_sample_information.csv` | Tensile sample metadata; 23 columns in the order specified in `scripts/01_data_integration.R`. |
| `manual/exclude_records_bending.csv` | Exclusion table with `species` and `id` columns; the existing script applies it to both tests. |

With no environment variable, inputs are read from `data/` in the project root.
Input datasets are ignored by Git. Preserve original exports unchanged. Derived
CSV files are written to `outputs/tables/`, never back to the input directory.

Before a public release, supply the actual dataset, a verified column dictionary
with units and missing-value conventions, a persistent archive identifier,
checksums, and an agreed data license. Column order matters: the integration
script replaces the metadata column names by position.
