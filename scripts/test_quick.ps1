[System.Net.ServicePointManager]::Expect100Continue = $false
[System.Net.ServicePointManager]::DefaultConnectionLimit = 50

try {
    $h = Invoke-RestMethod -Uri 'http://localhost:8000/api/health' -Method Get -TimeoutSec 3
    Write-Host "Health Status: $($h.status), Standards: $($h.standards), Taxonomy: $($h.taxonomyCount)"

    $jsonStr = @{ query = 'What are helmet shock absorption limits in IS 4151?' } | ConvertTo-Json
    $postBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonStr)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $r = Invoke-RestMethod -Uri 'http://localhost:8000/api/rag' -Method Post -Body $postBytes -ContentType 'application/json; charset=utf-8' -TimeoutSec 5
    $sw.Stop()
    Write-Host "RAG Top Standard: $($r.results[0].chunk.standardCode), Score: $($r.results[0].score), Latency: $($sw.ElapsedMilliseconds)ms"
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
