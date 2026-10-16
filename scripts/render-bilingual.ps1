# The English profile also renders Japanese through its post-render hook.
$ErrorActionPreference = 'Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    quarto render --profile en
    if ($LASTEXITCODE -ne 0) { throw 'Bilingual render failed.' }
} finally {
    Pop-Location
}
