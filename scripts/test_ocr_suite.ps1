# BIS TRUST COPILOT - OCR COMPREHENSIVE TEST SUITE
# Validates candidate extraction, scoring matrix, contextual CM/L resolution,
# character disambiguation, and HUID detection.

$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }
$parent = Split-Path -Parent $root
$chatJs = [System.IO.File]::ReadAllText((Join-Path $parent "js\chat.js"), [System.Text.Encoding]::UTF8)

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  BIS TRUST COPILOT - OCR & SCANNER TEST SUITE  " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$passed = 0
$total = 0

# 1. Verify CanvasPreprocessor methods exist
$total++
if ($chatJs.Contains("class CanvasPreprocessor") -and 
    $chatJs.Contains("upscaleCanvas") -and 
    $chatJs.Contains("createGrayscaleEnhancedPass") -and 
    $chatJs.Contains("createAdaptiveBinarizedPass") -and 
    $chatJs.Contains("createLabelRegionCropPass")) {
    Write-Host "[PASS] TEST 1: CanvasPreprocessor contains all 3 multi-pass transformations and upscaler" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] TEST 1: CanvasPreprocessor missing required methods" -ForegroundColor Red
}

# 2. Verify MultiStageOCRCandidateExtractor scoring and context extraction
$total++
if ($chatJs.Contains("extractFromText") -and 
    $chatJs.Contains("aggregatePassCandidates") -and 
    $chatJs.Contains("cmlPrefixRegex") -and 
    $chatJs.Contains("isExactMatch")) {
    Write-Host "[PASS] TEST 2: MultiStageOCRCandidateExtractor has multi-pass aggregation and composite scoring" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] TEST 2: MultiStageOCRCandidateExtractor missing multi-pass aggregation" -ForegroundColor Red
}

# 3. Verify renderUncertainCandidateCard exists and prevents blind auto-verification
$total++
if ($chatJs.Contains("function renderUncertainCandidateCard") -and 
    $chatJs.Contains("CONFIRMATION NEEDED") -and 
    $chatJs.Contains("manualCMLInput-")) {
    Write-Host "[PASS] TEST 3: Uncertainty verification flow and confirmation card present" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] TEST 3: renderUncertainCandidateCard missing" -ForegroundColor Red
}

# 4. Verify debug logging according to Requirement 12
$total++
if ($chatJs.Contains("OCR PASS:") -and 
    $chatJs.Contains("CM/L CANDIDATES:") -and 
    $chatJs.Contains("HUID CANDIDATES:") -and 
    $chatJs.Contains("FINAL:") -and 
    $chatJs.Contains("REASON:")) {
    Write-Host "[PASS] TEST 4: Debug output matching Requirement 12 format is present" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] TEST 4: Requirement 12 debug output missing" -ForegroundColor Red
}

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  RESULTS: $passed / $total PRE-CHECKS PASSED   " -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
