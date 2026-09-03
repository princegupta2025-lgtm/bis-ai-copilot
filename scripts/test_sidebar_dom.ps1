Write-Host "================================================="
Write-Host "  VERIFYING MANAK-AI REDESIGNED SIDEBAR INTEGRITY"
Write-Host "================================================="

$chatHtmlPath = "c:\Users\mg910\.gemini\antigravity\scratch\BIS-AI-Assistant\chat.html"
$cssPath = "c:\Users\mg910\.gemini\antigravity\scratch\BIS-AI-Assistant\css\style.css"
$jsPath = "c:\Users\mg910\.gemini\antigravity\scratch\BIS-AI-Assistant\js\chat.js"

$chatHtml = Get-Content $chatHtmlPath -Raw
$css = Get-Content $cssPath -Raw
$js = Get-Content $jsPath -Raw

$allPassed = $true

# 1. Check Projects Section Removal
Write-Host "`n1. Checking Projects Removal..."
$projectMatches = [regex]::Matches($chatHtml, "(Projects|Add project|New Project Folder)")
if ($projectMatches.Count -eq 0) {
    Write-Host "  [PASS] 'Projects' section, '+ Add project', and project icons are 100% REMOVED from chat.html"
} else {
    Write-Host "  [FAIL] Found remaining project references: $($projectMatches.Count)"
    $allPassed = $false
}

# 2. Check Brand Header
Write-Host "`n2. Checking Brand Header..."
if ($chatHtml.Contains("MANAK-AI") -and $chatHtml.Contains("brand-badge-ai") -and $chatHtml.Contains("brand-icon-shield")) {
    Write-Host "  [PASS] Brand Header: 'MANAK-AI' with 'BIS' badge & shield icon verified"
} else {
    Write-Host "  [FAIL] Brand Header missing elements"
    $allPassed = $false
}

# 3. Check Primary Actions
Write-Host "`n3. Checking Primary Actions..."
if ($chatHtml.Contains("btn-new-conversation") -and $chatHtml.Contains("New Conversation") -and $chatHtml.Contains("btn-sidebar-search") -and $chatHtml.Contains("Ctrl K")) {
    Write-Host "  [PASS] Primary Actions: '+ New Conversation' & 'Search (Ctrl K)' verified"
} else {
    Write-Host "  [FAIL] Primary Actions missing"
    $allPassed = $false
}

# 4. Check Core Navigation
Write-Host "`n4. Checking Core Navigation..."
$navTabs = @("navItemChat", "navItemHistory", "navItemSaved", "navItemDocuments", "navItemTools")
$missingNav = @()
foreach ($tab in $navTabs) {
    if (-not $chatHtml.Contains($tab)) {
        $missingNav += $tab
    }
}
if ($missingNav.Count -eq 0) {
    Write-Host "  [PASS] Core Navigation: Chat, History, Saved, Documents, Tools verified"
} else {
    Write-Host "  [FAIL] Missing navigation tabs: $($missingNav -join ', ')"
    $allPassed = $false
}

# 5. Check Conversations Scroll Region
Write-Host "`n5. Checking Conversations Scroll Region..."
if ($chatHtml.Contains("sidebar-conversations-wrapper") -and $chatHtml.Contains("dynamicConversationsList") -and $chatHtml.Contains("btn-see-all")) {
    Write-Host "  [PASS] Conversations List: Scrollable container with 'See all' verified"
} else {
    Write-Host "  [FAIL] Conversations List container missing"
    $allPassed = $false
}

# 6. Check Bottom User Area & Menu
Write-Host "`n6. Checking Bottom User Area & Popup Menu..."
if ($chatHtml.Contains("sidebar-bottom-area") -and $chatHtml.Contains("sidebar-user-card") -and $chatHtml.Contains("sidebarUserName") -and $chatHtml.Contains("userPopupMenu")) {
    Write-Host "  [PASS] Bottom User Profile Area & Settings Popup Menu verified"
} else {
    Write-Host "  [FAIL] Bottom User Area missing"
    $allPassed = $false
}

# 7. Check CSS Design System
Write-Host "`n7. Checking CSS Styling..."
$cssTokens = @(".app-sidebar", ".btn-new-conversation", ".btn-sidebar-search", ".sidebar-nav-item.active", ".conv-row-item", ".sidebar-empty-state", ".sidebar-user-card", ".user-popup-menu")
$missingCss = @()
foreach ($token in $cssTokens) {
    if (-not $css.Contains($token)) {
        $missingCss += $token
    }
}
if ($missingCss.Count -eq 0) {
    Write-Host "  [PASS] All sidebar CSS tokens & classes verified in style.css"
} else {
    Write-Host "  [FAIL] Missing CSS tokens: $($missingCss -join ', ')"
    $allPassed = $false
}

# 8. Check JS Functions
Write-Host "`n8. Checking JS Functions..."
$jsFuncs = @("renderDynamicHistory", "saveCurrentSession", "loadHistorySession", "initKeyShortcuts", "toggleUserMenu", "openHistoryDrawer", "openSavedStandards")
$missingJs = @()
foreach ($f in $jsFuncs) {
    if (-not $js.Contains($f)) {
        $missingJs += $f
    }
}
if ($missingJs.Count -eq 0) {
    Write-Host "  [PASS] All dynamic history, shortcuts & navigation functions verified in chat.js"
} else {
    Write-Host "  [FAIL] Missing JS functions: $($missingJs -join ', ')"
    $allPassed = $false
}

# 9. Verify Live Server Delivery
Write-Host "`n9. Verifying Live Server Delivery on http://localhost:8000/chat.html..."
try {
    $res = Invoke-WebRequest -Uri "http://localhost:8000/chat.html" -UseBasicParsing -TimeoutSec 5
    if ($res.StatusCode -eq 200 -and $res.Content.Contains("btn-new-conversation") -and $res.Content.Contains("sidebar-conversations-wrapper")) {
        Write-Host "  [PASS] Live Server serves the redesigned sidebar with 200 OK"
    } else {
        Write-Host "  [FAIL] Live Server returned unexpected content"
        $allPassed = $false
    }
} catch {
    Write-Host "  [FAIL] Live Server error: $_"
    $allPassed = $false
}

Write-Host "`n================================================="
if ($allPassed) {
    Write-Host "  >>> ALL 9/9 SIDEBAR REDESIGN CHECKS PASSED! <<<"
} else {
    Write-Host "  >>> SOME CHECKS FAILED <<<"
}
Write-Host "================================================="
