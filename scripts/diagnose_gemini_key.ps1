$key = $env:GEMINI_API_KEY
if (-not $key -and (Test-Path "$PSScriptRoot\..\.env")) {
    Get-Content "$PSScriptRoot\..\.env" | ForEach-Object {
        if ($_ -match "^GEMINI_API_KEY=(.+)$") { $key = $matches[1].Trim() }
    }
}
if (-not $key) {
    Write-Warning "GEMINI_API_KEY is not set in environment or .env"
    exit 1
}

Write-Host "=== DIAGNOSING GOOGLE GEMINI AQ-PREFIXED API KEY ===" -ForegroundColor Cyan

$testEndpoints = @(
    # 1. v1beta with x-goog-api-key header
    @{
        Name = "v1beta / gemini-1.5-flash [x-goog-api-key header]"
        Uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
        Headers = @{ "x-goog-api-key" = $key; "Content-Type" = "application/json" }
        Body = '{"contents":[{"parts":[{"text":"Hi"}]}]}'
    },
    # 2. v1 with x-goog-api-key header
    @{
        Name = "v1 / gemini-1.5-flash [x-goog-api-key header]"
        Uri = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent"
        Headers = @{ "x-goog-api-key" = $key; "Content-Type" = "application/json" }
        Body = '{"contents":[{"parts":[{"text":"Hi"}]}]}'
    },
    # 3. v1beta gemini-2.0-flash [x-goog-api-key]
    @{
        Name = "v1beta / gemini-2.0-flash [x-goog-api-key header]"
        Uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
        Headers = @{ "x-goog-api-key" = $key; "Content-Type" = "application/json" }
        Body = '{"contents":[{"parts":[{"text":"Hi"}]}]}'
    },
    # 4. v1beta query param ?key=
    @{
        Name = "v1beta / gemini-1.5-flash [?key= query param]"
        Uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key"
        Headers = @{ "Content-Type" = "application/json" }
        Body = '{"contents":[{"parts":[{"text":"Hi"}]}]}'
    },
    # 5. OpenAI-compatible with x-goog-api-key
    @{
        Name = "OpenAI-compatible [x-goog-api-key header]"
        Uri = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
        Headers = @{ "x-goog-api-key" = $key; "Authorization" = "Bearer $key"; "Content-Type" = "application/json" }
        Body = '{"model":"gemini-1.5-flash","messages":[{"role":"user","content":"Hi"}]}'
    },
    # 6. List Models with x-goog-api-key header
    @{
        Name = "List Models (v1beta) [x-goog-api-key header]"
        Uri = "https://generativelanguage.googleapis.com/v1beta/models"
        Headers = @{ "x-goog-api-key" = $key }
        Method = "GET"
    }
)

foreach ($test in $testEndpoints) {
    Write-Host "`n--- Testing: $($test.Name) ---" -ForegroundColor Yellow
    try {
        $method = if ($test.Method) { $test.Method } else { "POST" }
        $params = @{
            Uri = $test.Uri
            Method = $method
            Headers = $test.Headers
            TimeoutSec = 10
        }
        if ($test.Body) {
            $params["Body"] = $test.Body
        }
        $resp = Invoke-RestMethod @params
        Write-Host "✅ SUCCESS!" -ForegroundColor Green
        Write-Host ($resp | ConvertTo-Json -Depth 3)
    } catch {
        Write-Host "❌ FAILED with Status:" $_.Exception.Response.StatusCode.value__ -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Error Details: " $_.ErrorDetails.Message -ForegroundColor DarkYellow
        }
        if ($_.Exception.Response) {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Raw Response Body: " $responseBody -ForegroundColor Magenta
        }
    }
}
