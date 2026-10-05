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
