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

Write-Host "Testing Native Gemini endpoint..." -ForegroundColor Cyan
try {
    $body1 = '{"contents":[{"parts":[{"text":"Hello from BIS Copilot! Respond in one short sentence."}]}]}'
    $url1 = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$key"
    $res1 = Invoke-RestMethod -Uri $url1 -Method Post -Body $body1 -ContentType "application/json" -TimeoutSec 15
    Write-Host "✅ Native Gemini Status: OK" -ForegroundColor Green
    Write-Host "Response: " $res1.candidates[0].content.parts[0].text
} catch {
    Write-Host "❌ Native Gemini Error: " $_.Exception.Message -ForegroundColor Red
}

Write-Host "`nTesting OpenAI-compatible Gemini endpoint..." -ForegroundColor Cyan
try {
    $body2 = '{"model":"gemini-1.5-flash","messages":[{"role":"user","content":"Hello from BIS Copilot!"}]}'
    $url2 = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
    $headers = @{ "Authorization" = "Bearer $key" }
    $res2 = Invoke-RestMethod -Uri $url2 -Method Post -Headers $headers -Body $body2 -ContentType "application/json" -TimeoutSec 15
    Write-Host "✅ OpenAI-compatible Status: OK" -ForegroundColor Green
    Write-Host "Response: " $res2.choices[0].message.content
} catch {
    Write-Host "❌ OpenAI-compatible Error: " $_.Exception.Message -ForegroundColor Red
}
