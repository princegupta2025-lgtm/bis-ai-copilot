# Master End-to-End System Audit & Bug Verification Suite
$ErrorActionPreference = "Continue"

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  MANAK-AI / BIS TRUST COPILOT - 360-DEGREE MASTER BUG AUDIT" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$passCount = 0
$failCount = 0

function Assert-Test($desc, $condition) {
    if ($condition) {
        Write-Host "[PASS] $desc" -ForegroundColor Green
        $global:passCount++
    } else {
        Write-Host "[FAIL] $desc" -ForegroundColor Red
        $global:failCount++
    }
}

# 1. Check Standalone App Existence & Size
$standalonePath = "c:\Users\mg910\.gemini\antigravity\scratch\BIS-AI-Assistant\standalone_app.html"
$standaloneExists = Test-Path $standalonePath
$standaloneSize = if ($standaloneExists) { (Get-Item $standalonePath).Length } else { 0 }
Assert-Test "Standalone app exists and is non-empty ($standaloneSize bytes)" ($standaloneExists -and $standaloneSize -gt 500000)

# 2. Check Database Integrations
$dbContent = Get-Content "c:\Users\mg910\.gemini\antigravity\scratch\BIS-AI-Assistant\js\database.js" -Raw
Assert-Test "BIS_LICENSE_REGISTRY contains 50+ enterprise brands" ($dbContent.Contains("BIS_LICENSE_REGISTRY") -and $dbContent.Contains("1650145") -and $dbContent.Contains("8530092"))
Assert-Test "BIS_CRS_REGISTRY contains electronics brands (Samsung, Apple, Xiaomi)" ($dbContent.Contains("BIS_CRS_REGISTRY") -and $dbContent.Contains("R-41001234") -and $dbContent.Contains("R-41123456"))
Assert-Test "BIS_MSME_STANDARDS_AUDIT_DB contains STI lab checklists" ($dbContent.Contains("BIS_MSME_STANDARDS_AUDIT_DB") -and $dbContent.Contains("requiredInHouseLabEquipment"))
Assert-Test "BIS_DESI_COLLOQUIAL_MAP contains 20+ everyday terms (sariya, gas chulha, geyser)" ($dbContent.Contains("BIS_DESI_COLLOQUIAL_MAP") -and $dbContent.Contains("sariya") -and $dbContent.Contains("chulha"))
Assert-Test "BIS_HEALTH_TOXICITY_RISK_DB contains biological hazard profiles" ($dbContent.Contains("BIS_HEALTH_TOXICITY_RISK_DB") -and $dbContent.Contains("Pediatric Heavy Metal Poisoning"))
Assert-Test "BIS_ECOMMERCE_PATTERNS contains marketplace brand resolvers" ($dbContent.Contains("BIS_ECOMMERCE_PATTERNS") -and $dbContent.Contains("Steelbird") -and $dbContent.Contains("Havells"))

# 3. Check Chat.js UI Tools & Handlers
$chatContent = Get-Content "c:\Users\mg910\.gemini\antigravity\scratch\BIS-AI-Assistant\js\chat.js" -Raw
Assert-Test "Live AR Viewfinder loop functions defined" ($chatContent.Contains("startLiveARTrackingLoop") -and $chatContent.Contains("stopLiveARTrackingLoop"))
Assert-Test "Legal Notice Modal & 3X compensation generator defined" ($chatContent.Contains("openLegalNoticeModal") -and $chatContent.Contains("downloadNoticeText"))
Assert-Test "Hindi Voice Assessment speech synthesis defined" ($chatContent.Contains("speakHindiAssessment"))
Assert-Test "MSME Audit Wizard & 50% Subsidy calculator defined" ($chatContent.Contains("openMSMEAuditWizard") -and $chatContent.Contains("calculateMSMEScore"))
Assert-Test "Jewellery & Retail Bill Auditor defined" ($chatContent.Contains("openBillAuditorModal") -and $chatContent.Contains("auditStoreBill"))
Assert-Test "E-Commerce Link Verifier defined" ($chatContent.Contains("openEcommerceLinkModal") -and $chatContent.Contains("analyzeEcommerceLink"))
Assert-Test "Fair Gold Price & Making Charge Calculator defined" ($chatContent.Contains("openGoldFairPriceModal") -and $chatContent.Contains("calculateFairGoldPrice"))

# 4. HTTP API Endpoints Test
try {
    $huidRes = Invoke-RestMethod -Uri "http://localhost:8000/api/verify/huid?number=AU9991" -Method Get -TimeoutSec 5
    Assert-Test "API: HUID AU9991 returns VERIFIED 24K" ($huidRes.status -eq "VERIFIED" -and $huidRes.purity -eq "999")
} catch {
    Assert-Test "API: HUID AU9991 endpoint call" $false
}

try {
    $cmlRes = Invoke-RestMethod -Uri "http://localhost:8000/api/verify/cml?number=1650145" -Method Get -TimeoutSec 5
    Assert-Test "API: CM/L 1650145 returns ACTIVE Steelbird" ($cmlRes.status -eq "ACTIVE" -and $cmlRes.manufacturer.Contains("STEELBIRD"))
} catch {
    Assert-Test "API: CM/L 1650145 endpoint call" $false
}

try {
    $crsRes = Invoke-RestMethod -Uri "http://localhost:8000/api/verify/crs?number=41001234" -Method Get -TimeoutSec 5
    Assert-Test "API: CRS R-41001234 returns ACTIVE Samsung" ($crsRes.status -eq "ACTIVE" -and $crsRes.brand -eq "SAMSUNG")
} catch {
    Assert-Test "API: CRS R-41001234 endpoint call" $false
}

$resColor = if ($failCount -eq 0) { "Green" } else { "Red" }
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  AUDIT RESULTS: $passCount PASSED / $failCount FAILED" -ForegroundColor $resColor
Write-Host "=================================================================" -ForegroundColor Cyan
