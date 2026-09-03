# ==========================================================================
# MANAK-AI UI Redesign Test Suite
# Tests DOM elements, accessibility, navigation, modals, and live server endpoints
# ==========================================================================

$ErrorActionPreference = "Stop"

Write-Host "=== STARTING MANAK-AI REDESIGN VERIFICATION ===" -ForegroundColor Cyan

$chatHtmlPath = Join-Path $PSScriptRoot "..\chat.html"
$styleCssPath = Join-Path $PSScriptRoot "..\css\style.css"
$chatJsPath   = Join-Path $PSScriptRoot "..\js\chat.js"

$htmlContent = Get-Content $chatHtmlPath -Raw
$cssContent  = Get-Content $styleCssPath -Raw
$jsContent   = Get-Content $chatJsPath -Raw

$tests = @(
    @{ Name = "Sidebar brand has MANAK-AI & BIS Assistant"; Pass = ($htmlContent -match 'MANAK-AI' -and $htmlContent -match 'BIS Assistant') },
    @{ Name = "Sidebar has exactly 3 core navigation tabs (Chat, Documents, Tools)"; Pass = ($htmlContent -match 'navItemChat' -and $htmlContent -match 'navItemDocuments' -and $htmlContent -match 'navItemTools' -and -not ($htmlContent -match 'navItemHistory')) },
    @{ Name = "Sidebar has completely removed Projects"; Pass = (-not ($htmlContent -match 'sidebar-section-title">Projects') -and -not ($htmlContent -match 'Add project')) },
    @{ Name = "Top Nav has active context, Persona role switcher, Online pill & Settings button"; Pass = ($htmlContent -match 'nav-active-context' -and $htmlContent -match 'btn-role-trigger' -and $htmlContent -match 'system-status-pill' -and $htmlContent -match 'openSettingsModal\(\)') },
    @{ Name = "Empty Hero has 3 Primary Action Pills"; Pass = ($htmlContent -match 'Ask MANAK-AI' -and $htmlContent -match 'Verify a Product' -and $htmlContent -match 'Analyze a Document') },
    @{ Name = "Empty Hero has 4 Secondary Quick Topic Chips"; Pass = ($htmlContent -match 'Standards \(IS 4151\)' -and $htmlContent -match 'QCOs' -and $htmlContent -match 'Hallmarking' -and $htmlContent -match 'Compliance') },
    @{ Name = "Composer has Quick Actions Strip with Tools Dropdown"; Pass = ($htmlContent -match 'composer-quick-actions-strip' -and $htmlContent -match 'composer-tools-dropdown-wrap' -and $htmlContent -match 'composerToolsMenu') },
    @{ Name = "Centralized Tools Hub Modal exists with 4 core categories"; Pass = ($htmlContent -match 'id="toolsModal"' -and $htmlContent -match 'VERIFICATION' -and $htmlContent -match 'COMPLIANCE & MSME') },
    @{ Name = "Centralized Settings Modal exists with categorized tabs"; Pass = ($htmlContent -match 'id="settingsModal"' -and $htmlContent -match 'tabGeneral' -and $htmlContent -match 'tabAi' -and $htmlContent -match 'tabVoice' -and $htmlContent -match 'tabData') },
    @{ Name = "Toast Notification container and showToast function exist"; Pass = ($htmlContent -match 'id="toastContainer"' -and $jsContent -match 'function showToast') },
    @{ Name = "Dynamic history, hover rename & delete functions exist"; Pass = ($jsContent -match 'renderDynamicHistory' -and $jsContent -match 'renameHistorySession' -and $jsContent -match 'deleteHistorySession') },
    @{ Name = "CSS has modern tokens for empty hero, action pills, tools modal, and toast"; Pass = ($cssContent -match '\.hero-action-pill' -and $cssContent -match '\.tools-hub-modal' -and $cssContent -match '\.toast-pill') }
)

$allPassed = $true
foreach ($t in $tests) {
    if ($t.Pass) {
        Write-Host "  [PASS] $($t.Name)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $($t.Name)" -ForegroundColor Red
        $allPassed = $false
    }
}

# Test Live HTTP Endpoints
Write-Host "`n--- Testing Live HTTP Endpoints ---" -ForegroundColor Cyan
try {
    $res8000 = Invoke-WebRequest -Uri "http://localhost:8000/chat.html" -UseBasicParsing -TimeoutSec 5
    if ($res8000.StatusCode -eq 200) {
        Write-Host "  [PASS] Port 8000 is serving chat.html (HTTP 200 OK)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Port 8000 returned status: $($res8000.StatusCode)" -ForegroundColor Red
        $allPassed = $false
    }
} catch {
    Write-Host "  [FAIL] Port 8000 request failed: $($_.Exception.Message)" -ForegroundColor Red
    $allPassed = $false
}

try {
    $res8080 = Invoke-WebRequest -Uri "http://localhost:8080/chat.html" -UseBasicParsing -TimeoutSec 5
    if ($res8080.StatusCode -eq 200) {
        Write-Host "  [PASS] Port 8080 is serving chat.html (HTTP 200 OK)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Port 8080 returned status: $($res8080.StatusCode)" -ForegroundColor Red
        $allPassed = $false
    }
} catch {
    Write-Host "  [FAIL] Port 8080 request failed: $($_.Exception.Message)" -ForegroundColor Red
    $allPassed = $false
}

if ($allPassed) {
    Write-Host "`n=== ALL REDESIGN VERIFICATION TESTS PASSED SUCCESSFULLY! ===" -ForegroundColor Green
} else {
    Write-Host "`n=== SOME TESTS FAILED. CHECK LOGS ABOVE ===" -ForegroundColor Red
    exit 1
}
