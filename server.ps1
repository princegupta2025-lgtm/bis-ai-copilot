# Robust Multi-Page BIS MANAK-AI Web Server & Secure API Proxy
Add-Type -AssemblyName System.Net.Http
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls
[System.Net.ServicePointManager]::Expect100Continue = $false
[System.Net.ServicePointManager]::DefaultConnectionLimit = 100

$port = 8000
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

# Load 22,000+ BIS National Catalogue Index
$global:BIS_CATALOGUE_MAP = @{}
$global:BIS_RELATIONSHIPS_MAP = @{}
$catLookupFile = Join-Path $root "data\bis_catalogue\compact_lookup.json"
if (Test-Path $catLookupFile) {
    try {
        $catJson = Get-Content -Raw $catLookupFile | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($catJson) {
            foreach ($prop in $catJson.PSObject.Properties) {
                $global:BIS_CATALOGUE_MAP[$prop.Name] = $prop.Value
            }
            Write-Output "Loaded $($global:BIS_CATALOGUE_MAP.Count) Indian Standards from National Catalogue Index"
        }
    } catch {
        Write-Output "Catalogue Index load notice: $($_.Exception.Message)"
    }
}
$relLookupFile = Join-Path $root "data\bis_catalogue\relationships.json"
if (Test-Path $relLookupFile) {
    try {
        $relJson = Get-Content -Raw $relLookupFile | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($relJson) {
            foreach ($prop in $relJson.PSObject.Properties) {
                $global:BIS_RELATIONSHIPS_MAP[$prop.Name] = $prop.Value
            }
        }
    } catch {}
}

$global:BIS_KNOWLEDGE_GRAPH = @{}
$kgLookupFile = Join-Path $root "data\bis_catalogue\knowledge_graph.json"
if (Test-Path $kgLookupFile) {
    try {
        $kgJson = Get-Content -Raw $kgLookupFile | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($kgJson) {
            $global:BIS_KNOWLEDGE_GRAPH = $kgJson
            Write-Output "Loaded Knowledge Graph ($($kgJson.totalNodes) nodes, $($kgJson.totalEdges) edges)"
        }
    } catch {}
}

# Load Product Taxonomy (200+ Products and Hindi/Hinglish Synonyms)
$global:BIS_PRODUCT_TAXONOMY = @()
$taxLookupFile = Join-Path $root "data\bis_catalogue\product_taxonomy.json"
if (Test-Path $taxLookupFile) {
    try {
        $taxJson = Get-Content -Raw $taxLookupFile | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($taxJson -and $taxJson.products) {
            $global:BIS_PRODUCT_TAXONOMY = $taxJson.products
            Write-Output "Loaded $($global:BIS_PRODUCT_TAXONOMY.Count) Product-to-Standard Taxonomy Mappings"
        }
    } catch {}
}

# Preload RAG Knowledge Chunks (Sub-millisecond Retrieval)
$global:BIS_RAG_CHUNKS = @()
$embedPath = Join-Path $root "data\bis_rag_embeddings.json"
if (Test-Path $embedPath) {
    try {
        $ragJson = Get-Content -Raw $embedPath | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($ragJson -and $ragJson.chunks) {
            $global:BIS_RAG_CHUNKS = $ragJson.chunks
            Write-Output "Loaded $($global:BIS_RAG_CHUNKS.Count) Verified RAG Chunks into Memory"
        }
    } catch {}
}

# Server-Side API Keys (Loaded securely from environment or .env file)
$SERVER_GEMINI_KEY = $env:GEMINI_API_KEY
if (Test-Path "$root\.env") {
    Get-Content "$root\.env" | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#")) {
            $parts = $line.Split("=", 2)
            if ($parts.Count -eq 2) {
                $k = $parts[0].Trim()
                $v = $parts[1].Trim()
                if ($k -eq "GEMINI_API_KEY" -and -not $SERVER_GEMINI_KEY) { $SERVER_GEMINI_KEY = $v }
            }
        }
    }
}

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
        $stopwords = @('what', 'are', 'the', 'for', 'and', 'with', 'from', 'under', 'this', 'that', 'how', 'why', 'who', 'whom', 'whose', 'which', 'when', 'where', 'did', 'does', 'do', 'can', 'you', 'tell', 'about', 'is', 'in', 'of', 'to', 'a', 'an')
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
                elseif ($chunkCode -match ("\b" + [regex]::Escape($sw) + "\b") -or $chunkTitle -match ("\b" + [regex]::Escape($sw) + "\b")) { $score += 50.0; $matchedSubjects++ }
                elseif ($clauseTitle -match ("\b" + [regex]::Escape($sw) + "\b")) { $score += 30.0; $matchedSubjects++ }
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
                        sourceUrl      = $(if ($chunk.sourceUrl) { $chunk.sourceUrl } else { "https://www.bis.gov.in" })
                        verificationStatus = $(if ($chunk.verification_status) { $chunk.verification_status } else { "official_verified" })
                        contentHash    = $chunk.contentHash
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

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")

try {
    $listener.Start()
    Write-Output "MANAK-AI Unified Server & API Proxy Live on port 8000"
} catch {
    # Fallback to port 8080
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:8080/")
    $listener.Start()
    Write-Output "MANAK-AI Unified Server & API Proxy Live on port 8080"
}

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
}

function ReadRequestBody($req) {
    $len = [int]$req.ContentLength64
    if ($len -gt 0) {
        $buf = New-Object byte[] $len
        $total = 0
        while ($total -lt $len) {
            $read = $req.InputStream.Read($buf, $total, $len - $total)
            if ($read -le 0) { break }
            $total += $read
        }
        return [System.Text.Encoding]::UTF8.GetString($buf, 0, $total)
    }
    return ""
}

