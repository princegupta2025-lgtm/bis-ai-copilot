Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  BIS AI ASSISTANT GOOGLE GEMINI AUDIT" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$envFile = Join-Path $PSScriptRoot "..\.env"
$geminiKey = ""

if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line.StartsWith("GEMINI_API_KEY=")) { $geminiKey = $line.Substring(15).Trim() }
    }
}

Write-Host "`n1. Testing Google Gemini (gemini-3.6-flash)..." -ForegroundColor Yellow
if ($geminiKey) {
    try {
        $body = '{"model":"gemini-3.6-flash","messages":[{"role":"user","content":"What is IS 4151? Answer in 1 concise line."}]}'
        $headers = @{
            "x-goog-api-key" = $geminiKey
            "Authorization" = "Bearer $geminiKey"
            "Content-Type" = "application/json"
        }
        $resp = Invoke-RestMethod -Uri "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions" -Method Post -Headers $headers -Body $body -TimeoutSec 15
        Write-Host "   [OK] GEMINI STATUS: ONLINE AND WORKING!" -ForegroundColor Green
        Write-Host "   AI Response: " $resp.choices[0].message.content -ForegroundColor Cyan
    } catch {
        Write-Host "   [FAIL] GEMINI FAILED: " $_.Exception.Message -ForegroundColor Red
    }
} else {
    Write-Host "   [WARN] GEMINI_API_KEY is not set in .env." -ForegroundColor DarkYellow
}

Write-Host "`n==========================================" -ForegroundColor Cyan
