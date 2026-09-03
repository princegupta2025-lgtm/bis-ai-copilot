# Debug RAG search in pure PowerShell
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }
$baseDir = Split-Path $root -Parent

$embedPath = Join-Path $baseDir "data\bis_rag_embeddings.json"
$catLookupFile = Join-Path $baseDir "data\bis_catalogue\compact_lookup.json"
$taxLookupFile = Join-Path $baseDir "data\bis_catalogue\product_taxonomy.json"

Write-Host "Loading data files..."
$ragJson = Get-Content -Raw $embedPath | ConvertFrom-Json
$chunks = $ragJson.chunks
Write-Host "Loaded $($chunks.Count) chunks."

$taxJson = Get-Content -Raw $taxLookupFile | ConvertFrom-Json
$tax = $taxJson.products
Write-Host "Loaded $($tax.Count) products."

$q = "What are helmet shock absorption limits in IS 4151?"
Write-Host "Running query: $q"
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# Run RAG logic
$cleanQ = ($q.ToLower() -replace '[^a-z0-9\s]', ' ').Trim()
$stopwords = @('what', 'are', 'the', 'for', 'and', 'with', 'from', 'under', 'this', 'that', 'how', 'why', 'can', 'you', 'tell', 'about', 'is', 'in', 'of', 'to', 'a', 'an')
$genericModifiers = @('safety', 'requirements', 'requirement', 'specification', 'specifications', 'standard', 'standards', 'limits', 'limit', 'testing', 'tests', 'test', 'verification', 'verify', 'compliance', 'scheme', 'mandatory', 'order', 'active', 'rules', 'clause', 'clauses', 'mark', 'marking')

$words = ($cleanQ -split '\s+') | Where-Object { $_.Length -gt 2 -and $stopwords -notcontains $_ }
$subjectWords = $words | Where-Object { $genericModifiers -notcontains $_ }
$digitsInQuery = [regex]::Matches($q, '\b\d{3,5}\b') | ForEach-Object { $_.Value }

$bigrams = @()
if ($words.Count -ge 2) {
    for ($bi = 0; $bi -lt ($words.Count - 1); $bi++) {
        $bigrams += ($words[$bi] + " " + $words[$bi + 1])
    }
}

$clauseMatch = [regex]::Match($q, '(?i)(?:clause|table|section)\s*([0-9]+(?:\.[0-9]+)?)')
$targetClause = if ($clauseMatch.Success) { $clauseMatch.Groups[1].Value } else { "" }
$isQcoQuery = ($q.ToLower() -match '\b(qco|mandatory|order|compulsory|gazette|ministry)\b')

$matchedTaxonomy = @()
foreach ($prod in $tax) {
    $prodMatched = $false
    foreach ($alias in $prod.aliases) {
        if ($q.ToLower() -match ("\b" + [regex]::Escape($alias.ToLower()) + "\b")) {
            $prodMatched = $true
            break
        }
    }
    if ($prodMatched) { $matchedTaxonomy += $prod }
}

$results = @()
foreach ($chunk in $chunks) {
    $score = 0.0
    $chunkCode = if ($chunk.standardCode) { $chunk.standardCode.ToLower() } else { "" }
    $chunkTitle = if ($chunk.standardTitle) { $chunk.standardTitle.ToLower() } else { "" }
    $clauseTitle = if ($chunk.clauseTitle) { $chunk.clauseTitle.ToLower() } else { "" }
    $chunkNum = if ($chunk.clauseNumber) { $chunk.clauseNumber.ToString().ToLower() } else { "" }
    $chunkText = if ($chunk.text) { $chunk.text.ToLower() } else { "" }
    $keywords = if ($chunk.keywords) { @($chunk.keywords | ForEach-Object { $_.ToString().ToLower() }) } else { @() }
    $allTarget = "$chunkCode $chunkTitle $clauseTitle $chunkText"

    foreach ($mTax in $matchedTaxonomy) {
        if ($chunkCode.Contains($mTax.base_num) -or $chunkCode.Contains($mTax.standard_code.ToLower())) {
            $score += 220.0
        }
    }

    foreach ($d in $digitsInQuery) {
        if ($chunkCode.Contains($d)) { $score += 120.0 }
    }

    if ($targetClause) {
        if ($chunkNum -eq $targetClause -or $clauseTitle.Contains($targetClause)) {
            $score += 150.0
        }
    }

    if ($isQcoQuery -and ($chunk.isMandatory -or ($chunk.qco -and $chunk.qco.Length -gt 0))) {
        $score += 60.0
    }

    foreach ($bg in $bigrams) {
        if ($allTarget.Contains($bg)) { $score += 40.0 }
    }

    $matchedSubjects = 0
    foreach ($sw in $subjectWords) {
        if ($keywords -contains $sw -or $keywords -contains ($sw.TrimEnd('s'))) { $score += 70.0; $matchedSubjects++ }
        elseif ($chunkCode.Contains($sw) -or $chunkTitle.Contains($sw)) { $score += 50.0; $matchedSubjects++ }
        elseif ($clauseTitle.Contains($sw)) { $score += 30.0; $matchedSubjects++ }
        elseif ($chunkText.Contains($sw)) { $score += 10.0; $matchedSubjects++ }
    }

    foreach ($gw in ($words | Where-Object { $genericModifiers -contains $_ })) {
        if ($keywords -contains $gw) { $score += 6.0 }
        if ($chunkTitle.Contains($gw)) { $score += 4.0 }
        if ($clauseTitle.Contains($gw)) { $score += 4.0 }
        if ($chunkText.Contains($gw)) { $score += 1.5 }
    }

    if ($subjectWords.Count -gt 0 -and $matchedSubjects -eq 0 -and $digitsInQuery.Count -eq 0 -and $matchedTaxonomy.Count -eq 0) {
        $score = $score * 0.2
    }

    if ($score -gt 0) {
        $results += [PSCustomObject]@{
            standard = $chunk.standardCode
            clause = $chunk.clauseTitle
            score = [Math]::Round($score, 2)
        }
    }
}

$results = $results | Sort-Object -Property score -Descending | Select-Object -First 4
$sw.Stop()

Write-Host "Completed in $($sw.ElapsedMilliseconds) ms!"
foreach ($r in $results) {
    Write-Host "  $($r.standard) | $($r.clause) | Score: $($r.score)"
}
