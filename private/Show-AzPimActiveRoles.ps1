function Show-AzPimActiveRoles {
    [CmdletBinding()]
    param ()
    
    process {
        try {
            Clear-Host
            Write-Host "===== Active PIM Roles =====" -ForegroundColor Cyan
            Write-Host "Retrieving your active roles..." -ForegroundColor Yellow
            
            # Get active roles for the current user
            $activeRolesResult = Get-AzPimRoleActivation
            
            if (-not $activeRolesResult.Success) {
                Write-Error "Failed to retrieve active roles: $($activeRolesResult.ErrorMessage)"
                Read-Host "Press Enter to return to the main menu"
                return
            }
            
            $activeRoles = $activeRolesResult.ActiveRoles
            
            if ($activeRoles.Count -eq 0) {
                Write-Host "`nYou don't have any active PIM roles." -ForegroundColor Yellow
                Read-Host "Press Enter to return to the main menu"
                return
            }
            
            # Display active roles in a table format
            Write-Host "`nYour active roles:" -ForegroundColor Green
            
            $table = $activeRoles | ForEach-Object {
                [PSCustomObject]@{
                    "Role Name" = $_.RoleName
                    "Resource" = $_.ResourceName
                    "Activated" = $_.StartTime.ToString("yyyy-MM-dd HH:mm")
                    "Expires" = $_.EndTime.ToString("yyyy-MM-dd HH:mm")
                    "Time Left" = $_.RemainingTime
                }
            }
            
            $table | Format-Table -AutoSize
            
            Read-Host "`nPress Enter to return to the main menu"
        }
        catch {
            Write-Error "An error occurred: $_"
            Read-Host "Press Enter to return to the main menu"
        }
    }
}