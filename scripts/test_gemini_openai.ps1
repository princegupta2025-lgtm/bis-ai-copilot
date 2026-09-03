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

Write-Host "Testing OpenAI-compatible endpoint with gemini-3.6-flash..." -NoNewline
try {
    $body = '{"model":"gemini-3.6-flash","messages":[{"role":"user","content":"Hello from BIS Trust Copilot! Reply in 5 words."}]}'
    $url = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
    $headers = @{
        "x-goog-api-key" = $key
        "Authorization" = "Bearer $key"
        "Content-Type" = "application/json"
    }
    $resp = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -TimeoutSec 15
    Write-Host " -> ✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Response: " $resp.choices[0].message.content -ForegroundColor Cyan
} catch {
    Write-Host " -> ❌ FAILED ($($_.Exception.Response.StatusCode.value__))" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Details: $responseBody" -ForegroundColor DarkYellow
    }
}
