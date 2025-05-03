function Invoke-PimRoleActivation {
    [CmdletBinding()]
    param ()
    
    process {
        try {
            Clear-Host
            Write-Host "===== Role Activation Menu =====" -ForegroundColor 'Cyan'
            Write-Host "Retrieving your eligible roles..." -ForegroundColor 'Yellow'
            Write-Host ""

            # Get eligible roles for the current user
            $eligibleRolesResult = Get-AzPimEligibleRoles
            
            if (-not $eligibleRolesResult.Success) {
                Write-Error "Failed to retrieve eligible roles: $($eligibleRolesResult.ErrorMessage)"
                Read-Host "Press Enter to return to the main menu"
                return
            }
            
            $eligibleRoles = $eligibleRolesResult.EligibleRoles
            
            if ($eligibleRoles.Count -eq 0) {
                Write-Host "You don't have any eligible roles that can be activated." -ForegroundColor 'Yellow'
                Read-Host "Press Enter to return to the main menu"
                return
            }
            
            # Group eligible roles by resource type
            $rolesByResourceType = @{}
            $resourceTypeCount = @{}
            
            foreach ($role in $eligibleRoles) {
                if (-not $rolesByResourceType.ContainsKey($role.ResourceType)) {
                    $rolesByResourceType[$role.ResourceType] = @()
                    $resourceTypeCount[$role.ResourceType] = 0
                }
                $rolesByResourceType[$role.ResourceType] += $role
                $resourceTypeCount[$role.ResourceType]++
            }
            
            # Display resource type selection menu
            Write-Host "`nSelect a resource type to view eligible roles:" -ForegroundColor 'Green'
            Write-Host ""
            $index = 1
            $resourceTypeOptions = @()
            
            foreach ($resourceType in $rolesByResourceType.Keys) {
                $count = $resourceTypeCount[$resourceType]
                Write-Host "[$index] $resourceType ($count eligible roles)" -ForegroundColor White
                $resourceTypeOptions += $resourceType
                $index++
            }
            
            Write-Host "[0] Return to main menu" -ForegroundColor White
            
            # Get resource type selection
            $selection = Read-Host "`nSelect a resource type (0-$($resourceTypeOptions.Count))"
            
            if ($selection -eq "0") {
                return
            }
            
            $selectionIndex = [int]$selection - 1
            
            if ($selectionIndex -lt 0 -or $selectionIndex -ge $resourceTypeOptions.Count) {
                Write-Host "Invalid selection." -ForegroundColor Red
                Read-Host "Press Enter to continue"
                return
            }
            
            $selectedResourceType = $resourceTypeOptions[$selectionIndex]
            $filteredRoles = $rolesByResourceType[$selectedResourceType]
            
            # Display eligible roles for the selected resource type
            Clear-Host
            Write-Host "===== Role Activation - $($selectedResourceType) =====" -ForegroundColor Cyan
            Write-Host "`nYour eligible roles for $($selectedResourceType)" -ForegroundColor Green
            Write-Host "" # Adding a blank line for spacing
            
            for ($i = 0; $i -lt $filteredRoles.Count; $i++) {
                Write-Host "[$($i + 1)] Role:          $($filteredRoles[$i].Role)" -ForegroundColor 'White'
                Write-Host "    Resource:      $($filteredRoles[$i].Resource)" -ForegroundColor 'White'
                Write-Host "    Membership:    $($filteredRoles[$i].Membership)" -ForegroundColor 'White'
                Write-Host ""
            }
            
            Write-Host "[0] Go back to resource type selection" -ForegroundColor White
            
            # Get role selection
            $roleSelection = Read-Host "`nSelect a role to activate (0-$($filteredRoles.Count))"
            
            if ($roleSelection -eq "0") {
                # Recursive call to restart from resource type selection
                Invoke-PimRoleActivation
                return
            }
            
            $roleSelectionIndex = [int]$roleSelection - 1
            
            if ($roleSelectionIndex -lt 0 -or $roleSelectionIndex -ge $filteredRoles.Count) {
                Write-Host "Invalid selection." -ForegroundColor Red
                Read-Host "Press Enter to continue"
                Invoke-PimRoleActivation
                return
            }
            
            $selectedRole = $filteredRoles[$roleSelectionIndex]
            
            # Ask for the activation details such as the duration and the justification.
            Clear-Host
            Write-Host "===== Activation details =====" -ForegroundColor 'Cyan'
            Write-Host ""
            Write-Host "Role:     $($selectedRole.Role)" -ForegroundColor 'White'
            Write-Host "Resource: $($selectedRole.Resource)" -ForegroundColor 'White'
            Write-Host ""
            Write-Host "==============================" -ForegroundColor 'Cyan'
            Write-Host ""
            
            $duration = Read-Host "Enter activation duration in hours (default: 8)"
            
            if ([string]::IsNullOrWhiteSpace($duration)) {
                $duration = 8
            }
            else {
                $duration = [int]$duration
            }
            
            # Ask for justification
            $justification = Read-Host "Enter justification for activation"
            
            if ([string]::IsNullOrWhiteSpace($justification)) {
                Write-Host "Justification is required." -ForegroundColor Red
                Read-Host "Press Enter to try again"
                Invoke-PimRoleActivation
                return
            }
            
            # Submit activation request
            Write-Host "`nSubmitting role activation request..." -ForegroundColor Yellow
            
            $activationResult = New-AzPimRoleActivationRequest -RoleDefinitionId $selectedRole.RoleDefinitionId `
                                                              -ResourceId $selectedRole.ResourceId `
                                                              -Reason $justification `
                                                              -DurationInHours $duration
            
            if ($activationResult.Success) {
                Write-Host "`nRole activation request submitted successfully!" -ForegroundColor Green
                Write-Host "Request ID: $($activationResult.RequestId)" -ForegroundColor Cyan
                Write-Host "The role will be activated shortly if no approval is required, or once approved by an administrator." -ForegroundColor Yellow
            }
            else {
                Write-Host "`nFailed to submit role activation request: $($activationResult.ErrorMessage)" -ForegroundColor Red
            }
            
            Read-Host "`nPress Enter to return to the main menu"
        }
        catch {
            Write-Error "An error occurred: $_"
            Read-Host "Press Enter to return to the main menu"
        }
    }
}