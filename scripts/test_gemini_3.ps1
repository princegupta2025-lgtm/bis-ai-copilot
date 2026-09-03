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

$models = @("gemini-3.6-flash", "gemini-3.5-flash", "gemini-2.5-flash-latest", "gemini-2.5-pro", "gemini-3.0-flash", "gemini-3.6-pro")

foreach ($m in $models) {
    Write-Host "Testing model: $m with x-goog-api-key..." -NoNewline
    try {
        $body = '{"contents":[{"parts":[{"text":"Hello from BIS Trust Copilot! Reply in 5 words."}]}]}'
        $url = "https://generativelanguage.googleapis.com/v1beta/models/${m}:generateContent"
        $headers = @{ "x-goog-api-key" = $key; "Content-Type" = "application/json" }
        $resp = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -TimeoutSec 15
        Write-Host " -> ✅ SUCCESS!" -ForegroundColor Green
        Write-Host "Response: " $resp.candidates[0].content.parts[0].text -ForegroundColor Cyan
    } catch {
        Write-Host " -> ❌ FAILED ($($_.Exception.Response.StatusCode.value__))" -ForegroundColor Red
        if ($_.Exception.Response) {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "Details: $responseBody" -ForegroundColor DarkYellow
        }
    }
}
