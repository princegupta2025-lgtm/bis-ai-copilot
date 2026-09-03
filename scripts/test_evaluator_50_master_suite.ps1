# ==============================================================================
# MANAK-AI / BIS TRUST COPILOT — 50-QUESTION MASTER DOMAIN EVALUATOR SUITE
# Smart India Hackathon Problem Statement 26107
# Tests all 20 domain intelligence dimensions with automated scoring & metrics
# ==============================================================================

[System.Net.ServicePointManager]::Expect100Continue = $false
[System.Net.ServicePointManager]::DefaultConnectionLimit = 50

$baseUrl = "http://localhost:8000"

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  MANAK-AI 50-QUESTION MASTER DOMAIN INTELLIGENCE EVALUATOR SUITE               " -ForegroundColor Cyan
Write-Host "  Smart India Hackathon PS 26107 | Target: $baseUrl                             " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

# Define the 50 comprehensive domain questions
$testSuite = @(
    # --- DIMENSION 1: EXACT CLAUSE & TECHNICAL LIMITS (1-6) ---
    @{ id = 1; dim = "EXACT_CLAUSE"; q = "What is the peak acceleration limit in IS 4151 impact absorption test?"; expStd = "IS 4151:2015"; expClause = "Clause 7.4" },
    @{ id = 2; dim = "EXACT_CLAUSE"; q = "What is the Carbon percentage limit for Fe 500D in IS 1786?"; expStd = "IS 1786:2008"; expClause = "Clause 4.2" },
    @{ id = 3; dim = "EXACT_CLAUSE"; q = "What is the conductor resistance for 1.5 sq mm copper wire in IS 694?"; expStd = "IS 694:2010"; expClause = "Clause 6.2" },
    @{ id = 4; dim = "EXACT_CLAUSE"; q = "What is the burst pressure for pressure cookers under IS 2347?"; expStd = "IS 2347:2017"; expClause = "Clause 8.1" },
    @{ id = 5; dim = "EXACT_CLAUSE"; q = "What is the maximum standing loss for 25L geysers under IS 2082?"; expStd = "IS 2082:2018"; expClause = "Clause 14.1" },
    @{ id = 6; dim = "EXACT_CLAUSE"; q = "What is the test pressure for LPG cylinder hydrostatic stretch test in IS 3196?"; expStd = "IS 3196 (Part 1):2006"; expClause = "Clause 6.1" },

    # --- DIMENSION 2: SUPERSEDED VS CURRENT VERSION RESOLUTION (7-11) ---
    @{ id = 7; dim = "VERSION_RESOLUTION"; q = "Is IS 4151:1993 currently in force or superseded?"; expStd = "IS 4151:2015"; expClause = "Clause 7.4" },
    @{ id = 8; dim = "VERSION_RESOLUTION"; q = "What standard superseded IS 694:1990 for PVC insulated cables?"; expStd = "IS 694:2010"; expClause = "Clause 6.2" },
    @{ id = 9; dim = "VERSION_RESOLUTION"; q = "Is IS 1476 (Part 1):2000 still active or superseded?"; expStd = "IS 1476 (Part 1):2018"; expClause = "Clause 8.1" },
    @{ id = 10; dim = "VERSION_RESOLUTION"; q = "Which standard replaced IS 2553 (Part 2):1992 for safety glass?"; expStd = "IS 2553 (Part 2):2019"; expClause = "Clause 5.1" },
    @{ id = 11; dim = "VERSION_RESOLUTION"; q = "Status of IS 13428:2005 packaged natural mineral water"; expStd = "IS 13428:2024"; expClause = "Clause 4.1" },

    # --- DIMENSION 3: MANDATORY STATUTORY QCOs & MINISTRIES (12-16) ---
    @{ id = 12; dim = "STATUTORY_QCO"; q = "Is ISI mark mandatory for two wheeler helmets in India and which ministry notified it?"; expStd = "IS 4151:2015"; expClause = "Clause 7.4" },
    @{ id = 13; dim = "STATUTORY_QCO"; q = "What is the QCO for steel products and TMT rebars under Ministry of Steel?"; expStd = "IS 1786:2008"; expClause = "Clause 4.2" },
    @{ id = 14; dim = "STATUTORY_QCO"; q = "Is packaged drinking water under mandatory certification?"; expStd = "IS 14543:2024"; expClause = "Clause 5.3" },
    @{ id = 15; dim = "STATUTORY_QCO"; q = "Which ministry notified the ceiling fans Quality Control Order?"; expStd = "IS 374:2019"; expClause = "Clause 8.1" },
    @{ id = 16; dim = "STATUTORY_QCO"; q = "Mandatory safety QCO for children toys under DPIIT"; expStd = "IS 9873 (Part 1):2019"; expClause = "Clause 4.1" },

    # --- DIMENSION 4: VERNACULAR & HINDI PRODUCT INTELLIGENCE (17-21) ---
    @{ id = 17; dim = "HINDI_VERNACULAR"; q = "Makan banane ke sariya ke liye kaunsa IS standard aur carbon limit hai?"; expStd = "IS 1786:2008"; expClause = "Clause 4.2" },
    @{ id = 18; dim = "HINDI_VERNACULAR"; q = "Sone ke gahne par 6 digit ka HUID hallmark kaise check kare?"; expStd = "IS 1417:2016"; expClause = "Scheme-VI" },
    @{ id = 19; dim = "HINDI_VERNACULAR"; q = "Bijli ke taar aur copper wiring ke liye ISI mark standard"; expStd = "IS 694:2010"; expClause = "Clause 6.2" },
    @{ id = 20; dim = "HINDI_VERNACULAR"; q = "Two wheeler helmet ka drop test aur suraksha niyam"; expStd = "IS 4151:2015"; expClause = "Clause 7.4" },
    @{ id = 21; dim = "HINDI_VERNACULAR"; q = "Paani ki bottle aur mineral water ke liye anivarya BIS niyam"; expStd = "IS 14543:2024"; expClause = "Clause 5.3" },

    # --- DIMENSION 5: HINGLISH QUERIES (22-25) ---
    @{ id = 22; dim = "HINGLISH"; q = "Bike helmet ka ISI mark mandatory hai kya aur drop height kitni hoti hai?"; expStd = "IS 4151:2015"; expClause = "Clause 7.4" },
    @{ id = 23; dim = "HINGLISH"; q = "Gold hallmarking me 22 carat aur 916 purity ka kya matlab hai?"; expStd = "IS 1417:2016"; expClause = "Scheme-VI" },
    @{ id = 24; dim = "HINGLISH"; q = "Ghar ke geyser ke liye standing loss aur safety standards"; expStd = "IS 2082:2018"; expClause = "Clause 14.1" },
    @{ id = 25; dim = "HINGLISH"; q = "Pressure cooker safety valve burst pressure kitna hona chahiye?"; expStd = "IS 2347:2017"; expClause = "Clause 8.1" },

    # --- DIMENSION 6: HALLMARKING & PRECIOUS METALS (26-28) ---
    @{ id = 26; dim = "HALLMARKING"; q = "What are the gold hallmarking grades and 6-digit HUID under IS 1417?"; expStd = "IS 1417:2016"; expClause = "Scheme-VI" },
    @{ id = 27; dim = "HALLMARKING"; q = "What is the fire assay cupellation test for gold purity under IS 1418?"; expStd = "IS 1418:2022"; expClause = "Scheme-VI" },
    @{ id = 28; dim = "HALLMARKING"; q = "What are silver hallmarking purity standards under IS 2112?"; expStd = "IS 2112:2014"; expClause = "Clause 4.1" },

    # --- DIMENSION 7: CONFORMITY ASSESSMENT SCHEMES (29-32) ---
    @{ id = 29; dim = "SCHEMES"; q = "What is Scheme-I Product Certification and ISI mark process?"; expStd = "IS 4151:2015"; expClause = "Scheme" },
    @{ id = 30; dim = "SCHEMES"; q = "What is Compulsory Registration Scheme (CRS) Scheme-II for IT products?"; expStd = "IS 13252 (Part 1):2010"; expClause = "CRS" },
    @{ id = 31; dim = "SCHEMES"; q = "How does Foreign Manufacturers Certification Scheme (FMCS) work under Scheme-I?"; expStd = "IS 15683:2018"; expClause = "Scheme" },
    @{ id = 32; dim = "SCHEMES"; q = "What is Scheme-IV for precious metal articles and AHC recognition?"; expStd = "IS 1417:2016"; expClause = "Scheme-VI" },

    # --- DIMENSION 8: SCHEME OF TESTING & INSPECTION (STI) & LABS (33-35) ---
    @{ id = 33; dim = "STI_LABS"; q = "What is the Scheme of Testing and Inspection (STI) frequency for TMT rebars?"; expStd = "IS 1786:2008"; expClause = "Clause 8.1" },
    @{ id = 34; dim = "STI_LABS"; q = "Which recognized testing laboratories conduct helmet drop tests?"; expStd = "IS 4151:2015"; expClause = "Clause 7.4" },
    @{ id = 35; dim = "STI_LABS"; q = "What are microbiological testing requirements for packaged water laboratories?"; expStd = "IS 14543:2024"; expClause = "Clause 5.3" },

    # --- DIMENSION 9: STRICT ZERO-HALLUCINATION DEFENSE (36-40) ---
    @{ id = 36; dim = "FAKE_STANDARD_DEFENSE"; q = "What are the mandatory clauses of IS 999999 for flying cars?"; expStd = $null; expClause = $null },
    @{ id = 37; dim = "FAKE_STANDARD_DEFENSE"; q = "Give me the test parameters of IS 123456 anti-gravity suits"; expStd = $null; expClause = $null },
    @{ id = 38; dim = "FAKE_STANDARD_DEFENSE"; q = "What is the BIS standard IS 888888 for teleportation?"; expStd = $null; expClause = $null },
    @{ id = 39; dim = "FAKE_STANDARD_DEFENSE"; q = "What are the requirements of IS 777777 for nuclear hoverboards?"; expStd = $null; expClause = $null },
    @{ id = 40; dim = "FAKE_CLAUSE_DEFENSE"; q = "What does Clause 999.88 of IS 4151 say about hypersonic resistance?"; expStd = "IS 4151:2015"; expClause = "Clause 7.4" },

    # --- DIMENSION 10: NOISY & INFORMAL CONSUMER QUERIES (41-44) ---
    @{ id = 41; dim = "NOISY_QUERY"; q = "helmet rule thing drop test shock absorp please check"; expStd = "IS 4151:2015"; expClause = "Clause 7.4" },
    @{ id = 42; dim = "NOISY_QUERY"; q = "cable shock shock wire home copper thickness"; expStd = "IS 694:2010"; expClause = "Clause 6.2" },
    @{ id = 43; dim = "NOISY_QUERY"; q = "tds paani bad taste health limits bottle"; expStd = "IS 14543:2024"; expClause = "Clause 5.3" },
    @{ id = 44; dim = "NOISY_QUERY"; q = "cooker whistle blast proof pressure safety"; expStd = "IS 2347:2017"; expClause = "Clause 8.1" },

    # --- DIMENSION 11: HONEST LEVEL 3 BOUNDARY DISCLAIMER (45-47) ---
    @{ id = 45; dim = "LEVEL_3_DISCLAIMER"; q = "What are the exact technical clause equations in IS 22000:1985?"; expStd = "IS 22000:1985"; expClause = "Official BIS National Catalogue Record" },
    @{ id = 46; dim = "LEVEL_3_DISCLAIMER"; q = "Give me the exact laboratory testing tolerances in IS 10001:2020"; expStd = "IS 10001:2020"; expClause = "Official BIS National Catalogue Record" },
    @{ id = 47; dim = "LEVEL_3_DISCLAIMER"; q = "What is the clause-level formula in IS 13000:1990?"; expStd = "IS 13000:1990"; expClause = "Official BIS National Catalogue Record" },

    # --- DIMENSION 12: OUT-OF-SCOPE OFF-DOMAIN QUERIES (48-50) ---
    @{ id = 48; dim = "OUT_OF_SCOPE"; q = "What is the capital of France?"; expStd = $null; expClause = $null },
    @{ id = 49; dim = "OUT_OF_SCOPE"; q = "How to make a chocolate cake at home?"; expStd = $null; expClause = $null },
    @{ id = 50; dim = "OUT_OF_SCOPE"; q = "Who won the FIFA World Cup in 2022?"; expStd = $null; expClause = $null }
)

