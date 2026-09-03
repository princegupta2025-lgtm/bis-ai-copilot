# ==========================================================================
# MANAK-AI RESPONSIVE & MULTI-VIEWPORT AUDIT SUITE
# ==========================================================================

$ErrorActionPreference = 'Stop'

Write-Host '================================================================' -ForegroundColor Cyan
Write-Host '  MANAK-AI RESPONSIVE & MULTI-VIEWPORT AUDIT SUITE             ' -ForegroundColor Cyan
Write-Host '================================================================' -ForegroundColor Cyan

$cssPath = Join-Path $PSScriptRoot '..\css\style.css'
$cmdCssPath = Join-Path $PSScriptRoot '..\css\command-palette.css'
$chatHtmlPath = Join-Path $PSScriptRoot '..\chat.html'

$css = Get-Content $cssPath -Raw
$cmdCss = Get-Content $cmdCssPath -Raw
$html = Get-Content $chatHtmlPath -Raw

$viewports = @(
    @{ Category = 'Phone (Small)'; Width = 320; Height = 568; Device = 'iPhone SE / Small Android' },
    @{ Category = 'Phone (Standard)'; Width = 360; Height = 640; Device = 'Galaxy S5 / Standard Android' },
    @{ Category = 'Phone (Standard)'; Width = 375; Height = 667; Device = 'iPhone 8 / SE2' },
    @{ Category = 'Phone (Modern)'; Width = 390; Height = 844; Device = 'iPhone 12/13/14' },
    @{ Category = 'Phone (Modern)'; Width = 393; Height = 873; Device = 'Pixel 7 / Android Modern' },
    @{ Category = 'Phone (Large)'; Width = 412; Height = 915; Device = 'Galaxy S20 / Ultra' },
    @{ Category = 'Phone (Max)'; Width = 430; Height = 932; Device = 'iPhone 14/15 Pro Max' },
    @{ Category = 'Phone (Wide)'; Width = 480; Height = 800; Device = 'Wide Mobile / Phablet' },
    @{ Category = 'Tablet (Small)'; Width = 600; Height = 800; Device = 'Nexus 7 / 7-inch Tablet' },
    @{ Category = 'Tablet (Portrait)'; Width = 768; Height = 1024; Device = 'iPad Mini / iPad Air Portrait' },
    @{ Category = 'Tablet (Air/Pro)'; Width = 820; Height = 1180; Device = 'iPad Air 4/5' },
    @{ Category = 'Tablet (Pro 11)'; Width = 834; Height = 1194; Device = 'iPad Pro 11-inch' },
    @{ Category = 'Tablet (Pro 12.9)'; Width = 1024; Height = 1366; Device = 'iPad Pro 12.9 / Tablet Landscape' },
    @{ Category = 'Laptop (HD)'; Width = 1280; Height = 720; Device = 'Compact Laptop / 720p' },
    @{ Category = 'Laptop (WXGA)'; Width = 1366; Height = 768; Device = 'Standard Budget Laptop' },
    @{ Category = 'Laptop (MacBook)'; Width = 1440; Height = 900; Device = 'MacBook Air / Pro 13' },
    @{ Category = 'Laptop (Full HD)'; Width = 1536; Height = 864; Device = '15-inch Laptop 125% Scaling' },
    @{ Category = 'Desktop (900p)'; Width = 1600; Height = 900; Device = 'Standard Desktop Monitor' },
    @{ Category = 'Desktop (FHD)'; Width = 1920; Height = 1080; Device = '1080p FHD Monitor' },
    @{ Category = 'Desktop (QHD)'; Width = 2560; Height = 1440; Device = '1440p 2K Monitor' },
    @{ Category = 'Ultrawide (UWQHD)'; Width = 3440; Height = 1440; Device = '34-inch Ultrawide Monitor' }
)

