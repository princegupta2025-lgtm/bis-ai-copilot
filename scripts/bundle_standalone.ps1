# Build Standalone All-In-One HTML Bundle (Zero Variable Interpolation)
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }
$parent = Split-Path -Parent $root

$chatHtml = [System.IO.File]::ReadAllText((Join-Path $parent "chat.html"), [System.Text.Encoding]::UTF8)
$styleCss = [System.IO.File]::ReadAllText((Join-Path $parent "css\style.css"), [System.Text.Encoding]::UTF8)
$cmdCss   = [System.IO.File]::ReadAllText((Join-Path $parent "css\command-palette.css"), [System.Text.Encoding]::UTF8)

$themeJs  = if (Test-Path (Join-Path $parent "js\theme.js")) { [System.IO.File]::ReadAllText((Join-Path $parent "js\theme.js"), [System.Text.Encoding]::UTF8) } else { "" }
$dbJs     = [System.IO.File]::ReadAllText((Join-Path $parent "js\database.js"), [System.Text.Encoding]::UTF8)
$cmdJs    = [System.IO.File]::ReadAllText((Join-Path $parent "js\command-palette.js"), [System.Text.Encoding]::UTF8)
$wizJs    = [System.IO.File]::ReadAllText((Join-Path $parent "js\wizard.js"), [System.Text.Encoding]::UTF8)
$chatJs   = [System.IO.File]::ReadAllText((Join-Path $parent "js\chat.js"), [System.Text.Encoding]::UTF8)

# Construct CSS block with pure concatenation
$cssBlock = "`n  <!-- Inlined Stylesheets -->`n  <style>`n/* STYLE.CSS */`n" + $styleCss + "`n`n/* COMMAND-PALETTE.CSS */`n" + $cmdCss + "`n  </style>`n"

# Construct JS block with pure concatenation (prevents PowerShell from corrupting JS variables)
$jsBlock = "`n  <!-- Inlined Full Application Logic & Databases -->`n  <script>`n/* THEME.JS */`n" + $themeJs + "`n`n/* DATABASE.JS */`n" + $dbJs + "`n`n/* COMMAND-PALETTE.JS */`n" + $cmdJs + "`n`n/* WIZARD.JS */`n" + $wizJs + "`n`n/* CHAT.JS */`n" + $chatJs + "`n  </script>`n"

# 1. Replace CSS links with CSS Block using literal string slice
$cssStart = $chatHtml.IndexOf("<!-- CSS -->")
$cssEnd = $chatHtml.IndexOf("<!-- PDF.js", $cssStart)
if ($cssStart -ge 0 -and $cssEnd -gt $cssStart) {
  $chatHtml = $chatHtml.Substring(0, $cssStart) + $cssBlock + "  " + $chatHtml.Substring($cssEnd)
}

# 2. Replace Script links with JS Block using literal string slice
$scriptStart = $chatHtml.IndexOf("<!-- Scripts -->")
$unregIdx = $chatHtml.IndexOf("Aggressively unregister", $scriptStart)
if ($unregIdx -gt 0) {
  $scriptEnd = $chatHtml.LastIndexOf("<script>", $unregIdx)
  Write-Output "scriptStart: $scriptStart | unregIdx: $unregIdx | scriptEnd: $scriptEnd"
  if ($scriptStart -ge 0 -and $scriptEnd -gt $scriptStart) {
    $chatHtml = $chatHtml.Substring(0, $scriptStart) + $jsBlock + "  " + $chatHtml.Substring($scriptEnd)
  }
} else {
  Write-Output "Could not find unregister index from scriptStart: $scriptStart"
}

$targetPath = Join-Path $parent "standalone_app.html"
[System.IO.File]::WriteAllText($targetPath, $chatHtml, [System.Text.Encoding]::UTF8)

Write-Output "Successfully generated: $targetPath"
Write-Output "File size: $((Get-Item $targetPath).Length) bytes"
