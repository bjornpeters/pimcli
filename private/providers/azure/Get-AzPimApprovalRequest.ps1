function Get-AzPimApprovalRequest {
    <#
    .SYNOPSIS
        Returns Azure resource PIM requests awaiting the signed-in user's decision.

    .DESCRIPTION
        Calls roleAssignmentScheduleRequests with the asApprover() filter and
        projects each entry into the neutral Pim.ApprovalRequest shape.

    .EXAMPLE
        Get-AzPimApprovalRequest
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    $config = (Get-PimConfig).Arm
    $uri = '{0}/providers/Microsoft.Authorization/roleAssignmentScheduleRequests?api-version={1}&$filter=asApprover()' -f
        $config.BaseUri, $config.ApiVersion.RoleAssignmentScheduleRequest

    Write-Verbose "GET $uri"

    $response = Invoke-RestMethod -Method 'GET' -Uri $uri -Authentication 'Bearer' -Token (Get-PimAccessToken -Audience Arm) -ErrorAction Stop

    foreach ($request in $response.value) {
        $properties = $request.properties
        $expanded = $properties.expandedProperties

        New-PimApprovalRequest -Provider 'Azure' `
            -RequestId     $request.name `
            -ApprovalId    $properties.approvalId `
            -RoleName      $expanded.roleDefinition.displayName `
            -ScopeName     $expanded.scope.displayName `
            -ScopeType     $expanded.scope.type `
            -RequestorName $expanded.principal.displayName `
            -Justification $properties.justification `
            -Status        $properties.status `
            -RequestedOn   (ConvertTo-PimDateTime -Value $properties.createdOn) `
            -StartTime     (ConvertTo-PimDateTime -Value $properties.scheduleInfo.startDateTime) `
            -Duration      $properties.scheduleInfo.expiration.duration `
            -TicketNumber  $properties.ticketInfo.ticketNumber `
            -TicketSystem  $properties.ticketInfo.ticketSystem `
            -Raw           $request
    }
}