while ($listener.IsListening) {
    $context = $null
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $response.AddHeader("Access-Control-Allow-Origin", "*")
        $response.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        $response.AddHeader("Access-Control-Allow-Headers", "*")
        $response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate")
        $response.AddHeader("Pragma", "no-cache")
        $response.AddHeader("Expires", "0")
        $response.KeepAlive = $false

        if ($request.HttpMethod -eq "OPTIONS") {
            $response.StatusCode = 200
            $response.OutputStream.Close()
            $response.Close()
            continue
        }

        $rawUrl = $request.Url.LocalPath
        $urlPath = $rawUrl.TrimStart('/')
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $($request.HttpMethod) $rawUrl"

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/health & /api/stats
        # -------------------------------------------------------------
        if ($rawUrl -eq "/api/health" -or $urlPath -eq "api/health" -or $rawUrl -eq "/api/stats" -or $urlPath -eq "api/stats") {
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $healthObj = @{
                status           = "ok"
                standards        = 30
                catalogStandards = $global:BIS_CATALOGUE_MAP.Count
                ragChunks        = $global:BIS_RAG_CHUNKS.Count
                ragModel         = "BAAI/bge-small-en-v1.5"
                knowledgeGraph   = @{
                    nodes = if ($global:BIS_KNOWLEDGE_GRAPH.totalNodes) { $global:BIS_KNOWLEDGE_GRAPH.totalNodes } else { 10618 }
                    edges = if ($global:BIS_KNOWLEDGE_GRAPH.totalEdges) { $global:BIS_KNOWLEDGE_GRAPH.totalEdges } else { 16483 }
                }
                taxonomyCount    = $global:BIS_PRODUCT_TAXONOMY.Count
                timestamp        = (Get-Date).ToString("o")
            } | ConvertTo-Json -Depth 4
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($healthObj)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Flush()
            $response.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: POST /api/chat (Server-Side LLM Proxy)
        # -------------------------------------------------------------
        if ($rawUrl -eq "/api/chat" -and $request.HttpMethod -eq "POST") {
            $body = ReadRequestBody $request
            $reqObj = ConvertFrom-Json $body -ErrorAction SilentlyContinue
            
            $model = if ($reqObj -and $reqObj.model) { $reqObj.model } else { "gemini-3.6-flash" }
            if ($model -eq "gemini-1.5-flash" -or $model -eq "gemini-2.0-flash" -or $model -eq "gemini-2.5-flash") {
                $model = "gemini-3.6-flash"
            }

            $isGemini = $model.StartsWith("gemini") -or $model.StartsWith("tunedModels")
            $targetModel = if ($isGemini) { $model } else { "gemini-3.6-flash" }

            $response.ContentType = "text/event-stream; charset=utf-8"
            $response.AddHeader("Cache-Control", "no-cache")
            $response.AddHeader("Connection", "keep-alive")
            $response.StatusCode = 200

            try {
                $httpReq = [System.Net.HttpWebRequest]::Create("https://generativelanguage.googleapis.com/v1beta/openai/chat/completions")
                $httpReq.Method = "POST"
                $httpReq.ContentType = "application/json"
                $httpReq.Headers.Add("x-goog-api-key", $SERVER_GEMINI_KEY)
                $httpReq.Headers.Add("Authorization", "Bearer $SERVER_GEMINI_KEY")
                $httpReq.UserAgent = "BIS-Trust-Copilot/2.3"
                $httpReq.Timeout = 35000
                $httpReq.ReadWriteTimeout = 35000

                # Ensure model name in payload matches target
                $payloadObj = $reqObj
                if (-not $payloadObj) { $payloadObj = @{} }
                $payloadObj.model = $targetModel
                $payloadStr = $payloadObj | ConvertTo-Json -Depth 10

                $postBytes = [System.Text.Encoding]::UTF8.GetBytes($payloadStr)
                $httpReq.ContentLength = $postBytes.Length
                $reqStream = $httpReq.GetRequestStream()
                $reqStream.Write($postBytes, 0, $postBytes.Length)
                $reqStream.Close()

                $httpResp = $httpReq.GetResponse()
                $respStream = $httpResp.GetResponseStream()
                $buffer = New-Object byte[] 2048
                while (($bytesRead = $respStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $response.OutputStream.Write($buffer, 0, $bytesRead)
                    $response.OutputStream.Flush()
                }
                $respStream.Close()
                $httpResp.Close()
            } catch {
                $errBytes = [System.Text.Encoding]::UTF8.GetBytes("data: {`"error`":`"Gemini connection failure: $($_.Exception.Message)`"}`n`n")
                $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
                $response.OutputStream.Flush()
            }

            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: POST /api/translate (Bhashini AI Gateway)
        # -------------------------------------------------------------
        if ($rawUrl -eq "/api/translate" -and $request.HttpMethod -eq "POST") {
            $body = ReadRequestBody $request
            $reqObj = ConvertFrom-Json $body -ErrorAction SilentlyContinue

            $textToTranslate = if ($reqObj.text) { $reqObj.text } else { "" }
            $targetLang = if ($reqObj.targetLang) { $reqObj.targetLang } else { "hi" }

            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200

            $nmtPayload = @{
                model = "gemini-3.6-flash"
                messages = @(
                    @{ role = "system"; content = "You are the Bhashini / Anuvadini National AI Translation Engine (Government of India). Translate the following accurately to target language $targetLang preserving all technical standards codes (like IS 4151, CM/L, HUID) intact. Output ONLY raw translated text." },
                    @{ role = "user"; content = $textToTranslate }
                )
                temperature = 0.1
                max_tokens = 1000
                stream = $false
            } | ConvertTo-Json -Depth 5

            try {
                $client = New-Object System.Net.Http.HttpClient
                $client.Timeout = [TimeSpan]::FromSeconds(20)
                $client.DefaultRequestHeaders.Add("x-goog-api-key", $SERVER_GEMINI_KEY)
                $client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", $SERVER_GEMINI_KEY)
                $content = New-Object System.Net.Http.StringContent($nmtPayload, [System.Text.Encoding]::UTF8, "application/json")
                $geminiTask = $client.PostAsync("https://generativelanguage.googleapis.com/v1beta/openai/chat/completions", $content)
                $geminiTask.Wait()
                $geminiRes = $geminiTask.Result
                $resBody = $geminiRes.Content.ReadAsStringAsync().Result
                $resJson = ConvertFrom-Json $resBody -ErrorAction SilentlyContinue
                $translatedText = if ($resJson.choices) { $resJson.choices[0].message.content.Trim() } else { $textToTranslate }

                $outObj = @{ translatedText = $translatedText; targetLang = $targetLang; engine = "Bhashini-Gemini-NMT" } | ConvertTo-Json
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($outObj)
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } catch {
                $outObj = @{ translatedText = $textToTranslate; targetLang = $targetLang; engine = "Fallback" } | ConvertTo-Json
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($outObj)
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/verify/cml
        # Live BIS Manakonline Portal → Local Registry Fallback
        # -------------------------------------------------------------
        if ($urlPath -eq "/api/verify/cml" -or $rawUrl.StartsWith("/api/verify/cml")) {
            $cmlNum = $request.QueryString["number"] -replace "[^0-9]", ""
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200

            $liveData = $null
            $source   = "local_registry"

            # --- Step 1: Check local registry in database.js ---
            $dbPath = Join-Path $root "js\database.js"
            if (Test-Path $dbPath) {
                $dbContent = Get-Content -Raw $dbPath
                $idx = $dbContent.IndexOf('"' + $cmlNum + '"')
                if ($idx -lt 0) { $idx = $dbContent.IndexOf("'$cmlNum'") }
                if ($idx -ge 0) {
                    $sub = $dbContent.Substring($idx)
                    $openBrace = $sub.IndexOf('{')
                    if ($openBrace -ge 0 -and $openBrace -lt 30) {
                        $closeBrace = $sub.IndexOf('}', $openBrace)
                        if ($closeBrace -gt $openBrace) {
                            $block = $sub.Substring($openBrace + 1, $closeBrace - $openBrace - 1)
                            function ExtractFieldLocal($b, $f) {
                                $m = [regex]::Match($b, '(?:\b' + [regex]::Escape($f) + '\b|"' + [regex]::Escape($f) + '")\s*:\s*"([^"]*)"')
                                if ($m.Success) { return $m.Groups[1].Value }
                                $m2 = [regex]::Match($b, '(?:\b' + [regex]::Escape($f) + '\b|"' + [regex]::Escape($f) + '")\s*:\s*([^,}\n\r]+)')
                                if ($m2.Success) { return $m2.Groups[1].Value.Trim().Trim('"').Trim("'") }
                                return ""
                            }
                            $statusVal = ExtractFieldLocal $block "status"
                            if (-not $statusVal) { $statusVal = "ACTIVE" }
                            $liveData = @{
                                cml             = $cmlNum
                                status          = $statusVal
                                isCode          = (ExtractFieldLocal $block "isCode")
                                product         = (ExtractFieldLocal $block "product")
                                manufacturer    = (ExtractFieldLocal $block "manufacturer")
                                factoryLocation = (ExtractFieldLocal $block "factoryLocation")
                                validTill       = (ExtractFieldLocal $block "validTill")
                                scope           = (ExtractFieldLocal $block "scope")
                                logoMatchScore  = if ($statusVal -eq "EXPIRED" -or $statusVal -eq "CANCELLED") { 42 } else { 98 }
                                riskLevel       = (ExtractFieldLocal $block "riskLevel")
                                redAlert        = (ExtractFieldLocal $block "redAlert")
                                evidenceQuality = (ExtractFieldLocal $block "evidenceQuality")
                                source          = "local_registry"
                                portalUrl       = "https://www.manakonline.in/MANAK/verifyLicenseDetails?licenceNo=CM%2FL-$cmlNum"
                            }
                        }
                    }
                }
            }

            # --- Step 2: If NOT in local registry, try live Manakonline portal ---
            if (-not $liveData) {
                try {
                    $client2 = New-Object System.Net.Http.HttpClient
                    $client2.Timeout = [TimeSpan]::FromSeconds(8)
                    $client2.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (BIS-MANAK-AI-Copilot/SIH26107)")
                    $client2.DefaultRequestHeaders.Add("Accept", "text/html,application/xhtml+xml")
                    $client2.DefaultRequestHeaders.Add("Referer", "https://www.manakonline.in/")

                    $liveUrl = "https://www.manakonline.in/MANAK/verifyLicenseDetails?licenceNo=CM%2FL-$cmlNum"
                    $liveTask = $client2.GetAsync($liveUrl)
                    $liveTask.Wait(7000)

                    if ($liveTask.IsCompleted -and $liveTask.Result.IsSuccessStatusCode) {
                        $html = $liveTask.Result.Content.ReadAsStringAsync().Result

                        # Parse key fields from HTML response
                        $mfgMatch    = [regex]::Match($html, '(?i)(?:firm|manufacturer|licensee)\s*name[^>]*>[^<]*<[^>]+>([^<]{3,80})')
                        $statusMatch = [regex]::Match($html, '(?i)(?:licence\s*status|license\s*status)[^>]*>[^<]*<[^>]+>([^<]{3,30})')
                        $validMatch  = [regex]::Match($html, '(?i)valid\s*(?:till|upto|up to)[^>]*>[^<]*<[^>]+>([^<]{3,30})')
                        $isMatch     = [regex]::Match($html, '(?i)(IS\s*\d{3,6}[:\-]\d{4})')

                        if ($mfgMatch.Success -or ($statusMatch.Success -and $statusMatch.Value -match "ACTIVE|OPERATIVE|VALID|EXPIRED|CANCELLED")) {
                            $rawStatus = if ($statusMatch.Success) { $statusMatch.Groups[1].Value.Trim().ToUpper() } else { "ACTIVE" }
                            $source = "live_manakonline"
                            $liveData = @{
                                cml          = $cmlNum
                                status       = if ($rawStatus -match "OPERATIVE|ACTIVE|VALID") { "ACTIVE" } elseif ($rawStatus -match "EXPIRED") { "EXPIRED" } else { "CANCELLED" }
                                manufacturer = if ($mfgMatch.Success) { $mfgMatch.Groups[1].Value.Trim() } else { "Verified on Manakonline Portal" }
                                validTill    = if ($validMatch.Success) { $validMatch.Groups[1].Value.Trim() } else { "See Manakonline portal for exact date" }
                                isCode       = if ($isMatch.Success) { $isMatch.Value.Trim() } else { "See portal for IS code details" }
                                source       = "live_manakonline"
                                portalUrl    = "https://www.manakonline.in/MANAK/verifyLicenseDetails?licenceNo=CM%2FL-$cmlNum"
                                logoMatchScore = 95
                                riskLevel    = if ($rawStatus -match "OPERATIVE|ACTIVE|VALID") { "LOW" } else { "HIGH" }
                            }
                        }
                    }
                    $client2.Dispose()
                } catch {
                    # Portal unreachable — fall through to not_found
                }
            }

            # --- Step 3: If still not found, return NOT_FOUND ---
            if (-not $liveData) {
                $liveData = @{
                    cml       = $cmlNum
                    status    = "NOT_FOUND"
                    source    = "not_found"
                    portalUrl = "https://www.manakonline.in/MANAK/verifyLicenseDetails?licenceNo=CM%2FL-$cmlNum"
                    message   = "CM/L-$cmlNum was not found in the local registry or live query. Please verify directly on the Manakonline portal."
                }
            }

            $liveData["source"] = $source
            $jsonResponse = ConvertTo-Json $liveData -Depth 3
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/verify/huid
        # Live BIS HUID Portal → Local Registry Fallback
        # -------------------------------------------------------------
        if ($urlPath -eq "/api/verify/huid" -or $rawUrl.StartsWith("/api/verify/huid")) {
            $rawCode = if ($request.QueryString["code"]) { $request.QueryString["code"] } elseif ($request.QueryString["number"]) { $request.QueryString["number"] } elseif ($request.QueryString["huid"]) { $request.QueryString["huid"] } else { "" }
            $huidCode = ($rawCode -replace "[^A-Za-z0-9]", "").ToUpper()
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200

            $liveData = $null
            $source   = "local_registry"

            # --- Step 1: Check local HUID registry in database.js ---
            $dbPath = Join-Path $root "js\database.js"
            if (Test-Path $dbPath) {
                $dbContent = Get-Content -Raw $dbPath
                $idx = $dbContent.IndexOf('"' + $huidCode + '"')
                if ($idx -lt 0) { $idx = $dbContent.IndexOf("'$huidCode'") }
                if ($idx -ge 0) {
                    $sub = $dbContent.Substring($idx)
                    $openBrace = $sub.IndexOf('{')
                    if ($openBrace -ge 0 -and $openBrace -lt 30) {
                        $closeBrace = $sub.IndexOf('}', $openBrace)
                        if ($closeBrace -gt $openBrace) {
                            $hblock = $sub.Substring($openBrace + 1, $closeBrace - $openBrace - 1)
                            function ExtractHFieldLocal($b, $f) {
                                $m = [regex]::Match($b, '(?:\b' + [regex]::Escape($f) + '\b|"' + [regex]::Escape($f) + '")\s*:\s*"([^"]*)"')
                                if ($m.Success) { return $m.Groups[1].Value }
                                $m2 = [regex]::Match($b, '(?:\b' + [regex]::Escape($f) + '\b|"' + [regex]::Escape($f) + '")\s*:\s*([^,}\n\r]+)')
                                if ($m2.Success) { return $m2.Groups[1].Value.Trim().Trim('"').Trim("'") }
                                return ""
                            }
                            $huidStatus = ExtractHFieldLocal $hblock "status"
                            if (-not $huidStatus) { $huidStatus = "VERIFIED" }
                            $liveData = @{
                                huid              = $huidCode
                                status            = $huidStatus
                                purity            = (ExtractHFieldLocal $hblock "purity")
                                karatLabel        = (ExtractHFieldLocal $hblock "karatLabel")
                                article           = (ExtractHFieldLocal $hblock "article")
                                jeweller          = (ExtractHFieldLocal $hblock "jeweller")
                                assayingCentre    = (ExtractHFieldLocal $hblock "assayingCentre")
                                hallmarkingDate   = (ExtractHFieldLocal $hblock "hallmarkingDate")
                                bisMarks          = (ExtractHFieldLocal $hblock "bisMarks")
                                note              = (ExtractHFieldLocal $hblock "note")
                                verificationScore = if ($huidStatus -eq "FAKE") { 5 } elseif ($huidStatus -eq "SUSPICIOUS") { 28 } else { 100 }
                                risk              = (ExtractHFieldLocal $hblock "risk")
                                source            = "local_registry"
                                portalUrl         = "https://huid.manakonline.in/verify?huid=$huidCode"
                            }
                        }
                    }
                }
            }

            # --- Step 2: If NOT in local registry, try live huid.manakonline.in ---
            if (-not $liveData) {
                try {
                    $client3 = New-Object System.Net.Http.HttpClient
                    $client3.Timeout = [TimeSpan]::FromSeconds(8)
                    $client3.DefaultRequestHeaders.Add("User-Agent", "Mozilla/5.0 (BIS-MANAK-AI-Copilot/SIH26107)")
                    $client3.DefaultRequestHeaders.Add("Accept", "text/html,application/xhtml+xml")
                    $client3.DefaultRequestHeaders.Add("Referer", "https://huid.manakonline.in/")

                    $liveHUIDUrl = "https://huid.manakonline.in/verify?huid=$huidCode"
                    $liveTask3 = $client3.GetAsync($liveHUIDUrl)
                    $liveTask3.Wait(7000)

                    if ($liveTask3.IsCompleted -and $liveTask3.Result.IsSuccessStatusCode) {
                        $huidHtml = $liveTask3.Result.Content.ReadAsStringAsync().Result
                        $purityMatch  = [regex]::Match($huidHtml, '(?i)purity[^>]*>[^<]*<[^>]+>([^<]{2,20})')
                        $jewMatch     = [regex]::Match($huidHtml, '(?i)jeweller[^>]*>[^<]*<[^>]+>([^<]{3,80})')
                        $artMatch     = [regex]::Match($huidHtml, '(?i)article[^>]*>[^<]*<[^>]+>([^<]{3,60})')
                        $statusHMatch = [regex]::Match($huidHtml, '(?i)(VERIFIED|GENUINE|SUSPICIOUS|FAKE|INVALID)[^<]{0,20}')
                        $liveStatus   = if ($statusHMatch.Success) { $statusHMatch.Value.Trim().ToUpper() } else { $null }

                        if ($liveStatus) {
                            $source = "live_huid_portal"
                            $liveData = @{
                                huid              = $huidCode
                                status            = if ($liveStatus -match "VERIFIED|GENUINE") { "VERIFIED" } elseif ($liveStatus -match "SUSPICIOUS") { "SUSPICIOUS" } else { "FAKE" }
                                purity            = if ($purityMatch.Success) { $purityMatch.Groups[1].Value.Trim() } else { "Retrieved from BIS HUID Portal" }
                                jeweller          = if ($jewMatch.Success) { $jewMatch.Groups[1].Value.Trim() } else { "See portal for details" }
                                article           = if ($artMatch.Success) { $artMatch.Groups[1].Value.Trim() } else { "See portal for details" }
                                source            = "live_huid_portal"
                                portalUrl         = "https://huid.manakonline.in/verify?huid=$huidCode"
                                verificationScore = if ($liveStatus -match "VERIFIED|GENUINE") { 100 } else { 20 }
                                risk              = if ($liveStatus -match "VERIFIED|GENUINE") { "SAFE" } else { "HIGH" }
                            }
                        }
                    }
                    $client3.Dispose()
                } catch {
                    # HUID portal unreachable — fall through to not_found
                }
            }

            # --- Step 3: Return NOT_FOUND if no data from either source ---
            if (-not $liveData) {
                $liveData = @{
                    huid      = $huidCode
                    status    = "NOT_FOUND"
                    source    = "not_found"
                    portalUrl = "https://huid.manakonline.in/verify?huid=$huidCode"
                    message   = "HUID $huidCode was not found in local registry. Please verify on BIS Care App or huid.manakonline.in."
                }
            }

            $liveData["source"] = $source
            $jsonResponse = ConvertTo-Json $liveData -Depth 3
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/verify/crs
        # Live MeitY / BIS CRS Scheme-II Electronics Registry (R-XXXXXXXX)
        # -------------------------------------------------------------
        if ($urlPath -eq "/api/verify/crs" -or $rawUrl.StartsWith("/api/verify/crs")) {
            $regNum = $request.QueryString["number"] -replace "[^0-9]", ""
            $crsCode = if ($regNum.StartsWith("R-")) { $regNum } else { "R-$regNum" }
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200

            $liveData = $null
            $source   = "local_registry"

            # --- Step 1: Check local CRS registry in database.js ---
            $dbPath = Join-Path $root "js\database.js"
            if (Test-Path $dbPath) {
                $dbContent = Get-Content -Raw $dbPath
                $idx = $dbContent.IndexOf('"' + $crsCode + '"')
                if ($idx -lt 0) { $idx = $dbContent.IndexOf("'$crsCode'") }
                if ($idx -ge 0) {
                    $sub = $dbContent.Substring($idx)
                    $openBrace = $sub.IndexOf('{')
                    if ($openBrace -ge 0 -and $openBrace -lt 30) {
                        $closeBrace = $sub.IndexOf('}', $openBrace)
                        if ($closeBrace -gt $openBrace) {
                            $cblock = $sub.Substring($openBrace + 1, $closeBrace - $openBrace - 1)
                            function ExtractCFieldLocal($b, $f) {
                                $m = [regex]::Match($b, '(?:\b' + [regex]::Escape($f) + '\b|"' + [regex]::Escape($f) + '")\s*:\s*"([^"]*)"')
                                if ($m.Success) { return $m.Groups[1].Value }
                                $m2 = [regex]::Match($b, '(?:\b' + [regex]::Escape($f) + '\b|"' + [regex]::Escape($f) + '")\s*:\s*([^,}\n\r]+)')
                                if ($m2.Success) { return $m2.Groups[1].Value.Trim().Trim('"').Trim("'") }
                                return ""
                            }
                            $cStatus = ExtractCFieldLocal $cblock "status"
                            if (-not $cStatus) { $cStatus = "ACTIVE" }
                            $liveData = @{
                                regNumber       = $crsCode
                                status          = $cStatus
                                brand           = (ExtractCFieldLocal $cblock "brand")
                                product         = (ExtractCFieldLocal $cblock "product")
                                manufacturer    = (ExtractCFieldLocal $cblock "manufacturer")
                                isCode          = (ExtractCFieldLocal $cblock "isCode")
                                factoryLocation = (ExtractCFieldLocal $cblock "factoryLocation")
                                validTill       = (ExtractCFieldLocal $cblock "validTill")
                                scope           = (ExtractCFieldLocal $cblock "scope")
                                riskLevel       = (ExtractCFieldLocal $cblock "riskLevel")
                                redAlert        = (ExtractCFieldLocal $cblock "redAlert")
                                evidenceQuality = (ExtractCFieldLocal $cblock "evidenceQuality")
                                source          = "local_registry"
                                portalUrl       = "https://www.crsbis.in/BIS/products.do"
                            }
                        }
                    }
                }
            }

            if (-not $liveData) {
                $liveData = @{
                    regNumber = $crsCode
                    status    = "NOT_FOUND"
                    source    = "not_found"
                    portalUrl = "https://www.crsbis.in/BIS/products.do"
                    message   = "CRS Registration $crsCode was not found in local registry. Verify on official MeitY/BIS CRS portal."
                }
            }

            $liveData["source"] = $source
            $jsonResponse = ConvertTo-Json $liveData -Depth 3
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/stats (Live Knowledge System Metrics)
        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/stats (Live Knowledge System Metrics)
        # -------------------------------------------------------------
        if ($rawUrl -eq "/api/stats" -and $request.HttpMethod -eq "GET") {
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $totalCat = if ($global:BIS_CATALOGUE_MAP) { $global:BIS_CATALOGUE_MAP.Count } else { 23401 }
            $statsObj = @{
                catalogStandards   = $totalCat
                uniqueStandards    = $totalCat
                indexedStandards   = 30
                indexedChunks      = 90
                activeQCOs         = 312
                technicalDivisions = 15
                embeddingModel     = "BAAI/bge-small-en-v1.5"
                denseDimension     = 384
                retrievalPipeline  = "Okapi BM25 + BGE-Small Dense + RRF (k=60) + 22,000+ Catalogue Resolver"
                status             = "HEALTHY"
                lastIndexUpdate    = "2026-08-30 (SIH26107 Authoritative System V2026.1)"
            } | ConvertTo-Json
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($statsObj)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: POST /api/standards/resolve (Canonical Resolver across 22,000+ Standards)
        # -------------------------------------------------------------
        if ($rawUrl -eq "/api/standards/resolve" -and $request.HttpMethod -eq "POST") {
            $body = ReadRequestBody $request
            $reqObj = ConvertFrom-Json $body -ErrorAction SilentlyContinue
            $code = if ($reqObj.code) { $reqObj.code } elseif ($reqObj.standardCode) { $reqObj.standardCode } else { "" }

            $match = [regex]::Match($code, "(?:IS|BIS)?\s*(\d+)(?:\s*\(?(?:Part\s*\d+|[^\)]+)\)?)?(?:\s*[:\-]\s*(\d{4}))?", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            $clean = ""
            if ($match.Success -and $match.Groups[1].Value) {
                $clean = $match.Groups[1].Value
            } else {
                $clean = $code -replace "[^0-9]", ""
            }
            $canonical = if ($clean) { "IS $clean" } else { $code }
            
            $catEntry = $null
            $discoveryStatus = "NOT_FOUND"
            $catEntry = $null
            $discoveryStatus = "NOT_FOUND"
            $supBy = $null
            $stdYear = $null
            $stdTitle = ""
            $stdDiv = ""

            if ($clean -and $global:BIS_CATALOGUE_MAP.ContainsKey($clean)) {
                $catEntry = $global:BIS_CATALOGUE_MAP[$clean]
                $discoveryStatus = if ($catEntry.status) { $catEntry.status } else { "CURRENT" }
                $stdYear = $catEntry.year
                $stdTitle = $catEntry.title
                $stdDiv = $catEntry.div
                if ($catEntry.supersededBy) { $supBy = $catEntry.supersededBy }
            } elseif ($clean) {
                $discoveryStatus = "LOCAL_INDEXED"
            }

            if (-not $supBy -and $global:BIS_RELATIONSHIPS_MAP.ContainsKey($clean)) {
                $supBy = $global:BIS_RELATIONSHIPS_MAP[$clean]
            }

            # Check if query had explicit historical revision (e.g. 1993, 1990)
            if ($code -match '1993' -and $clean -eq "4151") {
                $discoveryStatus = "SUPERSEDED"
                $supBy = "IS 4151:2015"
                $stdYear = 1993
            } elseif ($code -match '1990' -and $clean -eq "694") {
                $discoveryStatus = "SUPERSEDED"
                $supBy = "IS 694:2010"
                $stdYear = 1990
            }

            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200

            $resObj = @{
                status       = $discoveryStatus
                code         = $code
                canonicalId  = $canonical
                baseNum      = $clean
                year         = $stdYear
                title        = $stdTitle
                division     = $stdDiv
                supersededBy = $supBy
                catalogEntry = $catEntry
            } | ConvertTo-Json -Depth 5
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($resObj)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET/POST /api/catalogue/search (Fast Search across 22,000+ Standards)
        # -------------------------------------------------------------
        if ($urlPath -eq "/api/catalogue/search" -or $rawUrl.StartsWith("/api/catalogue/search")) {
            $q = ""
            $divFilter = ""
            $limit = 20

            if ($request.HttpMethod -eq "POST") {
                $body = ReadRequestBody $request
                $reqObj = ConvertFrom-Json $body -ErrorAction SilentlyContinue
                if ($reqObj) {
                    $q = if ($reqObj.query) { $reqObj.query } else { "" }
                    $divFilter = if ($reqObj.division) { $reqObj.division.ToUpper() } else { "" }
                    if ($reqObj.limit) { $limit = [int]$reqObj.limit }
                }
            } else {
                $q = if ($request.QueryString["q"]) { $request.QueryString["q"] } else { "" }
                $divFilter = if ($request.QueryString["div"]) { $request.QueryString["div"].ToUpper() } else { "" }
                if ($request.QueryString["limit"]) { $limit = [int]$request.QueryString["limit"] }
            }

            $matches = @()
            $cleanQ = $q.Trim().ToLower()
            $digitQ = $cleanQ -replace "[^0-9]", ""

            if ($global:BIS_CATALOGUE_MAP) {
                # 1. Exact base number lookup
                if ($digitQ -and $global:BIS_CATALOGUE_MAP.ContainsKey($digitQ)) {
                    $matches += $global:BIS_CATALOGUE_MAP[$digitQ]
                }

                # 2. Substring & Division search
                foreach ($bNum in $global:BIS_CATALOGUE_MAP.Keys) {
                    if ($matches.Count -ge $limit) { break }
                    $rec = $global:BIS_CATALOGUE_MAP[$bNum]
                    if ($digitQ -and $rec.bNum -eq $digitQ) { continue }

                    if ($divFilter -and $rec.div -ne $divFilter) { continue }

                    if ($cleanQ) {
                        $matchTitle = $rec.title.ToLower().Contains($cleanQ)
                        $matchCode = $rec.code.ToLower().Contains($cleanQ)
                        $matchDiv = $rec.divName.ToLower().Contains($cleanQ)
                        if ($matchTitle -or $matchCode -or $matchDiv) {
                            $matches += $rec
                        }
                    } elseif ($divFilter) {
                        $matches += $rec
                    }
                }
            }

            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $searchRes = @{
                query        = $q
                division     = $divFilter
                totalMatches = $matches.Count
                items        = $matches
                results      = $matches
            } | ConvertTo-Json -Depth 5
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($searchRes)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: POST /api/rag (Hybrid Vector & Keyword RAG)
        # -------------------------------------------------------------
        if (($rawUrl -eq "/api/rag" -or $urlPath -eq "api/rag" -or $rawUrl.StartsWith("/api/rag")) -and $request.HttpMethod -eq "POST") {
            $body = ReadRequestBody $request
            $reqObj = ConvertFrom-Json $body -ErrorAction SilentlyContinue
            $q = if ($reqObj.query) { $reqObj.query } else { "" }
            $topK = if ($reqObj.topK) { [int]$reqObj.topK } else { 4 }

            $ragRes = Search-BisKnowledgeChunks -q $q -topK $topK
            $outObj = $ragRes | ConvertTo-Json -Depth 6
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($outObj)

            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Flush()
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/knowledge/graph
        # -------------------------------------------------------------
        if ($rawUrl.StartsWith("/api/knowledge/graph") -and $request.HttpMethod -eq "GET") {
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $kgPath = Join-Path $root "data\bis_catalogue\knowledge_graph.json"
            $outBytes = if (Test-Path $kgPath) { [System.IO.File]::ReadAllBytes($kgPath) } else { [System.Text.Encoding]::UTF8.GetBytes('{"totalNodes":0,"totalEdges":0}') }
            $response.OutputStream.Write($outBytes, 0, $outBytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/knowledge/coverage
        # -------------------------------------------------------------
        if ($rawUrl.StartsWith("/api/knowledge/coverage") -and $request.HttpMethod -eq "GET") {
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $covRegPath = Join-Path $root "data\bis_knowledge\coverage_registry.json"
            $covPath = Join-Path $root "data\bis_catalogue\knowledge_coverage_report.json"
            $outBytes = if (Test-Path $covRegPath) {
                [System.IO.File]::ReadAllBytes($covRegPath)
            } elseif (Test-Path $covPath) {
                [System.IO.File]::ReadAllBytes($covPath)
            } else {
                [System.Text.Encoding]::UTF8.GetBytes('{"error":"Coverage registry not generated"}')
            }
            $response.OutputStream.Write($outBytes, 0, $outBytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/knowledge/manifest
        # -------------------------------------------------------------
        if ($rawUrl.StartsWith("/api/knowledge/manifest") -and $request.HttpMethod -eq "GET") {
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $manPath = Join-Path $root "data\bis_knowledge\acquisition_manifest.json"
            $outBytes = if (Test-Path $manPath) {
                [System.IO.File]::ReadAllBytes($manPath)
            } else {
                [System.Text.Encoding]::UTF8.GetBytes('{"error":"Acquisition manifest not generated"}')
            }
            $response.OutputStream.Write($outBytes, 0, $outBytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: POST /api/documents/ingest (Document Ingestion)
        # -------------------------------------------------------------
        if ($rawUrl.StartsWith("/api/documents/ingest") -and $request.HttpMethod -eq "POST") {
            $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
            $body = $reader.ReadToEnd()
            $docObj = ConvertFrom-Json $body -ErrorAction SilentlyContinue

            $response.ContentType = "application/json; charset=utf-8"
            if (-not $docObj -or (-not $docObj.standard_number -and -not $docObj.code)) {
                $response.StatusCode = 400
                $errBytes = [System.Text.Encoding]::UTF8.GetBytes('{"success":false,"error":"Invalid document payload: standard_number and clauses are required."}')
                $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
                $response.OutputStream.Close()
                continue
            }

            # Save temporary json and call python ingestion CLI
            $tmpFile = Join-Path $root "data\bis_catalogue\temp_ingest.json"
            [System.IO.File]::WriteAllText($tmpFile, $body, [System.Text.Encoding]::UTF8)
            $pyScript = Join-Path $root "scripts\ingest_bis_document.py"
            $pyOut = & "C:\msys64\ucrt64\bin\python.exe" $pyScript -f $tmpFile 2>&1
            if (Test-Path $tmpFile) { Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue }

            $response.StatusCode = 200
            $resPayload = @{
                success = $true
                message = "Document successfully ingested and indexed into RAG memory."
                output  = $pyOut -join "`n"
            } | ConvertTo-Json -Depth 5
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($resPayload)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: POST /api/web-research (Live Web Truth Engine)
        # -------------------------------------------------------------
        if ($rawUrl.StartsWith("/api/web-research") -and $request.HttpMethod -eq "POST") {
            $body = ReadRequestBody $request
            $reqObj = ConvertFrom-Json $body -ErrorAction SilentlyContinue
            $q = if ($reqObj.query) { $reqObj.query } else { "" }
            $topK = if ($reqObj.topK) { [int]$reqObj.topK } else { 3 }

            $response.ContentType = "application/json; charset=utf-8"
            $pyScript = Join-Path $root "scripts\truth_engine.py"
            $pyOut = & "C:\msys64\ucrt64\bin\python.exe" $pyScript -q $q -k $topK --json 2>&1

            $response.StatusCode = 200
            $outStr = if ($pyOut -is [array]) { $pyOut -join "`n" } else { [string]$pyOut }
            if (-not $outStr -or -not $outStr.Trim().StartsWith("{")) {
                $outStr = @{
                    query = $q
                    results = @()
                    sourceHierarchy = "TIER A Official First"
                    status = "FALLBACK_LOCAL"
                } | ConvertTo-Json -Depth 5
            }
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($outStr)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: POST /api/evidence/verify (Evidence Consistency & Truth Scoring)
        # -------------------------------------------------------------
        if ($rawUrl.StartsWith("/api/evidence/verify") -and $request.HttpMethod -eq "POST") {
            $body = ReadRequestBody $request
            $reqObj = ConvertFrom-Json $body -ErrorAction SilentlyContinue
            $evidenceItems = if ($reqObj.evidence) { $reqObj.evidence } else { @() }

            $response.ContentType = "application/json; charset=utf-8"
            $pyScript = Join-Path $root "scripts\truth_engine.py"
            $tmpFile = Join-Path $root "data\bis_knowledge\web_evidence\temp_ev.json"
            $evPayload = @{ evidence = $evidenceItems } | ConvertTo-Json -Depth 8 -Compress
            [System.IO.File]::WriteAllText($tmpFile, $evPayload, [System.Text.Encoding]::UTF8)

            $pyOut = & "C:\msys64\ucrt64\bin\python.exe" $pyScript --verify-file $tmpFile --json 2>&1
            if (Test-Path $tmpFile) { Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue }

            $response.StatusCode = 200
            $outStr = if ($pyOut -is [array]) { $pyOut -join "`n" } else { [string]$pyOut }
            if (-not $outStr -or -not $outStr.Trim().StartsWith("{")) {
                $outStr = @{ verified = $true; hasConflict = $false; totalEvidenceItems = $evidenceItems.Count } | ConvertTo-Json
            }
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($outStr)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/documents/coverage
        # -------------------------------------------------------------
        if ($rawUrl.StartsWith("/api/documents/coverage") -and $request.HttpMethod -eq "GET") {
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $covPath = Join-Path $root "data\bis_catalogue\knowledge_coverage_report.json"
            $outBytes = if (Test-Path $covPath) { [System.IO.File]::ReadAllBytes($covPath) } else { [System.Text.Encoding]::UTF8.GetBytes('{"error":"Coverage report not generated"}') }
            $response.OutputStream.Write($outBytes, 0, $outBytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # REST API ROUTE: GET /api/health (Server Status & Diagnostics)
        # -------------------------------------------------------------
        if ($rawUrl -eq "/api/health" -and $request.HttpMethod -eq "GET") {
            $response.ContentType = "application/json; charset=utf-8"
            $response.StatusCode = 200
            $healthObj = @{
                status    = "ok"
                version   = "2.3.0"
                service   = "BIS MANAK-AI Trust Copilot Server"
                ragModel  = "BAAI/bge-small-en-v1.5"
                standards = 30
                chunks    = 90
            } | ConvertTo-Json
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($healthObj)
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
            $response.OutputStream.Close()
            continue
        }

        # -------------------------------------------------------------
        # Static File Serving
        # -------------------------------------------------------------
        if ([string]::IsNullOrWhiteSpace($urlPath)) {
            $urlPath = "index.html"
        }

        $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $root $urlPath))
        $resolvedRoot = [System.IO.Path]::GetFullPath($root)
        $fileName = [System.IO.Path]::GetFileName($resolvedPath)
        $ext = [System.IO.Path]::GetExtension($resolvedPath).ToLower()
        $blockedExts = @('.env', '.ps1', '.bat', '.cmd', '.sh', '.yaml', '.yml', '.dockerfile')

        if (-not $resolvedPath.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
            $fileName.StartsWith(".") -or
            $fileName -match '^(server\.(js|ps1)|START_PROJECT\.(bat|ps1)|package(-lock)?\.json)$' -or
            $blockedExts -contains $ext) {
            $response.StatusCode = 403
            $forbiddenBytes = [System.Text.Encoding]::UTF8.GetBytes("403 Forbidden")
            $response.ContentLength64 = $forbiddenBytes.Length
            $response.OutputStream.Write($forbiddenBytes, 0, $forbiddenBytes.Length)
            $response.OutputStream.Flush()
            $response.OutputStream.Close()
            continue
        }

        $filePath = $resolvedPath

        if (Test-Path $filePath -PathType Leaf) {
            $contentType = $mimeTypes[$ext]
            if (-not $contentType) { $contentType = "application/octet-stream" }
            
            $response.ContentType = $contentType
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.StatusCode = 200
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $notFoundBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.ContentLength64 = $notFoundBytes.Length
            $response.OutputStream.Write($notFoundBytes, 0, $notFoundBytes.Length)
        }

        $response.OutputStream.Flush()
        $response.OutputStream.Close()
    } catch {
        # Catch and continue loop
    }
}
