# Test HttpListener POST reading in PowerShell
[System.Net.ServicePointManager]::Expect100Continue = $false
[System.Net.ServicePointManager]::DefaultConnectionLimit = 50

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8899/")
$listener.Start()
Write-Host "Test Listener started on 8899"

$job = Start-Job -ScriptBlock {
    [System.Net.ServicePointManager]::Expect100Continue = $false
    Start-Sleep -Milliseconds 200
    $body = @{ test = "hello from client" } | ConvertTo-Json
    $res = Invoke-RestMethod -Uri "http://localhost:8899/api/test" -Method Post -Body $body -ContentType "application/json; charset=utf-8" -TimeoutSec 5
    return $res
}

$context = $listener.GetContext()
$req = $context.Request
$resp = $context.Response

$bodyStr = ""
$len = [int]$req.ContentLength64
Write-Host "Received Request! ContentLength64: $len"
if ($len -gt 0) {
    $buffer = New-Object byte[] $len
    $read = $req.InputStream.Read($buffer, 0, $len)
    $bodyStr = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $read)
    Write-Host "Read Body ($read bytes): $bodyStr"
}

$respObj = @{ received = $bodyStr; status = "OK" } | ConvertTo-Json
$respBytes = [System.Text.Encoding]::UTF8.GetBytes($respObj)
$resp.ContentType = "application/json; charset=utf-8"
$resp.ContentLength64 = $respBytes.Length
$resp.StatusCode = 200
$resp.OutputStream.Write($respBytes, 0, $respBytes.Length)
$resp.OutputStream.Flush()
$resp.Close()
$listener.Stop()

$jobResult = Receive-Job -Job $job -Wait
Write-Host "Job Result: $($jobResult | ConvertTo-Json)"
