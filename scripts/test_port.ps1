$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:8000/")
$l.Prefixes.Add("http://127.0.0.1:8000/")
try {
    $l.Start()
    Write-Host "SUCCESS: Port 8000 binds cleanly without admin!"
    $l.Stop()
    $l.Close()
} catch {
    Write-Host "Port 8000 error: $($_.Exception.Message)"
}