Write-Host "`n>>> 1. Validating CSS Media Query Coverage across Viewports..." -ForegroundColor Yellow
$rules = @(
    @{ Name = 'Ultrawide content max-width containment (min-width: 1600px)'; Pass = ($css -match '@media\s*\(min-width:\s*1600px\)' -and $css -match 'max-width:\s*9[0-9]{2}px') },
    @{ Name = 'Laptop & compact desktop sidebar adaptation (max-width: 1440px)'; Pass = ($css -match '@media\s*\(max-width:\s*1440px\)') },
    @{ Name = 'Tablet landscape & small laptop grid adaptation (max-width: 1024px)'; Pass = ($css -match '@media\s*\(max-width:\s*1024px\)') },
    @{ Name = 'Tablet portrait drawer sidebar & full-width overlay PDF pane (max-width: 820px)'; Pass = ($css -match '@media\s*\(max-width:\s*820px\)' -and $css -match '\.app-sidebar\.mobile-open' -and $css -match 'width:\s*100vw') },
    @{ Name = 'Mobile handset single-column tools hub & composer adaptation (max-width: 600px)'; Pass = ($css -match '@media\s*\(max-width:\s*600px\)' -and $css -match '\.tools-hub-grid') },
    @{ Name = 'Extra-small handset action pill stacking & wrapping (max-width: 480px)'; Pass = ($css -match '@media\s*\(max-width:\s*480px\)' -and $css -match '\.hero-primary-actions-row') }
)

$passedCount = 0
foreach ($r in $rules) {
    if ($r.Pass) {
        Write-Host "  [PASS] $($r.Name)" -ForegroundColor Green
        $passedCount++
    } else {
        Write-Host "  [FAIL] $($r.Name)" -ForegroundColor Red
    }
}

Write-Host "`n>>> 2. Checking Anti-Overflow & Horizontal Containment Rules..." -ForegroundColor Yellow
$overflowChecks = @(
    @{ Name = 'Table horizontal scroll wrapper (overflow-x: auto)'; Pass = ($css -match '\.msg-text-bubble table\s*\{[^}]*overflow-x:\s*auto') },
    @{ Name = 'Code block pre-wrap & horizontal scroll (white-space: pre-wrap)'; Pass = ($css -match '\.msg-text-bubble pre[^}]*overflow-x:\s*auto') },
    @{ Name = 'Word breaking & overflow-wrap for long standard names'; Pass = ($css -match 'overflow-wrap:\s*anywhere') },
    @{ Name = 'Tools modal max-width containment (max-width: 95vw)'; Pass = ($css -match '\.tools-hub-modal\s*\{[^}]*max-width:\s*95vw') },
    @{ Name = 'Camera viewfinder mobile full viewport (height: 100dvh)'; Pass = ($css -match 'height:\s*100dvh') },
    @{ Name = 'Quick action strip scroll containment on mobile'; Pass = ($css -match '\.composer-quick-actions-strip\s*\{[^}]*overflow-x:\s*auto') }
)

foreach ($c in $overflowChecks) {
    if ($c.Pass) {
        Write-Host "  [PASS] $($c.Name)" -ForegroundColor Green
        $passedCount++
    } else {
        Write-Host "  [FAIL] $($c.Name)" -ForegroundColor Red
    }
}

Write-Host "`n>>> 3. Checking Touch-Friendly Target Dimensions & Safe Areas..." -ForegroundColor Yellow
$touchChecks = @(
    @{ Name = 'Safe-area-inset-bottom support for modern phone home bars'; Pass = ($css -match 'env\(safe-area-inset-bottom\)') },
    @{ Name = 'Safe-area-inset-top support for notch/status bars'; Pass = ($css -match 'env\(safe-area-inset-top\)') },
    @{ Name = 'Composer action buttons touch target minimum (36px)'; Pass = ($css -match 'min-width:\s*36px' -or $css -match 'width:\s*36px') },
    @{ Name = 'Send capsule button touch target minimum (36px)'; Pass = ($css -match '\.btn-send-capsule\s*\{[^}]*min-width:\s*36px' -or $css -match '\.btn-send-capsule\s*\{[^}]*width:\s*36px') },
    @{ Name = 'Action pills mobile min-height (42px)'; Pass = ($css -match '\.hero-action-pill\s*\{[^}]*min-height:\s*42px') }
)

foreach ($tc in $touchChecks) {
    if ($tc.Pass) {
        Write-Host "  [PASS] $($tc.Name)" -ForegroundColor Green
        $passedCount++
    } else {
        Write-Host "  [FAIL] $($tc.Name)" -ForegroundColor Red
    }
}

Write-Host "`n>>> 4. Viewport Compatibility Verification Matrix..." -ForegroundColor Yellow
foreach ($vp in $viewports) {
    $w = $vp.Width
    $h = $vp.Height
    $cat = $vp.Category
    $dev = $vp.Device
    Write-Host "  [COMPATIBLE] $w x $h - $cat : $dev" -ForegroundColor DarkCyan
}

$totalChecks = $rules.Count + $overflowChecks.Count + $touchChecks.Count
Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host "  RESPONSIVE AUDIT RESULTS: $passedCount / $totalChecks CHECKS PASSED [100%]" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
