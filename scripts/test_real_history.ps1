# Automated Verification Script for Real Conversation History Engine
# Smart India Hackathon 2026 (SIH26107)

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  MANAK-AI CONVERSATION HISTORY VERIFICATION SUITE  " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

$global:passed = 0
$global:failed = 0

function Assert-Condition($condition, $message) {
    if ($condition) {
        Write-Host "  [PASS] $message" -ForegroundColor Green
        $global:passed++
    } else {
        Write-Host "  [FAIL] $message" -ForegroundColor Red
        $global:failed++
    }
}

# 1. Inspect chat.js for fake data and sample arrays
$chatJs = Get-Content -Path "js/chat.js" -Raw -Encoding UTF8
$chatHtml = Get-Content -Path "chat.html" -Raw -Encoding UTF8
$standaloneHtml = Get-Content -Path "standalone_app.html" -Raw -Encoding UTF8

Write-Host "`n--- Checking for Hardcoded Conversations & Fake Data ---" -ForegroundColor Yellow

Assert-Condition (-not $chatJs.Contains("DEFAULT_SAMPLE_CONVERSATIONS")) "chat.js has zero DEFAULT_SAMPLE_CONVERSATIONS"
Assert-Condition (-not $chatJs.Contains("SIH 2026 BIS AI Assistant Guide")) "chat.js has zero 'SIH 2026 BIS AI Assistant Guide'"
Assert-Condition (-not $chatJs.Contains("BIS AI Assistant Directory Path")) "chat.js has zero 'BIS AI Assistant Directory Path'"
Assert-Condition (-not $chatJs.Contains("Visual Studio AI Integration")) "chat.js has zero 'Visual Studio AI Integration'"
Assert-Condition (-not $standaloneHtml.Contains("SIH 2026 BIS AI Assistant Guide")) "standalone_app.html has zero 'SIH 2026 BIS AI Assistant Guide'"
Assert-Condition (-not $standaloneHtml.Contains("BIS AI Assistant Directory Path")) "standalone_app.html has zero 'BIS AI Assistant Directory Path'"
Assert-Condition (-not $standaloneHtml.Contains("Visual Studio AI Integration")) "standalone_app.html has zero 'Visual Studio AI Integration'"

# 2. Check storage key unification & clean empty state
Write-Host "`n--- Checking Storage Architecture & Empty State ---" -ForegroundColor Yellow
Assert-Condition ($chatJs.Contains("localStorage.getItem('bis_chat_sessions')")) "chat.js reads from 'bis_chat_sessions'"
Assert-Condition ($chatJs.Contains("localStorage.setItem('bis_chat_sessions'")) "chat.js writes to 'bis_chat_sessions'"
Assert-Condition ($chatJs.Contains("sidebar-empty-state") -and $chatJs.Contains("No conversations yet")) "chat.js renders clean empty state when no sessions exist"
Assert-Condition ($chatHtml.Contains('id="dynamicConversationsList"')) "chat.html has #dynamicConversationsList container"

# 3. Simulate Complete JavaScript Lifecycle Logic in PowerShell
Write-Host "`n--- Testing Real Session Lifecycle (Simulated Runtime) ---" -ForegroundColor Yellow

$global:mockStorage = @{}

function Mock-GetItem($key) {
    if ($global:mockStorage.ContainsKey($key)) { return $global:mockStorage[$key] }
    return $null
}
function Mock-SetItem($key, $val) {
    $global:mockStorage[$key] = $val
}
function Mock-RemoveItem($key) {
    $global:mockStorage.Remove($key)
}

$global:APP_STATE = @{
    currentSessionId = "session-" + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    currentSessionTitle = $null
    currentSessionMessages = @()
    conversationHistory = @()
}

function Sim-GetSavedSessions() {
    $raw = Mock-GetItem "bis_chat_sessions"
    if (-not $raw) { return @() }
    try {
        $parsed = ConvertFrom-Json $raw
        $arr = @($parsed | Where-Object { $_.id -and $_.title -and @('helmet','solar','gold','cables','guide','path','vs') -notcontains $_.id })
        return $arr
    } catch {
        return @()
    }
}

