function Connect-AzPim {
    [CmdletBinding()]
    param()
    
    try {
        Write-Host "Checking Azure connection status..." -ForegroundColor Cyan
        $context = Get-AzContext
        
        if (-not $context) {
            Write-Host "Not authenticated to Azure. Initiating login..." -ForegroundColor Yellow
            Connect-AzAccount -ErrorAction Stop | Out-Null
            $context = Get-AzContext
            Write-Host "Successfully logged in to Azure." -ForegroundColor Green

            # Set access token for Azure.
            $token = (Get-AzAccessToken -AsSecureString).Token
        }
        else {
            Write-Host "Already authenticated as $($context.Account)" -ForegroundColor Green
        }
        
        # Make sure we have a valid account name
        $accountName = if ($context.Account.Id) { 
            $context.Account.Id 
        } elseif ($context.Account) {
            $context.Account.ToString()
        } else {
            "Unknown Account"
        }
        
        # Verify the user has permissions to use PIM
        Write-Host "Verifying PIM access..." -ForegroundColor Cyan
        
        # Get role assignments to verify PIM access
        try {
            # Use the current user's context instead of relying on SignInName
            $roles = Get-AzRoleAssignment -ErrorAction Stop
            $hasPimAccess = $roles | Where-Object { 
                $_.RoleDefinitionName -like "*Administrator*" -or
                $_.RoleDefinitionName -like "*Owner*" -or
                $_.RoleDefinitionName -like "*Contributor*" -or
                $_.RoleDefinitionName -like "*Privileged*" 
            }
            
            if ($hasPimAccess) {
                Write-Host "PIM access verified." -ForegroundColor Green
                return @{
                    Success = $true
                    Context = $context
                    Account = $accountName
                    PimAccess = $true
                }
            }
            else {
                Write-Warning "You may not have sufficient permissions to manage PIM requests."
                return @{
                    Success = $true
                    Context = $context
                    Account = $accountName
                    PimAccess = $false
                }
            }
        }
        catch {
            Write-Warning "Could not verify PIM access: $_"
            return @{
                Success = $true
                Context = $context
                Account = $accountName
                PimAccess = $false
            }
        }
    }
    catch {
        Write-Error "Authentication failed: $_"
        return @{
            Success = $false
            ErrorMessage = $_.Exception.Message
            Account = "Not Authenticated"
        }
    }
}