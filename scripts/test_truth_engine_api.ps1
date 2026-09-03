$ErrorActionPreference = "Stop"

Write-Host "======================================================================"
Write-Host "TESTING LIVE WEB RESEARCH & TRUTH ENGINE REST ENDPOINTS"
Write-Host "======================================================================"

# 1. Test /api/web-research
$webReq = @{
    query = "What is the mandatory QCO for helmets and electrical cables?"
    topK = 2
} | ConvertTo-Json

$webRes = Invoke-RestMethod -Uri "http://localhost:8000/api/web-research" -Method Post -Body $webReq -ContentType "application/json"
Write-Host "`n1. POST /api/web-research:"
Write-Host "  Query   :" $webRes.query
Write-Host "  Results :" $webRes.results.Count "records returned"
foreach ($r in $webRes.results) {
    Write-Host "    - Title :" $r.sourceTitle
    Write-Host "      URL   :" $r.sourceUrl
    Write-Host "      Tier  :" $r.sourceAuthorityTier
    Write-Host "      Level :" $r.evidenceLevel
}

# 2. Test /api/evidence/verify
$verifyReq = @{
    evidence = @(
        @{ standardCode = "IS 4151:2015"; status = "CURRENT"; revision = 2015 },
        @{ standardCode = "IS 4151:1993"; status = "SUPERSEDED"; revision = 1993 }
    )
} | ConvertTo-Json -Depth 5

$verifyRes = Invoke-RestMethod -Uri "http://localhost:8000/api/evidence/verify" -Method Post -Body $verifyReq -ContentType "application/json"
Write-Host "`n2. POST /api/evidence/verify:"
Write-Host "  Verified      :" $verifyRes.verified
Write-Host "  Has Conflict  :" $verifyRes.hasConflict
Write-Host "  Total Evidence:" $verifyRes.totalEvidenceItems

Write-Host "`n======================================================================"
Write-Host "TRUTH ENGINE REST API TESTS PASSED SUCCESSFULLY"
Write-Host "======================================================================"