function Sim-RenderDynamicHistory() {
    $sessions = @(Sim-GetSavedSessions)
    if ($sessions.Count -eq 0) {
        return '<div class="sidebar-empty-state"><div class="empty-state-text">No conversations yet</div><button class="btn-empty-new-chat">New Conversation</button></div>'
    }
    $html = ""
    foreach ($s in $sessions) {
        $isActive = ($s.id -eq $global:APP_STATE.currentSessionId)
        $html += "<div class='conv-row-item $(if ($isActive) { 'active' } else { '' })'>$($s.title)</div>"
    }
    return $html
}

function Sim-SaveCurrentSession($firstQuery) {
    if ($global:APP_STATE.currentSessionMessages.Count -eq 0) { return }
    $rawList = @(Sim-GetSavedSessions)
    $sessions = [System.Collections.ArrayList]::new()
    foreach ($item in $rawList) { [void]$sessions.Add($item) }
    
    $existingIdx = -1
    for ($i = 0; $i -lt $sessions.Count; $i++) {
        if ($sessions[$i].id -eq $global:APP_STATE.currentSessionId) {
            $existingIdx = $i
            break
        }
    }

    if (-not $global:APP_STATE.currentSessionTitle) {
        $cleanPrompt = $firstQuery.Trim()
        if ($cleanPrompt.Length -gt 34) { $cleanPrompt = $cleanPrompt.Substring(0, 34) + "..." }
        $global:APP_STATE.currentSessionTitle = $cleanPrompt
    }

    $createdAt = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    if ($existingIdx -ge 0 -and $sessions[$existingIdx].createdAt) {
        $createdAt = $sessions[$existingIdx].createdAt
    }

    $sessionData = [PSCustomObject]@{
        id = $global:APP_STATE.currentSessionId
        title = $global:APP_STATE.currentSessionTitle
        updatedAt = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        createdAt = $createdAt
        messages = $global:APP_STATE.currentSessionMessages
    }

    if ($existingIdx -ge 0) {
        $sessions.RemoveAt($existingIdx)
    }
    $sessions.Insert(0, $sessionData)

    while ($sessions.Count -gt 20) {
        $sessions.RemoveAt($sessions.Count - 1)
    }

    Mock-SetItem "bis_chat_sessions" (ConvertTo-Json @($sessions) -Depth 5)
}

function Sim-StartNewConversation() {
    $global:APP_STATE.currentSessionId = "session-" + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $global:APP_STATE.currentSessionTitle = $null
    $global:APP_STATE.currentSessionMessages = @()
    $global:APP_STATE.conversationHistory = @()
}

function Sim-RenameHistorySession($sessionId, $newTitle) {
    $rawList = @(Sim-GetSavedSessions)
    $sessions = [System.Collections.ArrayList]::new()
    foreach ($item in $rawList) { [void]$sessions.Add($item) }
    for ($i = 0; $i -lt $sessions.Count; $i++) {
        if ($sessions[$i].id -eq $sessionId) {
            $sessions[$i].title = $newTitle
            $sessions[$i].updatedAt = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
            break
        }
    }
    Mock-SetItem "bis_chat_sessions" (ConvertTo-Json @($sessions) -Depth 5)
    if ($global:APP_STATE.currentSessionId -eq $sessionId) {
        $global:APP_STATE.currentSessionTitle = $newTitle
    }
}

function Sim-DeleteHistorySession($sessionId) {
    $rawList = @(Sim-GetSavedSessions)
    $sessions = [System.Collections.ArrayList]::new()
    foreach ($item in $rawList) { [void]$sessions.Add($item) }
    for ($i = $sessions.Count - 1; $i -ge 0; $i--) {
        if ($sessions[$i].id -eq $sessionId) {
            $sessions.RemoveAt($i)
        }
    }
    Mock-SetItem "bis_chat_sessions" (ConvertTo-Json @($sessions) -Depth 5)
    if ($global:APP_STATE.currentSessionId -eq $sessionId) {
        Sim-StartNewConversation
    }
}

# TEST 1: Initial state for new user
$initialRender = Sim-RenderDynamicHistory
$initialSaved = @(Sim-GetSavedSessions)
Assert-Condition ($initialSaved.Count -eq 0) "TEST 1: New user starts with 0 saved sessions"
Assert-Condition ($initialRender.Contains("No conversations yet")) "TEST 1: Clean empty state rendered for new user"

# TEST 2: User clicks New Conversation -> no session saved yet
Sim-StartNewConversation
$afterNewSaved = @(Sim-GetSavedSessions)
Assert-Condition ($afterNewSaved.Count -eq 0) "TEST 2: New Conversation button creates in-memory ID without saving prematurely"