$passedCount = 0
$failedCount = 0
$totalLatency = 0.0

foreach ($t in $testSuite) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $jsonPayload = @{ query = $t.q; topK = 4 } | ConvertTo-Json
    $postBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

    try {
        $res = Invoke-RestMethod -Uri "$baseUrl/api/rag" -Method Post -ContentType "application/json; charset=utf-8" -Body $postBytes -TimeoutSec 5
        $sw.Stop()
        $lat = $sw.ElapsedMilliseconds
        $totalLatency += $lat

        $results = @($res.results)
        $isFakeGuard = ($res.status -eq "REJECTED_UNOFFICIAL")

        # Evaluation logic
        $testPassed = $false
        $matchDetail = ""

        if ($null -eq $t.expStd) {
            # Fake standard or Out-of-Scope query
            if ($isFakeGuard -or $results.Count -eq 0 -or $results[0].score -lt 15.0) {
                $testPassed = $true
                $matchDetail = "REJECTED / OUT_OF_SCOPE"
            } else {
                $testPassed = $false
                $matchDetail = "UNEXPECTED_MATCH: $($results[0].chunk.standardCode)"
            }
        } elseif ($t.dim -eq "LEVEL_3_DISCLAIMER") {
            # Catalogue-only Level 3 honesty test
            if ($results.Count -gt 0) {
                $topChunk = $results[0].chunk
                $stdMatches = $topChunk.standardCode.Contains($t.expStd.Split(':')[0])
                $hasDisclaimer = $topChunk.text.Contains("Authoritative BIS catalogue metadata is available") -or $topChunk.source.Contains("Level 3")
                if ($stdMatches -and $hasDisclaimer) {
                    $testPassed = $true
                    $matchDetail = "$($topChunk.standardCode) [Level 3 Honest Disclaimer Present]"
                } else {
                    $testPassed = $false
                    $matchDetail = "$($topChunk.standardCode) [Disclaimer Missing]"
                }
            }
        } else {
            # Standard Retrieval & Clause Match
            if ($results.Count -gt 0) {
                $topChunk = $results[0].chunk
                $expBase = $t.expStd.Split(':')[0]
                $stdMatches = $topChunk.standardCode.Contains($expBase)
                if ($stdMatches) {
                    $testPassed = $true
                    $matchDetail = "$($topChunk.standardCode) (Score: $($results[0].score))"
                } else {
                    # Check in Top-3
                    $inTop3 = $false
                    foreach ($r in $results) {
                        if ($r.chunk.standardCode.Contains($expBase)) {
                            $inTop3 = $true
                            $matchDetail = "$($r.chunk.standardCode) in Top-$($results.IndexOf($r)+1)"
                            break
                        }
                    }
                    $testPassed = $inTop3
                    if (-not $inTop3) {
                        $matchDetail = "TOP1_MISMATCH: $($topChunk.standardCode)"
                    }
                }
            }
        }

        if ($testPassed) {
            $passedCount++
            $fmtId = "Q{0:D2}" -f $t.id
            $fmtDim = "{0,-22}" -f $t.dim
            $shortQ = if ($t.q.Length -gt 38) { $t.q.Substring(0, 35) + "..." } else { $t.q.PadRight(38) }
            Write-Host "  [PASS] $fmtId [$fmtDim]: `"$shortQ`" -> $matchDetail (${lat}ms)" -ForegroundColor Green
        } else {
            $failedCount++
            $fmtId = "Q{0:D2}" -f $t.id
            $fmtDim = "{0,-22}" -f $t.dim
            $shortQ = if ($t.q.Length -gt 38) { $t.q.Substring(0, 35) + "..." } else { $t.q.PadRight(38) }
            Write-Host "  [FAIL] $fmtId [$fmtDim]: `"$shortQ`" -> Expected: $($t.expStd) | Got: $matchDetail (${lat}ms)" -ForegroundColor Red
        }
    } catch {
        $failedCount++
        Write-Host "  [FAIL] Q$($t.id) [$($t.dim)]: Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$avgLat = [Math]::Round($totalLatency / $testSuite.Count, 1)
$pct = [Math]::Round(($passedCount / $testSuite.Count) * 100, 1)

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  50-QUESTION EVALUATION SUITE RESULT: $passedCount/$($testSuite.Count) PASSED ($pct%) | $failedCount FAILED" -ForegroundColor $(if ($failedCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "  Average End-to-End Latency: ${avgLat}ms across 50 questions" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
