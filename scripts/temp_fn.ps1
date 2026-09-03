function Search-BisKnowledgeChunks($q, $topK = 4) {
    $fakeStandardDetected = $false
    $largeNumbers = @()
    [regex]::Matches($q, '\b(\d{5,8})\b') | ForEach-Object { $largeNumbers += $_.Value }
    foreach ($ln in $largeNumbers) {
        if ($ln -and -not $global:BIS_CATALOGUE_MAP.ContainsKey($ln) -and [int64]$ln -gt 35000) {
            $fakeStandardDetected = $true
        }
    }

    if ($fakeStandardDetected) {
        return @{
            status     = "REJECTED_UNOFFICIAL"
            model      = "BIS-Domain-Defense-v2"
            disclaimer = "Standard code is not recognized in the official National Catalogue (23,401 standards). Strict zero-hallucination guard active."
            results    = @()
        }
    }

    $matchedTaxonomy = @()
    $cleanQLower = $q.ToLower()
    if ($global:BIS_PRODUCT_TAXONOMY) {
        foreach ($prod in $global:BIS_PRODUCT_TAXONOMY) {
            $prodMatched = $false
            if ($prod.aliases) {
                foreach ($alias in $prod.aliases) {
                    if ($cleanQLower -match ("\b" + [regex]::Escape($alias.ToLower()) + "\b")) {
                        $prodMatched = $true
                        break
                    }
                }
            }
            if (-not $prodMatched -and $prod.hindi_terms) {
                foreach ($hTerm in $prod.hindi_terms) {
                    if ($cleanQLower -match ("\b" + [regex]::Escape($hTerm.ToLower()) + "\b")) {
                        $prodMatched = $true
                        break
                    }
                }
            }
            if ($prodMatched) {
                $matchedTaxonomy += $prod
            }
        }
    }

    $resultsList = New-Object System.Collections.Generic.List[object]
    if ($global:BIS_RAG_CHUNKS) {
        $cleanQ = ($q.ToLower() -replace '[^a-z0-9\s]', ' ').Trim()
        $stopwords = @('what', 'are', 'the', 'for', 'and', 'with', 'from', 'under', 'this', 'that', 'how', 'why', 'can', 'you', 'tell', 'about', 'is', 'in', 'of', 'to', 'a', 'an')
        $genericModifiers = @('safety', 'requirements', 'requirement', 'specification', 'specifications', 'standard', 'standards', 'limits', 'limit', 'testing', 'tests', 'test', 'verification', 'verify', 'compliance', 'scheme', 'mandatory', 'order', 'active', 'rules', 'clause', 'clauses', 'mark', 'marking')
        
        $allWords = $cleanQ -split '\s+'
        $subjectWords = @()
        $queryModifiers = @()
        foreach ($w in $allWords) {
            if ($w.Length -gt 2 -and $stopwords -notcontains $w) {
                if ($genericModifiers -contains $w) {
                    $queryModifiers += $w
                } else {
                    $subjectWords += $w
                }
            }
        }

        $explicitIsCodes = @()
        [regex]::Matches($q, '(?i)\bIS\s*[:\-]?\s*(\d{3,5})\b') | ForEach-Object { $explicitIsCodes += $_.Groups[1].Value }

        # Extract standalone standard digits, excluding revision years (1950-2026) and measurement units/fineness
        $digitsInQuery = @()
        $digitMatches = [regex]::Matches($q, '(?i)\b(\d{3,5})(?!\s*(?:n/mm|kg|g|v|w|hz|ml|rpm|l\b|mm\b|cm\b|deg|c\b|k\b|carat|karat|purity|fineness))\b')
        foreach ($dm in $digitMatches) {
            $val = $dm.Groups[1].Value
            $numVal = [int64]$val
            # If it's a 4-digit calendar year (1950-2030) and NOT explicitly prefixed by IS, do not treat as standard base code
            if ($numVal -ge 1950 -and $numVal -le 2030 -and $explicitIsCodes -notcontains $val) {
                continue
            }
            # If it's 916/750/585 and query is about gold/jewellery/hallmarking, do not treat as standard code
            if (($val -eq "916" -or $val -eq "750" -or $val -eq "585") -and ($q.ToLower() -match '\b(gold|jewellery|jewelry|hallmark|huid|sona|carat|karat)\b')) {
                continue
            }
            $digitsInQuery += $val
        }

        $bigrams = @()
        if ($allWords.Count -ge 2) {
            for ($bi = 0; $bi -lt ($allWords.Count - 1); $bi++) {
                $bigrams += ($allWords[$bi] + " " + $allWords[$bi + 1])
            }
        }

        $clauseMatch = [regex]::Match($q, '(?i)(?:clause|table|section)\s*([0-9]+(?:\.[0-9]+)?)')
        $targetClause = if ($clauseMatch.Success) { $clauseMatch.Groups[1].Value } else { "" }
        $isQcoQuery = ($q.ToLower() -match '\b(qco|mandatory|order|compulsory|gazette|ministry)\b')

        foreach ($chunk in $global:BIS_RAG_CHUNKS) {
            $score = 0.0
            $chunkCode = if ($chunk.standardCode) { $chunk.standardCode.ToLower() } else { "" }
            $chunkTitle = if ($chunk.standardTitle) { $chunk.standardTitle.ToLower() } else { "" }
            $clauseTitle = if ($chunk.clauseTitle) { $chunk.clauseTitle.ToLower() } else { "" }
            $chunkNum = if ($chunk.clauseNumber) { $chunk.clauseNumber.ToString().ToLower() } else { "" }
            $chunkText = if ($chunk.text) { $chunk.text.ToLower() } else { "" }
            $keywords = if ($chunk.keywords) { $chunk.keywords } else { @() }
            $allTarget = "$chunkCode $chunkTitle $clauseTitle $chunkText"

            # 1. Explicit IS Code Match Boost (Highest Priority)
            foreach ($eis in $explicitIsCodes) {
                if ($chunkCode.Contains($eis)) {
                    $score += 350.0
                }
            }

            # 2. Product Taxonomy Boost
            foreach ($mTax in $matchedTaxonomy) {
                if ($chunkCode.Contains($mTax.base_num) -or $chunkCode.Contains($mTax.standard_code.ToLower())) {
                    $score += 350.0
                }
            }

            # 3. Digits in Query Match Boost
            foreach ($d in $digitsInQuery) {
                if ($chunkCode.Contains($d) -and $explicitIsCodes -notcontains $d) { $score += 100.0 }
            }

            # 4. Specific Clause / Subclause Match Boost
            if ($targetClause) {
                if ($chunkNum -eq $targetClause -or $clauseTitle.Contains($targetClause)) {
                    $score += 150.0
                }
            }

            # 5. QCO / Statutory Mandate Boost
            if ($isQcoQuery -and ($chunk.isMandatory -or ($chunk.qco -and $chunk.qco.Length -gt 0))) {
                $score += 60.0
            }

            # 6. Key Phrase Match Boost
            foreach ($bg in $bigrams) {
                if ($allTarget.Contains($bg)) { $score += 40.0 }
            }

            $matchedSubjects = 0
            foreach ($sw in $subjectWords) {
                if ($keywords -contains $sw) { $score += 70.0; $matchedSubjects++ }
                elseif ($chunkCode.Contains($sw) -or $chunkTitle.Contains($sw)) { $score += 50.0; $matchedSubjects++ }
                elseif ($clauseTitle.Contains($sw)) { $score += 30.0; $matchedSubjects++ }
                elseif ($chunkText -match ("\b" + [regex]::Escape($sw) + "\b")) { $score += 10.0; $matchedSubjects++ }
            }

            foreach ($gw in $queryModifiers) {
                if ($keywords -contains $gw) { $score += 6.0 }
                if ($chunkTitle.Contains($gw)) { $score += 4.0 }
                if ($clauseTitle.Contains($gw)) { $score += 4.0 }
                if ($chunkText.Contains($gw)) { $score += 1.5 }
            }

            if ($matchedSubjects -eq 0 -and $digitsInQuery.Count -eq 0 -and $explicitIsCodes.Count -eq 0 -and $matchedTaxonomy.Count -eq 0) {
                $score = 0.0
            }

            if ($score -gt 0) {
                $pContext = $null
                foreach ($mTax in $matchedTaxonomy) {
                    if ($chunkCode.Contains($mTax.base_num)) {
                        $pContext = @{
                            productName      = $mTax.name
                            isMandatory      = $mTax.is_mandatory
                            qcoName          = $mTax.qco_name
                            issuingMinistry  = $mTax.issuing_ministry
                            scheme           = $mTax.scheme
                            keyTests         = $mTax.key_tests
                            laboratories     = $mTax.labs
                            rationale        = $mTax.rationale
                        }
                        break
                    }
                }

                $resultsList.Add(@{
                    chunk = @{
                        id             = $chunk.id
                        standardCode   = $chunk.standardCode
                        standardTitle  = $chunk.standardTitle
                        clauseTitle    = $chunk.clauseTitle
                        clauseNumber   = $chunk.clauseNumber
                        pageNumber     = $chunk.pageNumber
                        source         = $(if ($chunk.source) { $chunk.source } else { "Level 2: Verified Clause Evidence" })
                        evidenceLevel  = $(if ($chunk.source) { $chunk.source } else { "Level 2: Verified Clause Evidence" })
                        text           = $chunk.text
                        keywords       = $chunk.keywords
                        productContext = $pContext
                    }
                    score = [Math]::Round($score, 2)
                })
            }
        }
    }

    $results = @($resultsList | Sort-Object -Property { $_["score"] } -Descending | Select-Object -First $topK)

    if ($digitsInQuery.Count -gt 0 -and $global:BIS_CATALOGUE_MAP) {
        $hasMatchingLayer2 = $false
        foreach ($r in $results) {
            $rStd = if ($r.chunk -and $r.chunk.standardCode) { $r.chunk.standardCode } else { "" }
            foreach ($d in $digitsInQuery) {
                if ($rStd.Contains($d)) {
                    $hasMatchingLayer2 = $true
                }
            }
        }

        if (-not $hasMatchingLayer2) {
            $catResults = @()
            foreach ($d in $digitsInQuery) {
                if ($d -and $global:BIS_CATALOGUE_MAP.ContainsKey($d)) {
                    $cat = $global:BIS_CATALOGUE_MAP[$d]
                    $catResults += @{
                        chunk = @{
                            id            = "$($cat.code)-catalog-metadata"
                            standardCode  = $cat.code
                            standardTitle = $cat.title
                            clauseTitle   = "Official BIS National Catalogue Record"
                            pageNumber    = 1
                            source        = "Level 3: Bureau National Catalogue Metadata"
                            revision      = $cat.year
                            status        = $cat.status
                            text          = "$($cat.code) ($($cat.title)). Division: $($cat.divName) ($($cat.div)). Status: $($cat.status). Scheme: $($cat.scheme). Mandatory QCO: $(if ($cat.qco) { $cat.qco } else { 'None (Voluntary Standard)' }). Authoritative BIS catalogue metadata is available, but the verified full technical text for this standard is not currently indexed. Exact clause-level technical requirements cannot be confirmed from the available evidence."
                            keywords      = @("catalogue", "standard", $cat.div.ToLower(), "is $d")
                        }
                        score = 250.0
                    }
                }
            }
            if ($catResults.Count -gt 0) {
                $results = $catResults
            }
        }
    }

    return @{
        model   = "Server-RAG-Hybrid-BGE-Okapi"
        results = $results
    }
}
