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

$tests = @(
    @{
        Name = "v1beta / gemini-2.0-flash with x-goog-api-key"
        Uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
        Headers = @{ "x-goog-api-key" = $key; "Content-Type" = "application/json" }
        Body = '{"contents":[{"parts":[{"text":"Say hello in 3 words"}]}]}'
    },
    @{
        Name = "v1beta / gemini-1.5-flash with x-goog-api-key"
        Uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
        Headers = @{ "x-goog-api-key" = $key; "Content-Type" = "application/json" }
        Body = '{"contents":[{"parts":[{"text":"Say hello in 3 words"}]}]}'
    },
    @{
        Name = "v1beta / gemini-2.5-flash with x-goog-api-key"
        Uri = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
        Headers = @{ "x-goog-api-key" = $key; "Content-Type" = "application/json" }
        Body = '{"contents":[{"parts":[{"text":"Say hello in 3 words"}]}]}'
    },
    @{
        Name = "OpenAI-compatible / gemini-2.0-flash with x-goog-api-key & Bearer"
        Uri = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
        Headers = @{ "x-goog-api-key" = $key; "Authorization" = "Bearer $key"; "Content-Type" = "application/json" }
        Body = '{"model":"gemini-2.0-flash","messages":[{"role":"user","content":"Say hello in 3 words"}]}'
    }
)

foreach ($t in $tests) {
    Write-Host "Testing $($t.Name)..." -NoNewline
    try {
        $resp = Invoke-RestMethod -Uri $t.Uri -Method Post -Headers $t.Headers -Body $t.Body -TimeoutSec 15
        Write-Host " -> SUCCESS! " -ForegroundColor Green
        if ($resp.candidates) {
            Write-Host "Response:" $resp.candidates[0].content.parts[0].text
        } elseif ($resp.choices) {
            Write-Host "Response:" $resp.choices[0].message.content
        }
    } catch {
        Write-Host " -> FAILED ($($_.Exception.Response.StatusCode.value__))" -ForegroundColor Red
        if ($_.Exception.Response) {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Details: $responseBody" -ForegroundColor DarkYellow
        }
    }
}
