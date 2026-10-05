# Migration provenance and release status

- Source: https://github.com/maple60/paper-leaf-mechanics
- Imported source commit: `606501e6a66bde009e91a9326a1c216c9e6e16d1`.
- Migration date: 2026-10-06 (Japan).
- Source Git history is retained. The source repository is unchanged.
- Initial destination files are preserved locally in `.migration/starter/`
  (ignored by Git). The source lockfile replaces the destination starter lockfile
  because it records the analysis dependencies.
- All 18 source files are retained. Changes are limited to documentation,
  input/output locations, raw CSV discovery, and a missing-input check.
- Statistical methods and record-exclusion expressions were not changed.

## Before making the repository public

- Obtain and validate the missing measurement and metadata files.
- Run the complete analysis and compare outputs against the manuscript.
- Review the inherited record exclusions, including the use of the bending
  exclusion list for tensile data.
- Confirm manuscript metadata, author list, citation, data DOI, and licenses.
- Review the retained Git history for material unsuitable for public release.

No license or manuscript citation has been invented. This private staging
repository does not yet grant a public reuse license or claim full reproduction.

## Local Dropbox data migration (2026-10-06)

The local `Dropbox/Konrai_exp/Paper` collection was copied to
`Dropbox/GitHub/leaf-mechanics-dehydration` without writing to the source.

- `originals/Paper/`: all 1,387 source files, preserving the source hierarchy.
- `raw/`: 56 instrument CSV files for analysis.
- `manual/`: 3 metadata/exclusion CSV files and 7 Excel workbooks.
- `reference/processed/`: 2 previous derived CSV files for later comparison.
- `migration-records/2026-10-06/`: source inventories, copy manifest, SHA-256
  verification, directory mapping, and the copy script.

All 1,455 file copies were verified by SHA-256. The source was checked again
after copying: all file contents, sizes, last-write timestamps, and file count
matched the pre-copy inventory. Data remain outside Git. The local `.Renviron`
points to the new input directory and is ignored by Git.

This verifies copying only. Full analysis and comparison with the previous
derived CSV files and manuscript figures remain to be performed.

### Removal of the redundant archive copy (2026-10-06)

At the user's request, the destination `originals/` directory was deleted.
The original `Dropbox/Konrai_exp/Paper` remains in place with 1,387 files.
The 68 retained files in `raw/`, `manual/`, and `reference/processed/` were
verified again against the migration SHA-256 manifest. The initial migration
records remain as historical evidence; `originals-removal.json` records the
subsequent deletion of the archive copy.

### Minimal external input package (2026-10-06)

The external data folder now contains only `raw/` (56 CSV files), `manual/`
(three CSV files), and a data README: 59 input files, 103,222,680 bytes.
The seven Excel workbooks were removed after checksum comparison with the
unchanged original collection. Migration records and previous derived CSV
files were retained outside the data package in the local ignored `.migration/`
working directory. Three manuscript DOCX files were preserved in the local
ignored `manuscripts/` directory of the code checkout.

All five R scripts and Figure S3 R chunks completed under R 4.5.3 and mgcv
1.9-4, producing 58 SVGs. Regenerated bending (496 rows) and tensile (262 rows)
data matched the previous derived tables (`all.equal`: TRUE). All 59 input
checksums were unchanged. Figure S3 also rendered successfully to HTML using
a writable validation cache and the existing user R library. This does not
verify the lockfile's mgcv 1.9-3 or visual equivalence with manuscript figures.
