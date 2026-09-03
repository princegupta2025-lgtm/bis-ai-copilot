$r1 = Invoke-WebRequest -Uri 'http://localhost:8000/standalone_app.html' -UseBasicParsing
Write-Host "standalone_app.html Status: $($r1.StatusCode) Size: $($r1.RawContentLength)"

$h1 = Invoke-RestMethod -Uri 'http://localhost:8000/api/verify/huid?code=AU9991'
Write-Host "HUID 24K AU9991: $($h1.status) - $($h1.karatLabel) - $($h1.jeweller)"

$c1 = Invoke-RestMethod -Uri 'http://localhost:8000/api/verify/cml?number=1650145'
Write-Host "CML 1650145 (Steelbird): $($c1.status) - $($c1.manufacturer)"

$crs1 = Invoke-RestMethod -Uri 'http://localhost:8000/api/verify/crs?number=41001234'
Write-Host "CRS R-41001234 (Samsung Smartphone): $($crs1.status) - $($crs1.brand) - $($crs1.manufacturer)"

$crs2 = Invoke-RestMethod -Uri 'http://localhost:8000/api/verify/crs?number=41123456'
Write-Host "CRS R-41123456 (Apple India): $($crs2.status) - $($crs2.brand) - $($crs2.product)"
