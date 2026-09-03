$tunnel = "https://forums-summary-worldwide-spiritual.trycloudflare.com"
Write-Host "Verifying Live Public Cloudflare Tunnel: $tunnel"

try {
    $r = Invoke-WebRequest -Uri "$tunnel/standalone_app.html" -UseBasicParsing -TimeoutSec 15
    Write-Host "Public Standalone App: Status $($r.StatusCode) - Size $($r.RawContentLength) bytes"
} catch {
    Write-Host "Standalone App Notice: $_"
}

try {
    $rChat = Invoke-WebRequest -Uri "$tunnel/chat.html" -UseBasicParsing -TimeoutSec 15
    Write-Host "Public Chat App: Status $($rChat.StatusCode)"
} catch {
    Write-Host "Chat App Notice: $_"
}

try {
    $rApi = Invoke-RestMethod -Uri "$tunnel/api/verify/huid?code=AB8492" -TimeoutSec 15
    Write-Host "Public HUID API: Status $($rApi.status) - Jeweller: $($rApi.jeweller)"
} catch {
    Write-Host "HUID API Notice: $_"
}
