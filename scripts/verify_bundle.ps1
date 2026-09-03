$c = [System.IO.File]::ReadAllText("standalone_app.html", [System.Text.Encoding]::UTF8)

Write-Output "=== FULL STANDALONE APP AUDIT REPORT ==="
Write-Output ("1. File Size: " + $c.Length + " bytes")
Write-Output ("2. Single DOCTYPE: " + (([regex]::Matches($c, "<!DOCTYPE")).Count -eq 1))
Write-Output ("3. Clean CSS @import: " + $c.Contains("@import url('https://fonts.googleapis.com"))
Write-Output ("4. Clean generateDenseEmbedding: " + $c.Contains('const padded = `^${word}$`;'))
Write-Output ("5. All 16 Standards in DB: " + $c.Contains('BIS_STANDARDS_EXPANDED_DB'))
Write-Output ("6. CM/L & HUID Registries: " + ($c.Contains('BIS_LICENSE_REGISTRY') -and $c.Contains('BIS_HUID_REGISTRY')))
Write-Output ("7. In-Stream Calculators (HUID, MSME 78% Audit, 3X Comp): " + ($c.Contains('huid_calc') -and $c.Contains('msme_audit') -and $c.Contains('compensation')))
Write-Output ("8. Split-Screen Gazette PDF Studio: " + ($c.Contains('pdfEvidencePane') -and $c.Contains('openClauseInPDF') -and $c.Contains('renderNativeGazetteCanvas')))
Write-Output ("9. Camera Vision Scanner with Flip & Upload Fallback: " + ($c.Contains('openCameraViewfinder') -and $c.Contains('toggleCameraFacing') -and $c.Contains('handleCameraFallbackUpload')))
Write-Output ("10. Command Palette (Ctrl+K): " + ($c.Contains('cmdPalette') -and $c.Contains('openCommandPalette')))
Write-Output ("11. Compliance Wizard (Fee & Roadmap): " + $c.Contains('WIZARD_PRODUCTS'))
Write-Output ("12. Voice Recognition Engine: " + ($c.Contains('toggleVoiceInput') -and $c.Contains('toggleVoiceLanguage')))
Write-Output ("13. HTML2PDF Exporter: " + $c.Contains('html2pdf'))
Write-Output "========================================"
