function Get-AzPimEligibleRole {
    <#
    .SYNOPSIS
        Returns the Azure resource roles the signed-in user is eligible for.

    .DESCRIPTION
        Calls roleEligibilitySchedules with the asTarget() filter, which scopes
        the result to the caller, and projects each entry into the neutral
        Pim.EligibleRole shape.

        Errors are thrown rather than returned as a success flag, so the
        dispatcher can attribute a failure to this provider and still return
        results from the others.

    .EXAMPLE
        Get-AzPimEligibleRole
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    $config = (Get-PimConfig).Arm
    $uri = '{0}/providers/Microsoft.Authorization/roleEligibilitySchedules?api-version={1}&$filter=asTarget()' -f
        $config.BaseUri, $config.ApiVersion.RoleEligibilitySchedule

    Write-Verbose "GET $uri"

    $response = Invoke-RestMethod -Method 'GET' -Uri $uri -Authentication 'Bearer' -Token (Get-PimAccessToken -Audience Arm) -ErrorAction Stop

    foreach ($schedule in $response.value) {
        $expanded = $schedule.properties.expandedProperties

        New-PimEligibleRole -Provider 'Azure' `
            -RoleName         $expanded.roleDefinition.displayName `
            -RoleDefinitionId $schedule.properties.roleDefinitionId `
            -ScopeName        $expanded.scope.displayName `
            -ScopeId          $expanded.scope.id `
            -ScopeType        $expanded.scope.type `
            -PrincipalId      $schedule.properties.principalId `
            -MemberType       $schedule.properties.memberType `
            -Raw              $schedule
    }
}
