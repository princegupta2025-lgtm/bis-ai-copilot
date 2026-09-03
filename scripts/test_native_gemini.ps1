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

$body = '{"contents":[{"parts":[{"text":"Explain what IS 1786 covers in 1 sentence."}]}]}'
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent"
$headers = @{
    "x-goog-api-key" = $key
    "Content-Type" = "application/json"
}

$resp = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -TimeoutSec 15
Write-Host "Native Gemini generateContent Result:" -ForegroundColor Green
$resp.candidates[0].content.parts[0].text
