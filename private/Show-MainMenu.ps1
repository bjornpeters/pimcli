function Show-MainMenu {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Account
    )
    
    Clear-Host
    Show-Banner
    Write-Host "Connected as: $Account" -ForegroundColor Green
    Write-Host ""
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. View and approve pending PIM requests" -ForegroundColor White
    Write-Host "2. Request a role activation" -ForegroundColor White
    Write-Host "3. View your active roles" -ForegroundColor White
    Write-Host "4. Disconnect from Azure" -ForegroundColor White
    Write-Host "5. Exit" -ForegroundColor White
    Write-Host ""
}