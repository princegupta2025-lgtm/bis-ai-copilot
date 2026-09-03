$queries = @(
    "hi",
    "What are the mandatory testing requirements for IS 4151 helmets?",
    "Explain IS 14543 for bottled drinking water"
)

foreach ($q in $queries) {
    Write-Host "`n================================================="
    Write-Host "USER QUERY: '$q'"
    Write-Host "================================================="

    $chatBody = @{
        model = "qwen/qwen3.8-27b"
        messages = @(
            @{
                role = "system"
                content = "You are MANAK-AI, the official Bureau of Indian Standards Trust Copilot."
            },
            @{
                role = "user"
                content = $q
            }
        )
        temperature = 0.12
        max_tokens = 150
        stream = $true
    } | ConvertTo-Json -Depth 5

    $httpReq = [System.Net.HttpWebRequest]::Create("http://localhost:8000/api/chat")
    $httpReq.Method = "POST"
    $httpReq.ContentType = "application/json"
    $httpReq.UserAgent = "BIS-Trust-Copilot/2.3"
    $httpReq.Timeout = 25000

    $postBytes = [System.Text.Encoding]::UTF8.GetBytes($chatBody)
    $httpReq.ContentLength = $postBytes.Length
    $reqStream = $httpReq.GetRequestStream()
    $reqStream.Write($postBytes, 0, $postBytes.Length)
    $reqStream.Close()

    $httpResp = $httpReq.GetResponse()
    $sr = New-Object System.IO.StreamReader($httpResp.GetResponseStream(), [System.Text.Encoding]::UTF8)
    $responseTokens = ""
    while (-not $sr.EndOfStream) {
        $line = $sr.ReadLine()
        if ($line.StartsWith("data: ") -and $line -notmatch "\[DONE\]") {
            $jsonStr = $line.Substring(6)
            $parsed = ConvertFrom-Json $jsonStr -ErrorAction SilentlyContinue
            if ($parsed.choices[0].delta.content) {
                $responseTokens += $parsed.choices[0].delta.content
            }
        }
    }
    $sr.Close()
    $httpResp.Close()

    Write-Host "AI STREAMED RESPONSE:`n$responseTokens"
}
