$envLines = Get-Content ".env"
$key = ""
foreach ($line in $envLines) {
    if ($line.StartsWith("GROQ_API_KEY=")) {
        $key = $line.Substring(13).Trim()
    }
}

Write-Host "Groq Key found: $($key.Length > 0)"
if (-not $key) {
    Write-Host "No key found in .env"
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $key"
    "Content-Type" = "application/json"
}

try {
    $modelsResp = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/models" -Headers $headers -Method Get
    Write-Host "`n=== ACTIVE GROQ MODELS ==="
    foreach ($m in $modelsResp.data) {
        Write-Host " - $($m.id)"
    }
} catch {
    Write-Host "Error querying models: $_"
}

# Test chat completion with llama-3.3-70b-versatile or llama-3.1-8b-instant
$testModels = @("llama-3.3-70b-versatile", "llama-3.1-8b-instant", "qwen/qwen3.8-27b", "llama3-70b-8192", "mixtral-8x7b-32768")
foreach ($tmod in $testModels) {
    Write-Host "`nTesting completion with model: $tmod..."
    $body = @{
        model = $tmod
        messages = @(
            @{
                role = "system"
                content = "You are a helpful assistant for Bureau of Indian Standards."
            },
            @{
                role = "user"
                content = "What is BIS standard for packaged drinking water?"
            }
        )
        max_tokens = 100
        temperature = 0.2
    } | ConvertTo-Json -Depth 5

    try {
        $chatResp = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" -Headers $headers -Method Post -Body $body
        Write-Host ">>> SUCCESS with $tmod!"
        Write-Host "Response snippet: $($chatResp.choices[0].message.content.Substring(0, [Math]::Min(150, $chatResp.choices[0].message.content.Length)))"
    } catch {
        Write-Host ">>> FAILED with $tmod : $($_.Exception.Message)"
    }
}
