# Comprehensive BIS National Catalogue & 22,000+ Standards Verification Audit (PowerShell)
# Bureau of Indian Standards — Smart India Hackathon 2026 (SIH26107)

param(
    [string]$Target = "http://localhost:8000"
)

$pythonExe = "C:\msys64\ucrt64\bin\python.exe"
if (-not (Test-Path $pythonExe)) {
    $pythonExe = "python"
}

$scriptPath = Join-Path $PSScriptRoot "run_catalogue_audit.py"
& $pythonExe $scriptPath $Target
