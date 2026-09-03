$tunnelUrl = "https://list-sensitivity-authorized-book.trycloudflare.com"
Write-Host "Testing Public Cloudflare Tunnel: $tunnelUrl"

try {
    $r = Invoke-WebRequest -Uri "$tunnelUrl/" -UseBasicParsing -TimeoutSec 15
    Write-Host "Public URL Status: $($r.StatusCode)"
    Write-Host "Contains BIS MANAK-AI: $($r.Content.Contains('BIS MANAK-AI'))"
} catch {
    Write-Host "Tunnel request error: $_"
}

# Test chat page
try {
    $r = Invoke-WebRequest -Uri "$tunnelUrl/chat.html" -UseBasicParsing -TimeoutSec 15
    Write-Host "Public Chat Page Status: $($r.StatusCode)"
} catch {
    Write-Host "Chat page request error: $_"
}

# Test stats API
try {
    $res = Invoke-RestMethod -Uri "$tunnelUrl/api/stats" -Method Get -TimeoutSec 15
    Write-Host "Public Stats API Status: $($res.status) (Standards: $($res.catalogStandards))"
} catch {
    Write-Host "Public Stats API Notice: $_"
}
