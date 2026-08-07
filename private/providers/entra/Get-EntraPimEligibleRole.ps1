function Get-EntraPimEligibleRole {
    <#
    .SYNOPSIS
        Returns the Entra ID directory roles the signed-in user is eligible for.

    .DESCRIPTION
        Not implemented yet.

        When implemented:
            GET {graph}/roleManagement/directory/roleEligibilitySchedules
                ?$filter=principalId eq '{principalId}'
                &$expand=roleDefinition,directoryScope

        Graph has no asTarget() equivalent, so the principal object ID has to be
        filtered on explicitly. That is why Get-PimPrincipalId resolves it once
        at sign-in.

        The token must be Graph-audience: Get-PimAccessToken -Audience Graph.
        An ARM token will be rejected here.

        Project through New-PimEligibleRole with Provider 'Entra'. ScopeName is
        'Directory' for a tenant-wide role, or the administrative unit name when
        directoryScopeId points at one.

    .EXAMPLE
        Get-EntraPimEligibleRole
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    throw [System.NotImplementedException]::new('Entra ID support is not wired up yet')
}