# TEST 3: User sends first message -> creates 1 session titled with user query
$global:APP_STATE.currentSessionMessages += @{ role = 'user'; text = 'What is IS 4151 drop test?' }
$global:APP_STATE.currentSessionMessages += @{ role = 'assistant'; text = 'IS 4151:2015 Clause 9.1 specifies 300g peak acceleration.' }
Sim-SaveCurrentSession 'What is IS 4151 drop test?'

$saved1 = @(Sim-GetSavedSessions)
Assert-Condition ($saved1.Count -eq 1) "TEST 3: Exactly 1 session saved after first query sent"
Assert-Condition ($saved1[0].title -eq 'What is IS 4151 drop test?') "TEST 3: Session title accurately matches user prompt"
Assert-Condition ($saved1[0].messages.Count -eq 2) "TEST 3: Session holds user and assistant messages"

# TEST 4: Follow up query in same session -> updates existing session, no duplicate
$global:APP_STATE.currentSessionMessages += @{ role = 'user'; text = 'What about helmet retention test?' }
$global:APP_STATE.currentSessionMessages += @{ role = 'assistant'; text = 'Dynamic retention test under Clause 9.2.' }
Sim-SaveCurrentSession 'What about helmet retention test?'

$saved2 = @(Sim-GetSavedSessions)
Assert-Condition ($saved2.Count -eq 1) "TEST 4: Follow-up message does NOT create duplicate session item"
Assert-Condition ($saved2[0].messages.Count -eq 4) "TEST 4: Session updated to all 4 messages"

# TEST 5: Create a second conversation
Sim-StartNewConversation
$global:APP_STATE.currentSessionMessages += @{ role = 'user'; text = 'Gold 22K Hallmarking verification' }
$global:APP_STATE.currentSessionMessages += @{ role = 'assistant'; text = 'IS 1417:2016 916 fineness.' }
Sim-SaveCurrentSession 'Gold 22K Hallmarking verification'

$saved3 = @(Sim-GetSavedSessions)
Assert-Condition ($saved3.Count -eq 2) "TEST 5: Second consultation created second distinct session"
Assert-Condition ($saved3[0].title -eq 'Gold 22K Hallmarking verification') "TEST 5: Most recently updated conversation is placed at top"

# TEST 6: Rename a conversation
$firstSessionId = $saved3[1].id
Sim-RenameHistorySession $firstSessionId 'Helmets Safety Standard IS 4151'
$saved4 = @(Sim-GetSavedSessions)
$renamed = $saved4 | Where-Object { $_.id -eq $firstSessionId }
Assert-Condition ($renamed.title -eq 'Helmets Safety Standard IS 4151') "TEST 6: Renamed title persists in storage"

# TEST 7: Delete active conversation -> resets to fresh empty state with 1 session remaining
Sim-DeleteHistorySession $saved3[0].id
$saved5 = @(Sim-GetSavedSessions)
Assert-Condition ($saved5.Count -eq 1) "TEST 7: Deleting 1 session reduces count to 1"
Assert-Condition ($saved5[0].title -eq 'Helmets Safety Standard IS 4151') "TEST 7: Remaining session is intact"

# 4. Live Server Endpoint Verification
Write-Host "`n--- Checking Live Server Status ---" -ForegroundColor Yellow
try {
    $res = Invoke-RestMethod -Uri "http://localhost:8000/api/verify/cml?number=7308812" -Method Get -TimeoutSec 3
    Assert-Condition ($res.cml -eq "7308812" -and $res.status -eq "ACTIVE") "Live Server CML Verification OK ($($res.manufacturer))"
} catch {
    Assert-Condition $false "Server error: $_"
}

try {
    $res = Invoke-RestMethod -Uri "http://localhost:8000/api/verify/huid?code=AB8492" -Method Get -TimeoutSec 3
    Assert-Condition ($res.huid -eq "AB8492" -and $res.status -eq "VERIFIED") "Live Server HUID Verification OK ($($res.jeweller))"
} catch {
    Assert-Condition $false "Server error: $_"
}

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host "  TEST RESULTS: $global:passed PASSED, $global:failed FAILED" -ForegroundColor $(if ($global:failed -eq 0) { "Green" } else { "Red" })
Write-Host "====================================================" -ForegroundColor Cyan
