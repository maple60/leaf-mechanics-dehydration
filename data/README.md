# Input data

This folder documents the measurement data used by the analysis code. The
data themselves are archived on Zenodo together with the code
(DOI: [10.5281/zenodo.23554265](https://doi.org/10.5281/zenodo.23554265)) and are released under
[CC BY 4.0](../LICENSE-DATA.md). The code is released under the MIT License
([LICENSE](../LICENSE)).

## Contents of the archive

`leaf-mechanics-dehydration-data.zip` unpacks to the folder structure expected
by the analysis (set `PROJECT_DATA_DIR` in `.Renviron` to the unpacked folder):

| Path | Content |
| --- | --- |
| `raw/*.csv` | 56 instrument exports (28 bending, 28 tensile) in CP932 (Shift_JIS) with Japanese headers. Preserved unchanged from the testing machine. |
| `manual/bending_sample_information.csv` | Bending sample metadata (24 columns, see below). |
| `manual/tensile_sample_information.csv` | Tensile sample metadata (23 columns, see below). |
| `manual/exclude_records_bending.csv` | Records excluded from the analysis; columns `species` and `id`. Applied to both bending and tensile records. |

Integrity: SHA-256 checksums of every file are provided in
`SHA256SUMS-files.txt` (and of the zip in `SHA256SUMS-zip.txt`) in the Zenodo
record. Verify with `sha256sum -c SHA256SUMS-files.txt` from the unpacked folder.

## Raw instrument exports

File names follow `YYYYMMDD_<test>_<species>.csv`:

| Part | Values |
| --- | --- |
| `YYYYMMDD` | Date of the test session. |
| `<test>` | `bending` (three-point bending) or `tensile`. |
| `<species>` | Species code, see the table below. |

| Code | Species | Functional group |
| --- | --- | --- |
| `ubayuri` | *Cardiocrinum cordatum* | herbaceous |
| `youshuyamagobou` | *Phytolacca americana* | herbaceous |
| `yurinoki` | *Liriodendron tulipifera* | deciduous woody |
| `niseakashia` | *Robinia pseudoacacia* | deciduous woody |
| `aoki` | *Aucuba japonica* | evergreen woody |
| `nezumimochi` | *Ligustrum lucidum* | evergreen woody |

Each export contains a header block, a table of sample dimensions
(`thick`, `width`, `span` or length; mm) and a table of results
(`Fmax`, `DISmax`, `E` for bending; `E`, `strength`, `strain` for tensile).
The parsing rules are in `notebook/01-data-integration.qmd`.

Bending sample IDs have the form `<n>_f` or `<n>_b`; `f` (force applied from
the adaxial side) is treated as `adaxial` bending and `b` (force applied from
the abaxial side) as `abaxial` bending by the analysis code. Conventions in the raw
files: `-.-` marks an empty modulus, and `failed` marks a failed tensile test;
both are removed during integration.

## Sample information tables (`manual/`)

The analysis renames the columns **by position**, so the column order must not
be changed. Names below are those assigned in `notebook/01-data-integration.qmd`.
The `liquid`, `solid`, and `air` formulas were reconstructed from the data: they
hold for all bending records and for most tensile records. The Young's modulus
(`E`) is calculated by the testing machine software.

| Column | Description | Unit |
| --- | --- | --- |
| `ID` | Sample identifier (matches the ID in the raw export). | – |
| `leaf_side` | `front` (force applied from the adaxial side) or `back` (force applied from the abaxial side); bending only. `front` is recoded to `adaxial` and `back` to `abaxial`. | – |
| `dry_time` | Drying time in the desiccator. | min |
| `turgid_weight` | Sample weight at full turgor. | mg |
| `fresh_weight` | Sample weight at the time of the mechanical test. | mg |
| `thickness` | Sample thickness at the time of the mechanical test. | mm |
| `width`, `length` | Sample width and length. | mm |
| `F_max`, `DIS_max` | Maximum force and displacement at maximum force. | N, mm |
| `E` | Young's modulus. | MPa |
| `dry_weight` | Oven-dry weight (24 h or more at 70 °C). | mg |
| `water_content` | Relative water content (RWC), calculated as (Wa − Wd) / (Wt − Wd) × 100. | % |
| `I` | Second moment of area. | mm⁴ |
| `EI` | Bending stiffness (`E × I`). | N mm² |
| `area` | Sample area from the scanned image. | mm² |
| `water_weight` | Weight of water in the sample, `fresh_weight − dry_weight` (for 82 bending records of *Aucuba japonica* and *Cardiocrinum cordatum* and 10 tensile records of *C. cordatum*, the stored value equals `turgid_weight − dry_weight`). | mg |
| `liquid` | Equivalent layer thickness of the liquid phase, `water_weight / area`. | mm |
| `solid` | Equivalent layer thickness of the solid phase, `dry_weight / (1.2 × area)` (assumed solid density 1.2 mg mm⁻³). | mm |
| `air` | Equivalent layer thickness of the air (gas) phase, `thickness − liquid − solid`. | mm |
| `air_fraction` | Fraction of the air phase, `air / thickness` (0–1). | – |
| `date` | Date of the measurement (`YYYYMMDD`). | – |
| `thickness_TW` | Sample thickness at full turgor. **Not recorded for *Aucuba japonica* and *Ligustrum lucidum*.** | mm |
| `spp` | Species code (see above). | – |

The tensile table has the same columns without `leaf_side`.

Missing values are empty or `NA`. Tensile stiffness is calculated by the
analysis code as `EA = E × thick × width` in N, using the sample thickness
(`thick`) and width (`width`) from the instrument export together with the
instrument Young's modulus (see `R/add_tensile_stiffness.R`). The `EI` column of
the tensile sample-information table is a legacy value that the analysis does
not use.

## Reproducing the analysis

1. Unpack the data archive and set `PROJECT_DATA_DIR` in `.Renviron` to the
   unpacked folder (`.Renviron.example` shows the format).
2. Restore the R environment with `renv::restore()`.
3. Render the notebooks with `quarto render`. The first notebook writes the
   integrated tables `outputs/tables/bending.csv` and `tensile.csv` (never into
   the input folder); later notebooks reproduce Figures 1–3, the
   supplementary figures, and the GAM statistics (Table S1).

## Citation

Please cite the Zenodo record (see [CITATION.cff](../CITATION.cff)) and the
associated article.
