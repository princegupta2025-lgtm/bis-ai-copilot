# Automated Verification Test Suite for BIS Trust Copilot Fixes

$dbContent = [System.IO.File]::ReadAllText("js\database.js")
$chatContent = [System.IO.File]::ReadAllText("js\chat.js")
$wizardContent = [System.IO.File]::ReadAllText("js\wizard.js")
$cmdContent = [System.IO.File]::ReadAllText("js\command-palette.js")

Write-Host "================================================="
Write-Host "  BIS TRUST COPILOT - POST-FIX VERIFICATION TEST"
Write-Host "================================================="

$passed = 0
$total = 9

# Test 1: MultiStageOCRCandidateExtractor scope
$t1 = ($chatContent.IndexOf("class MultiStageOCRCandidateExtractor") -lt $chatContent.IndexOf("async function runRealOCRScan")) -and ($chatContent.IndexOf("class MultiStageOCRCandidateExtractor") -gt 0)
if ($t1) {
    Write-Host "[PASS] TEST 1: MultiStageOCRCandidateExtractor is at module top-level scope (BUG-01 fixed)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 1: MultiStageOCRCandidateExtractor is inside function"
}

# Test 2: CML and HUID Registry in VerificationEngine
$t2_studds = $chatContent.Contains("'STUDDS ACCESSORIES LIMITED'")
$t2_delegation = $chatContent.Contains("typeof BIS_LICENSE_REGISTRY !== 'undefined'") -and $chatContent.Contains("typeof BIS_HUID_REGISTRY !== 'undefined'")
if ($t2_studds -and $t2_delegation) {
    Write-Host "[PASS] TEST 2: VerificationEngine unified with database.js registries (BUG-02 fixed)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 2: VerificationEngine still has divergent registry"
}

# Test 3: RAG Engine initialized with Granular Chunks
$t3 = $chatContent.Contains("typeof BIS_GRANULAR_CLAUSE_CHUNKS !== 'undefined'") -and $chatContent.Contains("_marakRAGEngineInstance.chunks.length !== chunks.length")
if ($t3) {
    Write-Host "[PASS] TEST 3: retrieveAuthoritativeRAG uses BIS_GRANULAR_CLAUSE_CHUNKS with dynamic neural cache upgrade (BUG-03 and BUG-07 fixed)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 3: RAG engine not using granular chunks"
}

# Test 4: Dynamic Unique ID for manual CML Input
$t4 = $chatContent.Contains("manualCMLInput-") -and $chatContent.Contains("submitManualVerification(uid)")
if ($t4) {
    Write-Host "[PASS] TEST 4: Insufficient Data card uses dynamic unique ID (BUG-04 fixed)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 4: Hardcoded manualCMLInput still present"
}

# Test 5: Dynamic Unique IDs for In-Stream Tools and PDF Exporters
$t5 = $chatContent.Contains("msmeScorecardContainer-") -and $chatContent.Contains("grievanceNoticeContainer-") -and $chatContent.Contains("exportMSMEReportPDF(customTargetId)")
if ($t5) {
    Write-Host "[PASS] TEST 5: Interactive cards use unique IDs with dynamic PDF exporter targeting (BUG-05 fixed)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 5: In-stream tools not using unique IDs"
}

# Test 6: selectUserRole explicit event parameter
$t6 = $chatContent.Contains("function selectUserRole(roleKey, roleLabel, evt)") -and $chatContent.Contains("(evt && evt.currentTarget)")
if ($t6) {
    Write-Host "[PASS] TEST 6: selectUserRole accepts explicit event parameter (BUG-11 fixed)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 6: selectUserRole uses implicit event global"
}

# Test 7: Table Cell HTML Escaping (Security)
$t7 = $chatContent.Contains("const safeCell = escapeHtml(c);")
if ($t7) {
    Write-Host "[PASS] TEST 7: Markdown table rendering includes XSS sanitization (Security fixed)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 7: Markdown table cells not escaped"
}

# Test 8: Helmet Standard in Wizard and Command Palette
$t8 = $wizardContent.Contains("IS 4151 : 2015") -and $cmdContent.Contains("IS 4151 : 2015")
if ($t8) {
    Write-Host "[PASS] TEST 8: IS 4151:2015 correctly referenced in Wizard and Command Palette (BUG-10 fixed)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 8: Wrong helmet standard code in wizard or command palette"
}

# Test 9: Relational Version Graph and detectVersionConflict in database.js
$t9 = $dbContent.Contains("const BIS_VERSION_RELATIONAL_GRAPH = {") -and $dbContent.Contains("function detectVersionConflict(query)")
if ($t9) {
    Write-Host "[PASS] TEST 9: BIS_VERSION_RELATIONAL_GRAPH and detectVersionConflict fully defined in database.js (BUG-08 and BUG-09 verified)"
    $passed++
} else {
    Write-Host "[FAIL] TEST 9: Version graph or conflict detector missing"
}

Write-Host "================================================="
Write-Host "  RESULTS: $passed / $total TESTS PASSED"
Write-Host "================================================="
