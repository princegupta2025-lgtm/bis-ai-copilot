Write-Host "================================================="
Write-Host "  TESTING LIVE BIS AI SERVER ON PORTS 8000 & 8080"
Write-Host "================================================="

$ports = @(8000, 8080)
$allPassed = $true

foreach ($p in $ports) {
    $baseUrl = "http://localhost:$p"
    Write-Host "`n>>> Testing Server on $baseUrl..."
    
    # 1. Static Home Page
    try {
        $res = Invoke-WebRequest -Uri "$baseUrl/" -UseBasicParsing -TimeoutSec 5
        if ($res.StatusCode -eq 200 -and $res.Content.Contains("BIS MANAK-AI")) {
            Write-Host "  [PASS] Static Home Page (GET $baseUrl/) is LIVE (200 OK)"
        } else {
            Write-Host "  [FAIL] Static Home Page returned status: $($res.StatusCode)"
            $allPassed = $false
        }
    } catch {
        Write-Host "  [FAIL] Static Home Page error: $_"
        $allPassed = $false
    }

    # 2. Chat Page
    try {
        $res = Invoke-WebRequest -Uri "$baseUrl/chat.html" -UseBasicParsing -TimeoutSec 5
        if ($res.StatusCode -eq 200 -and $res.Content.Contains("chatMessages")) {
            Write-Host "  [PASS] Chat Interface (GET $baseUrl/chat.html) is LIVE (200 OK)"
        } else {
            Write-Host "  [FAIL] Chat Interface returned status: $($res.StatusCode)"
            $allPassed = $false
        }
    } catch {
        Write-Host "  [FAIL] Chat Interface error: $_"
        $allPassed = $false
    }

    # 3. CML Verification
    try {
        $res = Invoke-RestMethod -Uri "$baseUrl/api/verify/cml?number=7308812" -Method Get -TimeoutSec 5
        if ($res.cml -eq "7308812" -and $res.status -eq "ACTIVE") {
            Write-Host "  [PASS] CML Verification: $($res.status) - $($res.manufacturer)"
        } else {
            Write-Host "  [FAIL] CML Verification unexpected: $($res | ConvertTo-Json -Compress)"
            $allPassed = $false
        }
    } catch {
        Write-Host "  [FAIL] CML Verification error: $_"
        $allPassed = $false
    }

    # 4. HUID Verification
    try {
        $res = Invoke-RestMethod -Uri "$baseUrl/api/verify/huid?code=AB8492" -Method Get -TimeoutSec 5
        if ($res.huid -eq "AB8492" -and $res.status -eq "VERIFIED") {
            Write-Host "  [PASS] HUID Verification: $($res.status) - $($res.purity) - $($res.jeweller)"
        } else {
            Write-Host "  [FAIL] HUID Verification unexpected: $($res | ConvertTo-Json -Compress)"
            $allPassed = $false
        }
    } catch {
        Write-Host "  [FAIL] HUID Verification error: $_"
        $allPassed = $false
    }
}

# Test AI Chat stream on port 8000
Write-Host "`n>>> Testing Live AI Chat Stream via Groq (port 8000)..."
try {
    $chatBody = @{
        model = "qwen/qwen3.8-27b"
        messages = @(
            @{ role = "system"; content = "You are the Bureau of Indian Standards assistant." },
            @{ role = "user"; content = "What is IS 4151?" }
        )
        temperature = 0.1
        max_tokens = 60
        stream = $true
    } | ConvertTo-Json -Depth 5

    $httpReq = [System.Net.HttpWebRequest]::Create("http://localhost:8000/api/chat")
    $httpReq.Method = "POST"
    $httpReq.ContentType = "application/json"
    $httpReq.Timeout = 20000

    $postBytes = [System.Text.Encoding]::UTF8.GetBytes($chatBody)
    $httpReq.ContentLength = $postBytes.Length
    $reqStream = $httpReq.GetRequestStream()
    $reqStream.Write($postBytes, 0, $postBytes.Length)
    $reqStream.Close()

    $httpResp = $httpReq.GetResponse()
    $sr = New-Object System.IO.StreamReader($httpResp.GetResponseStream(), [System.Text.Encoding]::UTF8)
    $tokenCount = 0
    $sampleTokens = ""
    while (-not $sr.EndOfStream) {
        $line = $sr.ReadLine()
        if ($line.StartsWith("data: ") -and $line -notmatch "\[DONE\]") {
            $tokenCount++
            $jsonStr = $line.Substring(6)
            $parsed = ConvertFrom-Json $jsonStr -ErrorAction SilentlyContinue
            if ($parsed.choices[0].delta.content) {
                $sampleTokens += $parsed.choices[0].delta.content
            }
        }
        if ($tokenCount -gt 15) { break }
    }
    $sr.Close()
    $httpResp.Close()

    if ($tokenCount -gt 0) {
        Write-Host "  [PASS] AI Chat Stream: Received $tokenCount live SSE tokens from Groq!"
        Write-Host "  Sample snippet: $sampleTokens"
    } else {
        Write-Host "  [FAIL] AI Chat Stream received no tokens"
        $allPassed = $false
    }
} catch {
    Write-Host "  [FAIL] AI Chat stream error: $_"
    $allPassed = $false
}

# Test Public Cloudflare Tunnel
$tunnelUrl = "https://formerly-catalogue-sub-epson.trycloudflare.com"
Write-Host "`n>>> Testing Public Cloudflare Tunnel ($tunnelUrl)..."
try {
    $r = Invoke-WebRequest -Uri "$tunnelUrl/" -UseBasicParsing -TimeoutSec 15
    if ($r.StatusCode -eq 200 -and $r.Content.Contains("BIS MANAK-AI")) {
        Write-Host "  [PASS] Public Tunnel is LIVE (200 OK)"
    } else {
        Write-Host "  [FAIL] Public Tunnel returned status: $($r.StatusCode)"
        $allPassed = $false
    }
} catch {
    Write-Host "  [FAIL] Public Tunnel error: $_"
    $allPassed = $false
}

Write-Host "`n================================================="
if ($allPassed) {
    Write-Host "  >>> ALL LIVE SERVER & AI STREAM TESTS PASSED! <<<"
} else {
    Write-Host "  >>> SOME TESTS FAILED <<<"
}
Write-Host "================================================="
