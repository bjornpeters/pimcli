function Remove-EntraPimActiveRole {
    <#
    .SYNOPSIS
        Ends an active Entra ID directory role assignment early.

    .DESCRIPTION
        Not implemented yet.

        When implemented:
            POST {graph}/roleManagement/directory/roleAssignmentScheduleRequests

        with action 'selfDeactivate', targeting the same roleDefinitionId and
        directoryScopeId as the active assignment.

    .PARAMETER RoleDefinitionId
        Graph identifier of the directory role definition.

    .PARAMETER ScopeId
        Directory scope ID. '/' for tenant-wide.

    .PARAMETER PrincipalId
        Object ID of the principal holding the assignment.

    .EXAMPLE
        Remove-EntraPimActiveRole -RoleDefinitionId $id -ScopeId '/' -PrincipalId $me
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '',
        Justification = 'Declared now so both providers present the same parameters to the dispatcher; ShouldProcess is called once the request is implemented.'
    )]
    param(
        [Parameter(Mandatory)]
        [string]$RoleDefinitionId,

        [Parameter(Mandatory)]
        [string]$ScopeId,

        [Parameter(Mandatory)]
        [string]$PrincipalId
    )

    throw [System.NotImplementedException]::new('Entra ID support is not wired up yet')
}
