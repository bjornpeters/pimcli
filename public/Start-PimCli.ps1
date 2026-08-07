function Start-PimCli {
    try {
        # Check if Az module is installed
        if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
            Write-Error "This script requires the Az PowerShell module. Please install it with: Install-Module -Name Az -AllowClobber -Force"
            return
        }
        
        # Authenticate to Azure
        Clear-Host
        Show-Banner
        Write-Host "Welcome to the Azure PIM CLI tool!" -ForegroundColor 'Green'
        Write-Host "Authenticating to Azure..." -ForegroundColor 'Cyan'
        
        $authResult = Connect-AzPim
        
        if (-not $authResult.Success) {
            Write-Error "Authentication failed: $($authResult.ErrorMessage)"
            return
        }
        
        if (-not $authResult.PimAccess) {
            Write-Warning "You may not have sufficient permissions for PIM operations."
            Write-Host "Do you want to continue anyway? (Y/N)" -ForegroundColor 'Yellow'
            $continue = Read-Host
            
            if ($continue -ne "Y" -and $continue -ne "y") {
                return
            }
        }
        
        Start-Sleep 5

        # Main menu loop
        $exit = $false
        while (-not $exit) {
            Show-MainMenu -Account $authResult.Account
            $choice = Read-Host -Prompt 'Enter your choice'
            
            switch ($choice) {
                "1" { Invoke-PimRequestApproval }
                "2" { Invoke-PimRoleActivation }
                "3" { Show-AzPimActiveRoles }
                "4" { 
                    Disconnect-AzPim 
                    $exit = $true
                }
                "5" { $exit = $true }
                default {
                    Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                    Start-Sleep -Seconds 2
                }
            }
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
    finally {
        # Ensure we disconnect from Azure if something fails
        try {
            $context = Get-AzContext -ErrorAction SilentlyContinue
            if ($context) {
                # Write-Host "Disconnecting from Azure..." -ForegroundColor Cyan
                # Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
            }
        }
        catch {
            # Ignore errors during cleanup
        }
    }
}