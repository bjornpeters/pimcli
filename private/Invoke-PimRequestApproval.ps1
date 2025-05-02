function Invoke-PimRequestApproval {
    Clear-Host
    Show-Banner
    
    # Send request to the Azure Management API to get active approval requests in Priviliged Identity Management.
    Write-Host "Retrieving pending PIM requests..." -ForegroundColor 'Cyan'
    [array]$requests = Get-AzPimRequest
    
    # When there are no requests returned, simply report that back in the console and return back to the previous screen.
    # TODO: Walk through the flow when no active approval requests are found.
    if (-not $requests -or $requests.Count -eq 0) {
        Write-Host "No pending PIM requests found." -ForegroundColor 'Yellow'
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Found $($requests.Count) pending PIM request(s)." -ForegroundColor 'Green'
    Write-Host ""
    
    # Redeclare the variable but sort the array based on the request date. If there is no date found in the request, specify the max date value.
    $requests = $requests | Sort-Object { 
        if ($_.properties.scheduleInfo.startDateTime) {
            [DateTime]$_.properties.scheduleInfo.startDateTime 
        } 
        else { 
            [DateTime]::MaxValue 
        }
    }

    # Display all pending requests
    for ($i = 0; $i -lt $requests.Count; $i++) {
        # Set up human-readable variables to prepare for displaying pending requests.
        [string]$approvalId = $($requests[$i].properties.approvalId).Trim('providers/Microsoft.Authorization/roleAssignmentApprovals/')

        Write-Host "[$($i + 1)] Approval ID: $approvalId" -ForegroundColor 'White'
        Write-Host "    Principal: $($requests[$i].properties.expandedProperties.principal.displayName)" -ForegroundColor 'White'
        Write-Host "    Role: $($requests[$i].properties.expandedProperties.roleDefinition.displayName)" -ForegroundColor 'White'
        Write-Host "    Requested on: $($requests[$i].properties.createdOn)" -ForegroundColor 'White'
        Write-Host "    Justification: $($requests[$i].properties.justification)" -ForegroundColor 'White'
        Write-Host ""
    }
    
    $selection = Read-Host -Prompt 'Enter request number to view details and approve (or C to return to menu)'
    
    if ($selection -eq "C") {
        return
    }
    
    if (-not [int]::TryParse($selection, [ref]$null) -or [int]$selection -lt 1 -or [int]$selection -gt $requests.Count) {
        Write-Host "Invalid selection, returning..." -ForegroundColor 'Red'
        Start-Sleep 2
        return
    }
    
    $selectedRequest = $requests[[int]$selection - 1]
    $pimRequestDetailsParams = @{
        CreatedOn = $selectedRequest.properties.createdOn
        Duration = if ([string]::IsNullOrEmpty($selectedRequest.properties.scheduleInfo.expiration.duration)) { 'N/A' } else { $selectedRequest.properties.scheduleInfo.expiration.duration }
        Justification = $selectedRequest.properties.justification
        PrincipalName = $selectedRequest.properties.expandedProperties.principal.displayName
        ResourceName = $selectedRequest.properties.expandedProperties.scope.displayName
        ResourceType = $selectedRequest.properties.expandedProperties.scope.type
        RoleDefinitionName = $selectedRequest.properties.expandedProperties.roleDefinition.displayName
        StartDateTime = if ($selectedRequest.properties.scheduleInfo.startDateTime) { $selectedRequest.properties.scheduleInfo.startDateTime } else { 'Immediate' }
        Status = $selectedRequest.properties.status
        TicketNumber = if ([string]::IsNullOrEmpty($selectedRequest.properties.ticketInfo.ticketNumber)) { 'N/A' } else { $selectedRequest.properties.ticketInfo.ticketNumber }
        TicketSystem = if ([string]::IsNullOrEmpty($selectedRequest.properties.ticketInfo.ticketSystem)) { 'N/A' } else { $selectedRequest.properties.ticketInfo.ticketSystem }
    }
    
    # Show detailed information about the selected request
    Clear-Host
    Show-AzPimRequestDetail @pimRequestDetailsParams
    
    Write-Host "Action options:" -ForegroundColor 'Yellow'
    Write-Host "Y - Approve the request" -ForegroundColor 'Green'
    Write-Host "N - Reject the request" -ForegroundColor 'Red'
    Write-Host "C - Cancel and return to main menu" -ForegroundColor 'Cyan'
    Write-Host ""
    $action = Read-Host -Prompt 'What would you like to do? (Y/N/C)'
    
    switch ($action.ToUpper()) {
        "Y" {
            $reason = Read-Host -Prompt 'Please provide a justification for this approval'

            # TODO: Think about what to do when a reason is not provided.
            if ([string]::IsNullOrWhiteSpace($reason)) {
                $reason = "Approved by PIM CLI tool"
            }
            
            $result = New-AzPimDecisionRequest -ApprovalId $selectedRequest.properties.approvalId -Reason $reason -ReviewResult 'Approve'
            
            if ($result) {
                Write-Host "Request approved successfully." -ForegroundColor 'Green'
            }
            else {
                Write-Host "Failed to approve request." -ForegroundColor 'Red'
            }
        }
        "N" {
            $reason = Read-Host -Prompt 'Please provide a reason for rejecting this request'
            
            # TODO: Think about what to do when a reason is not provided.
            if ([string]::IsNullOrWhiteSpace($reason)) {
                $reason = "Rejected by PIM CLI tool"
            }
            
            $result = New-AzPimDecisionRequest -ApprovalId $selectedRequest.properties.approvalId -Reason $reason -ReviewResult 'Deny'
            
            if ($result) {
                Write-Host "Request rejected successfully." -ForegroundColor Green
            }
            else {
                Write-Host "Failed to reject request." -ForegroundColor Red
            }
        }
        "C" {
            Write-Host "Returning to request list..." -ForegroundColor Cyan
            # No action needed, will fall through to continue
            return
        }
        default {
            Write-Host "Invalid option. Returning to request list..." -ForegroundColor Yellow
        }
    }
    
    Read-Host "Press Enter to continue"
}