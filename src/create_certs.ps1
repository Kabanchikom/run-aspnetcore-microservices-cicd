$services = @(
    @{Name="Catalog.API"},
    @{Name="Basket.API"},
    @{Name="Discount.gRPC"},
    @{Name="Ordering.API"},
    @{Name="YarpApiGateway"},
    @{Name="Shopping.Web"}
)

$certPath = "$env:APPDATA\ASP.NET\Https"
$password = "SwN12345678"

New-Item -ItemType Directory -Force -Path $certPath | Out-Null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Creating certificates for all services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($service in $services) {
    $certName = $service.Name
    $certFile = "$certPath\$certName.pfx"
    
    Write-Host "Creating certificate for $certName..." -ForegroundColor Yellow
    
    if (Test-Path $certFile) {
        Remove-Item $certFile -Force
        Write-Host "  Removed old certificate" -ForegroundColor Gray
    }
    
    dotnet dev-certs https -ep $certFile -p $password
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  $certName.pfx created successfully" -ForegroundColor Green
    } else {
        Write-Host "  Failed to create $certName.pfx" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Trusting certificates" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

dotnet dev-certs https --trust

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Get-ChildItem -Path $certPath -Filter "*.pfx" | ForEach-Object {
    $size = [math]::Round($_.Length / 1KB, 2)
    Write-Host "  $($_.Name) ($size KB)" -ForegroundColor Green
}

Write-Host ""
Write-Host "All certificates created successfully!" -ForegroundColor Green